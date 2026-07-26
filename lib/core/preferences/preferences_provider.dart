import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:money_fit/core/models/theme_settings.dart';
import 'package:money_fit/core/preferences/app_preferences.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>(
  (ref) => AppPreferencesRepository(ref.watch(sharedPreferencesProvider)),
);

class PreferencesController extends StateNotifier<AppPreferences> {
  PreferencesController(this._repository) : super(_repository.load()) {
    _repository.migrateIfNeeded();
  }

  final AppPreferencesRepository _repository;

  Future<void> updateTheme(ThemeSettings theme) async {
    final updated = state.copyWith(theme: theme);
    if (await _repository.save(updated)) state = updated;
  }

  /// Theme is persisted as one preference value.  Keep all mutations here so
  /// presentation providers can derive their values directly from [state].
  Future<void> setThemeSeedColor(Color color, List<Color> favoriteColors) {
    return updateTheme(
      state.theme.copyWith(
        colorSeedValue: color.toARGB32(),
        favoriteColors: favoriteColors
            .map((value) => value.toARGB32())
            .toList(),
      ),
    );
  }

  Future<void> setDarkMode(bool isDarkMode) {
    return updateTheme(state.theme.copyWith(isDarkMode: isDarkMode));
  }

  Future<void> setFontSizeOption(FontSizeOption option) {
    return updateTheme(state.theme.copyWith(fontSizeScale: option.scale));
  }

  Future<void> updateLanguage(String languageCode) async {
    final updated = state.copyWith(languageCode: languageCode);
    if (await _repository.save(updated)) state = updated;
  }

  /// Changes the ledger currency explicitly. Language selection must use
  /// [updateLanguage] only, otherwise existing decimal amounts could be
  /// reinterpreted with a different scale.
  Future<void> updateLedgerCurrency(String currencyCode) async {
    final updated = state.copyWith(currencyCode: currencyCode.toUpperCase());
    if (await _repository.save(updated)) state = updated;
  }

  Future<void> clear() => _repository.clear();
}

final appPreferencesProvider =
    StateNotifierProvider<PreferencesController, AppPreferences>((ref) {
      return PreferencesController(ref.watch(appPreferencesRepositoryProvider));
    });
