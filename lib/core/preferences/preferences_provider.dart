import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> updateLanguage(String languageCode) async {
    final updated = state.copyWith(languageCode: languageCode);
    if (await _repository.save(updated)) state = updated;
  }

  Future<void> clear() => _repository.clear();
}

final appPreferencesProvider =
    StateNotifierProvider<PreferencesController, AppPreferences>((ref) {
      return PreferencesController(ref.watch(appPreferencesRepositoryProvider));
    });
