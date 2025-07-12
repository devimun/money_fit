// 캘린더 뷰를 담당할 모델과 뷰모델
// 캘린더 화면에 들어가는 정보

// 년 월
// 스텟창(2row 1row. 월간 자율 지출 / 월간 필수 지출액 2row. 성공,실패,연속 성공)

// 바디
// 일~토
// 요일별 해당 일의 지출 내역을 갖고 날짜에 표시
// 날짜 컨테이너 좌측 상단 날짜 우측 상단 성공/실패 표시
// 하단 자율 지출 금액과 필수 지출 금액 표시
// 컨테이너 클릭하면 해당 일의 지출 내역 전부 볼 수 있게함

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

class CalendarCellData {
  final DateTime date;
  final List<Expense> expenses;
  final bool isSuccess;

  CalendarCellData({
    required this.date,
    required this.expenses,
    required this.isSuccess,
  });

  factory CalendarCellData.from(
    DateTime date,
    List<Expense> expenses,
    double dailyBudget,
  ) {
    double varTotal = expenses
        .where((e) => e.type == ExpenseType.variable)
        .fold(0.0, (sum, e) => sum + e.amount);

    final isSuccess = varTotal > 0 && varTotal <= dailyBudget;

    return CalendarCellData(
      date: date,
      expenses: expenses,
      isSuccess: isSuccess,
    );
  }

  double get variableTotal => expenses
      .where((e) => e.type == ExpenseType.variable)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get essentialTotal => expenses
      .where((e) => e.type == ExpenseType.required)
      .fold(0.0, (sum, e) => sum + e.amount);
}

class CalendarState {
  final DateTime selectedDay;
  final CalendarStat calendarStat;
  final Map<DateTime, CalendarCellData> calendarCells;

  CalendarState({
    required this.selectedDay,
    required this.calendarStat,
    required this.calendarCells,
  });
}

// 상단 스테이터스바 전용 클래스
class CalendarStat {
  double monthlyVariableExpense; // 월간 자율 지출 총액
  double monthlyEssentialExpense; // 월간 필수 지출 총액
  int successfulDays; // 성공일 수
  int failedDays; // 실패일 수
  int consecutiveSuccessfulDays; // 연속 성공일 수

  CalendarStat({
    required this.monthlyVariableExpense,
    required this.monthlyEssentialExpense,
    required this.successfulDays,
    required this.failedDays,
    required this.consecutiveSuccessfulDays,
  });

  factory CalendarStat.fromExpenses(
    Map<DateTime, List<Expense>> expensesMap,
    double dailyBudget,
  ) {
    double varTotal = 0;
    double reqTotal = 0;
    int success = 0;
    int fail = 0;
    int streak = 0;
    int maxStreak = 0;

    final sortedDates = expensesMap.keys.toList()..sort();

    for (final day in sortedDates) {
      final expenses = expensesMap[day]!;
      double dayVar = 0;
      double dayReq = 0;

      for (final e in expenses) {
        if (e.type == ExpenseType.variable) {
          dayVar += e.amount;
        } else {
          dayReq += e.amount;
        }
      }

      varTotal += dayVar;
      reqTotal += dayReq;

      final isSuccess = (dayVar <= dailyBudget && dayVar > 0);
      if (isSuccess) {
        success++;
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        fail++;
        streak = 0;
      }
    }

    return CalendarStat(
      monthlyVariableExpense: varTotal,
      monthlyEssentialExpense: reqTotal,
      successfulDays: success,
      failedDays: fail,
      consecutiveSuccessfulDays: maxStreak,
    );
  }
}

class CalendarViewModel extends AsyncNotifier<CalendarState> {
  @override
  Future<CalendarState> build() async {
    final expensesMap = await ref.watch(coreExpensesProvider.future);
    final userAsync = ref.watch(userSettingsProvider);
    final user = userAsync.value!;
    final today = DateTime.now();

    final calendarCells = <DateTime, CalendarCellData>{};
    for (final entry in expensesMap.entries) {
      calendarCells[entry.key] = CalendarCellData.from(
        entry.key,
        entry.value,
        user.dailyBudget,
      );
    }

    final stats = CalendarStat.fromExpenses(expensesMap, user.dailyBudget);

    return CalendarState(
      selectedDay: today,
      calendarStat: stats,
      calendarCells: calendarCells,
    );
  }
}

final calendarViewModel =
    AsyncNotifierProvider<CalendarViewModel, CalendarState>(
      () => CalendarViewModel(),
    );
