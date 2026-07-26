/// Locale Provider - 앱의 언어/화폐 설정을 관리합니다.
/// LocaleConfig를 기반으로 사용자가 선택한 로케일 상태를 제공합니다.
library;

import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/preferences/app_preferences.dart';
import 'package:money_fit/core/preferences/preferences_provider.dart';

/// LocaleNotifier - 언어/화폐 설정 상태 관리
class LocaleNotifier extends StateNotifier<LocaleConfig> {
  LocaleNotifier(this._ref)
    : super(_localeFor(_ref.read(appPreferencesProvider).languageCode)) {
    _ref.listen<AppPreferences>(appPreferencesProvider, (_, next) {
      state = _localeFor(next.languageCode);
    });
  }

  final Ref _ref;

  /// 로케일 변경
  Future<void> setLocale(String languageCode) async {
    if (!isLanguageSupported(languageCode)) {
      return;
    }

    await _ref
        .read(appPreferencesProvider.notifier)
        .updateLanguage(languageCode);
  }

  /// LocaleConfig로 직접 로케일 변경
  Future<void> setLocaleConfig(LocaleConfig config) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .updateLanguage(config.languageCode);
  }
}

/// LocaleProvider - 현재 LocaleConfig 상태 제공
/// theme_provider.dart의 sharedPreferencesProvider를 사용
final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleConfig>((
  ref,
) {
  return LocaleNotifier(ref);
});

LocaleConfig _localeFor(String languageCode) =>
    isLanguageSupported(languageCode)
    ? getLocaleConfig(languageCode)
    : defaultLocaleConfig;

/// 현재 Locale 객체 제공 (MaterialApp.locale에 사용)
final currentLocaleProvider = Provider<Locale>((ref) {
  final localeConfig = ref.watch(localeProvider);
  return localeConfig.locale;
});
