import 'package:money_fit/core/config/remote_config_service.dart';

class AdPolicyConfig {
  const AdPolicyConfig({
    required this.masterEnabled,
    required this.bannerEnabled,
    required this.interstitialEnabled,
    required this.actionsRequired,
    required this.cooldown,
    required this.minSessionAge,
    required this.newUserGraceSessions,
    required this.maxPerSession,
    required this.maxPer24Hours,
    required this.appOpenEnabled,
    required this.appOpenMinBackground,
    required this.appOpenCooldown,
    required this.policyVersion,
    this.invalidKeys = const [],
  });

  final bool masterEnabled;
  final bool bannerEnabled;
  final bool interstitialEnabled;
  final int actionsRequired;
  final Duration cooldown;
  final Duration minSessionAge;
  final int newUserGraceSessions;
  final int maxPerSession;
  final int maxPer24Hours;
  final bool appOpenEnabled;
  final Duration appOpenMinBackground;
  final Duration appOpenCooldown;
  final String policyVersion;
  final List<String> invalidKeys;

  factory AdPolicyConfig.fromRemoteConfig(RemoteConfigService config) {
    final invalidKeys = <String>[];
    int bounded(String key, int fallback, int min, int max) {
      final value = config.intValue(key);
      if (value < min || value > max) {
        invalidKeys.add(key);
        return fallback;
      }
      return value;
    }

    final policyVersion = config.stringValue('ads_policy_version').trim();
    final validPolicyVersion =
        policyVersion.isNotEmpty &&
        policyVersion.length <= 80 &&
        RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(policyVersion);
    if (!validPolicyVersion) invalidKeys.add('ads_policy_version');
    return AdPolicyConfig(
      masterEnabled: config.boolValue('ads_master_enabled'),
      bannerEnabled: config.boolValue('ads_banner_enabled'),
      interstitialEnabled: config.boolValue('ads_interstitial_enabled'),
      actionsRequired: bounded('ads_interstitial_actions_required', 12, 6, 30),
      cooldown: Duration(
        seconds: bounded('ads_interstitial_cooldown_seconds', 600, 300, 86400),
      ),
      minSessionAge: Duration(
        seconds: bounded('ads_min_session_age_seconds', 120, 60, 3600),
      ),
      newUserGraceSessions: bounded('ads_new_user_grace_sessions', 3, 2, 20),
      maxPerSession: bounded('ads_fullscreen_max_per_session', 3, 1, 4),
      maxPer24Hours: bounded('ads_fullscreen_max_per_24h', 8, 1, 12),
      appOpenEnabled: config.boolValue('ads_app_open_enabled'),
      appOpenMinBackground: Duration(
        seconds: bounded('ads_app_open_min_background_seconds', 120, 60, 86400),
      ),
      appOpenCooldown: Duration(
        seconds: bounded('ads_app_open_cooldown_seconds', 14400, 300, 172800),
      ),
      policyVersion: validPolicyVersion ? policyVersion : 'control_12_600_v1',
      invalidKeys: invalidKeys,
    );
  }
}
