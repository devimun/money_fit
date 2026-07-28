import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';

void main() {
  test('uses the 1.2.7 control defaults', () {
    const policy = AdPolicy.defaults;

    expect(policy.actionsRequired, 6);
    expect(policy.interstitialCooldown, const Duration(seconds: 300));
    expect(policy.minSessionAge, const Duration(seconds: 120));
    expect(policy.newUserGraceSessions, 0);
    expect(policy.maxFullscreenPerSession, 3);
    expect(policy.maxFullscreenPer24Hours, 8);
    expect(policy.appOpenEnabled, isFalse);
  });

  test('accepts an 80-character canonical policy version', () {
    final version = List.filled(80, 'p').join();
    final policy = AdPolicy.fromReader(
      _Reader(<String, String>{'ads_policy_version': version}),
    );

    expect(policy.version, version);
    expect(policy.invalidKeys, isEmpty);
  });

  test('falls back per invalid Remote Config key without disabling policy', () {
    final policy = AdPolicy.fromReader(
      _Reader(<String, String>{
        'ads_master_enabled': 'true',
        'ads_banner_enabled': 'not-a-bool',
        'ads_interstitial_enabled': 'true',
        'ads_interstitial_actions_required': '5',
        'ads_interstitial_cooldown_seconds': '299',
        'ads_min_session_age_seconds': '120',
        'ads_new_user_grace_sessions': '0',
        'ads_fullscreen_max_per_session': '3',
        'ads_fullscreen_max_per_24h': '99',
        'ads_app_open_enabled': 'true',
        'ads_app_open_min_background_seconds': '120',
        'ads_app_open_cooldown_seconds': '14400',
        'ads_policy_version': 'bad version!',
      }),
    );

    expect(policy.masterEnabled, isTrue);
    expect(policy.bannerEnabled, isTrue);
    expect(policy.actionsRequired, 6);
    expect(policy.interstitialCooldown, const Duration(seconds: 300));
    expect(policy.maxFullscreenPer24Hours, 8);
    expect(policy.appOpenEnabled, isTrue);
    expect(policy.version, AdPolicy.defaultVersion);
    expect(
      policy.invalidKeys,
      containsAll(<String>[
        'ads_banner_enabled',
        'ads_interstitial_actions_required',
        'ads_interstitial_cooldown_seconds',
        'ads_fullscreen_max_per_24h',
        'ads_policy_version',
      ]),
    );
  });
}

class _Reader implements AdPolicyReader {
  const _Reader(this._values);

  final Map<String, String> _values;

  @override
  String stringValue(String key) =>
      _values[key] ?? const DefaultAdPolicyReader().stringValue(key);
}
