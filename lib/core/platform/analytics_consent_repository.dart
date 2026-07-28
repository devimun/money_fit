import 'package:shared_preferences/shared_preferences.dart';

/// Persisted privacy choice. New installations collect analytics by default,
/// while an existing explicit opt-out is never overwritten.
class AnalyticsConsentRepository {
  AnalyticsConsentRepository(this._preferences);

  static const collectionKey = 'analytics_collection_enabled';
  static const versionKey = 'analytics_consent_version';

  final SharedPreferences _preferences;

  bool get isEnabled => _preferences.getBool(collectionKey) ?? true;

  Future<void> setEnabled(bool value, {String version = '1'}) async {
    await _preferences.setBool(collectionKey, value);
    await _preferences.setString(versionKey, version);
  }

  Future<void> clear() async {
    await _preferences.remove(collectionKey);
    await _preferences.remove(versionKey);
  }
}
