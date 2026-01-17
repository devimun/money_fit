// ThemeRepository의 Riverpod Provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_repository.dart';

/// SharedPreferences 인스턴스를 제공하는 Provider
///
/// 앱 시작 시 main()에서 override되어야 합니다.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

/// ThemeRepository 인스턴스를 제공하는 Provider
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeRepository(prefs);
});
