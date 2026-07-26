import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/monetization/widgets/ad_banner_widget.dart';
import 'package:money_fit/features/statistics/application/statistics_projection.dart';
import 'package:money_fit/features/statistics/view/widgets/statistics_category_spending_chart.dart';
import 'package:money_fit/features/statistics/view/widgets/statistics_date_selector.dart';
import 'package:money_fit/features/statistics/view/widgets/statistics_top_expenses_section.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(statisticsViewModelProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: statistics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StatisticsDateSelector(data: data),
              if (data.top3Expenses.isNotEmpty) ...[
                const SizedBox(height: 12),
                CategorySpendingChart(data: data),
                const SizedBox(height: 12),
                const AdBannerWidget(placement: AdPlacement.stats),
                const SizedBox(height: 24),
                TopExpensesSection(data: data),
              ] else ...[
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Icon(Icons.receipt_long_outlined, size: 64),
                const SizedBox(height: 16),
                Text(l10n.noExpenseData),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
