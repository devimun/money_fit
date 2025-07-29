import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/calendar/model/model.dart';

class CalendarCell extends ConsumerWidget {
  final CalendarCellData? cellData;
  final DateTime day;

  const CalendarCell({
    super.key,
    required this.cellData,
    required this.day,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            padding: const EdgeInsets.all(2.0),
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
                _buildDayHeader(context),
                if (cellData != null) _buildExpenseInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '${day.day}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cellData != null && cellData!.isSuccess
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
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
                color: cellData!.isSuccess
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseInfo(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₩${numberFormatting(cellData!.variableTotal)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₩${numberFormatting(cellData!.essentialTotal)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}