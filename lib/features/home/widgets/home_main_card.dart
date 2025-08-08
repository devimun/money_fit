import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/theme/app_theme.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/animate_circular_budget.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class HomeMainCard extends StatelessWidget {
  final HomeState homeState;

  const HomeMainCard({super.key, required this.homeState});
  String getMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String message;
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

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = homeState.spendingStatus;
    final todaySpending = homeState.todayDiscretionarySpending;
    final heightSpace = MediaQuery.of(context).size.height * 0.035;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: AppTheme.getBoxDecoration(context),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              getMessage(context),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: heightSpace),

          AnimatedCircularBudget(
            ratio: status.spendingRatio,
            color: status.color,
            remainingAmount: status.remainingAmount,
          ),

          SizedBox(height: heightSpace),

          /// 예산/사용 금액 텍스트
          _buildBudgetInfo(context, todaySpending, l10n),
          SizedBox(height: heightSpace),

          /// 📈 통계 정보
          _buildStatistics(context, l10n),
        ],
      ),
    );
  }

  Widget _buildBudgetInfo(
    BuildContext context,
    double todaySpending,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCircleWidget(true, context),
            const SizedBox(width: 8),
            Text(
              l10n.dailyDiscretionarySpending(
                formatCurrencyAdaptive(context, todaySpending),
              ),
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
              l10n.dailyBudget(
                formatCurrencyAdaptive(context, homeState.dailyBudget),
              ),
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
