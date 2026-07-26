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
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/features/budget/domain/spending_policy.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/features/ledger/application/ledger_currency_provider.dart';
import 'package:money_fit/features/calendar/application/calendar_projection.dart';

class CalendarViewModel extends AsyncNotifier<CalendarState> {
  static const _spendingPolicy = SpendingPolicy();

  @override
  Future<CalendarState> build() async {
    final expensesMap = await ref.watch(coreExpensesProvider.future);
    final currentBudget = await ref.watch(currentBudgetProvider.future);
    if (currentBudget == null) {
      throw StateError(
        'Calendar projection requires a configured current budget.',
      );
    }

    final visibleMonth = ref.watch(calendarVisibleMonthProvider);
    final selectedDay = ref.watch(calendarSelectedDayProvider);

    final double dailyBudget = _spendingPolicy.dailyBudget(
      budgetType: currentBudget.type,
      budget: currentBudget.amount,
      month: visibleMonth,
      decimalDigits: ref.watch(currencyDecimalDigitsProvider),
    );

    final calendarCells = <DateTime, CalendarCellData>{};
    for (final entry in expensesMap.entries) {
      calendarCells[entry.key] = CalendarCellData.from(
        entry.key,
        entry.value,
        dailyBudget,
        policy: _spendingPolicy,
      );
    }

    final stats = CalendarStat.fromExpenses(
      expensesMap,
      dailyBudget,
      policy: _spendingPolicy,
    );

    return CalendarState(
      selectedDay: selectedDay,
      visibleMonth: visibleMonth,
      calendarStat: stats,
      calendarCells: calendarCells,
    );
  }
}

DateTime _normalized(DateTime value) =>
    DateTime(value.year, value.month, value.day);

final calendarVisibleMonthProvider = StateProvider<DateTime>((ref) {
  final now = ref.watch(clockProvider).now();
  return DateTime(now.year, now.month);
});

final calendarSelectedDayProvider = StateProvider<DateTime>(
  (ref) => _normalized(ref.watch(clockProvider).now()),
);

final calendarViewModel =
    AsyncNotifierProvider<CalendarViewModel, CalendarState>(
      () => CalendarViewModel(),
    );
