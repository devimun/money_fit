import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/features/calendar/model/model.dart';
import 'package:money_fit/features/calendar/viewmodel/calendar_view_model.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

void main() {
  test(
    'current_bug_R16_calendar_zero_discretionary_day_is_successful_remove_in_PR_4_1',
    () {
      final cell = CalendarCellData.from(DateTime(2026, 7, 1), const [], 100);
      final stat = CalendarStat.fromExpenses({
        DateTime(2026, 7, 1): const [],
      }, 100);

      expect(cell.isSuccess, isTrue);
      expect(stat.successfulDays, 1);
      expect(stat.failedDays, 0);
    },
  );

  test(
    'current_bug_R16_calendar_missing_days_do_not_break_streak_remove_in_PR_4_1',
    () {
      final firstDay = DateTime(2026, 7, 1);
      final thirdDay = DateTime(2026, 7, 3);
      final stat = CalendarStat.fromExpenses({
        firstDay: [_expense(date: firstDay, amount: 10)],
        thirdDay: [_expense(date: thirdDay, amount: 10)],
      }, 100);

      expect(stat.successfulDays, 2);
      expect(stat.consecutiveSuccessfulDays, 2);
    },
  );

  test(
    'current_bug_R10_daily_budget_default_rounds_KRW_as_two_decimals_remove_in_PR_1_5',
    () {
      final dailyBudget = calculateDailyBudget(
        BudgetType.monthly,
        10000,
        DateTime(2026, 7, 15),
      );

      expect(dailyBudget, 322.58);
    },
  );

  test(
    'current_bug_R10_daily_budget_default_rounds_IDR_as_two_decimals_remove_in_PR_1_5',
    () {
      final dailyBudget = calculateDailyBudget(
        BudgetType.monthly,
        100000,
        DateTime(2026, 7, 15),
      );

      expect(dailyBudget, 3225.81);
    },
  );

  test(
    'current_bug_R10_daily_budget_default_keeps_USD_two_decimals_remove_in_PR_1_5',
    () {
      final dailyBudget = calculateDailyBudget(
        BudgetType.monthly,
        10000,
        DateTime(2026, 7, 15),
      );

      expect(dailyBudget, 322.58);
    },
  );

  test(
    'current_bug_R10_calendar_KRW_uses_two_decimal_budget_remove_in_PR_1_5',
    () async {
      final day = DateTime(2026, 7, 15);
      final state = await _readCalendarState(
        user: _monthlyUser(budget: 10000, currencyCode: 'KRW'),
        selectedDay: day,
        expenses: {
          day: [_expense(date: day, amount: 322.5)],
        },
      );

      expect(state.calendarCells[day]!.isSuccess, isTrue);
    },
  );

  test(
    'current_bug_R10_calendar_IDR_uses_two_decimal_budget_remove_in_PR_1_5',
    () async {
      final day = DateTime(2026, 7, 15);
      final state = await _readCalendarState(
        user: _monthlyUser(budget: 100000, currencyCode: 'IDR'),
        selectedDay: day,
        expenses: {
          day: [_expense(date: day, amount: 3225.5)],
        },
      );

      expect(state.calendarCells[day]!.isSuccess, isTrue);
    },
  );
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
      coreExpensesProvider.overrideWith(
        () => _FixtureExpensesNotifier(expenses),
      ),
      dateManager.overrideWith(() => _FixtureDateManager(selectedDay)),
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

class _FixtureDateManager extends DateManager {
  _FixtureDateManager(this.selectedDay);

  final DateTime selectedDay;

  @override
  DateTime build() => selectedDay;
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
