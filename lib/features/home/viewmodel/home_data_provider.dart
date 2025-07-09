// home_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/repositories/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/design_palette.dart';

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
    final ratio = remaining / dailyBudget;

    late String message;
    late Color color;

    if (spent == 0) {
      message = '오늘의 지출을 등록해 주세요 😊';
      color = LightAppColors.primary;
    } else if (ratio > 0.69) {
      message = '좋아요! 오늘은 아직 여유 있어요 🌿';
      color = LightAppColors.primary;
    } else if (ratio > 0.3) {
      message = '절반 넘게 사용했어요! 조심해서 써봐요 🔔';
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

/// 🔧 ViewModel
class HomeViewModel extends StateNotifier<HomeState> {
  final ExpenseRepository expenseRepository;

  HomeViewModel({required this.expenseRepository})
    : super(
        const HomeState(
          dailyBudget: 0,
          todayExpenseList: [],
          monthlyVariableExpenseAvg: 0,
          consecutiveAchievementDays: 0,
        ),
      );

  /// 📦 초기 데이터 로딩
  Future<bool> initialize(User user) async {
    try {
      final today = DateTime.now();
      final expenses = await expenseRepository.getExpensesByDate(
        user.id,
        today,
      );

      final monthlyExpenses = await expenseRepository.getExpensesByMonth(
        user.id,
        today.year,
        today.month,
      );

      final variableExpenses = monthlyExpenses.where(
        (e) => e.type == ExpenseType.variable,
      );

      final variableTotal = variableExpenses.fold<double>(
        0,
        (sum, e) => sum + e.amount,
      );

      final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
      final monthlyAvg = variableTotal / daysInMonth;

      final consecutiveDays = await _calculateConsecutiveAchievementDays(
        user,
        expenseRepository,
      );

      state = state.copyWith(
        dailyBudget: user.dailyBudget,
        todayExpenseList: expenses,
        monthlyVariableExpenseAvg: monthlyAvg,
        consecutiveAchievementDays: consecutiveDays,
        hasError: false,
      );

      return true;
    } catch (_) {
      state = state.copyWith(hasError: true);
      return false;
    }
  }

  /// ➕ 지출 등록
  Future<void> addExpense(Expense expense) async {
    await expenseRepository.createExpense(expense);
    final updated = [...state.todayExpenseList, expense];
    state = state.copyWith(todayExpenseList: updated);
  }

  /// ✏️ 지출 수정
  Future<void> updateExpense(Expense expense) async {
    await expenseRepository.updateExpense(expense);
    final updated = state.todayExpenseList
        .map((e) => e.id == expense.id ? expense : e)
        .toList();
    state = state.copyWith(todayExpenseList: updated);
  }

  /// ❌ 지출 삭제
  Future<void> deleteExpense(String id) async {
    await expenseRepository.deleteExpense(id);
    final updated = state.todayExpenseList.where((e) => e.id != id).toList();
    state = state.copyWith(todayExpenseList: updated);
  }

  /// ⚙️ 예산 변경
  void updateDailyBudget(double newBudget) {
    state = state.copyWith(dailyBudget: newBudget);
  }

  /// 🔁 연속 성취일 계산 (dailyBudget 이하 소비)
  Future<int> _calculateConsecutiveAchievementDays(
    User user,
    ExpenseRepository repo,
  ) async {
    // 실제 구현 필요. 아래는 예시로 고정값 반환.
    return 6;
  }
}

/// 💡 Provider
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>(
  (ref) =>
      HomeViewModel(expenseRepository: ref.read(expenseRepositoryProvider)),
);
