import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/migrations/sqlite_v6_migration.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/core/foundation/year_month.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/repositories/sqlite_v6_user_repository.dart';
import 'package:money_fit/features/budget/data/sqlite_v6_current_budget_repository.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_ledger_repository.dart';
import 'package:money_fit/features/ledger/domain/ledger_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/expense_sqlite_fixture.dart';
import '../../support/legacy_database_fixture.dart';

void main() {
  const usd = LedgerCurrency(code: 'USD', decimalDigits: 2);

  test('fresh v6 schema is usable through user and budget adapters', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await database.execute('PRAGMA foreign_keys = ON');
    await SqliteV6Migration.createSchema(database);
    await database.setVersion(SqliteV6Migration.version);
    final appDatabase = TestAppDatabase(database);
    final users = SqliteV6UserRepository(database: appDatabase);
    final budgets = SqliteV6CurrentBudgetRepository(
      appDatabase,
      now: () => DateTime.utc(2026, 7, 26),
    );

    await users.createUser(
      User(
        id: 'fresh-owner',
        budget: 0,
        budgetType: BudgetType.daily,
        isDarkMode: false,
        notificationsEnabled: false,
        createdAt: DateTime.utc(2026, 7, 26),
        updatedAt: DateTime.utc(2026, 7, 26),
      ),
    );
    await budgets.save(
      'fresh-owner',
      const CurrentBudget(amount: 42.5, type: BudgetType.daily),
    );

    expect((await users.getUser('fresh-owner'))?.budget, 42.5);
    expect((await budgets.read('fresh-owner'))?.amount, 42.5);
    expect(await database.getVersion(), SqliteV6Migration.version);
  });

  test(
    'a v5 upgrade is read by the v6 user, budget, and ledger adapters',
    () async {
      final database = await LegacyDatabaseFixture.openUpgradedToV5(
        sourceVersion: 5,
      );
      addTearDown(database.close);
      await SqliteV6Migration.migrate(database);
      await database.setVersion(SqliteV6Migration.version);
      final appDatabase = TestAppDatabase(database);

      final user = await SqliteV6UserRepository(
        database: appDatabase,
      ).getUser('history-owner');
      final budget = await SqliteV6CurrentBudgetRepository(
        appDatabase,
      ).read('history-owner');
      final ledger = await SqliteV6LedgerRepository(database: appDatabase)
          .readMonth(
            const ExpenseMonthKey(
              ownerId: 'history-owner',
              month: YearMonth(2026, 7),
            ),
          );

      expect(user?.budget, 12.34);
      expect(budget?.amount, 12.34);
      expect(
        ledger.entries.single.amount,
        const Money(minorUnits: 1234, currency: usd),
      );
      expect(await database.getVersion(), SqliteV6Migration.version);
    },
  );
}
