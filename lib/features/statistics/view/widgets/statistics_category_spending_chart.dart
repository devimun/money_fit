import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/ledger/application/legacy/category_providers.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';
import 'package:money_fit/features/statistics/application/statistics_projection.dart';
import 'package:money_fit/features/statistics/application/statistics_ui_state.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class CategorySpendingChart extends ConsumerWidget {
  const CategorySpendingChart({required this.data, super.key});

  final StatisticsModel data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoryNotifier = ref.read(categoryProvider.notifier);
    final expenses = [
      ...(data.expenseType == ExpenseType.discretionary
          ? data.flexExpenses
          : data.essentialExpenses),
    ]..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final totalAmount = expenses.fold<double>(
      0,
      (sum, item) => sum + item.totalAmount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveTitleText(
          text: l10n.spendingByCategory,
          style: context.textTheme.bodyLarge!.copyWith(
            color: context.colors.brandPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Row(
                children: [
                  _ExpenseTypeTab(
                    title: l10n.discretionaryExpense,
                    type: ExpenseType.discretionary,
                    selectedType: data.expenseType,
                  ),
                  _ExpenseTypeTab(
                    title: l10n.essentialExpense,
                    type: ExpenseType.essential,
                    selectedType: data.expenseType,
                  ),
                ],
              ),
              Divider(
                height: 0,
                thickness: 0.2,
                color: context.colors.textSecondary,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: expenses.isEmpty
                    ? Text(l10n.noExpenseData)
                    : Column(
                        children: [
                          SizedBox(
                            height: 300,
                            child: PieChart(
                              PieChartData(
                                sections: expenses.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final expense = entry.value;
                                  final percentage =
                                      (expense.totalAmount / totalAmount) * 100;
                                  return PieChartSectionData(
                                    color: categoryChartColor(
                                      context,
                                      index,
                                      expenses.length,
                                    ),
                                    value: expense.totalAmount,
                                    title: '${percentage.toStringAsFixed(1)}%',
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 1,
                                centerSpaceRadius: 20,
                              ),
                              curve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 900),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: expenses.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 6,
                                ),
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              final color = categoryChartColor(
                                context,
                                index,
                                expenses.length,
                              );
                              return Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ResponsiveLabelText(
                                      text: categoryNotifier.getCategoryName(
                                        context,
                                        expense.categoryId,
                                      ),
                                      style: context.textTheme.labelMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatCurrencyAdaptive(
                                      context,
                                      expense.totalAmount,
                                    ),
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpenseTypeTab extends ConsumerWidget {
  const _ExpenseTypeTab({
    required this.title,
    required this.type,
    required this.selectedType,
  });

  final String title;
  final ExpenseType type;
  final ExpenseType selectedType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = type == selectedType;
    return Expanded(
      child: InkWell(
        onTap: () {
          InterstitialAdManager.instance.logActionAndShowAd();
          ref
              .read(statisticsViewModelProvider.notifier)
              .changeExpenseType(type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          color: isSelected
              ? context.colors.brandPrimary.withValues(alpha: 0.1)
              : null,
          child: Center(
            child: ResponsiveLabelText(
              text: title,
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? context.colors.brandPrimary
                    : context.colors.navUnselected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color categoryChartColor(BuildContext context, int index, int total) {
  final base = HSLColor.fromColor(context.colors.brandPrimary);
  final steps = total < 3 ? 3 : (total > 12 ? 12 : total);
  final hue = (base.hue + 360.0 / steps * index) % 360.0;
  final saturation = (base.saturation + 0.08 * ((index % 3) - 1)).clamp(
    0.55,
    0.90,
  );
  final lightness = (0.48 + ((index % 4) - 1) * 0.04).clamp(0.38, 0.60);
  var color = HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  if (color.computeLuminance() > 0.82) {
    final hsl = HSLColor.fromColor(color);
    color = hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.35, 0.60))
        .toColor();
  }
  return color;
}
