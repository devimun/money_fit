/// A narrow read-only boundary for advertising Remote Config values.
///
/// The remote-config feature owns fetching and activation. Monetization only
/// consumes an already-active snapshot through this interface so it never
/// overwrites another feature's Remote Config settings.
abstract interface class AdPolicyReader {
  String stringValue(String key);
}

/// Safe advertising defaults used when Remote Config is absent or malformed.
///
/// App-open values are deliberately retained in the policy contract for the
/// deployed template, but no app-open lifecycle is implemented in this
/// release.
class AdPolicy {
  const AdPolicy({
    required this.masterEnabled,
    required this.bannerEnabled,
    required this.interstitialEnabled,
    required this.actionsRequired,
    required this.interstitialCooldown,
    required this.minSessionAge,
    required this.newUserGraceSessions,
    required this.maxFullscreenPerSession,
    required this.maxFullscreenPer24Hours,
    required this.appOpenEnabled,
    required this.appOpenMinBackground,
    required this.appOpenCooldown,
    required this.version,
    this.invalidKeys = const <String>[],
  });

  static const defaultVersion = 'control_6_300_first_session_v1';

  static const defaults = AdPolicy(
    masterEnabled: true,
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
    version: defaultVersion,
  );

  final bool masterEnabled;
  final bool bannerEnabled;
  final bool interstitialEnabled;
  final int actionsRequired;
  final Duration interstitialCooldown;
  final Duration minSessionAge;
  final int newUserGraceSessions;
  final int maxFullscreenPerSession;
  final int maxFullscreenPer24Hours;
  final bool appOpenEnabled;
  final Duration appOpenMinBackground;
  final Duration appOpenCooldown;
  final String version;
  final List<String> invalidKeys;

  factory AdPolicy.fromReader(AdPolicyReader reader) {
    final invalidKeys = <String>[];

    bool boolValue(String key, bool fallback) {
      switch (reader.stringValue(key).trim().toLowerCase()) {
        case 'true':
          return true;
        case 'false':
          return false;
        default:
          invalidKeys.add(key);
          return fallback;
      }
    }

    int bounded(String key, int fallback, int min, int max) {
      final value = int.tryParse(reader.stringValue(key).trim());
      if (value == null || value < min || value > max) {
        invalidKeys.add(key);
        return fallback;
      }
      return value;
    }

    final version = reader.stringValue('ads_policy_version').trim();
    final validVersion =
        version.isNotEmpty &&
        version.length <= 80 &&
        RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(version);
    if (!validVersion) invalidKeys.add('ads_policy_version');

    return AdPolicy(
      masterEnabled: boolValue('ads_master_enabled', defaults.masterEnabled),
      bannerEnabled: boolValue('ads_banner_enabled', defaults.bannerEnabled),
      interstitialEnabled: boolValue(
        'ads_interstitial_enabled',
        defaults.interstitialEnabled,
      ),
      actionsRequired: bounded(
        'ads_interstitial_actions_required',
        defaults.actionsRequired,
        6,
        30,
      ),
      interstitialCooldown: Duration(
        seconds: bounded(
          'ads_interstitial_cooldown_seconds',
          defaults.interstitialCooldown.inSeconds,
          300,
          86400,
        ),
      ),
      minSessionAge: Duration(
        seconds: bounded(
          'ads_min_session_age_seconds',
          defaults.minSessionAge.inSeconds,
          60,
          3600,
        ),
      ),
      newUserGraceSessions: bounded(
        'ads_new_user_grace_sessions',
        defaults.newUserGraceSessions,
        0,
        20,
      ),
      maxFullscreenPerSession: bounded(
        'ads_fullscreen_max_per_session',
        defaults.maxFullscreenPerSession,
        1,
        4,
      ),
      maxFullscreenPer24Hours: bounded(
        'ads_fullscreen_max_per_24h',
        defaults.maxFullscreenPer24Hours,
        1,
        12,
      ),
      appOpenEnabled: boolValue(
        'ads_app_open_enabled',
        defaults.appOpenEnabled,
      ),
      appOpenMinBackground: Duration(
        seconds: bounded(
          'ads_app_open_min_background_seconds',
          defaults.appOpenMinBackground.inSeconds,
          60,
          86400,
        ),
      ),
      appOpenCooldown: Duration(
        seconds: bounded(
          'ads_app_open_cooldown_seconds',
          defaults.appOpenCooldown.inSeconds,
          300,
          172800,
        ),
      ),
      version: validVersion ? version : defaultVersion,
      invalidKeys: invalidKeys,
    );
  }
}

/// Default values represented as strings, matching Remote Config's boundary.
class DefaultAdPolicyReader implements AdPolicyReader {
  const DefaultAdPolicyReader();

  static const _values = <String, String>{
    'ads_master_enabled': 'true',
    'ads_banner_enabled': 'true',
    'ads_interstitial_enabled': 'true',
    'ads_interstitial_actions_required': '6',
    'ads_interstitial_cooldown_seconds': '300',
    'ads_min_session_age_seconds': '120',
    'ads_new_user_grace_sessions': '0',
    'ads_fullscreen_max_per_session': '3',
    'ads_fullscreen_max_per_24h': '8',
    'ads_app_open_enabled': 'false',
    'ads_app_open_min_background_seconds': '120',
    'ads_app_open_cooldown_seconds': '14400',
    'ads_policy_version': AdPolicy.defaultVersion,
  };

  @override
  String stringValue(String key) => _values[key] ?? '';
}
