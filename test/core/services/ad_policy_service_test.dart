import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/ad_policy_config.dart';
import 'package:money_fit/core/services/ad_policy_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const policy = AdPolicyConfig(
    masterEnabled: true,
    bannerEnabled: true,
    interstitialEnabled: true,
    actionsRequired: 6,
    cooldown: Duration(seconds: 300),
    minSessionAge: Duration(seconds: 120),
    newUserGraceSessions: 0,
    maxPerSession: 3,
    maxPer24Hours: 8,
    appOpenEnabled: false,
    appOpenMinBackground: Duration(seconds: 120),
    appOpenCooldown: Duration(hours: 4),
    policyVersion: 'control_6_300_first_session_v1',
  );

  late DateTime now;
  late SharedPreferences prefs;
  late AdPolicyService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    now = DateTime.utc(2026, 7, 21, 12);
    service = AdPolicyService(prefs, () => policy, now: () => now);
  });

  Future<void> eligibleSession() async {
    await service.initializeSession();
    now = now.add(const Duration(seconds: 120));
  }

  test(
    'allows the first session after its age and 6-action thresholds',
    () async {
      await service.initializeSession();
      expect(
        service.interstitialEligibility(consentReady: true).reason,
        AdSuppressionReason.sessionTooYoung,
      );
      now = now.add(const Duration(seconds: 120));
      expect(
        service.interstitialEligibility(consentReady: true).reason,
        AdSuppressionReason.actionThreshold,
      );
      for (var i = 0; i < 5; i++) {
        now = now.add(const Duration(seconds: 3));
        expect(await service.recordMeaningfulAction('action_$i'), isTrue);
      }
      expect(
        service.interstitialEligibility(consentReady: true).reason,
        AdSuppressionReason.actionThreshold,
      );
      now = now.add(const Duration(seconds: 3));
      await service.recordMeaningfulAction('action_5');
      expect(
        service.interstitialEligibility(consentReady: true).allowed,
        isTrue,
      );
    },
  );

  test('debounces a duplicate trigger without consuming an action', () async {
    await service.recordMeaningfulAction('calendar_open');
    expect(await service.recordMeaningfulAction('calendar_open'), isFalse);
    now = now.add(const Duration(seconds: 2));
    expect(await service.recordMeaningfulAction('calendar_open'), isTrue);
    expect(service.actionCount, 2);
  });

  test(
    'only an actual show consumes action, cooldown, session, and rolling caps',
    () async {
      await eligibleSession();
      for (var i = 0; i < 6; i++) {
        now = now.add(const Duration(seconds: 3));
        await service.recordMeaningfulAction('action_$i');
      }
      expect(
        service.interstitialEligibility(consentReady: true).allowed,
        isTrue,
      );
      await service.recordFullscreenShown();
      expect(service.actionCount, 0);
      expect(service.shownThisSession, 1);
      for (var i = 0; i < 6; i++) {
        now = now.add(const Duration(seconds: 3));
        await service.recordMeaningfulAction('cooldown_$i');
      }
      expect(
        service.interstitialEligibility(consentReady: true).reason,
        AdSuppressionReason.cooldown,
      );
      now = now.add(const Duration(seconds: 300));
      for (var i = 0; i < 6; i++) {
        now = now.add(const Duration(seconds: 3));
        await service.recordMeaningfulAction('again_$i');
      }
      expect(
        service.interstitialEligibility(consentReady: true).allowed,
        isTrue,
      );
    },
  );

  test('persisted rolling history survives a new policy service', () async {
    await eligibleSession();
    await prefs.setStringList(
      'ads_fullscreen_history',
      List<String>.generate(
        8,
        (index) => now.subtract(Duration(hours: index)).toIso8601String(),
      ),
    );
    for (var i = 0; i < 6; i++) {
      now = now.add(const Duration(seconds: 3));
      await service.recordMeaningfulAction('rolling_$i');
    }
    final restarted = AdPolicyService(prefs, () => policy, now: () => now);
    expect(
      restarted.interstitialEligibility(consentReady: true).reason,
      AdSuppressionReason.rolling24hCap,
    );
    now = now.add(const Duration(hours: 17));
    expect(
      restarted.interstitialEligibility(consentReady: true).reason,
      isNot(AdSuppressionReason.rolling24hCap),
    );
  });

  test('time moving backwards never opens a cap or cooldown bypass', () async {
    await eligibleSession();
    await service.recordFullscreenShown();
    now = now.subtract(const Duration(hours: 1));
    expect(
      service.interstitialEligibility(consentReady: true).reason,
      AdSuppressionReason.sessionTooYoung,
    );
  });
}
