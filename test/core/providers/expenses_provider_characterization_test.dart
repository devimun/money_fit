import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/repositories/expense_repository.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/expense_sqlite_fixture.dart';

void main() {
  group('CoreExpensesNotifier current behavior', () {
    late Database database;
    late ExpenseRepository repository;

    setUp(() async {
      database = await ExpenseSqliteFixture.open();
      repository = ExpenseRepository.forTesting(databaseExecutor: database);
    });

    tearDown(() => database.close());

    test(
      'current_bug_R07_month_cache_omits_user_identity_remove_in_pr_1_3',
      () async {
        final firstUserExpense = _expense(id: 'first-user-expense');
        await repository.createExpense(firstUserExpense);
        final container = _container(repository);
        addTearDown(container.dispose);

        await container.read(coreExpensesProvider.future);
        final secondUserResult = await container
            .read(coreExpensesProvider.notifier)
            .loadMonthlyExpenses('second-user', 2024, 1);

        _expectExpenseIds(secondUserResult, {
          DateTime(2024, 1, 10): ['first-user-expense'],
        });
      },
    );

    test(
      'current_bug_R08_empty_month_refresh_keeps_previous_visible_month_remove_in_pr_1_3',
      () async {
        final januaryExpense = _expense(id: 'january-expense');
        await repository.createExpense(januaryExpense);
        final container = _container(repository);
        addTearDown(container.dispose);

        await container.read(coreExpensesProvider.future);
        final didRefresh = await container
            .read(coreExpensesProvider.notifier)
            .refreshExpensesFor(DateTime(2024, 2, 1));

        expect(didRefresh, isFalse);
        expect(container.read(dateManager), DateTime(2024, 1, 1));
        _expectExpenseIds(container.read(coreExpensesProvider).value!, {
          DateTime(2024, 1, 10): ['january-expense'],
        });
      },
    );

    test(
      'current_bug_R07_update_in_another_month_leaves_old_month_stale_remove_in_pr_1_3',
      () async {
        final original = _expense(id: 'moved-expense');
        final moved = original.copyWith(date: DateTime(2024, 2, 3));
        await repository.createExpense(original);
        final container = _container(repository);
        addTearDown(container.dispose);

        await container.read(coreExpensesProvider.future);
        await container
            .read(coreExpensesProvider.notifier)
            .updateExpense(moved);

        _expectExpenseIds(
          await repository.getExpensesByMonth('first-user', 2024, 2),
          {
            DateTime(2024, 2, 3): ['moved-expense'],
          },
        );
        _expectExpenseIds(container.read(coreExpensesProvider).value!, {
          DateTime(2024, 1, 10): ['moved-expense'],
          DateTime(2024, 2, 3): const <String>[],
        });
      },
    );

    test(
      'current_bug_R07_create_analytics_failure_leaves_saved_expense_out_of_state_remove_in_pr_1_3',
      () async {
        final created = _expense(id: 'created-expense');
        final container = _container(repository);
        addTearDown(container.dispose);

        await container.read(coreExpensesProvider.future);

        await expectLater(
          container.read(coreExpensesProvider.notifier).addExpense(created),
          throwsA(isA<Object>()),
        );

        _expectExpenseIds(
          await repository.getExpensesByMonth('first-user', 2024, 1),
          {
            DateTime(2024, 1, 10): ['created-expense'],
          },
        );
        expect(container.read(coreExpensesProvider).value, isEmpty);
      },
    );

    test(
      'current_bug_R07_delete_only_mutates_current_public_state_remove_in_pr_1_3',
      () async {
        final expense = _expense(id: 'deleted-expense');
        await repository.createExpense(expense);
        final container = _container(repository);
        addTearDown(container.dispose);

        await container.read(coreExpensesProvider.future);
        await container
            .read(coreExpensesProvider.notifier)
            .deleteExpense(expense);

        expect(
          await repository.getExpensesByMonth('first-user', 2024, 1),
          isEmpty,
        );
        expect(container.read(coreExpensesProvider).value, isEmpty);
      },
    );
  });
}

ProviderContainer _container(ExpenseRepository repository) {
  return ProviderContainer(
    overrides: [
      dateManager.overrideWith(_FixedDateManager.new),
      userSettingsProvider.overrideWith(_TestUserSettingsNotifier.new),
      expenseRepositoryProvider.overrideWith((ref) => repository),
    ],
  );
}

class _FixedDateManager extends DateManager {
  @override
  DateTime build() => DateTime(2024, 1, 1);
}

class _TestUserSettingsNotifier extends UserSettingsNotifier {
  @override
  Future<User> build() async {
    return User(
      id: 'first-user',
      budget: 0,
      budgetType: BudgetType.daily,
      isDarkMode: false,
      notificationsEnabled: false,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
  }
}

Expense _expense({required String id}) {
  return ExpenseSqliteFixture.expense(
    id: id,
    userId: 'first-user',
    name: 'Coffee',
    amount: 4,
    date: DateTime(2024, 1, 10),
    categoryId: 'food',
    type: ExpenseType.essential,
    createdAt: DateTime(2024, 1, 10, 9),
    updatedAt: DateTime(2024, 1, 10, 9),
  );
}

void _expectExpenseIds(
  Map<DateTime, List<Expense>> actual,
  Map<DateTime, List<String>> expected,
) {
  expect(
    actual.map(
      (date, expenses) =>
          MapEntry(date, expenses.map((expense) => expense.id).toList()),
    ),
    expected,
  );
}
