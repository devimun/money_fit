// 지원되는 언어/화폐 조합을 정의하는 설정 클래스입니다.
// 14개 언어/화폐 조합을 제공하며, 로케일 관련 유틸리티 함수를 포함합니다.
import 'package:flutter/material.dart';

/// 언어/화폐 조합을 정의하는 불변 설정 클래스
@immutable
class LocaleConfig {
  final String languageCode;
  final String displayName;
  final String currencySymbol;
  final String currencyCode;
  final int decimalDigits;

  const LocaleConfig({
    required this.languageCode,
    required this.displayName,
    required this.currencySymbol,
    required this.currencyCode,
    required this.decimalDigits,
  });

  /// Locale 객체 반환
  Locale get locale => Locale(languageCode);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocaleConfig &&
        other.languageCode == languageCode &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => languageCode.hashCode ^ currencyCode.hashCode;

  @override
  String toString() => 'LocaleConfig($languageCode, $currencyCode)';
}

/// 지원되는 14개 언어/화폐 조합 목록
const List<LocaleConfig> supportedLocaleConfigs = [
  // 아시아
  LocaleConfig(
    languageCode: 'ko',
    displayName: '한국어',
    currencySymbol: '₩',
    currencyCode: 'KRW',
    decimalDigits: 0,
  ),
  LocaleConfig(
    languageCode: 'en',
    displayName: 'English',
    currencySymbol: '\$',
    currencyCode: 'USD',
    decimalDigits: 2,
  ),
  // 유럽 - 1차 (스페인어, 폴란드어)
  LocaleConfig(
    languageCode: 'es',
    displayName: 'Español',
    currencySymbol: '€',
    currencyCode: 'EUR',
    decimalDigits: 2,
  ),
  LocaleConfig(
    languageCode: 'pl',
    displayName: 'Polski',
    currencySymbol: 'zł',
    currencyCode: 'PLN',
    decimalDigits: 2,
  ),
  // 유럽 - 2차 (우크라이나어, 체코어)
  LocaleConfig(
    languageCode: 'uk',
    displayName: 'Українська',
    currencySymbol: '₴',
    currencyCode: 'UAH',
    decimalDigits: 2,
  ),
  LocaleConfig(
    languageCode: 'cs',
    displayName: 'Čeština',
    currencySymbol: 'Kč',
    currencyCode: 'CZK',
    decimalDigits: 2,
  ),
  // 유럽 - 3차 (독일어, 이탈리아어, 루마니아어, 슬로바키아어, 불가리아어)
  LocaleConfig(
    languageCode: 'de',
    displayName: 'Deutsch',
    currencySymbol: '€',
    currencyCode: 'EUR',
    decimalDigits: 2,
  ),
  LocaleConfig(
    languageCode: 'it',
    displayName: 'Italiano',
    currencySymbol: '€',
    currencyCode: 'EUR',
    decimalDigits: 2,
  ),
  LocaleConfig(
    languageCode: 'ro',
    displayName: 'Română',
    currencySymbol: 'lei',
    currencyCode: 'RON',
    decimalDigits: 2,
  ),
  LocaleConfig(
    languageCode: 'sk',
    displayName: 'Slovenčina',
    currencySymbol: '€',
    currencyCode: 'EUR',
    decimalDigits: 2,
  ),
  LocaleConfig(
    languageCode: 'bg',
    displayName: 'Български',
    currencySymbol: 'лв',
    currencyCode: 'BGN',
    decimalDigits: 2,
  ),
  // 동남아시아
  LocaleConfig(
    languageCode: 'id',
    displayName: 'Bahasa Indonesia',
    currencySymbol: 'Rp',
    currencyCode: 'IDR',
    decimalDigits: 0,
  ),
  LocaleConfig(
    languageCode: 'ms',
    displayName: 'Bahasa Melayu',
    currencySymbol: 'RM',
    currencyCode: 'MYR',
    decimalDigits: 2,
  ),
  LocaleConfig(
    languageCode: 'fil',
    displayName: 'Filipino',
    currencySymbol: '₱',
    currencyCode: 'PHP',
    decimalDigits: 2,
  ),
];

/// 필수 지원 언어 코드 목록
const List<String> requiredLanguageCodes = [
  'ko', 'en', 'es', 'pl', 'uk', 'cs', 'de', 'it', 'ro', 'sk', 'bg', 'id', 'ms', 'fil',
];

/// 언어 코드로 LocaleConfig 조회
/// 지원되지 않는 언어 코드인 경우 영어(en) 반환
LocaleConfig getLocaleConfig(String languageCode) {
  return supportedLocaleConfigs.firstWhere(
    (config) => config.languageCode == languageCode,
    orElse: () => supportedLocaleConfigs.firstWhere(
      (config) => config.languageCode == 'en',
    ),
  );
}

/// 언어 코드가 지원되는지 확인
bool isLanguageSupported(String languageCode) {
  return supportedLocaleConfigs.any(
    (config) => config.languageCode == languageCode,
  );
}

/// 지원되는 Locale 목록 반환 (MaterialApp에서 사용)
List<Locale> get supportedLocales {
  return supportedLocaleConfigs.map((config) => config.locale).toList();
}

/// 기본 로케일 (영어)
const LocaleConfig defaultLocaleConfig = LocaleConfig(
  languageCode: 'en',
  displayName: 'English',
  currencySymbol: '\$',
  currencyCode: 'USD',
  decimalDigits: 2,
);
