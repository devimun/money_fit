// home_view_model.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// 📦 상태 모델
class HomeState {
  final double dailyBudget;
  final List<Expense> todayExpenseList;
  final double monthlyDiscretionaryExpenseAvg;
  final int consecutiveAchievementDays;
  final bool hasError;

  const HomeState({
    required this.dailyBudget,
    required this.todayExpenseList,
    required this.monthlyDiscretionaryExpenseAvg,
    required this.consecutiveAchievementDays,
    this.hasError = false,
  });

  HomeState copyWith({
    double? dailyBudget,
    List<Expense>? todayExpenseList,
    double? monthlyDiscretionaryExpenseAvg,
    int? consecutiveAchievementDays,
    bool? hasError,
  }) {
    return HomeState(
      dailyBudget: dailyBudget ?? this.dailyBudget,
      todayExpenseList: todayExpenseList ?? this.todayExpenseList,
      monthlyDiscretionaryExpenseAvg:
          monthlyDiscretionaryExpenseAvg ?? this.monthlyDiscretionaryExpenseAvg,
      consecutiveAchievementDays:
          consecutiveAchievementDays ?? this.consecutiveAchievementDays,
      hasError: hasError ?? this.hasError,
    );
  }

  /// 🎯 오늘 자율 지출 총합
  double get todayDiscretionarySpending => todayExpenseList
      .where((e) => e.type == ExpenseType.discretionary)
      .fold(0.0, (sum, e) => sum + e.amount);

  /// 📊 남은 금액, 비율, 색상, 메시지 계산 결과
  SpendingStatus get spendingStatus {
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
}

class HomeViewModel extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    final userAsyncValue = ref.watch(userSettingsProvider);

    return await userAsyncValue.when(
      data: (user) async {
        final expensesByDate = await ref.watch(coreExpensesProvider.future);
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

        return HomeState(
          dailyBudget: user.dailyBudget,
          todayExpenseList: todayExpenses,
          monthlyDiscretionaryExpenseAvg: average,
          consecutiveAchievementDays: consecutiveDays,
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

  Future<void> updateDailyBudget(double newBudget) async {
    await ref.read(userSettingsProvider.notifier).updateDailyBudget(newBudget);
  }

  /// 오늘부터 역순으로 이번 달 안에서 연속 성취일 계산
  int _calculateConsecutiveAchievementDays(
    User user,
    Map<DateTime, List<Expense>> expensesByDate,
  ) {
    final dailyBudget = user.dailyBudget;
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);

    int streak = 0;

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