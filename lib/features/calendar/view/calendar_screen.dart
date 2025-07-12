import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/calendar/viewmodel/calendar_view_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(calendarViewModel);
    return viewModel.when(
      data: (data) => Scaffold(
        body: TableCalendar(
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            rightChevronVisible: false,
            leftChevronVisible: false,
          ),
          calendarStyle: CalendarStyle(
            tablePadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
          ),

          daysOfWeekHeight: 30,
          currentDay: DateTime.now(),
          rowHeight: MediaQuery.sizeOf(context).height * 0.095,
          focusedDay: data.selectedDay,
          firstDay: DateTime(2025, 07, 01),
          lastDay: DateTime(2030, 12, 31),
          calendarBuilders: CalendarBuilders(
            headerTitleBuilder: (context, day) =>
                _buildCalendarHeader(data.calendarStat, day, context),
            dowBuilder: (context, day) {
              const koreanWeekdays = ['일', '월', '화', '수', '목', '금', '토'];
              final weekdayIndex = day.weekday % 7; // 일요일(0), 월(1), ..., 토(6)
              final label = koreanWeekdays[weekdayIndex];

              Color? color;
              if (day.weekday == DateTime.sunday) {
                color = Colors.red;
              } else if (day.weekday == DateTime.saturday) {
                color = Colors.blue;
              } else {
                color = null;
              }

              return Align(
                alignment: Alignment.topCenter,
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: color),
                ),
              );
            },
            disabledBuilder: (context, day, focusedDay) {
              return const SizedBox.shrink();
            },
            outsideBuilder: (context, day, focusedDay) {
              return const SizedBox.shrink();
            },
            defaultBuilder: (context, day, focusedDay) {
              final date = normalizedDate(day);
              return _buildCalendarCell(
                data.calendarCells[date],
                date,
                context,
                ref,
              );
            },
            todayBuilder: (context, day, focusedDay) {
              final date = normalizedDate(day);
              return _buildCalendarCell(
                data.calendarCells[date],
                date,
                context,
                ref,
              );
            },
            selectedBuilder: (context, day, focusedDay) {
              final date = normalizedDate(day);
              return _buildCalendarCell(
                data.calendarCells[date],
                date,
                context,
                ref,
              );
            },
          ),
        ),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Text('$error, $stackTrace'),
    );
  }
}

Widget _buildCalendarCell(
  CalendarCellData? cellData,
  DateTime day,
  BuildContext context,
  WidgetRef ref,
) {
  return Padding(
    padding: const EdgeInsets.all(1.0),
    child: Material(
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          ref.read(dateManager.notifier).changeDate(day);
          showModalBottomSheet(
            isDismissible: false,
            context: context,
            builder: (context) => TodayExpenseListBottomSheet(
              onClose: () => Navigator.of(context).pop(),
              isHome: false,
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cellData != null && cellData.isSuccess
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                  if (cellData != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.5),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cellData.isSuccess
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              if (cellData != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₩${numberFormatting(cellData.variableTotal)}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '₩${numberFormatting(cellData.essentialTotal)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

// 캘린더 헤더를 만드는 위젯으로 월간 지출 내역에 대한 통계가 추가되어있다.
Widget _buildCalendarHeader(
  CalendarStat stat,
  DateTime day,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Text('${day.year}년 ${day.month}월'),
        Container(
          height: MediaQuery.sizeOf(context).height * 0.18,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderSpecific(
                    '월간 자율 지출',
                    context,
                    doubleValue: stat.monthlyVariableExpense,
                  ),
                  _buildHeaderSpecific(
                    '월간 필수 지출',
                    context,
                    doubleValue: stat.monthlyEssentialExpense,
                  ),
                ],
              ),
              Divider(
                color: Theme.of(context).colorScheme.onSecondaryFixed,
                height: 0.5,
                thickness: 0.5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderSpecific(
                    '성공',
                    context,
                    intValue: stat.successfulDays,
                  ),
                  _buildHeaderSpecific(
                    '실패',
                    context,
                    intValue: stat.failedDays,
                  ),
                  _buildHeaderSpecific(
                    '연속 성공',
                    context,
                    intValue: stat.consecutiveSuccessfulDays,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildHeaderSpecific(
  String title,
  BuildContext context, {
  int? intValue,
  double? doubleValue,
}) {
  return Column(
    children: [
      Text((title), style: Theme.of(context).textTheme.labelMedium),
      SizedBox(height: 5),
      if (intValue != null) Text('$intValue일'),
      if (doubleValue != null)
        Text(
          '${numberFormatting(doubleValue)}원',
          style: Theme.of(context).textTheme.displaySmall,
        ),
    ],
  );
}
