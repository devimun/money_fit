
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/providers/database_provider.dart';
import 'package:money_fit/core/repositories/category_repository.dart';
import 'package:money_fit/core/repositories/expense_repository.dart';
import 'package:money_fit/core/repositories/user_repository.dart';

/// UserRepository 인스턴스를 제공하는 Provider입니다.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  return UserRepository(dbHelper: dbHelper);
});

/// CategoryRepository 인스턴스를 제공하는 Provider입니다.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  return CategoryRepository(dbHelper: dbHelper);
});

/// ExpenseRepository 인스턴스를 제공하는 Provider입니다.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dbHelper = ref.read(databaseHelperProvider);
  return ExpenseRepository(dbHelper: dbHelper);
});
