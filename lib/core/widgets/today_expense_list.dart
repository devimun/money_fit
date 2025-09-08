import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';

import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/providers/expenses_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';
import 'package:money_fit/core/widgets/expense_management/expense_add_form.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class TodayExpenseListBottomSheet extends ConsumerWidget {
  final VoidCallback onClose;
  final bool isHome;

  const TodayExpenseListBottomSheet({
    super.key,
    required this.onClose,
    required this.isHome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(coreExpensesProvider);
    final selectedDate = ref.watch(dateManager);
    final categoryState = ref.watch(categoryProvider);
    if (categoryState.isLoading || categoryState.hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    final expenses = asyncState.when(
      data: (_) => ref
          .watch(coreExpensesProvider.notifier)
          .getTodayExpense(selectedDate),
      loading: () => null,
      error: (_, __) => null,
    );

    return BaseBottomSheet(
      title: !isHome
          ? dateFormatting(context, selectedDate)
          : l10n.dailyExpenseHistory,
      onClose: onClose,
      child: expenses == null
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noExpenseHistory,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: expenses.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: const Divider(thickness: 0.1),
              ),
              itemBuilder: (_, index) {
                final e = expenses[index];
                final categoryName = ref
                    .read(categoryProvider.notifier)
                    .getCategoryName(context, e.categoryId);
                final typeLabel = getExpenseTypeName(context, e.type);

                return Material(
                  child: InkWell(
                    onLongPress: () {
                      if (isHome) {}
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(l10n.editDeleteExpense),
                            content: Text(l10n.editDeleteExpensePrompt(e.name)),
                            actions: [
                              if (isHome)
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return ExpenseAddForm(
                                          initExpense: e,
                                          uid: e.userId,
                                          onSubmit: (updatedExpense) async {
                                            await ref
                                                .read(
                                                  homeViewModelProvider
                                                      .notifier,
                                                )
                                                .updateExpense(updatedExpense);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Text(l10n.edit),
                                ),
                              TextButton(
                                onPressed: () async {
                                  if (isHome) {
                                    await ref
                                        .read(homeViewModelProvider.notifier)
                                        .deleteExpense(e);
                                  } else {
                                    await ref
                                        .read(coreExpensesProvider.notifier)
                                        .deleteExpense(e);
                                  }
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(l10n.delete),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: ListTile(
                      title: Text(e.name),
                      subtitle: Text(
                        '$typeLabel · $categoryName',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      trailing: Text(
                        '-${formatCurrencyAdaptive(context, e.amount)}',
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
