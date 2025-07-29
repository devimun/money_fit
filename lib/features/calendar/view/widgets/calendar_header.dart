import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/features/calendar/model/model.dart';
import 'package:money_fit/core/services/ad_service.dart';

class CalendarHeader extends ConsumerWidget {
  final CalendarStat stat;
  final DateTime day;

  const CalendarHeader({
    super.key,
    required this.stat,
    required this.day,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildNavigationHeader(context, ref),
          const SizedBox(height: 16),
          _buildStatisticsCard(context),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            // 전면 광고 표시 (조건부)
            InterstitialAdManager.instance.showAdIfReady();
            
            // 이전 달의 데이터를 조회한다.
            bool refreshAvailable = await ref
                .read(coreExpensesProvider.notifier)
                .refreshExpensesFor(DateTime(day.year, day.month - 1));
            if (!refreshAvailable) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('데이터가 존재하지 않습니다.'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        Text(
          '${day.year}년 ${day.month}월',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        IconButton(
          onPressed: () async {
            // 전면 광고 표시 (조건부)
            InterstitialAdManager.instance.showAdIfReady();
            
            // 다음 달의 데이터를 조회한다.
            bool refreshAvailable = await ref
                .read(coreExpensesProvider.notifier)
                .refreshExpensesFor(DateTime(day.year, day.month + 1));
            if (!refreshAvailable) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('데이터가 존재하지 않습니다.'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.16,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '월간 자율 지출',
                  doubleValue: stat.monthlyVariableExpense,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '월간 필수 지출',
                  doubleValue: stat.monthlyEssentialExpense,
                ),
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSecondaryFixed,
            height: 0.5,
            thickness: 0.5,
          ),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '성공',
                  intValue: stat.successfulDays,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '실패',
                  intValue: stat.failedDays,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '연속 성공',
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
    String title, {
    int? intValue,
    double? doubleValue,
  }) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 5),
        if (intValue != null)
          Text(
            '$intValue일',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        if (doubleValue != null)
          Text(
            '${numberFormatting(doubleValue)}원',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
      ],
    );
  }
}