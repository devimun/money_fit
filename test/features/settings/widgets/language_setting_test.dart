// Tests for LanguageSetting and LanguageCurrencySelector widgets
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/settings/widgets/language_setting.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('LanguageSetting Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          home: const Scaffold(
            body: LanguageSetting(),
          ),
        ),
      );
    }

    testWidgets('displays language setting with icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(LanguageSetting), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('displays language setting title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Language & Currency'), findsOneWidget);
    });
  });

  group('LocaleConfig Unit Tests', () {
    test('supportedLocaleConfigs contains 14 languages', () {
      expect(supportedLocaleConfigs.length, 14);
    });

    test('all required language codes are supported', () {
      for (final code in requiredLanguageCodes) {
        expect(isLanguageSupported(code), isTrue,
            reason: 'Language $code should be supported');
      }
    });

    test('getLocaleConfig returns correct config for valid code', () {
      final config = getLocaleConfig('ko');
      expect(config.languageCode, 'ko');
      expect(config.currencyCode, 'KRW');
      expect(config.currencySymbol, '₩');
    });

    test('getLocaleConfig returns English for invalid code', () {
      final config = getLocaleConfig('invalid');
      expect(config.languageCode, 'en');
      expect(config.currencyCode, 'USD');
    });

    test('defaultLocaleConfig is English', () {
      expect(defaultLocaleConfig.languageCode, 'en');
      expect(defaultLocaleConfig.currencyCode, 'USD');
      expect(defaultLocaleConfig.currencySymbol, '\$');
    });

    test('LocaleConfig equality works correctly', () {
      final config1 = getLocaleConfig('ko');
      final config2 = getLocaleConfig('ko');
      final config3 = getLocaleConfig('en');

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('supportedLocales returns correct Locale list', () {
      final locales = supportedLocales;
      expect(locales.length, 14);
      expect(locales.any((l) => l.languageCode == 'ko'), isTrue);
      expect(locales.any((l) => l.languageCode == 'en'), isTrue);
    });
  });
}
