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
  final String message;
  final Color color;

  SpendingStatus({
    required this.remainingAmount,
    required this.spendingRatio,
    required this.message,
    required this.color,
  });
}

/// 📦 상태 모델
class HomeState {
  final double dailyBudget;
  final List<Expense> todayExpenseList;
  final double monthlyVariableExpenseAvg;
  final int consecutiveAchievementDays;
  final bool hasError;

  const HomeState({
    required this.dailyBudget,
    required this.todayExpenseList,
    required this.monthlyVariableExpenseAvg,
    required this.consecutiveAchievementDays,
    this.hasError = false,
  });

  HomeState copyWith({
    double? dailyBudget,
    List<Expense>? todayExpenseList,
    double? monthlyVariableExpenseAvg,
    int? consecutiveAchievementDays,
    bool? hasError,
  }) {
    return HomeState(
      dailyBudget: dailyBudget ?? this.dailyBudget,
      todayExpenseList: todayExpenseList ?? this.todayExpenseList,
      monthlyVariableExpenseAvg:
          monthlyVariableExpenseAvg ?? this.monthlyVariableExpenseAvg,
      consecutiveAchievementDays:
          consecutiveAchievementDays ?? this.consecutiveAchievementDays,
      hasError: hasError ?? this.hasError,
    );
  }

  /// 🎯 오늘 자율 지출 총합
  double get todayVariableSpending => todayExpenseList
      .where((e) => e.type == ExpenseType.variable)
      .fold(0.0, (sum, e) => sum + e.amount);

  /// 📊 남은 금액, 비율, 색상, 메시지 계산 결과
  SpendingStatus get spendingStatus {
    final spent = todayVariableSpending;
    final remaining = dailyBudget - spent;
    final ratio = dailyBudget > 0 ? remaining / dailyBudget : 0.0;

    late String message;
    late Color color;

    if (spent == 0) {
      message = '오늘의 지출을 등록해 주세요 😊';
      color = LightAppColors.primary;
    } else if (ratio > 0.69) {
      message = '좋아요! 오늘은 아직 여유 있어요 🌿';
      color = LightAppColors.primary;
    } else if (ratio > 0.5) {
      message = '절반 가까이 사용했어요!\n이제 조금만 신경써볼까요? 🔔';
      color = Colors.green;
    } else if (ratio > 0.0) {
      message = '조금만 더 쓰면 오늘 예산을 초과해요! ⚠️';
      color = Colors.orange;
    } else {
      message = '오늘 예산을 초과했어요! 지출을 조절해봐요 ❗';
      color = Colors.red;
    }

    return SpendingStatus(
      remainingAmount: remaining,
      spendingRatio: ratio.clamp(0.0, 1.0),
      message: message,
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
        final variableExpenses = expensesByDate.entries
            .expand((entry) => entry.value)
            .where((e) => e.type == ExpenseType.variable)
            .toList();

        final totalAmount = variableExpenses.fold<double>(
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
          monthlyVariableExpenseAvg: average,
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
      final totalVariable = expenses
          .where((e) => e.type == ExpenseType.variable)
          .fold(0.0, (sum, e) => sum + e.amount);

      if (totalVariable <= dailyBudget && totalVariable != 0) {
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
