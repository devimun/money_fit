import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/preferences/app_preferences.dart';
import 'package:money_fit/core/preferences/preferences_provider.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    expect(
      jsonDecode(preferences.getString(AppPreferencesRepository.storageKey)!),
      isNot(contains('currencyCode')),
    );
  });

  test('changing language drops a legacy currency preference', () async {
    SharedPreferences.setMockInitialValues({
      AppPreferencesRepository.storageKey: jsonEncode({
        'theme': {},
        'languageCode': 'ko',
        'currencyCode': 'KRW',
      }),
    });
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    await container.read(localeProvider.notifier).setLocale('en');

    expect(container.read(currentLocaleProvider).languageCode, 'en');
    expect(
      container.read(appPreferencesProvider).toJson(),
      isNot(contains('currencyCode')),
    );
  });

  test(
    'rewrites previously migrated documents without a currency field',
    () async {
      SharedPreferences.setMockInitialValues({
        AppPreferencesRepository.storageKey: jsonEncode({
          'theme': {},
          'languageCode': 'ko',
          'currencyCode': 'KRW',
        }),
        'app_preferences_migrated_v1': true,
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = AppPreferencesRepository(preferences);

      expect(await repository.migrateIfNeeded(), isTrue);
      expect(
        jsonDecode(preferences.getString(AppPreferencesRepository.storageKey)!),
        isNot(contains('currencyCode')),
      );
    },
  );
}
