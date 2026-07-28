import 'package:money_fit/core/config/ad_policy_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reasons an opportunity did not become a full-screen ad. Keep these stable:
/// they are sent to the analytics facade and used by rollout dashboards.
enum AdSuppressionReason {
  notConfigured('not_configured'),
  masterDisabled('master_disabled'),
  formatDisabled('format_disabled'),
  consentNotReady('consent_not_ready'),
  newUserGrace('new_user_grace'),
  sessionTooYoung('session_too_young'),
  actionThreshold('action_threshold'),
  cooldown('cooldown'),
  sessionCap('session_cap'),
  rolling24hCap('rolling_24h_cap'),
  fullscreenUiBusy('fullscreen_ui_busy'),
  adNotReady('ad_not_ready'),
  duplicateTrigger('duplicate_trigger'),
  staleAppOpen('stale_app_open');

  const AdSuppressionReason(this.value);
  final String value;
}

class AdEligibility {
  const AdEligibility.allowed() : allowed = true, reason = null;
  const AdEligibility.suppressed(this.reason) : allowed = false;

  final bool allowed;
  final AdSuppressionReason? reason;
}

/// Persisted, SDK-independent full-screen ad policy.
///
/// Only an actual full-screen impression consumes a cap. Loading, a rejected
/// opportunity and a failed show do not reset actions or alter the history.
class AdPolicyService {
  AdPolicyService(this._prefs, this._policy, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SharedPreferences _prefs;
  final AdPolicyConfig Function() _policy;
  final DateTime Function() _now;

  static const _sessionStartedAt = 'ads_session_started_at';
  static const _sessionNumber = 'ads_session_number';
  static const _sessionShown = 'ads_fullscreen_session_shown';
  static const _pendingActions = 'ads_pending_meaningful_actions';
  static const _lastShownAt = 'ads_last_fullscreen_at';
  static const _shownHistory = 'ads_fullscreen_history';
  static const _lastTriggerPrefix = 'ads_last_trigger_';

  AdPolicyConfig get policy => _policy();
  int get actionCount => _prefs.getInt(_pendingActions) ?? 0;
  int get sessionCount => _prefs.getInt(_sessionNumber) ?? 0;
  int get shownThisSession => _prefs.getInt(_sessionShown) ?? 0;

  Future<void> initializeSession() async {
    final now = _utcNow();
    final started = _readDate(_sessionStartedAt);
    if (started == null ||
        now.difference(started) >= const Duration(minutes: 30)) {
      await _prefs.setInt(_sessionNumber, sessionCount + 1);
      await _prefs.setInt(_sessionShown, 0);
      await _prefs.setString(_sessionStartedAt, now.toIso8601String());
    }
  }

  Future<bool> recordMeaningfulAction(String trigger) async {
    final now = _utcNow();
    final key = '$_lastTriggerPrefix$trigger';
    final previous = _readDate(key);
    if (previous != null &&
        !now.isBefore(previous) &&
        now.difference(previous) < const Duration(seconds: 2)) {
      return false;
    }
    await _prefs.setString(key, now.toIso8601String());
    await _prefs.setInt(_pendingActions, actionCount + 1);
    return true;
  }

  AdEligibility interstitialEligibility({required bool consentReady}) {
    final config = policy;
    if (!config.masterEnabled) {
      return const AdEligibility.suppressed(AdSuppressionReason.masterDisabled);
    }
    if (!config.interstitialEnabled) {
      return const AdEligibility.suppressed(AdSuppressionReason.formatDisabled);
    }
    if (!consentReady) {
      return const AdEligibility.suppressed(
        AdSuppressionReason.consentNotReady,
      );
    }
    return _fullscreenEligibility(
      config,
      requiresActions: true,
      cooldown: config.cooldown,
    );
  }

  AdEligibility appOpenEligibility({required bool consentReady}) {
    final config = policy;
    if (!config.masterEnabled) {
      return const AdEligibility.suppressed(AdSuppressionReason.masterDisabled);
    }
    if (!config.appOpenEnabled) {
      return const AdEligibility.suppressed(AdSuppressionReason.formatDisabled);
    }
    if (!consentReady) {
      return const AdEligibility.suppressed(
        AdSuppressionReason.consentNotReady,
      );
    }
    return _fullscreenEligibility(
      config,
      requiresActions: false,
      cooldown: config.appOpenCooldown,
    );
  }

  AdEligibility _fullscreenEligibility(
    AdPolicyConfig config, {
    required bool requiresActions,
    required Duration cooldown,
  }) {
    final now = _utcNow();
    if (sessionCount <= config.newUserGraceSessions) {
      return const AdEligibility.suppressed(AdSuppressionReason.newUserGrace);
    }
    final sessionStarted = _readDate(_sessionStartedAt);
    if (sessionStarted == null ||
        now.isBefore(sessionStarted) ||
        now.difference(sessionStarted) < config.minSessionAge) {
      return const AdEligibility.suppressed(
        AdSuppressionReason.sessionTooYoung,
      );
    }
    if (requiresActions && actionCount < config.actionsRequired) {
      return const AdEligibility.suppressed(
        AdSuppressionReason.actionThreshold,
      );
    }
    final lastShown = _readDate(_lastShownAt);
    if (lastShown != null &&
        (now.isBefore(lastShown) || now.difference(lastShown) < cooldown)) {
      return const AdEligibility.suppressed(AdSuppressionReason.cooldown);
    }
    if (shownThisSession >= config.maxPerSession) {
      return const AdEligibility.suppressed(AdSuppressionReason.sessionCap);
    }
    if (_recentHistory(now).length >= config.maxPer24Hours) {
      return const AdEligibility.suppressed(AdSuppressionReason.rolling24hCap);
    }
    return const AdEligibility.allowed();
  }

  Future<void> recordFullscreenShown() async {
    final now = _utcNow();
    final history = _recentHistory(now)..add(now);
    await _prefs.setString(_lastShownAt, now.toIso8601String());
    await _prefs.setStringList(
      _shownHistory,
      history.map((value) => value.toIso8601String()).toList(),
    );
    await _prefs.setInt(_sessionShown, shownThisSession + 1);
    await _prefs.setInt(_pendingActions, 0);
  }

  List<DateTime> _recentHistory(DateTime now) {
    final history = <DateTime>[];
    for (final raw in _prefs.getStringList(_shownHistory) ?? const <String>[]) {
      final value = DateTime.tryParse(raw)?.toUtc();
      if (value != null &&
          !now.isBefore(value) &&
          now.difference(value) <= const Duration(hours: 24)) {
        history.add(value);
      }
    }
    return history;
  }

  DateTime _utcNow() => _now().toUtc();
  DateTime? _readDate(String key) =>
      DateTime.tryParse(_prefs.getString(key) ?? '')?.toUtc();
}
