import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/database_providers.dart';
import 'package:money_fit/features/ledger/data/legacy/category_repository.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_repository.dart';
import 'package:money_fit/core/repositories/user_repository.dart';

/// UserRepository 인스턴스를 제공하는 Provider입니다.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(database: ref.read(appDatabaseProvider));
});

/// CategoryRepository 인스턴스를 제공하는 Provider입니다.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(database: ref.read(appDatabaseProvider));
});

/// ExpenseRepository 인스턴스를 제공하는 Provider입니다.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(database: ref.read(appDatabaseProvider));
});
