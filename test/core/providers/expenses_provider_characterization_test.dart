import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/repositories/expense_repository.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/expense_sqlite_fixture.dart';

void main() {
  group('CoreExpensesNotifier month identity and invalidation', () {
    late Database database;
    late ExpenseRepository repository;

    setUp(() async {
      database = await ExpenseSqliteFixture.open();
      repository = ExpenseRepository.forTesting(databaseExecutor: database);
    });

    tearDown(() => database.close());

    test(
      'keeps separate cache entries for different users in the same month',
      () async {
        final firstUserExpense = _expense(id: 'first-user-expense');
        await repository.createExpense(firstUserExpense);
        final container = _container(repository);
        addTearDown(container.dispose);

        await container.read(coreExpensesProvider.future);
        final secondUserResult = await container
            .read(coreExpensesProvider.notifier)
            .loadMonthlyExpenses('second-user', 2024, 1);

        expect(secondUserResult, isEmpty);
      },
    );

    test('moves to an empty month as successful empty data', () async {
      final januaryExpense = _expense(id: 'january-expense');
      await repository.createExpense(januaryExpense);
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(coreExpensesProvider.future);
      final didRefresh = await container
          .read(coreExpensesProvider.notifier)
          .refreshExpensesFor(DateTime(2024, 2, 1));
      await Future<void>.delayed(Duration.zero);

      expect(didRefresh, isTrue);
      expect(container.read(dateManager), DateTime(2024, 2, 1));
      expect(container.read(coreExpensesProvider).value, isEmpty);
    });

    test(
      'invalidates both months when an expense moves across a month boundary',
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

        expect(container.read(coreExpensesProvider).value, isEmpty);
        _expectExpenseIds(
          await container
              .read(coreExpensesProvider.notifier)
              .loadMonthlyExpenses('first-user', 2024, 2),
          {
            DateTime(2024, 2, 3): ['moved-expense'],
          },
        );
      },
    );

    test(
      'analytics failure does not prevent committed state from updating',
      () async {
        final created = _expense(id: 'created-expense');
        final container = _container(
          repository,
          analytics: ThrowingAnalyticsTracker(StateError('offline')),
        );
        addTearDown(container.dispose);

        await container.read(coreExpensesProvider.future);

        await container.read(coreExpensesProvider.notifier).addExpense(created);

        _expectExpenseIds(
          await repository.getExpensesByMonth('first-user', 2024, 1),
          {
            DateTime(2024, 1, 10): ['created-expense'],
          },
        );
        _expectExpenseIds(container.read(coreExpensesProvider).value!, {
          DateTime(2024, 1, 10): ['created-expense'],
        });
      },
    );

    test('reloads the visible month after deletion', () async {
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
    });
  });
}

ProviderContainer _container(
  ExpenseRepository repository, {
  AnalyticsTracker analytics = const NoopAnalyticsTracker(),
}) {
  return ProviderContainer(
    overrides: [
      dateManager.overrideWith(_FixedDateManager.new),
      userSettingsProvider.overrideWith(_TestUserSettingsNotifier.new),
      expenseRepositoryProvider.overrideWith((ref) => repository),
      analyticsTrackerProvider.overrideWithValue(analytics),
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
