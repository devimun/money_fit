import 'dart:convert';

import 'package:money_fit/core/models/theme_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The single persisted preference document for presentation-only settings.
///
/// Ledger currency intentionally does not live here: changing a display locale
/// must not rewrite the currency meaning of existing financial records.
class AppPreferences {
  const AppPreferences({required this.theme, required this.languageCode});

  final ThemeSettings theme;
  final String languageCode;

  factory AppPreferences.defaults() => AppPreferences(
    theme: ThemeSettings.defaultSettings(),
    languageCode: 'en',
  );

  AppPreferences copyWith({ThemeSettings? theme, String? languageCode}) {
    return AppPreferences(
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, Object> toJson() => {
    'theme': theme.toJson(),
    'languageCode': languageCode,
  };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    final theme = json['theme'];
    final languageCode = json['languageCode'] is String
        ? json['languageCode'] as String
        : 'en';
    return AppPreferences(
      theme: theme is Map<String, dynamic>
          ? ThemeSettings.fromJson(theme)
          : ThemeSettings.defaultSettings(),
      languageCode: languageCode,
    );
  }
}

/// Migrates the independent theme/locale preference keys exactly once and then
/// writes the complete preference state as a single document.
class AppPreferencesRepository {
  AppPreferencesRepository(this._preferences);

  static const storageKey = 'app_preferences_v1';
  static const _migrationKey = 'app_preferences_migrated_v1';
  static const _schemaVersionKey = 'app_preferences_schema_version';
  static const _currentSchemaVersion = 2;
  static const _legacyThemeKey = 'theme_settings';
  static const _legacyLanguageKey = 'locale_language_code';

  final SharedPreferences _preferences;

  AppPreferences load() {
    final encoded = _preferences.getString(storageKey);
    if (encoded != null) {
      try {
        return AppPreferences.fromJson(
          jsonDecode(encoded) as Map<String, dynamic>,
        );
      } catch (_) {
        // A malformed preference must not block local financial data.
      }
    }

    final migrated = _readLegacy();
    // SharedPreferences mutations are asynchronous; the state is valid now and
    // the controller persists it before exposing a user initiated update.
    return migrated;
  }

  Future<bool> save(AppPreferences value) async {
    final saved = await _preferences.setString(storageKey, jsonEncode(value));
    if (saved) {
      await _preferences.setBool(_migrationKey, true);
      await _preferences.setInt(_schemaVersionKey, _currentSchemaVersion);
    }
    return saved;
  }

  Future<bool> migrateIfNeeded() async {
    if (_preferences.getInt(_schemaVersionKey) == _currentSchemaVersion) {
      return true;
    }
    // [load] retains an existing preference document while dropping its old
    // currency field. v6 ledger_settings is the financial source of truth.
    return save(load());
  }

  Future<void> clear() async {
    await _preferences.remove(storageKey);
    await _preferences.remove(_migrationKey);
    await _preferences.remove(_schemaVersionKey);
  }

  AppPreferences _readLegacy() {
    ThemeSettings theme = ThemeSettings.defaultSettings();
    final encodedTheme = _preferences.getString(_legacyThemeKey);
    if (encodedTheme != null) {
      try {
        theme = ThemeSettings.fromJson(
          jsonDecode(encodedTheme) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return AppPreferences(
      theme: theme,
      languageCode: _preferences.getString(_legacyLanguageKey) ?? 'en',
    );
  }
}
