import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';
import 'package:money_fit/features/expense/view/widgets/filter_components/month_year_picker_dialog.dart';
import 'package:money_fit/features/statistics/model/models.dart';
import 'package:money_fit/features/statistics/viewmodel/view_model.dart';
import 'package:money_fit/l10n/app_localizations.dart';

final statisticsViewModelProvider =
    AsyncNotifierProvider<StatisticsViewModel, StatisticsModel>(
      () => StatisticsViewModel(),
    );

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
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildDateSelector(context, ref, data),
                if (data.top3Expenses.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCategorySpendingChart(context, ref, data),
                  const SizedBox(height: 12),
                  AdBannerWidget(screenType: ScreenType.stats),
                  const SizedBox(height: 24),
                  _buildTop3Expenses(context, ref, data),
                ] else ...[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Icon(Icons.receipt_long_outlined, size: 64),
                  SizedBox(height: 16),
                  Text(l10n.noExpenseData),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    WidgetRef ref,
    StatisticsModel data,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            final selectedDate = await showDialog<DateTime>(
              context: context,
              builder: (context) {
                return MonthYearPickerDialog(
                  initialDate: DateTime(data.year, data.month),
                  firstDate: DateTime(2025),
                  lastDate: DateTime.now(),
                );
              },
            );
            if (selectedDate != null) {
              InterstitialAdManager.instance.logActionAndShowAd();
              ref
                  .read(statisticsViewModelProvider.notifier)
                  .changeDate(selectedDate.year, selectedDate.month);
            }
          },
          child: Row(
            children: [
              SizedBox(width: 32.0),
              Text(
                l10n.yearMonth(
                  DateFormat.MMM(
                    locale,
                  ).format(DateTime(data.year, data.month, 1)).toString(),
                  DateFormat.y(
                    locale,
                  ).format(DateTime(data.year, data.month, 1)).toString(),
                ),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(width: 8.0),
              Icon(Icons.keyboard_arrow_down_rounded, size: 24.0),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(
    BuildContext context,
    String categoryId,
    int index,
    int total,
  ) {
    // Generate harmonious, theme-driven colors for pie sections while avoiding whites.
    // We derive hues from the app's primary color and vary them by index.
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final HSLColor base = HSLColor.fromColor(scheme.primary);

    // Keep the number of distinct hue steps within a sensible range for visual harmony
    final int steps = total < 3 ? 3 : (total > 12 ? 12 : total);
    final double hueStep = 360.0 / steps;

    // Rotate hue based on index, keep saturation high enough for vibrancy,
    // and lightness in mid range to ensure no white-ish tones.
    final double hue = (base.hue + hueStep * index) % 360.0;
    final double satBase = base.saturation;
    final double satTweaked = (satBase + 0.08 * ((index % 3) - 1)).clamp(
      0.55,
      0.90,
    );

    double light = 0.48 + ((index % 4) - 1) * 0.04; // 0.44 ~ 0.56
    light = light.clamp(0.38, 0.60);

    Color color = HSLColor.fromAHSL(1.0, hue, satTweaked, light).toColor();

    // Final guard: ensure it's not too close to white; if so, darken slightly.
    final double luminance = color.computeLuminance();
    if (luminance > 0.82) {
      final HSLColor c = HSLColor.fromColor(color);
      color = c.withLightness((c.lightness - 0.12).clamp(0.35, 0.60)).toColor();
    }

    return color;
  }

  Widget _buildCategorySpendingChart(
    BuildContext context,
    WidgetRef ref,
    StatisticsModel data,
  ) {
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
    final selectedType = data.expenseType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.spendingByCategory,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
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
                  _buildExpenseTypeTab(
                    context,
                    ref,
                    l10n.discretionaryExpense,
                    ExpenseType.discretionary,
                    selectedType,
                  ),
                  _buildExpenseTypeTab(
                    context,
                    ref,
                    l10n.essentialExpense,
                    ExpenseType.essential,
                    selectedType,
                  ),
                ],
              ),
              Divider(
                height: 0,
                thickness: 0.2,
                color: Theme.of(context).colorScheme.onSecondaryFixed,
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
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 900),
                              PieChartData(
                                sections: expenses.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final expense = entry.value;
                                  final percentage =
                                      (expense.totalAmount / totalAmount) * 100;
                                  final color = _getCategoryColor(
                                    context,
                                    expense.categoryId,
                                    index,
                                    expenses.length,
                                  );
                                  return PieChartSectionData(
                                    color: color,
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
                              final color = _getCategoryColor(
                                context,
                                expense.categoryId,
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
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        categoryNotifier.getCategoryName(
                                          context,
                                          expense.categoryId,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    formatCurrencyAdaptive(
                                      context,
                                      expense.totalAmount,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
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

  Widget _buildExpenseTypeTab(
    BuildContext context,
    WidgetRef ref,
    String title,
    ExpenseType type,
    ExpenseType selectedType,
  ) {
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
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop3Expenses(
    BuildContext context,
    WidgetRef ref,
    StatisticsModel data,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final categoryNotifier = ref.read(categoryProvider.notifier);
    final top3 = data.top3Expenses;

    final List<Color> rankColors = [
      const Color(0xFF825A3D),
      const Color.fromRGBO(130, 90, 61, 0.8),
      const Color.fromRGBO(130, 90, 61, 0.6),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.top3ExpensesThisMonth,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: top3.length,
          itemBuilder: (context, index) {
            final expense = top3[index];
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryNotifier.getCategoryName(
                              context,
                              expense.categoryId,
                            ),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrencyAdaptive(context, expense.totalAmount),
                      style: Theme.of(context).textTheme.labelMedium,
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
