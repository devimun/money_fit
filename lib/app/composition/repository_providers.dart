import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/database_providers.dart';
import 'package:money_fit/features/ledger/data/legacy/category_repository.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_repository.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_legacy_category_repository.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_legacy_expense_repository.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:money_fit/core/repositories/sqlite_v6_user_repository.dart';
import 'package:money_fit/features/session/data/sqlite_v6_local_owner_repository.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';

/// UserRepository 인스턴스를 제공하는 Provider입니다.
/// Expose the contract so application controllers can be tested without a
/// sqflite database and do not take a dependency on the legacy implementation.
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return SqliteV6UserRepository(database: ref.read(appDatabaseProvider));
});

/// The v6 runtime owns a stable, local ledger identifier independently from
/// the historical user compatibility projection.
final localOwnerRepositoryProvider = Provider<LocalOwnerRepository>((ref) {
  return SqliteV6LocalOwnerRepository(ref.read(appDatabaseProvider));
});

/// CategoryRepository 인스턴스를 제공하는 Provider입니다.
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  return SqliteV6LegacyCategoryRepository(ref.read(appDatabaseProvider));
});

/// ExpenseRepository 인스턴스를 제공하는 Provider입니다.
final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) {
  return SqliteV6LegacyExpenseRepository(ref.read(appDatabaseProvider));
});
