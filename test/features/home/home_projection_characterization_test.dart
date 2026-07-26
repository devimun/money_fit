import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

void main() {
  test(
    'current_bug_R16_home_zero_discretionary_day_breaks_streak_remove_in_PR_4_1',
    () async {
      final today = _today();
      final state = await _readHomeState(
        user: _dailyUser(),
        selectedDay: today,
        expenses: {
          today: [
            _expense(date: today, amount: 20, type: ExpenseType.essential),
          ],
        },
      );

      expect(state.consecutiveAchievementDays, 0);
      expect(state.monthlyDiscretionaryExpenseAvg, 0);
    },
  );

  test(
    'current_bug_R16_home_missing_day_breaks_streak_and_average_uses_expense_keys_remove_in_PR_4_1',
    () async {
      final today = _today();
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      final state = await _readHomeState(
        user: _dailyUser(),
        selectedDay: today,
        expenses: {
          today: [_expense(date: today, amount: 40)],
          twoDaysAgo: [_expense(date: twoDaysAgo, amount: 80)],
        },
      );

      expect(state.consecutiveAchievementDays, 1);
      expect(state.monthlyDiscretionaryExpenseAvg, 60);
    },
  );

  test('home uses zero-decimal KRW daily budget', () async {
    final state = await _readHomeState(
      user: _monthlyUser(budget: 10000, currencyCode: 'KRW'),
      selectedDay: DateTime(2026, 7, 15),
      expenses: const {},
    );

    expect(state.dailyBudget, 322);
  });

  test('home uses zero-decimal IDR daily budget', () async {
    final state = await _readHomeState(
      user: _monthlyUser(budget: 100000, currencyCode: 'IDR'),
      selectedDay: DateTime(2026, 7, 15),
      expenses: const {},
    );

    expect(state.dailyBudget, 3225);
  });
}

Future<HomeState> _readHomeState({
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
      currencyDecimalDigitsProvider.overrideWith(
        (ref) => _decimalDigitsFor(user.currencyCode),
      ),
    ],
  );
  try {
    // HomeViewModel's current loading branch returns an unfinished Future.
    // Resolve its watched dependencies first so this fixture observes only the
    // projection behaviour covered by this test file.
    await container.read(userSettingsProvider.future);
    await container.read(coreExpensesProvider.future);
    return await container.read(homeViewModelProvider.future);
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

User _dailyUser() => _monthlyUser(
  budget: 100,
  currencyCode: 'USD',
  budgetType: BudgetType.daily,
);

User _monthlyUser({
  required double budget,
  required String currencyCode,
  BudgetType budgetType = BudgetType.monthly,
}) {
  return User(
    id: 'user',
    budget: budget,
    budgetType: budgetType,
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

Expense _expense({
  required DateTime date,
  required double amount,
  ExpenseType type = ExpenseType.discretionary,
}) {
  return Expense(
    id: 'expense-$amount-${date.day}',
    userId: 'user',
    name: 'expense',
    amount: amount,
    date: date,
    categoryId: 'cafe',
    type: type,
    createdAt: date,
    updatedAt: date,
  );
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
