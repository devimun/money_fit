import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/features/home/application/home_projection.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

void main() {
  test(
    'essential-only recorded day contributes a successful zero-spend streak',
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

      expect(state.consecutiveAchievementDays, 1);
      expect(state.monthlyDiscretionaryExpenseAvg, 0);
    },
  );

  test(
    'missing day breaks streak and average uses elapsed calendar days',
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
      expect(
        state.monthlyDiscretionaryExpenseAvg,
        closeTo(120 / today.day, 0.001),
      );
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

  test('display mode survives a projection rebuild', () async {
    final today = DateTime(2026, 7, 3);
    final container = ProviderContainer(
      overrides: [
        userSettingsProvider.overrideWith(
          () => _FixtureUserSettingsNotifier(_dailyUser()),
        ),
        currentBudgetProvider.overrideWith(
          (ref) async =>
              const CurrentBudget(amount: 100, type: BudgetType.daily),
        ),
        coreExpensesProvider.overrideWith(
          () => _FixtureExpensesNotifier({
            today: [_expense(date: today, amount: 1)],
          }),
        ),
        homeDayProvider.overrideWith((ref) => today),
        currencyDecimalDigitsProvider.overrideWith((ref) => 2),
      ],
    );
    addTearDown(container.dispose);

    await container.read(homeViewModelProvider.future);
    container.read(homeBudgetDisplayModeProvider.notifier).state =
        BudgetDisplayMode.monthly;
    expect(
      (await container.read(homeViewModelProvider.future)).budgetDisplayMode,
      BudgetDisplayMode.monthly,
    );
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
      currentBudgetProvider.overrideWith(
        (ref) async =>
            CurrentBudget(amount: user.budget, type: user.budgetType),
      ),
      coreExpensesProvider.overrideWith(
        () => _FixtureExpensesNotifier(expenses),
      ),
      homeDayProvider.overrideWith((ref) => selectedDay),
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
