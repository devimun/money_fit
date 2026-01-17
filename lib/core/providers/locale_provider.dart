/// Locale Provider - 앱의 언어/화폐 설정을 관리합니다.
/// LocaleConfig를 기반으로 사용자가 선택한 로케일 상태를 제공합니다.
library;

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';

/// SharedPreferences 키
const String _languageCodeKey = 'locale_language_code';
const String _currencyCodeKey = 'locale_currency_code';
const String _isFirstLaunchKey = 'locale_is_first_launch';

/// LocaleNotifier - 언어/화폐 설정 상태 관리
class LocaleNotifier extends StateNotifier<LocaleConfig> {
  LocaleNotifier(this._ref) : super(defaultLocaleConfig) {
    _initialize();
  }

  final Ref _ref;

  /// 초기화: 저장된 설정 로드 또는 기기 언어 감지
  void _initialize() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;

    if (isFirstLaunch) {
      // 첫 실행: 기기 언어 감지
      _detectAndSetDeviceLocale();
      prefs.setBool(_isFirstLaunchKey, false);
    } else {
      // 이후 실행: 저장된 설정 로드
      _loadSavedLocale();
    }
  }

  /// 기기 언어를 감지하여 지원되는 언어면 적용, 아니면 영어/USD
  void _detectAndSetDeviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    final languageCode = deviceLocale.languageCode;

    if (isLanguageSupported(languageCode)) {
      state = getLocaleConfig(languageCode);
      _saveLocale(state);
    } else {
      // 지원되지 않는 언어 → 영어/USD
      state = defaultLocaleConfig;
      _saveLocale(state);
    }
  }

  /// SharedPreferences에서 저장된 로케일 로드
  void _loadSavedLocale() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final savedLanguageCode = prefs.getString(_languageCodeKey);

    if (savedLanguageCode != null && isLanguageSupported(savedLanguageCode)) {
      state = getLocaleConfig(savedLanguageCode);
    } else {
      state = defaultLocaleConfig;
    }
  }

  /// 로케일을 SharedPreferences에 저장
  Future<void> _saveLocale(LocaleConfig config) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_languageCodeKey, config.languageCode);
    await prefs.setString(_currencyCodeKey, config.currencyCode);
  }

  /// 로케일 변경
  Future<void> setLocale(String languageCode) async {
    if (!isLanguageSupported(languageCode)) {
      return;
    }

    final newConfig = getLocaleConfig(languageCode);
    state = newConfig;
    await _saveLocale(newConfig);
  }

  /// LocaleConfig로 직접 로케일 변경
  Future<void> setLocaleConfig(LocaleConfig config) async {
    state = config;
    await _saveLocale(config);
  }
}

/// LocaleProvider - 현재 LocaleConfig 상태 제공
/// theme_provider.dart의 sharedPreferencesProvider를 사용
final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleConfig>((
  ref,
) {
  return LocaleNotifier(ref);
});

/// 현재 Locale 객체 제공 (MaterialApp.locale에 사용)
final currentLocaleProvider = Provider<Locale>((ref) {
  final localeConfig = ref.watch(localeProvider);
  return localeConfig.locale;
});

/// 현재 화폐 심볼 제공
final currencySymbolProvider = Provider<String>((ref) {
  final localeConfig = ref.watch(localeProvider);
  return localeConfig.currencySymbol;
});

/// 현재 화폐 소수점 자릿수 제공
final currencyDecimalDigitsProvider = Provider<int>((ref) {
  final localeConfig = ref.watch(localeProvider);
  return localeConfig.decimalDigits;
});
