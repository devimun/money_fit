import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/ledger/application/legacy/category_providers.dart';
import 'package:money_fit/features/statistics/application/statistics_ui_state.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class TopExpensesSection extends ConsumerWidget {
  const TopExpensesSection({required this.data, super.key});

  final StatisticsModel data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoryNotifier = ref.read(categoryProvider.notifier);
    const rankColors = [
      Color(0xFF825A3D),
      Color.fromRGBO(130, 90, 61, 0.8),
      Color.fromRGBO(130, 90, 61, 0.6),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveTitleText(
          text: l10n.top3ExpensesThisMonth,
          style: context.textTheme.bodyLarge!.copyWith(
            color: context.colors.brandPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.top3Expenses.length,
          itemBuilder: (context, index) {
            final expense = data.top3Expenses[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: rankColors[index].withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: rankColors[index],
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ResponsiveLabelText(
                        text: categoryNotifier.getCategoryName(
                          context,
                          expense.categoryId,
                        ),
                        style: context.textTheme.labelMedium,
                      ),
                    ),
                    Text(
                      formatCurrencyAdaptive(context, expense.totalAmount),
                      style: context.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 5),
        ),
      ],
    );
  }
}
