import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/repositories/expense_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../../support/expense_sqlite_fixture.dart';

void main() {
  group('ExpenseRepository current behavior characterization', () {
    late Database database;
    late ExpenseRepository repository;

    setUp(() async {
      database = await ExpenseSqliteFixture.open();
      repository = ExpenseRepository.forTesting(databaseExecutor: database);
    });

    tearDown(() => database.close());

    test(
      'current_bug_r08_empty_month_is_indistinguishable_from_query_failure_remove_in_pr_1_3',
      () async {
        final expenses = await repository.getExpensesByMonth('user-1', 2026, 7);

        expect(expenses, isEmpty);
      },
    );

    test(
      'current_bug_r03_query_failure_becomes_empty_month_remove_in_pr_1_1',
      () async {
        await database.execute('DROP TABLE expenses');

        final expenses = await repository.getExpensesByMonth('user-1', 2026, 7);

        expect(expenses, isEmpty);
      },
    );

    test(
      'current_bug_r03_malformed_date_row_becomes_empty_month_remove_in_pr_1_1',
      () async {
        await database.insert('expenses', {
          'id': 'malformed-date',
          'user_id': 'user-1',
          'name': 'Lunch',
          'amount': 12.5,
          'date': 'not-a-date',
          'category_id': 'food',
          'type': 'essential',
          'created_at': '2026-07-15T12:00:00.000',
          'updated_at': '2026-07-15T12:00:00.000',
        });

        final expenses = await repository.getExpensesByMonth('user-1', 2026, 7);

        expect(expenses, isEmpty);
      },
    );

    test(
      'current_bug_r03_unknown_type_becomes_sentinel_remove_in_pr_1_1',
      () async {
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

        final expenses = await repository.getExpensesByMonth('user-1', 2026, 7);

        expect(expenses.values.single.single.type, ExpenseType.n);
      },
    );

    test('current_bug_r04_zero_row_update_succeeds_remove_in_pr_1_1', () async {
      await repository.updateExpense(ExpenseSqliteFixture.expense());

      expect(await database.query('expenses'), isEmpty);
    });

    test(
      'current_bug_r04_update_database_exception_is_swallowed_remove_in_pr_1_1',
      () async {
        await database.execute('DROP TABLE expenses');

        await expectLater(
          repository.updateExpense(ExpenseSqliteFixture.expense()),
          completes,
        );
      },
    );
  });
}
