// LocaleConfig 클래스의 지원 로케일 목록 완전성을 검증하는 테스트입니다.
// Property 4: 지원 로케일 목록 완전성
// Validates: Requirements 4.3

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/locale_config.dart';

void main() {
  group('Property 4: 지원 로케일 목록 완전성', () {
    // 필수 지원 언어 코드 목록 (Requirements 4.3)
    const expectedLanguageCodes = [
      'ko', 'en', 'es', 'pl', 'uk', 'cs', 
      'de', 'it', 'ro', 'sk', 'bg', 
      'id', 'ms', 'fil',
    ];

    test('모든 필수 언어 코드가 supportedLocaleConfigs에 존재해야 한다', () {
      // Property: For any required language code, 
      // supportedLocaleConfigs should contain a LocaleConfig with that code
      for (final code in expectedLanguageCodes) {
        final hasLocale = supportedLocaleConfigs.any(
          (config) => config.languageCode == code,
        );
        expect(
          hasLocale, 
          isTrue, 
          reason: '언어 코드 "$code"가 supportedLocaleConfigs에 없습니다',
        );
      }
    });

    test('supportedLocaleConfigs는 정확히 14개의 로케일을 포함해야 한다', () {
      expect(supportedLocaleConfigs.length, equals(14));
    });

    test('requiredLanguageCodes와 supportedLocaleConfigs가 일치해야 한다', () {
      final configCodes = supportedLocaleConfigs
          .map((config) => config.languageCode)
          .toSet();
      final requiredCodes = requiredLanguageCodes.toSet();
      
      expect(configCodes, equals(requiredCodes));
    });

    test('각 LocaleConfig는 유효한 화폐 정보를 가져야 한다', () {
      for (final config in supportedLocaleConfigs) {
        expect(config.currencyCode.isNotEmpty, isTrue,
            reason: '${config.languageCode}의 currencyCode가 비어있습니다');
        expect(config.currencySymbol.isNotEmpty, isTrue,
            reason: '${config.languageCode}의 currencySymbol이 비어있습니다');
        expect(config.decimalDigits >= 0, isTrue,
            reason: '${config.languageCode}의 decimalDigits가 음수입니다');
      }
    });

    test('getLocaleConfig는 지원되는 언어 코드에 대해 올바른 설정을 반환해야 한다', () {
      for (final code in expectedLanguageCodes) {
        final config = getLocaleConfig(code);
        expect(config.languageCode, equals(code));
      }
    });

    test('getLocaleConfig는 지원되지 않는 언어 코드에 대해 영어를 반환해야 한다', () {
      // Property 7: 지원되지 않는 로케일 폴백
      final unsupportedCodes = ['fr', 'ja', 'zh', 'ar', 'xyz', ''];
      for (final code in unsupportedCodes) {
        final config = getLocaleConfig(code);
        expect(config.languageCode, equals('en'),
            reason: '지원되지 않는 코드 "$code"에 대해 영어로 폴백되지 않았습니다');
      }
    });

    test('isLanguageSupported는 지원 여부를 정확히 반환해야 한다', () {
      for (final code in expectedLanguageCodes) {
        expect(isLanguageSupported(code), isTrue);
      }
      expect(isLanguageSupported('fr'), isFalse);
      expect(isLanguageSupported('xyz'), isFalse);
    });

    test('supportedLocales getter는 올바른 Locale 목록을 반환해야 한다', () {
      final locales = supportedLocales;
      expect(locales.length, equals(14));
      
      for (final code in expectedLanguageCodes) {
        final hasLocale = locales.any((l) => l.languageCode == code);
        expect(hasLocale, isTrue);
      }
    });
  });
}
