import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/monetization/application/ad_policy_service.dart';
import 'package:money_fit/features/monetization/domain/ad_frequency_state.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';

void main() {
  const policy = AdPolicy.defaults;
  late DateTime now;
  late _MemoryStore store;
  late AdPolicyService service;

  setUp(() {
    now = DateTime.utc(2026, 7, 28, 12);
    store = _MemoryStore();
    service = AdPolicyService(store, () => policy, now: () => now);
  });

  test(
    'allows the first session at exactly 120 seconds and six actions',
    () async {
      await service.initializeSession();

      expect(
        (await service.interstitialEligibility(canRequestAds: true)).reason,
        AdSuppressionReason.sessionTooYoung,
      );
      now = now.add(const Duration(seconds: 120));
      expect(
        (await service.interstitialEligibility(canRequestAds: true)).reason,
        AdSuppressionReason.actionThreshold,
      );

      await _recordActions(
        service,
        5,
        () => now = now.add(const Duration(seconds: 3)),
      );
      expect(
        (await service.interstitialEligibility(canRequestAds: true)).reason,
        AdSuppressionReason.actionThreshold,
      );
      await _recordActions(
        service,
        1,
        () => now = now.add(const Duration(seconds: 3)),
      );

      expect(
        (await service.interstitialEligibility(canRequestAds: true)).allowed,
        isTrue,
      );
    },
  );

  test('only a real display consumes actions, cooldown, and caps', () async {
    await _makeEligible(
      service,
      () => now = now.add(const Duration(seconds: 3)),
      () => now = now.add(const Duration(seconds: 120)),
    );

    await service.recordFullscreenShown();
    expect(await service.pendingMeaningfulActionCount(), 0);
    await _recordActions(
      service,
      6,
      () => now = now.add(const Duration(seconds: 3)),
    );
    expect(
      (await service.interstitialEligibility(canRequestAds: true)).reason,
      AdSuppressionReason.cooldown,
    );

    now = now.add(const Duration(seconds: 300));
    expect(
      (await service.interstitialEligibility(canRequestAds: true)).allowed,
      isTrue,
    );
  });

  test('duplicate trigger inside two seconds is not counted', () async {
    await service.initializeSession();

    expect(
      await service.recordSuccessfulMeaningfulAction(
        MeaningfulAdAction.calendarDateOpened,
      ),
      isTrue,
    );
    expect(
      await service.recordSuccessfulMeaningfulAction(
        MeaningfulAdAction.calendarDateOpened,
      ),
      isFalse,
    );
    now = now.add(const Duration(seconds: 2));
    expect(
      await service.recordSuccessfulMeaningfulAction(
        MeaningfulAdAction.calendarDateOpened,
      ),
      isTrue,
    );
    expect(await service.pendingMeaningfulActionCount(), 2);
  });

  test(
    'rolls a session over before recording an action after 30 minutes',
    () async {
      store.state = AdFrequencyState(
        sessionStartedAt: now.subtract(const Duration(minutes: 30)),
        sessionNumber: 4,
        fullscreenShownThisSession: 3,
      );

      await service.recordSuccessfulMeaningfulAction(
        MeaningfulAdAction.calendarDateOpened,
      );

      expect(store.state.sessionNumber, 5);
      expect(store.state.fullscreenShownThisSession, 0);
      expect(store.state.pendingMeaningfulActions, 1);
    },
  );

  test(
    'rolls a session over before eligibility refreshes its session cap',
    () async {
      store.state = AdFrequencyState(
        sessionStartedAt: now.subtract(const Duration(minutes: 30)),
        sessionNumber: 2,
        fullscreenShownThisSession: 3,
        pendingMeaningfulActions: 6,
      );

      expect(
        (await service.interstitialEligibility(canRequestAds: true)).reason,
        AdSuppressionReason.sessionTooYoung,
      );
      expect(store.state.sessionNumber, 3);
      expect(store.state.fullscreenShownThisSession, 0);

      now = now.add(const Duration(seconds: 120));
      expect(
        (await service.interstitialEligibility(canRequestAds: true)).allowed,
        isTrue,
      );
    },
  );

  test(
    'rolls a session over before eligibility refreshes grace sessions',
    () async {
      store.state = AdFrequencyState(
        sessionStartedAt: now.subtract(const Duration(minutes: 30)),
        sessionNumber: 2,
        pendingMeaningfulActions: 6,
      );
      final graceService = AdPolicyService(
        store,
        () => _twoSessionGracePolicy,
        now: () => now,
      );

      expect(
        (await graceService.interstitialEligibility(
          canRequestAds: true,
        )).reason,
        AdSuppressionReason.sessionTooYoung,
      );
      expect(store.state.sessionNumber, 3);
    },
  );

  test('persists rolling caps across a policy-service restart', () async {
    store.state = AdFrequencyState(
      sessionStartedAt: now.subtract(const Duration(minutes: 5)),
      sessionNumber: 1,
      pendingMeaningfulActions: 6,
      fullscreenHistory: List<DateTime>.generate(
        8,
        (index) => now.subtract(Duration(hours: index)),
      ),
    );
    final restarted = AdPolicyService(store, () => policy, now: () => now);

    expect(
      (await restarted.interstitialEligibility(canRequestAds: true)).reason,
      AdSuppressionReason.rolling24hCap,
    );
    now = now.add(const Duration(hours: 18));
    expect(
      (await restarted.interstitialEligibility(canRequestAds: true)).reason,
      isNot(AdSuppressionReason.rolling24hCap),
    );
  });

  test(
    'enforces the per-session cap and does not bypass on clock reversal',
    () async {
      store.state = AdFrequencyState(
        sessionStartedAt: now.subtract(const Duration(minutes: 5)),
        sessionNumber: 1,
        fullscreenShownThisSession: 3,
        pendingMeaningfulActions: 6,
      );
      expect(
        (await service.interstitialEligibility(canRequestAds: true)).reason,
        AdSuppressionReason.sessionCap,
      );

      store.state = AdFrequencyState(
        sessionStartedAt: now.subtract(const Duration(hours: 1)),
        sessionNumber: 1,
        pendingMeaningfulActions: 6,
        lastFullscreenShownAt: now,
      );
      service = AdPolicyService(store, () => policy, now: () => now);
      now = now.subtract(const Duration(hours: 1));
      expect(
        (await service.interstitialEligibility(canRequestAds: true)).reason,
        AdSuppressionReason.sessionTooYoung,
      );
    },
  );

  test(
    'consent and kill switches suppress before any cap is consumed',
    () async {
      await service.initializeSession();

      expect(
        (await service.interstitialEligibility(canRequestAds: false)).reason,
        AdSuppressionReason.consentNotReady,
      );
      final disabled = AdPolicyService(
        store,
        () => const AdPolicy(
          masterEnabled: false,
          bannerEnabled: true,
          interstitialEnabled: true,
          actionsRequired: 6,
          interstitialCooldown: Duration(seconds: 300),
          minSessionAge: Duration(seconds: 120),
          newUserGraceSessions: 0,
          maxFullscreenPerSession: 3,
          maxFullscreenPer24Hours: 8,
          appOpenEnabled: false,
          appOpenMinBackground: Duration(seconds: 120),
          appOpenCooldown: Duration(seconds: 14400),
          version: 'disabled',
        ),
        now: () => now,
      );
      expect(
        (await disabled.interstitialEligibility(canRequestAds: true)).reason,
        AdSuppressionReason.masterDisabled,
      );
    },
  );
}

