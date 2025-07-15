import 'package:money_fit/core/models/expense_model.dart';

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

      final isSuccess = (dayVar <= dailyBudget);
      if (isSuccess) {
        success++;
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      }
      if (dayVar >= 0 && dayVar > dailyBudget) {
        fail++;
        streak = 0;
      } else {
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
