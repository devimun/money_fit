import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';

import 'package:money_fit/features/ledger/application/legacy/category_providers.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';
import 'package:money_fit/features/ledger/presentation/editor/expense_add_form.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class TodayExpenseListBottomSheet extends ConsumerWidget {
  final VoidCallback onClose;
  final bool isHome;
  final DateTime? selectedDate;

  const TodayExpenseListBottomSheet({
    super.key,
    required this.onClose,
    required this.isHome,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncState = ref.watch(coreExpensesProvider);
    final selectedDate =
        this.selectedDate ??
        ref.watch(ledgerVisibleDateProvider) ??
        DateTime.now();
    final categoryState = ref.watch(categoryProvider);
    if (categoryState.isLoading || categoryState.hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    return BaseBottomSheet(
      title: !isHome
          ? dateFormatting(context, selectedDate)
          : l10n.dailyExpenseHistory,
      onClose: onClose,
      child: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ExpenseLoadError(
          message: l10n.errorOccurred(error.toString()),
          onRetry: () => ref.invalidate(coreExpensesProvider),
        ),
        data: (_) {
          final expenses = ref
              .watch(coreExpensesProvider.notifier)
              .getTodayExpense(selectedDate);
          return expenses.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: context.colors.navUnselected,
                        ),
                        const SizedBox(height: 16),
                        ResponsiveMessageText(
                          text: l10n.noExpenseHistory,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colors.textSecondary,
                          ),
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
                                title: ResponsiveTitleText(
                                  text: l10n.editDeleteExpense,
                                ),
                                content: ResponsiveDescriptionText(
                                  text: l10n.editDeleteExpensePrompt(e.name),
                                ),
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
                                                      coreExpensesProvider
                                                          .notifier,
                                                    )
                                                    .updateExpense(
                                                      updatedExpense,
                                                    );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: ResponsiveButtonText(
                                        text: l10n.edit,
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: () async {
                                      if (isHome) {
                                        await ref
                                            .read(coreExpensesProvider.notifier)
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
                                    child: ResponsiveButtonText(
                                      text: l10n.delete,
                                    ),
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
                            style: context.textTheme.labelSmall,
                          ),
                          trailing: Text(
                            '-${formatCurrencyAdaptive(context, e.amount)}',
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}

class _ExpenseLoadError extends StatelessWidget {
  const _ExpenseLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            tooltip: MaterialLocalizations.of(
              context,
            ).refreshIndicatorSemanticLabel,
          ),
        ],
      ),
    );
  }
}
