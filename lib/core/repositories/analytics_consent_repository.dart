import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsConsentRepository {
  AnalyticsConsentRepository(this._prefs);
  final SharedPreferences _prefs;
  static const collectionKey = 'analytics_collection_enabled';
  static const versionKey = 'analytics_consent_version';

  // Collection starts enabled for new installs. A stored `false` is always
  // respected, so this is still an explicit opt-out control.
  bool get isEnabled => _prefs.getBool(collectionKey) ?? true;
  Future<void> setEnabled(bool value, {String version = '1'}) async {
    await _prefs.setBool(collectionKey, value);
    await _prefs.setString(versionKey, version);
  }
}
