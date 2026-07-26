import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/features/budget/domain/spending_policy.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

/// Presentation maps this semantic level to theme colors.
enum SpendingLevel {
  /// 지출 없음 또는 70% 이상 남음 → brandPrimary
  excellent,

  /// 50~69% 남음 → green
  good,

  /// 1~49% 남음 → orange
  warning,

  /// 초과 → red
  exceeded,
}

/// 💡 뷰에서 사용할 계산된 값들 묶음
class SpendingStatus {
  final double remainingAmount;
  final double spendingRatio; // 0.0 ~ 1.0 (초과 가능)
  final SpendingLevel level;

  SpendingStatus({
    required this.remainingAmount,
    required this.spendingRatio,
    required this.level,
  });
}

/// 예산 표시 모드
enum BudgetDisplayMode { daily, monthly }

/// 📦 상태 모델
class HomeState {
  final double budget;
  final double dailyBudget;
  final double monthlyDiscretionarySpending;
  final List<Expense> todayExpenseList;
  final double monthlyDiscretionaryExpenseAvg;
  final int consecutiveAchievementDays;
  final bool hasError;
  final BudgetDisplayMode budgetDisplayMode;

  const HomeState({
    required this.budget,
    required this.dailyBudget,
    required this.monthlyDiscretionarySpending,
    required this.todayExpenseList,
    required this.monthlyDiscretionaryExpenseAvg,
    required this.consecutiveAchievementDays,
    this.hasError = false,
    this.budgetDisplayMode = BudgetDisplayMode.daily,
  });

  HomeState copyWith({
    double? budget,
    double? dailyBudget,
    double? monthlyDiscretionarySpending,
    List<Expense>? todayExpenseList,
    double? monthlyDiscretionaryExpenseAvg,
    int? consecutiveAchievementDays,
    bool? hasError,
    BudgetDisplayMode? budgetDisplayMode,
  }) {
    return HomeState(
      budget: budget ?? this.budget,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      monthlyDiscretionarySpending:
          monthlyDiscretionarySpending ?? this.monthlyDiscretionarySpending,
      todayExpenseList: todayExpenseList ?? this.todayExpenseList,
      monthlyDiscretionaryExpenseAvg:
          monthlyDiscretionaryExpenseAvg ?? this.monthlyDiscretionaryExpenseAvg,
      consecutiveAchievementDays:
          consecutiveAchievementDays ?? this.consecutiveAchievementDays,
      hasError: hasError ?? this.hasError,
      budgetDisplayMode: budgetDisplayMode ?? this.budgetDisplayMode,
    );
  }

  /// 🎯 오늘 자율 지출 총합
  double get todayDiscretionarySpending => todayExpenseList
      .where((e) => e.type == ExpenseType.discretionary)
      .fold(0.0, (sum, e) => sum + e.amount);

  /// 📊 남은 금액, 비율, 색상, 메시지 계산 결과
  SpendingStatus get spendingStatus {
    if (budgetDisplayMode == BudgetDisplayMode.daily) {
      return _getDailySpendingStatus();
    } else {
      return _getMonthlySpendingStatus();
    }
  }

  /// 일일 예산 기준 상태
  SpendingStatus _getDailySpendingStatus() {
    final spent = todayDiscretionarySpending;
    final remaining = dailyBudget - spent;
    final ratio = dailyBudget > 0 ? remaining / dailyBudget : 0.0;

    late SpendingLevel level;

    if (spent == 0) {
      level = SpendingLevel.excellent;
    } else if (ratio > 0.69) {
      level = SpendingLevel.excellent;
    } else if (ratio > 0.5) {
      level = SpendingLevel.good;
    } else if (ratio > 0.0) {
      level = SpendingLevel.warning;
    } else {
      level = SpendingLevel.exceeded;
    }

    return SpendingStatus(
      remainingAmount: remaining,
      spendingRatio: ratio.clamp(0.0, 1.0),
      level: level,
    );
  }

