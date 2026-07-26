import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/database_providers.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_ledger_repository.dart';
import 'package:money_fit/features/ledger/domain/ledger_repository.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return SqliteV6LedgerRepository(
    database: ref.watch(appDatabaseProvider),
    currency: ref.watch(ledgerCurrencyProvider),
  );
});

final monthlyLedgerProvider =
    FutureProvider.family<MonthlyLedger, ExpenseMonthKey>((ref, key) {
      return ref.watch(ledgerRepositoryProvider).readMonth(key);
    });

final ledgerCategoriesProvider = FutureProvider.family((ref, String ownerId) {
  return ref.watch(ledgerRepositoryProvider).readCategories(ownerId);
});
