import 'dart:convert';

import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/models/theme_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The single persisted preference document for presentation-only settings.
///
/// Ledger currency intentionally does not live here: changing a display locale
/// must not rewrite the currency meaning of existing financial records.
class AppPreferences {
  const AppPreferences({
    required this.theme,
    required this.languageCode,
    required this.currencyCode,
  });

  final ThemeSettings theme;
  final String languageCode;

  /// Currency is a ledger interpretation setting, not a presentation locale.
  /// It is persisted independently so a language change cannot reinterpret
  /// existing amounts with a different minor-unit scale.
  final String currencyCode;

  factory AppPreferences.defaults() => AppPreferences(
    theme: ThemeSettings.defaultSettings(),
    languageCode: 'en',
    currencyCode: 'USD',
  );

  AppPreferences copyWith({
    ThemeSettings? theme,
    String? languageCode,
    String? currencyCode,
  }) {
    return AppPreferences(
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  Map<String, Object> toJson() => {
    'theme': theme.toJson(),
    'languageCode': languageCode,
    'currencyCode': currencyCode,
  };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    final theme = json['theme'];
    final languageCode = json['languageCode'] is String
        ? json['languageCode'] as String
        : 'en';
    // v1 preference documents did not contain a currency. Preserve the
    // previous first-run behaviour once, then persist the separate value.
    final currencyCode = json['currencyCode'] is String
        ? json['currencyCode'] as String
        : getLocaleConfig(languageCode).currencyCode;
    return AppPreferences(
      theme: theme is Map<String, dynamic>
          ? ThemeSettings.fromJson(theme)
          : ThemeSettings.defaultSettings(),
      languageCode: languageCode,
      currencyCode: currencyCode,
    );
  }
}

/// Migrates the independent theme/locale preference keys exactly once and then
/// writes the complete preference state as a single document.
class AppPreferencesRepository {
  AppPreferencesRepository(this._preferences);

  static const storageKey = 'app_preferences_v1';
  static const _migrationKey = 'app_preferences_migrated_v1';
  static const _currencyMigrationKey = 'app_preferences_currency_migrated_v1';
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
      await _preferences.setBool(_currencyMigrationKey, true);
    }
    return saved;
  }

  Future<bool> migrateIfNeeded() async {
    if (_preferences.getBool(_migrationKey) == true &&
        _preferences.getBool(_currencyMigrationKey) == true) {
      return true;
    }
    // [load] retains an existing v1 document (including its theme) and fills
    // the new currency field from its original language exactly once.
    return save(load());
  }

  Future<void> clear() async {
    await _preferences.remove(storageKey);
    await _preferences.remove(_migrationKey);
    await _preferences.remove(_currencyMigrationKey);
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
      currencyCode: getLocaleConfig(
        _preferences.getString(_legacyLanguageKey) ?? 'en',
      ).currencyCode,
    );
  }
}
