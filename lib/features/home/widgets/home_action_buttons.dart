import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/widgets/expense_add_form.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/home_button.dart';

class HomeActionButtons extends ConsumerWidget {
  final HomeState homeState;
  final String userId;

  const HomeActionButtons({
    super.key,
    required this.homeState,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: HomeButton(
            title: '오늘 지출 보기',
            subtitle: '총 ${homeState.todayExpenseList.length}건의 지출이 있어요',
            onPressed: () {
              showModalBottomSheet(
                isDismissible: false,
                context: context,
                builder: (context) => TodayExpenseListBottomSheet(
                  onClose: () => Navigator.of(context).pop(),
                  isHome: true,
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
                    final height = constraints.maxHeight;

                    return SizedBox(
                      height: height * 0.9,
                      child: ExpenseAddForm(
                        uid: userId,
                        onSubmit: (expense) async {
                          // 지출 등록 후 상태 업데이트
                          await ref
                              .read(homeViewModelProvider.notifier)
                              .addExpense(expense);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}