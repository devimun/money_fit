import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/ledger/presentation/history/view/widgets/filter_components/month_year_picker_dialog.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';
import 'package:money_fit/features/statistics/application/statistics_projection.dart';
import 'package:money_fit/features/statistics/application/statistics_ui_state.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class StatisticsDateSelector extends ConsumerWidget {
  const StatisticsDateSelector({required this.data, super.key});

  final StatisticsModel data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final selectedMonth = DateTime(data.year, data.month, 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            final selectedDate = await showDialog<DateTime>(
              context: context,
              builder: (context) => MonthYearPickerDialog(
                initialDate: DateTime(data.year, data.month),
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
              ),
            );
            if (selectedDate == null ||
                isSameStatisticsMonth(selectedDate, selectedMonth)) {
              return;
            }
            ref
                .read(statisticsViewModelProvider.notifier)
                .changeDate(selectedDate.year, selectedDate.month);
            await ref.read(monetizationSafePointProvider)(
              MeaningfulAdAction.statisticsMonthChanged,
            );
          },
          child: Row(
            children: [
              const SizedBox(width: 32.0),
              Text(
                l10n.yearMonth(
                  DateFormat.MMM(locale).format(selectedMonth),
                  DateFormat.y(locale).format(selectedMonth),
                ),
                style: context.textTheme.displaySmall,
              ),
              const SizedBox(width: 8.0),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 24.0),
            ],
          ),
        ),
      ],
    );
  }
}

bool isSameStatisticsMonth(DateTime first, DateTime second) =>
    first.year == second.year && first.month == second.month;
