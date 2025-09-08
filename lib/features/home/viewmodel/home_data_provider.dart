// home_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

/// 💡 뷰에서 사용할 계산된 값들 묶음
class SpendingStatus {
  final double remainingAmount;
  final double spendingRatio; // 0.0 ~ 1.0 (초과 가능)
  final Color color;

  SpendingStatus({
    required this.remainingAmount,
    required this.spendingRatio,
    required this.color,
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

    late Color color;

    if (spent == 0) {
      color = LightAppColors.primary;
    } else if (ratio > 0.69) {
      color = LightAppColors.primary;
    } else if (ratio > 0.5) {
      color = Colors.green;
    } else if (ratio > 0.0) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return SpendingStatus(
      remainingAmount: remaining,
      spendingRatio: ratio.clamp(0.0, 1.0),
      color: color,
    );
  }

  /// 월간 예산 기준 상태
  SpendingStatus _getMonthlySpendingStatus() {
    final spent = monthlyDiscretionarySpending;
    final remaining = budget - spent;
    final ratio = budget > 0 ? remaining / budget : 0.0;

    late Color color;

    if (spent == 0) {
      color = LightAppColors.primary;
    } else if (ratio > 0.69) {
      color = LightAppColors.primary;
    } else if (ratio > 0.5) {
      color = Colors.green;
    } else if (ratio > 0.0) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return SpendingStatus(
      remainingAmount: remaining,
      spendingRatio: ratio.clamp(0.0, 1.0),
      color: color,
    );
  }
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final userAsyncValue = ref.watch(userSettingsProvider);

    return await userAsyncValue.when(
      data: (user) async {
        final expensesByDate = await ref.watch(coreExpensesProvider.future);
        double monthlyDiscretionarySpending = expensesByDate.values
            .expand((expense) => expense)
            .where(
              (Expense expense) => expense.type == ExpenseType.discretionary,
            )
            .fold(0.0, (sum, expense) => sum + expense.amount);
        final today = ref.watch(dateManager);
        final todayExpenses = expensesByDate[today] ?? [];
        final discretionaryExpenses = expensesByDate.entries
            .expand((entry) => entry.value)
            .where((e) => e.type == ExpenseType.discretionary)
            .toList();

        final totalAmount = discretionaryExpenses.fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );

        final count = expensesByDate.keys.length;
        final average = count > 0 ? totalAmount / count : 0.0;

        final consecutiveDays = _calculateConsecutiveAchievementDays(
          user,
          expensesByDate,
        );

        // 현재 날짜를 기준으로 일일 및 월간 예산을 계산합니다.
        final double dailyBudget = calculateDailyBudget(
          user.budgetType,
          user.budget,
          today,
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
          budgetDisplayMode: BudgetDisplayMode.daily,
        );
      },
      loading: () {
        return Completer<HomeState>().future;
      },
      error: (e, s) {
        throw e;
      },
    );
  }

  Future<void> addExpense(Expense expense) async {
    await ref.read(coreExpensesProvider.notifier).addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await ref.read(coreExpensesProvider.notifier).updateExpense(expense);
  }

  Future<void> deleteExpense(Expense expense) async {
    await ref.read(coreExpensesProvider.notifier).deleteExpense(expense);
  }

  /// 예산 표시 모드 전환 (일일/월간)
  void toggleBudgetDisplayMode(BudgetDisplayMode mode) {
    final currentState = state.value!;
    if (currentState.budgetDisplayMode == mode) {
    } else {
      final newMode = currentState.budgetDisplayMode == BudgetDisplayMode.daily
          ? BudgetDisplayMode.monthly
          : BudgetDisplayMode.daily;

      state = AsyncValue.data(
        currentState.copyWith(budgetDisplayMode: newMode),
      );
    }
  }

  /// 오늘부터 역순으로 이번 달 안에서 연속 성취일 계산
  int _calculateConsecutiveAchievementDays(
    User user,
    Map<DateTime, List<Expense>> expensesByDate,
  ) {
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);

    int streak = 0;
    final dailyBudget = calculateDailyBudget(user.budgetType, user.budget, now);
    for (int i = 0; ; i++) {
      final date = todayKey.subtract(Duration(days: i));
      if (date.month != now.month) break; // 이번 달만 체크
      final expenses = expensesByDate[date] ?? [];
      final totalDiscretionary = expenses
          .where((e) => e.type == ExpenseType.discretionary)
          .fold(0.0, (sum, e) => sum + e.amount);

      if (totalDiscretionary <= dailyBudget && totalDiscretionary != 0) {
        streak += 1;
      } else {
        break;
      }
    }

    return streak;
  }
}

/// 💡 Provider
final homeViewModelProvider = AsyncNotifierProvider<HomeViewModel, HomeState>(
  () => HomeViewModel(),
);
