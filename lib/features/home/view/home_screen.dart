import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/functions/functions.dart';

import 'package:money_fit/core/theme/app_theme.dart';
import 'package:money_fit/core/widgets/expense_add_form.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/animate_circular_budget.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final user = ref.watch(userSettingsProvider).valueOrNull;
    final status = state.spendingStatus;
    final todaySpending = state.todayVariableSpending;

    var heightSpace = MediaQuery.of(context).size.height * 0.035;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// 📅 오늘 날짜
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat(
                      'yyyy.MM.dd EEEE',
                      'ko_KR',
                    ).format(DateTime.now()),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                SizedBox(height: 10),

                /// 💳 카드 영역
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: AppTheme.boxDecoration,
                  child: Column(
                    children: [
                      /// 🎯 동기부여 문구
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          status.message,
                          style: Theme.of(context).textTheme.bodyLarge,
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

                      ///  예산/사용 금액 텍스트
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCircleWidget(true, context),
                          SizedBox(width: 8),
                          Text(
                            '일일 자율 지출 : ${numberFormatting(todaySpending)}원',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCircleWidget(false, context),
                          SizedBox(width: 8),
                          Text(
                            '일일 예산 : ${numberFormatting(state.dailyBudget)}원',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: heightSpace),

                      /// 📈 통계 정보
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                '월평균 자율 지출',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${numberFormatting(state.monthlyVariableExpenseAvg)}원',
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '연속 목표 달성일',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              SizedBox(height: 4),
                              Text('${state.consecutiveAchievementDays}일'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: HomeButton(
                        title: '오늘 지출 보기',
                        subtitle:
                            '총 ${state.todayExpenseList.length}건의 지출이 있어요',
                        onPressed: () {
                          showModalBottomSheet(
                            isDismissible: false,
                            context: context,
                            builder: (context) => TodayExpenseListBottomSheet(
                              expenses: state.todayExpenseList,

                              onClose: () => Navigator.of(context).pop(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: HomeButton(
                        title: '지출 등록',
                        subtitle: '새로운 지출을 등록해 주세요',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => LayoutBuilder(
                              builder: (context, constraints) {
                                final height = constraints.maxHeight; // 최대 80%

                                return SizedBox(
                                  height: height * 0.9,
                                  child: ExpenseAddForm(
                                    uid: user!.id,
                                    onClose: () => Navigator.of(context).pop(),
                                    onSubmit: (expense) {},
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 📦 버튼 위젯
class HomeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const HomeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: AppTheme.boxDecoration,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
