import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/error/app_failure.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/expense_sqlite_fixture.dart';

void main() {
  group('ExpenseRepository failure contract', () {
    late Database database;
    late ExpenseRepository repository;

    setUp(() async {
      database = await ExpenseSqliteFixture.open();
      repository = ExpenseRepository(database: TestAppDatabase(database));
    });

    tearDown(() => database.close());

    test('an empty month is successful empty data', () async {
      final expenses = await repository.getExpensesByMonth('user-1', 2026, 7);

      expect(expenses, isEmpty);
    });

    test(
      'a database query failure is a StorageFailure, not empty data',
      () async {
        await database.execute('DROP TABLE expenses');

        await expectLater(
          repository.getExpensesByMonth('user-1', 2026, 7),
          throwsA(
            isA<StorageFailure>()
                .having((failure) => failure.cause, 'cause', isA<Object>())
                .having(
                  (failure) => failure.stackTrace,
                  'stackTrace',
                  isNotNull,
                ),
          ),
        );
      },
    );

    test('a malformed date row is a CorruptDataFailure', () async {
      await database.insert('expenses', {
        'id': 'malformed-date',
        'user_id': 'user-1',
        'name': 'Lunch',
        'amount': 12.5,
        'date': '2026-07-99',
        'category_id': 'food',
        'type': 'essential',
        'created_at': '2026-07-15T12:00:00.000',
        'updated_at': '2026-07-15T12:00:00.000',
      });

      await expectLater(
        repository.getExpensesByMonth('user-1', 2026, 7),
        throwsA(isA<CorruptDataFailure>()),
      );
    });

    test('an unknown expense type is a CorruptDataFailure', () async {
      await database.insert('expenses', {
        'id': 'unknown-type',
        'user_id': 'user-1',
        'name': 'Lunch',
        'amount': 12.5,
        'date': '2026-07-15',
        'category_id': 'food',
        'type': 'unexpected',
        'created_at': '2026-07-15T12:00:00.000',
        'updated_at': '2026-07-15T12:00:00.000',
      });

      await expectLater(
        repository.getExpensesByMonth('user-1', 2026, 7),
        throwsA(isA<CorruptDataFailure>()),
      );
    });

    test('zero-row update is a NotFoundFailure', () async {
      await expectLater(
        repository.updateExpense(ExpenseSqliteFixture.expense()),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('an update database exception is a StorageFailure', () async {
      await database.execute('DROP TABLE expenses');

      await expectLater(
        repository.updateExpense(ExpenseSqliteFixture.expense()),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('zero-row delete is a NotFoundFailure', () async {
      await expectLater(
        repository.deleteExpense('missing-expense', 'user-1'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('delete is scoped to the owning user', () async {
      final expense = ExpenseSqliteFixture.expense(userId: 'owner');
      await repository.createExpense(expense);

      await expectLater(
        repository.deleteExpense(expense.id, 'another-user'),
        throwsA(isA<NotFoundFailure>()),
      );

      expect(await database.query('expenses'), hasLength(1));
      await repository.deleteExpense(expense.id, 'owner');
      expect(await database.query('expenses'), isEmpty);
    });
  });
}
