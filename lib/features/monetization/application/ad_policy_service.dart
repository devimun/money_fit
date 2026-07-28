import 'dart:async';

import 'package:money_fit/features/monetization/domain/ad_frequency_state.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';

/// SDK-independent policy engine. Only [recordFullscreenShown] consumes a
/// cap; loading, rejected opportunities and failed displays never do.
class AdPolicyService {
  AdPolicyService(this._store, this._policy, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AdFrequencyStateStore _store;
  final AdPolicy Function() _policy;
  final DateTime Function() _now;

  AdFrequencyState? _state;
  Future<void> _tail = Future<void>.value();

  AdPolicy get policy => _policy();

  Future<int> pendingMeaningfulActionCount() => _serialize(() async {
    await _ensureSession();
    return (await _load()).pendingMeaningfulActions;
  });

  Future<void> initializeSession() => _serialize(_ensureSession);

  Future<bool> recordSuccessfulMeaningfulAction(MeaningfulAdAction action) =>
      _serialize(() async {
        await _ensureSession();
        final state = await _load();
        final now = _utcNow();
        final previous = state.lastTriggerAt[action.trigger];
        if (previous != null &&
            !now.isBefore(previous) &&
            now.difference(previous) < const Duration(seconds: 2)) {
          return false;
        }
        final triggers = Map<String, DateTime>.from(state.lastTriggerAt)
          ..[action.trigger] = now;
        await _save(
          state.copyWith(
            pendingMeaningfulActions: state.pendingMeaningfulActions + 1,
            lastTriggerAt: triggers,
          ),
        );
        return true;
      });

  Future<AdEligibility> interstitialEligibility({
    required bool canRequestAds,
  }) => _serialize(() async {
    await _ensureSession();
    final state = await _load();
    final config = policy;
    if (!config.masterEnabled) {
      return const AdEligibility.suppressed(AdSuppressionReason.masterDisabled);
    }
    if (!config.interstitialEnabled) {
      return const AdEligibility.suppressed(AdSuppressionReason.formatDisabled);
    }
    if (!canRequestAds) {
      return const AdEligibility.suppressed(
        AdSuppressionReason.consentNotReady,
      );
    }
    final now = _utcNow();
    if (state.sessionNumber <= config.newUserGraceSessions) {
      return const AdEligibility.suppressed(AdSuppressionReason.newUserGrace);
    }
    final startedAt = state.sessionStartedAt;
    if (startedAt == null ||
        now.isBefore(startedAt) ||
        now.difference(startedAt) < config.minSessionAge) {
      return const AdEligibility.suppressed(
        AdSuppressionReason.sessionTooYoung,
      );
    }
    if (state.pendingMeaningfulActions < config.actionsRequired) {
      return const AdEligibility.suppressed(
        AdSuppressionReason.actionThreshold,
      );
    }
    final lastShownAt = state.lastFullscreenShownAt;
    if (lastShownAt != null &&
        (now.isBefore(lastShownAt) ||
            now.difference(lastShownAt) < config.interstitialCooldown)) {
      return const AdEligibility.suppressed(AdSuppressionReason.cooldown);
    }
    if (state.fullscreenShownThisSession >= config.maxFullscreenPerSession) {
      return const AdEligibility.suppressed(AdSuppressionReason.sessionCap);
    }
    if (_recentHistory(state, now).length >= config.maxFullscreenPer24Hours) {
      return const AdEligibility.suppressed(AdSuppressionReason.rolling24hCap);
    }
    return const AdEligibility.allowed();
  });

  Future<void> recordFullscreenShown() => _serialize(() async {
    await _ensureSession();
    final state = await _load();
    final now = _utcNow();
    final history = _recentHistory(state, now)..add(now);
    await _save(
      state.copyWith(
        fullscreenShownThisSession: state.fullscreenShownThisSession + 1,
        pendingMeaningfulActions: 0,
        lastFullscreenShownAt: now,
        fullscreenHistory: history,
      ),
    );
  });

  Future<void> clear() => _serialize(() async {
    await _store.clear();
    _state = const AdFrequencyState();
  });

  Future<void> _ensureSession() async {
    final state = await _load();
    final now = _utcNow();
    final startedAt = state.sessionStartedAt;
    if (startedAt == null ||
        now.isBefore(startedAt) ||
        now.difference(startedAt) >= const Duration(minutes: 30)) {
      await _save(
        state.copyWith(
          sessionStartedAt: now,
          sessionNumber: state.sessionNumber + 1,
          fullscreenShownThisSession: 0,
        ),
      );
    }
  }

  List<DateTime> _recentHistory(AdFrequencyState state, DateTime now) {
    return state.fullscreenHistory
        .where(
          (value) =>
              !now.isBefore(value) &&
              now.difference(value) <= const Duration(hours: 24),
        )
        .toList(growable: true);
  }

  Future<AdFrequencyState> _load() async => _state ??= await _store.read();

  Future<void> _save(AdFrequencyState state) async {
    await _store.write(state);
    _state = state;
  }

  DateTime _utcNow() => _now().toUtc();

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (_, _) {});
    return result;
  }
}

/// Local lease boundary until the shared prompt coordinator is composed at the
/// application boundary. A caller must pass a lease to display an ad.
abstract interface class FullscreenExperienceGate {
  Future<FullscreenExperienceLease?> tryAcquireInterstitial();
}

abstract interface class FullscreenExperienceLease {
  void release();
}
