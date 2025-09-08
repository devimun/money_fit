import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/widgets/expense_management/expense_add_form.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/home_button.dart';
import 'package:money_fit/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: HomeButton(
            title: l10n.viewTodaySpending,
            subtitle: l10n.totalSpendingCount(
              homeState.todayExpenseList.length,
            ),
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
            title: l10n.addExpense,
            subtitle: l10n.addNewExpensePrompt,
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
