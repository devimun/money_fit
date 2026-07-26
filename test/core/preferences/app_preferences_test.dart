import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/preferences/app_preferences.dart';
import 'package:money_fit/core/preferences/preferences_provider.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/foundation/money.dart';
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
    expect(value.currencyCode, 'KRW');
    expect(value.theme.isDarkMode, isTrue);
    expect(value.theme.fontSizeScale, 1.15);
    expect(
      preferences.getString(AppPreferencesRepository.storageKey),
      isNotNull,
    );
    expect(
      jsonDecode(preferences.getString(AppPreferencesRepository.storageKey)!),
      containsPair('currencyCode', 'KRW'),
    );
  });

  test(
    'changing language preserves the persisted ledger currency and scale',
    () async {
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

      expect(container.read(currencySymbolProvider), '₩');
      final before = Money.parse(
        '1200.5',
        container.read(ledgerCurrencyProvider),
      );
      expect(before.minorUnits, 1201);

      await container.read(localeProvider.notifier).setLocale('en');

      expect(container.read(currentLocaleProvider).languageCode, 'en');
      expect(container.read(currencySymbolProvider), '₩');
      final after = Money.parse(
        '1200.5',
        container.read(ledgerCurrencyProvider),
      );
      expect(after, before);
      expect(container.read(appPreferencesProvider).currencyCode, 'KRW');
    },
  );
}
