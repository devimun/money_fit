import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/theme/app_theme.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/animate_circular_budget.dart';

class HomeMainCard extends StatelessWidget {
  final HomeState homeState;

  const HomeMainCard({
    super.key,
    required this.homeState,
  });

  @override
  Widget build(BuildContext context) {
    final status = homeState.spendingStatus;
    final todaySpending = homeState.todayVariableSpending;
    final heightSpace = MediaQuery.of(context).size.height * 0.035;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: AppTheme.getBoxDecoration(context),
      child: Column(
        children: [
          /// 🎯 동기부여 문구
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              status.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: heightSpace),

          /// ⭕ 원형 프로그레스바
          AnimatedCircularBudget(
            ratio: status.spendingRatio,
            color: status.color,
            remainingAmount: status.remainingAmount,
          ),

          SizedBox(height: heightSpace),

          /// 예산/사용 금액 텍스트
          _buildBudgetInfo(context, todaySpending),
          SizedBox(height: heightSpace),

          /// 📈 통계 정보
          _buildStatistics(context),
        ],
      ),
    );
  }

  Widget _buildBudgetInfo(BuildContext context, double todaySpending) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCircleWidget(true, context),
            const SizedBox(width: 8),
            Text(
              '일일 자율 지출 : ${numberFormatting(todaySpending)}원',
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
              '일일 예산 : ${numberFormatting(homeState.dailyBudget)}원',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                '월평균 일일 자율 지출',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${numberFormatting(homeState.monthlyVariableExpenseAvg)}원',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '연속 목표 달성일',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${homeState.consecutiveAchievementDays}일',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}