import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/calendar/model/model.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class CalendarCell extends ConsumerWidget {
  final CalendarCellData? cellData;
  final DateTime day;

  const CalendarCell({super.key, required this.cellData, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            // 캘린더 셀 선택 액션 기록
            InterstitialAdManager.instance.logActionAndShowAd();

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
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDayHeader(context),
                if (cellData != null)
                  _buildExpenseInfo(
                    context,
                    AppLocalizations.of(context)!,
                    Localizations.localeOf(context).toString(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Row(
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
              padding: const EdgeInsets.only(top: 3.0),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cellData!.isSuccess
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseInfo(
    BuildContext context,
    AppLocalizations l10n,
    String locale,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatCurrencyAdaptive(context, cellData!.discretionaryTotal),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatCurrencyAdaptive(context, cellData!.essentialTotal),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
