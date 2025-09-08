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
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/features/calendar/model/model.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

class CalendarViewModel extends AsyncNotifier<CalendarState> {
  @override
  Future<CalendarState> build() async {
    final expensesMap = await ref.watch(coreExpensesProvider.future);
    final user = await ref.watch(userSettingsProvider.future);

    final today = ref.watch(dateManager);

    final double dailyBudget = calculateDailyBudget(
      user.budgetType,
      user.budget,
      today,
    );

    final calendarCells = <DateTime, CalendarCellData>{};
    for (final entry in expensesMap.entries) {
      calendarCells[entry.key] = CalendarCellData.from(
        entry.key,
        entry.value,
        dailyBudget,
      );
    }

    final stats = CalendarStat.fromExpenses(expensesMap, dailyBudget);

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
