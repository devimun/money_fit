import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/animate_circular_budget.dart';
import 'package:money_fit/features/home/widgets/budget_mode_tabs.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class HomeMainCard extends StatelessWidget {
  final HomeState homeState;

  const HomeMainCard({super.key, required this.homeState});

  String getMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String message;

    if (homeState.budgetDisplayMode == BudgetDisplayMode.daily) {
      final spent = homeState.todayDiscretionarySpending;
      final ratio = homeState.spendingStatus.spendingRatio;
      if (spent == 0) {
        message = l10n.todayExpenseMessageZero;
      } else if (ratio > 0.69) {
        message = l10n.todayExpenseMessageGood;
      } else if (ratio > 0.5) {
        message = l10n.todayExpenseMessageHalf;
      } else if (ratio > 0.0) {
        message = l10n.todayExpenseMessageNearLimit;
      } else {
        message = l10n.todayExpenseMessageOverLimit;
      }
    } else {
      final spent = homeState.monthlyDiscretionarySpending;
      final ratio = homeState.spendingStatus.spendingRatio;
      if (spent == 0) {
        message = l10n.monthlyExpenseMessageZero;
      } else if (ratio > 0.69) {
        message = l10n.monthlyExpenseMessageGood;
      } else if (ratio > 0.5) {
        message = l10n.monthlyExpenseMessageHalf;
      } else if (ratio > 0.0) {
        message = l10n.monthlyExpenseMessageNearLimit;
      } else {
        message = l10n.monthlyExpenseMessageOverLimit;
      }
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = homeState.spendingStatus;
    final todaySpending = homeState.todayDiscretionarySpending;
    final heightSpace = MediaQuery.of(context).size.height * 0.035;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16.0),
      ),
      child: Column(
        children: [
          BudgetModeTabs(),
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  getMessage(context),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: heightSpace),

          AnimatedCircularBudget(
            ratio: status.spendingRatio,
            color: status.color,
            remainingAmount: status.remainingAmount,
            isMonthly: homeState.budgetDisplayMode == BudgetDisplayMode.monthly,
          ),

          SizedBox(height: heightSpace),

          /// 예산/사용 금액 텍스트
          _buildBudgetInfo(context, todaySpending, l10n),
          SizedBox(height: heightSpace),

          /// 📈 통계 정보
          _buildStatistics(context, l10n),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBudgetInfo(
    BuildContext context,
    double todaySpending,
    AppLocalizations l10n,
  ) {
    final isMonthly = homeState.budgetDisplayMode == BudgetDisplayMode.monthly;
    final spent = isMonthly
        ? homeState.monthlyDiscretionarySpending
        : todaySpending;
    final budget = isMonthly ? homeState.budget : homeState.dailyBudget;
    final spentLabel = isMonthly
        ? l10n.monthlyDiscretionarySpending2
        : l10n.dailyDiscretionarySpending;
    final budgetLabel = isMonthly ? l10n.monthlyBudget : l10n.dailyBudget;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCircleWidget(true, context),
            const SizedBox(width: 8),
            Text(
              '$spentLabel ${formatCurrencyAdaptive(context, spent)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCircleWidget(false, context),
            const SizedBox(width: 8),
            Text(
              '$budgetLabel ${formatCurrencyAdaptive(context, budget)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, AppLocalizations l10n) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.monthlyAvgDiscSpending,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatCurrencyAdaptive(
                    context,
                    homeState.monthlyDiscretionaryExpenseAvg,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.consecutiveDays,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.days(homeState.consecutiveAchievementDays),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
