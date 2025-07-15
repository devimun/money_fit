import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/calendar/model/model.dart';

Widget buildCalendarCell(
  CalendarCellData? cellData,
  DateTime day,
  BuildContext context,
  WidgetRef ref,
) {
  return Padding(
    padding: const EdgeInsets.all(3.0),
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
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSecondaryFixed,
              width: 0.2,
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
Widget buildCalendarHeader(
  WidgetRef ref,
  CalendarStat stat,
  DateTime day,
  BuildContext context,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () async {
                // 이전 달의 데이터를 조회한다.
                await ref
                    .read(coreExpensesProvider.notifier)
                    .refreshExpensesFor(DateTime(day.year, day.month - 1));
              },
              icon: Icon(Icons.arrow_back_ios),
            ),
            Text(
              '${day.year}년 ${day.month}월',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            IconButton(
              onPressed: () async {
                // 다음 달의 데이터를 조회한다.
                await ref
                    .read(coreExpensesProvider.notifier)
                    .refreshExpensesFor(DateTime(day.year, day.month + 1));
              },
              icon: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: MediaQuery.sizeOf(context).height * 0.16,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderSpecific(
                      '월간 자율 지출',
                      context,
                      doubleValue: stat.monthlyVariableExpense,
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderSpecific(
                      '월간 필수 지출',
                      context,
                      doubleValue: stat.monthlyEssentialExpense,
                    ),
                  ),
                ],
              ),
              Divider(
                color: Theme.of(context).colorScheme.onSecondaryFixed,
                height: 0.5,
                thickness: 0.5,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderSpecific(
                      '성공',
                      context,
                      intValue: stat.successfulDays,
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderSpecific(
                      '실패',
                      context,
                      intValue: stat.failedDays,
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderSpecific(
                      '연속 성공',
                      context,
                      intValue: stat.consecutiveSuccessfulDays,
                    ),
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
      if (doubleValue != null) Text('${numberFormatting(doubleValue)}원'),
    ],
  );
}
