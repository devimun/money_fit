import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Single owner of Firebase Remote Config settings, defaults and activation.
class RemoteConfigService {
  RemoteConfigService(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;
  StreamSubscription<RemoteConfigUpdate>? _updatesSubscription;
  final _updates = StreamController<void>.broadcast();

  Stream<void> get updates => _updates.stream;

  static final defaults = <String, dynamic>{
    'latest_version': '',
    'min_supported_version': '',
    'update_changelog': '',
    'amplitude_collection_enabled': true,
    'ads_master_enabled': true,
    'ads_banner_enabled': true,
    'ads_interstitial_enabled': true,
    'ads_interstitial_actions_required': 12,
    'ads_interstitial_cooldown_seconds': 600,
    'ads_min_session_age_seconds': 120,
    'ads_new_user_grace_sessions': 3,
    'ads_fullscreen_max_per_session': 3,
    'ads_fullscreen_max_per_24h': 8,
    'ads_app_open_enabled': false,
    'ads_app_open_min_background_seconds': 120,
    'ads_app_open_cooldown_seconds': 14400,
    'ads_policy_version': 'control_12_600_v1',
    'feedback_prompt_enabled': false,
    'feedback_prompt_rollout_percent': 0,
    'feedback_prompt_min_install_days': 7,
    'feedback_prompt_min_sessions': 3,
    'feedback_prompt_min_actions': 10,
    'feedback_prompt_min_active_days': 3,
  };

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 30),
        ),
      );
      await _remoteConfig.setDefaults(defaults);
      await _remoteConfig.fetchAndActivate();
      _updatesSubscription = _remoteConfig.onConfigUpdated.listen((_) async {
        try {
          await _remoteConfig.activate();
          _updates.add(null);
        } catch (_) {
          // Retain the last activated values if a real-time update fails.
        }
      });
    } catch (_) {
      // Defaults or Firebase's last activated cache remain safe to use.
    }
  }

  bool boolValue(String key) => _remoteConfig.getBool(key);
  int intValue(String key) => _remoteConfig.getInt(key);
  String stringValue(String key) => _remoteConfig.getString(key);

  Future<void> dispose() async {
    await _updatesSubscription?.cancel();
    await _updates.close();
  }
}
