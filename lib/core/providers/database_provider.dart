
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/database/database_helper.dart';

/// DatabaseHelper 인스턴스를 제공하는 Provider입니다.
/// 앱의 다른 부분에서 데이터베이스에 접근해야 할 때 이 Provider를 사용합니다.
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});
