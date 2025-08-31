import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/features/calendar/model/model.dart';
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
          onPressed: () async {
            // 이전 달의 데이터를 조회한다.
            bool refreshAvailable = await ref
                .read(coreExpensesProvider.notifier)
                .refreshExpensesFor(DateTime(day.year, day.month - 1));
            if (!refreshAvailable) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.noDataExists),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              }
            } else {
              InterstitialAdManager.instance.logActionAndShowAd();
            }
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        Text(
          l10n.yearMonth(
            DateFormat.MMM(locale).format(day).toString(),
            DateFormat.y(locale).format(day).toString(),
          ),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        IconButton(
          onPressed: () async {
            // 다음 달의 데이터를 조회한다.
            bool refreshAvailable = await ref
                .read(coreExpensesProvider.notifier)
                .refreshExpensesFor(DateTime(day.year, day.month + 1));
            if (!refreshAvailable) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.noDataExists),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              }
            } else {
              InterstitialAdManager.instance.logActionAndShowAd();
            }
          },
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
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
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        if (intValue != null)
          Text(
            l10n.daysCount(intValue),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryFixed,
            ),
          ),
        if (doubleValue != null)
          Text(
            formatCurrencyAdaptive(context, doubleValue),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: title == l10n.monthlyDiscretionarySpending
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSecondaryFixed,
              fontWeight: title == l10n.monthlyDiscretionarySpending
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
