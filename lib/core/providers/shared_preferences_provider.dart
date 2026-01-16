/// SharedPreferences Provider - 앱 전역에서 사용하는 SharedPreferences 인스턴스를 제공합니다.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 인스턴스를 제공하는 Provider
/// main.dart에서 overrideWithValue로 초기화해야 합니다.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});
