import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/budget/domain/spending_policy.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/features/calendar/application/calendar_projection.dart';
import 'package:money_fit/features/calendar/application/calendar_view_model.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

void main() {
  test('zero discretionary spending is a successful recorded day', () {
    final cell = CalendarCellData.from(DateTime(2026, 7, 1), const [], 100);
    final stat = CalendarStat.fromExpenses({
      DateTime(2026, 7, 1): const [],
    }, 100);

    expect(cell.isSuccess, isTrue);
    expect(stat.successfulDays, 1);
    expect(stat.failedDays, 0);
  });

  test('missing calendar days break a streak', () {
    final firstDay = DateTime(2026, 7, 1);
    final thirdDay = DateTime(2026, 7, 3);
    final stat = CalendarStat.fromExpenses({
      firstDay: [_expense(date: firstDay, amount: 10)],
      thirdDay: [_expense(date: thirdDay, amount: 10)],
    }, 100);

    expect(stat.successfulDays, 2);
    expect(stat.consecutiveSuccessfulDays, 1);
  });

  test('daily budget floors zero-decimal currencies', () {
    final dailyBudget = const SpendingPolicy().dailyBudget(
      budgetType: BudgetType.monthly,
      budget: 10000,
      month: DateTime(2026, 7, 15),
      decimalDigits: 0,
    );

    expect(dailyBudget, 322);
  });

  test('daily budget floors IDR to whole units', () {
    final dailyBudget = const SpendingPolicy().dailyBudget(
      budgetType: BudgetType.monthly,
      budget: 100000,
      month: DateTime(2026, 7, 15),
      decimalDigits: 0,
    );

    expect(dailyBudget, 3225);
  });

  test('daily budget rounds USD at two decimal places', () {
    final dailyBudget = const SpendingPolicy().dailyBudget(
      budgetType: BudgetType.monthly,
      budget: 10000,
      month: DateTime(2026, 7, 15),
      decimalDigits: 2,
    );

    expect(dailyBudget, 322.58);
  });

  test('calendar uses zero-decimal KRW threshold', () async {
    final day = DateTime(2026, 7, 15);
    final state = await _readCalendarState(
      user: _monthlyUser(budget: 10000, currencyCode: 'KRW'),
      selectedDay: day,
      expenses: {
        day: [_expense(date: day, amount: 322.5)],
      },
    );

    expect(state.calendarCells[day]!.isSuccess, isFalse);
  });

  test('calendar uses zero-decimal IDR threshold', () async {
    final day = DateTime(2026, 7, 15);
    final state = await _readCalendarState(
      user: _monthlyUser(budget: 100000, currencyCode: 'IDR'),
      selectedDay: day,
      expenses: {
        day: [_expense(date: day, amount: 3225.5)],
      },
    );

    expect(state.calendarCells[day]!.isSuccess, isFalse);
  });
}

Future<CalendarState> _readCalendarState({
  required User user,
  required DateTime selectedDay,
  required Map<DateTime, List<Expense>> expenses,
}) async {
  final container = ProviderContainer(
    overrides: [
      userSettingsProvider.overrideWith(
        () => _FixtureUserSettingsNotifier(user),
      ),
      currentBudgetProvider.overrideWith(
        (ref) async =>
            CurrentBudget(amount: user.budget, type: user.budgetType),
      ),
      coreExpensesProvider.overrideWith(
        () => _FixtureExpensesNotifier(expenses),
      ),
      calendarVisibleMonthProvider.overrideWith((ref) => selectedDay),
      calendarSelectedDayProvider.overrideWith((ref) => selectedDay),
      currencyDecimalDigitsProvider.overrideWith(
        (ref) => _decimalDigitsFor(user.currencyCode),
      ),
    ],
  );
  try {
    return await container.read(calendarViewModel.future);
  } finally {
    container.dispose();
  }
}

class _FixtureUserSettingsNotifier extends UserSettingsNotifier {
  _FixtureUserSettingsNotifier(this.user);

  final User user;

  @override
  Future<User> build() async => user;
}

class _FixtureExpensesNotifier extends CoreExpensesNotifier {
  _FixtureExpensesNotifier(this.expenses);

  final Map<DateTime, List<Expense>> expenses;

  @override
  Future<Map<DateTime, List<Expense>>> build() async => expenses;
}

User _monthlyUser({required double budget, required String currencyCode}) {
  return User(
    id: 'user',
    budget: budget,
    budgetType: BudgetType.monthly,
    isDarkMode: false,
    notificationsEnabled: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    currencyCode: currencyCode,
  );
}

int _decimalDigitsFor(String currencyCode) => switch (currencyCode) {
  'KRW' || 'IDR' => 0,
  _ => 2,
};

Expense _expense({required DateTime date, required double amount}) {
  return Expense(
    id: 'expense-$amount-${date.day}',
    userId: 'user',
    name: 'expense',
    amount: amount,
    date: date,
    categoryId: 'cafe',
    type: ExpenseType.discretionary,
    createdAt: date,
    updatedAt: date,
  );
}
