import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsConsentRepository {
  AnalyticsConsentRepository(this._prefs);
  final SharedPreferences _prefs;
  static const collectionKey = 'analytics_collection_enabled';
  static const versionKey = 'analytics_consent_version';

  bool get isEnabled => _prefs.getBool(collectionKey) ?? false;
  Future<void> setEnabled(bool value, {String version = '1'}) async {
    await _prefs.setBool(collectionKey, value);
    await _prefs.setString(versionKey, version);
  }
}
