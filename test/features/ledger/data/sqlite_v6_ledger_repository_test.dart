import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/migrations/sqlite_v6_migration.dart';
import 'package:money_fit/core/foundation/local_date.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/core/foundation/year_month.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_ledger_repository.dart';
import 'package:money_fit/features/ledger/domain/category.dart';
import 'package:money_fit/features/ledger/domain/expense_entry.dart';
import 'package:money_fit/features/ledger/domain/ledger_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../support/expense_sqlite_fixture.dart';

void main() {
  const currency = LedgerCurrency(code: 'KRW', decimalDigits: 0);
  late Database database;
  late SqliteV6LedgerRepository repository;

  setUp(() async {
    sqfliteFfiInit();
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await database.execute('PRAGMA foreign_keys = ON');
    await SqliteV6Migration.createSchema(database);
    await _seed(database);
    repository = SqliteV6LedgerRepository(
      database: TestAppDatabase(database),
      currency: currency,
    );
  });

  tearDown(() => database.close());

  test('reads an owner-scoped month with exact minor units', () async {
    await database.insert('expenses', _row(id: 'alice-july', ownerId: 'alice'));
    await database.insert(
      'expenses',
      _row(id: 'bob-july', ownerId: 'bob', categoryId: 'bob-food'),
    );
    await database.insert(
      'expenses',
      _row(id: 'alice-june', ownerId: 'alice', occurredOn: '2026-06-30'),
    );

    final ledger = await repository.readMonth(
      const ExpenseMonthKey(ownerId: 'alice', month: YearMonth(2026, 7)),
    );

    expect(ledger.entries, hasLength(1));
    expect(ledger.entries.single.id, 'alice-july');
    expect(
      ledger.entries.single.amount,
      const Money(minorUnits: 1250, currency: currency),
    );
    expect(ledger.entries.single.occurredOn, const LocalDate(2026, 7, 15));
  });

  test(
    'only exposes active categories owned by the requested ledger',
    () async {
      await database.insert('categories', {
        'id': 'alice-custom',
        'owner_id': 'alice',
        'stable_code': null,
        'display_name': 'Coffee',
        'spending_kind': 'discretionary',
        'is_built_in': 0,
        'archived_at': null,
      });
      await database.insert('categories', {
        'id': 'alice-archived',
        'owner_id': 'alice',
        'stable_code': null,
        'display_name': 'Old',
        'spending_kind': 'essential',
        'is_built_in': 0,
        'archived_at': '2026-07-15T10:00:00.000Z',
      });

      final categories = await repository.readCategories('alice');

      expect(categories.map((category) => category.id), [
        'alice-custom',
        'alice-food',
      ]);
      expect(categories.first, isA<LedgerCategory>());
      expect(categories.first.name, 'Coffee');
      expect(categories.first.kind, SpendingKind.discretionary);
      expect(categories.last.name, 'food');
      expect(categories.last.isBuiltIn, isTrue);
    },
  );

  test(
    'writes exact minor amounts and rejects cross-owner categories',
    () async {
      final expense = ExpenseEntry(
        id: 'new-expense',
        ownerId: 'alice',
        name: 'Dinner',
        amount: Money(minorUnits: 9876, currency: currency),
        occurredOn: LocalDate(2026, 7, 20),
        categoryId: 'alice-food',
        createdAt: DateTime.utc(2026, 7, 20, 8),
        updatedAt: DateTime.utc(2026, 7, 20, 8),
      );

      await repository.insertExpense(expense);

      expect((await database.query('expenses')).single['amount_minor'], 9876);
      expect(
        (await repository.findExpense('new-expense', 'alice'))?.name,
        'Dinner',
      );
      await expectLater(
        repository.insertExpense(
          ExpenseEntry(
            id: 'cross-owner',
            ownerId: 'alice',
            name: 'Invalid',
            amount: Money(minorUnits: 1, currency: currency),
            occurredOn: LocalDate(2026, 7, 20),
            categoryId: 'bob-food',
            createdAt: DateTime.utc(2026, 7, 20, 8),
            updatedAt: DateTime.utc(2026, 7, 20, 8),
          ),
        ),
        throwsStateError,
      );
    },
  );

  test('replaces and deletes strictly within the owner scope', () async {
    await database.insert('expenses', _row(id: 'shared', ownerId: 'alice'));
    await database.insert(
      'expenses',
      _row(id: 'bob-expense', ownerId: 'bob', categoryId: 'bob-food'),
    );
    final replacement = ExpenseEntry(
      id: 'shared',
      ownerId: 'alice',
      name: 'Updated',
      amount: Money(minorUnits: 3000, currency: currency),
      occurredOn: LocalDate(2026, 7, 21),
      categoryId: 'alice-food',
      createdAt: DateTime.utc(2026, 7, 15, 8),
      updatedAt: DateTime.utc(2026, 7, 21, 8),
    );

    await repository.replaceExpense(replacement);
    await repository.deleteExpense('shared', 'bob');

    expect(
      (await repository.findExpense('shared', 'alice'))?.amount.minorUnits,
      3000,
    );
    expect(await repository.findExpense('bob-expense', 'bob'), isNotNull);
    await repository.deleteExpense('shared', 'alice');
    expect(await repository.findExpense('shared', 'alice'), isNull);
  });
}

Future<void> _seed(Database database) async {
  for (final owner in ['alice', 'bob']) {
    await database.insert('local_users', {
      'id': owner,
      'remote_user_id': null,
      'created_at': '2026-07-01T00:00:00.000Z',
    });
    await database.insert('ledger_settings', {
      'owner_id': owner,
      'currency_code': 'KRW',
    });
    await database.insert('categories', {
      'id': '$owner-food',
      'owner_id': owner,
      'stable_code': 'food',
      'display_name': null,
      'spending_kind': 'essential',
      'is_built_in': 1,
      'archived_at': null,
    });
  }
}

Map<String, Object?> _row({
  required String id,
  required String ownerId,
  String? categoryId,
  String occurredOn = '2026-07-15',
}) => {
  'id': id,
  'owner_id': ownerId,
  'title': 'Lunch',
  'amount_minor': 1250,
  'occurred_on': occurredOn,
  'category_id': categoryId ?? '$ownerId-food',
  'created_at': '2026-07-15T08:00:00.000Z',
  'updated_at': '2026-07-15T08:00:00.000Z',
};
