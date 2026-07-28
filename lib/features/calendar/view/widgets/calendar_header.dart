import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/calendar/application/calendar_projection.dart';
import 'package:money_fit/features/calendar/application/calendar_view_model.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class CalendarHeader extends ConsumerWidget {
  final CalendarStat stat;
  final DateTime day;

  const CalendarHeader({super.key, required this.stat, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildNavigationHeader(context, ref, l10n, locale),
          const SizedBox(height: 16),
          _buildStatisticsCard(context, l10n),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String locale,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeMonth(ref, DateTime(day.year, day.month - 1)),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        Text(
          l10n.yearMonth(
            DateFormat.MMM(locale).format(day).toString(),
            DateFormat.y(locale).format(day).toString(),
          ),
          style: context.textTheme.displaySmall,
        ),
        IconButton(
          onPressed: () => _changeMonth(ref, DateTime(day.year, day.month + 1)),
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  void _changeMonth(WidgetRef ref, DateTime targetMonth) {
    final currentMonth = ref.read(calendarVisibleMonthProvider);
    if (isSameCalendarMonth(currentMonth, targetMonth)) return;
    ref.read(calendarVisibleMonthProvider.notifier).state = targetMonth;
    unawaited(
      ref.read(monetizationSafePointProvider)(
        MeaningfulAdAction.calendarMonthChanged,
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: context.colors.calendarCellBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  l10n,
                  l10n.monthlyDiscretionarySpending,
                  doubleValue: stat.monthlyDiscretionaryExpense,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  l10n,
                  l10n.monthlyEssentialSpending,
                  doubleValue: stat.monthlyEssentialExpense,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  l10n,
                  l10n.success,
                  intValue: stat.successfulDays,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  l10n,
                  l10n.failure,
                  intValue: stat.failedDays,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  l10n,
                  l10n.consecutiveSuccess,
                  intValue: stat.consecutiveSuccessfulDays,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    AppLocalizations l10n,
    String title, {
    int? intValue,
    double? doubleValue,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: context.textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        if (intValue != null)
          Text(
            l10n.daysCount(intValue),
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        if (doubleValue != null)
          Text(
            formatCurrencyAdaptive(context, doubleValue),
            style: context.textTheme.labelMedium?.copyWith(
              color: title == l10n.monthlyDiscretionarySpending
                  ? context.colors.brandPrimary
                  : context.colors.textSecondary,
              fontWeight: title == l10n.monthlyDiscretionarySpending
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
      ],
    );
  }
}

bool isSameCalendarMonth(DateTime first, DateTime second) =>
    first.year == second.year && first.month == second.month;
