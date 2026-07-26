import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('migrates legacy theme and locale keys into one document', () async {
    SharedPreferences.setMockInitialValues({
      'theme_settings': jsonEncode({
        'isDarkMode': true,
        'colorSeedValue': 0xFF123456,
        'favoriteColors': [0xFF654321],
        'fontSizeScale': 1.15,
      }),
      'locale_language_code': 'ko',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = AppPreferencesRepository(preferences);

    expect(await repository.migrateIfNeeded(), isTrue);
    final value = repository.load();

    expect(value.languageCode, 'ko');
    expect(value.theme.isDarkMode, isTrue);
    expect(value.theme.fontSizeScale, 1.15);
    expect(
      preferences.getString(AppPreferencesRepository.storageKey),
      isNotNull,
    );
  });
}
