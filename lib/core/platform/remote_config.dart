import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Read-only Remote Config boundary consumed by feature policies.
///
/// Features never fetch, activate, or replace defaults. That lifecycle has one
/// owner: [RemoteConfigService] at the platform boundary.
abstract interface class RemoteConfigReader {
  bool boolValue(String key);
  int intValue(String key);
  String stringValue(String key);
  bool isRemoteValue(String key);
}

/// Canonical policy for spacing proactive full-screen experiences. The
/// feedback and monetization features deliberately share this value because
/// both acquire the same app-wide prompt lease.
const proactiveFullscreenQuietSecondsKey = 'proactive_fullscreen_quiet_seconds';
const proactiveFullscreenQuietSecondsDefault = 120;
const proactiveFullscreenQuietSecondsMinimum = 30;
const proactiveFullscreenQuietSecondsMaximum = 600;

/// Falls back to the canonical local policy instead of coercing an invalid
/// Remote Config experiment into a different quiet period.
int validatedProactiveFullscreenQuietSeconds(int seconds) {
  return seconds >= proactiveFullscreenQuietSecondsMinimum &&
          seconds <= proactiveFullscreenQuietSecondsMaximum
      ? seconds
      : proactiveFullscreenQuietSecondsDefault;
}

/// Reads any published alias for the shared quiet-period policy while keeping
/// its fallback anchored to the canonical local default.
int readValidatedProactiveFullscreenQuietSeconds(
  RemoteConfigReader remoteConfig, {
  String key = proactiveFullscreenQuietSecondsKey,
}) {
  try {
    return validatedProactiveFullscreenQuietSeconds(remoteConfig.intValue(key));
  } catch (_) {
    return proactiveFullscreenQuietSecondsDefault;
  }
}

/// Small SDK seam so the Remote Config lifecycle remains independently
/// testable and a Firebase failure can fall back to local defaults.
abstract interface class RemoteConfigClient {
  Future<void> configure({
    required Duration fetchTimeout,
    required Duration minimumFetchInterval,
  });

  Future<void> setDefaults(Map<String, Object> defaults);
  Future<bool> fetchAndActivate();
  Future<bool> activate();

  Stream<void> get updates;

  bool boolValue(String key);
  int intValue(String key);
  String stringValue(String key);
  bool isRemoteValue(String key);
}

class FirebaseRemoteConfigClient implements RemoteConfigClient {
  FirebaseRemoteConfigClient(this._remoteConfig);

  final FirebaseRemoteConfig Function() _remoteConfig;

  @override
  Future<void> configure({
    required Duration fetchTimeout,
    required Duration minimumFetchInterval,
  }) {
    return _remoteConfig().setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: fetchTimeout,
        minimumFetchInterval: minimumFetchInterval,
      ),
    );
  }

  @override
  Future<void> setDefaults(Map<String, Object> defaults) =>
      _remoteConfig().setDefaults(defaults);

  @override
  Future<bool> fetchAndActivate() => _remoteConfig().fetchAndActivate();

  @override
  Future<bool> activate() => _remoteConfig().activate();

  @override
  Stream<void> get updates => _remoteConfig().onConfigUpdated.map<void>((_) {});

  @override
  bool boolValue(String key) => _remoteConfig().getBool(key);

  @override
  int intValue(String key) => _remoteConfig().getInt(key);

  @override
  String stringValue(String key) => _remoteConfig().getString(key);

  @override
  bool isRemoteValue(String key) =>
      _remoteConfig().getValue(key).source == ValueSource.valueRemote;
}

/// The one canonical set of local Remote Config defaults.
///
/// Individual features validate their own values further (for example bounded
/// ad limits), so a malformed remote value degrades only that setting.
const remoteConfigDefaults = <String, Object>{
  'latest_version': '',
  'min_supported_version': '',
  'update_changelog': '',
  'amplitude_collection_enabled': true,
  'ads_master_enabled': true,
  'ads_banner_enabled': true,
  'ads_interstitial_enabled': true,
  'ads_interstitial_actions_required': 6,
  'ads_interstitial_cooldown_seconds': 300,
  'ads_min_session_age_seconds': 120,
  'ads_new_user_grace_sessions': 0,
  'ads_fullscreen_max_per_session': 3,
  'ads_fullscreen_max_per_24h': 8,
  'ads_app_open_enabled': false,
  'ads_app_open_min_background_seconds': 120,
  'ads_app_open_cooldown_seconds': 14400,
  'ads_policy_version': 'control_6_300_first_session_v1',
  'feedback_prompt_enabled': false,
  'feedback_prompt_rollout_percent': 0,
  'feedback_prompt_min_install_days': 7,
  'feedback_prompt_min_sessions': 3,
  'feedback_prompt_min_actions': 10,
  'feedback_prompt_min_active_days': 3,
  'feedback_prompt_global_cooldown_days': 30,
  'feedback_prompt_later_days': 30,
  'feedback_prompt_dismiss_days': 14,
  'feedback_prompt_submitted_days': 120,
  'feedback_prompt_max_shows_180d': 3,
  proactiveFullscreenQuietSecondsKey: proactiveFullscreenQuietSecondsDefault,
  // Backward-compatible reads for published templates. Canonical keys above
  // always remain the local source of truth.
  'feedback_prompt_max_shows_180_days': 3,
  'feedback_prompt_engagement_cooldown_days': 30,
  'feedback_prompt_quiet_period_seconds': 120,
  'feedback_prompt_policy_version': 'feedback_v1',
};

/// Fail-open, single-owner Firebase Remote Config lifecycle.
class RemoteConfigService implements RemoteConfigReader {
  RemoteConfigService(
    this._client, {
    Map<String, Object> defaults = remoteConfigDefaults,
  }) : _defaults = Map.unmodifiable(defaults);

  final RemoteConfigClient _client;
  final Map<String, Object> _defaults;
  final _updates = StreamController<void>.broadcast();
  StreamSubscription<void>? _updatesSubscription;
  Future<void>? _initializeFuture;

  Stream<void> get updates => _updates.stream;

  Future<void> initialize() => _initializeFuture ??= _initialize();

  Future<void> _initialize() async {
    try {
      await _client.configure(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 30),
      );
      await _client.setDefaults(_defaults);
      await _client.fetchAndActivate();
      _updatesSubscription = _client.updates.listen((_) async {
        try {
          await _client.activate();
          if (!_updates.isClosed) _updates.add(null);
        } catch (_) {
          // Retain the last activated/default values after a failed update.
        }
      });
    } catch (_) {
      // Firebase is optional. Getter methods below continue to use defaults.
    }
  }

  @override
  bool boolValue(String key) => _read(
    key,
    read: _client.boolValue,
    fallback: _defaults[key] is bool ? _defaults[key]! as bool : false,
  );

  @override
  int intValue(String key) => _read(
    key,
    read: _client.intValue,
    fallback: _defaults[key] is int ? _defaults[key]! as int : 0,
  );

  @override
  String stringValue(String key) => _read(
    key,
    read: _client.stringValue,
    fallback: _defaults[key] is String ? _defaults[key]! as String : '',
  );

  @override
  bool isRemoteValue(String key) {
    try {
      return _client.isRemoteValue(key);
    } catch (_) {
      return false;
    }
  }

  T _read<T>(
    String key, {
    required T Function(String key) read,
    required T fallback,
  }) {
    try {
      return read(key);
    } catch (_) {
      return fallback;
    }
  }

  Future<void> dispose() async {
    await _updatesSubscription?.cancel();
    await _updates.close();
  }
}