  /// 월간 예산 기준 상태
  SpendingStatus _getMonthlySpendingStatus() {
    final spent = monthlyDiscretionarySpending;
    final remaining = budget - spent;
    final ratio = budget > 0 ? remaining / budget : 0.0;

    late SpendingLevel level;

    if (spent == 0) {
      level = SpendingLevel.excellent;
    } else if (ratio > 0.69) {
      level = SpendingLevel.excellent;
    } else if (ratio > 0.5) {
      level = SpendingLevel.good;
    } else if (ratio > 0.0) {
      level = SpendingLevel.warning;
    } else {
      level = SpendingLevel.exceeded;
    }

    return SpendingStatus(
      remainingAmount: remaining,
      spendingRatio: ratio.clamp(0.0, 1.0),
      level: level,
    );
  }
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  static const _spendingPolicy = SpendingPolicy();

  @override
  Future<HomeState> build() async {
    final user = await ref.watch(userSettingsProvider.future);
    final expensesByDate = await ref.watch(coreExpensesProvider.future);
    double monthlyDiscretionarySpending = expensesByDate.values
        .expand((expense) => expense)
        .where((Expense expense) => expense.type == ExpenseType.discretionary)
        .fold(0.0, (sum, expense) => sum + expense.amount);
    final today = ref.watch(homeDayProvider);
    final todayExpenses = expensesByDate[today] ?? [];
    final discretionaryByDay = _discretionaryByDay(expensesByDate);
    final average = _spendingPolicy.monthlyAverage(
      discretionaryByDay: discretionaryByDay,
      month: today,
      asOf: today,
    );

    // 현재 날짜를 기준으로 일일 및 월간 예산을 계산합니다.
    final double dailyBudget = _spendingPolicy.dailyBudget(
      budgetType: user.budgetType,
      budget: user.budget,
      month: today,
      decimalDigits: ref.watch(currencyDecimalDigitsProvider),
    );

    final consecutiveDays = _spendingPolicy.currentStreak(
      discretionaryByDay: discretionaryByDay,
      recordedDays: expensesByDate.keys.map(_day).toSet(),
      asOf: today,
      dailyBudgetFor: (day) => _spendingPolicy.dailyBudget(
        budgetType: user.budgetType,
        budget: user.budget,
        month: day,
        decimalDigits: ref.read(currencyDecimalDigitsProvider),
      ),
    );

    final double budget;
    if (user.budgetType == BudgetType.monthly) {
      // 월간 예산 설정 시, 그대로 사용합니다.
      budget = user.budget;
    } else {
      // 일간 예산 설정 시, 현재 월의 일수를 곱해 월간 예산을 계산합니다.
      final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
      budget = dailyBudget * daysInMonth;
    }

    return HomeState(
      budget: budget,
      dailyBudget: dailyBudget,
      monthlyDiscretionarySpending: monthlyDiscretionarySpending,
      todayExpenseList: todayExpenses,
      monthlyDiscretionaryExpenseAvg: average,
      consecutiveAchievementDays: consecutiveDays,
      budgetDisplayMode: ref.watch(homeBudgetDisplayModeProvider),
    );
  }
}

Map<DateTime, double> _discretionaryByDay(
  Map<DateTime, List<Expense>> expensesByDate,
) => {
  for (final entry in expensesByDate.entries)
    _day(entry.key): entry.value
        .where((expense) => expense.type == ExpenseType.discretionary)
        .fold<double>(0, (sum, expense) => sum + expense.amount),
};

DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

final homeDayProvider = StateProvider<DateTime>(
  (ref) => _day(ref.watch(clockProvider).now()),
);

final homeBudgetDisplayModeProvider = StateProvider<BudgetDisplayMode>(
  (ref) => BudgetDisplayMode.daily,
);

/// 💡 Provider
final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, HomeState>(
  () => HomeViewModel(),
);
