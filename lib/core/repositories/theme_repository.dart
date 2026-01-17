// ThemeSettings를 SharedPreferences를 통해 영구 저장하는 Repository

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_settings.dart';

/// ThemeSettings를 로컬 저장소에 저장하고 불러오는 Repository
///
/// SharedPreferences를 사용하여 사용자의 테마 설정을 영구 저장합니다.
class ThemeRepository {
  static const String _themeSettingsKey = 'theme_settings';
  static const String _migrationCompletedKey = 'theme_migration_completed';

  final SharedPreferences _prefs;

  ThemeRepository(this._prefs);

  /// 마이그레이션이 완료되었는지 확인합니다.
  bool isMigrationCompleted() {
    return _prefs.getBool(_migrationCompletedKey) ?? false;
  }

  /// 마이그레이션 완료 플래그를 설정합니다.
  Future<bool> setMigrationCompleted() async {
    return await _prefs.setBool(_migrationCompletedKey, true);
  }

  /// 기존 User.isDarkMode 값으로 ThemeSettings를 마이그레이션합니다.
  /// 
  /// 마이그레이션이 이미 완료되었거나 ThemeSettings가 이미 존재하면 무시합니다.
  Future<bool> migrateFromUserDarkMode(bool userIsDarkMode) async {
    // 이미 마이그레이션 완료된 경우 스킵
    if (isMigrationCompleted()) {
      return true;
    }

    // ThemeSettings가 이미 존재하면 스킵
    final existingJson = _prefs.getString(_themeSettingsKey);
    if (existingJson != null) {
      await setMigrationCompleted();
      return true;
    }

    // User.isDarkMode 값으로 새 ThemeSettings 생성
    final settings = ThemeSettings.defaultSettings().copyWith(
      isDarkMode: userIsDarkMode,
    );

    final success = await saveSettings(settings);
    if (success) {
      await setMigrationCompleted();
    }
    return success;
  }

  /// 저장된 ThemeSettings를 불러옵니다.
  ///
  /// 저장된 설정이 없으면 기본 설정을 반환합니다.
  ThemeSettings loadSettings() {
    try {
      final String? jsonString = _prefs.getString(_themeSettingsKey);
      
      if (jsonString == null) {
        return ThemeSettings.defaultSettings();
      }

      final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ThemeSettings.fromJson(json);
    } catch (e) {
      // JSON 파싱 실패 시 기본 설정 반환
      return ThemeSettings.defaultSettings();
    }
  }

  /// ThemeSettings를 저장합니다.
  ///
  /// 저장 실패 시 false를 반환합니다.
  Future<bool> saveSettings(ThemeSettings settings) async {
    try {
      final String jsonString = jsonEncode(settings.toJson());
      return await _prefs.setString(_themeSettingsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// 저장된 설정을 삭제합니다.
  ///
  /// 테스트나 초기화 목적으로 사용됩니다.
  Future<bool> clearSettings() async {
    try {
      return await _prefs.remove(_themeSettingsKey);
    } catch (e) {
      return false;
    }
  }
}