const _twoSessionGracePolicy = AdPolicy(
  masterEnabled: true,
  bannerEnabled: true,
  interstitialEnabled: true,
  actionsRequired: 6,
  interstitialCooldown: Duration(seconds: 300),
  minSessionAge: Duration(seconds: 120),
  newUserGraceSessions: 2,
  maxFullscreenPerSession: 3,
  maxFullscreenPer24Hours: 8,
  appOpenEnabled: false,
  appOpenMinBackground: Duration(seconds: 120),
  appOpenCooldown: Duration(seconds: 14400),
  version: 'grace-test',
);

Future<void> _makeEligible(
  AdPolicyService service,
  void Function() advanceAction,
  void Function() advanceSession,
) async {
  await service.initializeSession();
  advanceSession();
  await _recordActions(service, 6, advanceAction);
}

Future<void> _recordActions(
  AdPolicyService service,
  int count,
  void Function() advance,
) async {
  final actions = MeaningfulAdAction.values;
  for (var index = 0; index < count; index++) {
    advance();
    await service.recordSuccessfulMeaningfulAction(
      actions[index % (actions.length - 1)],
    );
  }
}

class _MemoryStore implements AdFrequencyStateStore {
  AdFrequencyState state = const AdFrequencyState();

  @override
  Future<void> clear() async => state = const AdFrequencyState();

  @override
  Future<AdFrequencyState> read() async => state;

  @override
  Future<void> write(AdFrequencyState value) async => state = value;
}
