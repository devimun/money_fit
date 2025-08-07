import 'package:flutter/material.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class ExpenseTypeFilterSection extends StatelessWidget {
  final ExpenseType? selectedExpenseType;
  final Function(ExpenseType?) onExpenseTypeChanged;

  const ExpenseTypeFilterSection({
    super.key,
    required this.selectedExpenseType,
    required this.onExpenseTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildFormSection(
      label: l10n.expenseType,
      child: Row(
        children: [
          Expanded(
            child: ToggleButtons(
              constraints: const BoxConstraints(minHeight: 36),
              isSelected: [
                selectedExpenseType == null,
                selectedExpenseType == ExpenseType.essential,
                selectedExpenseType == ExpenseType.discretionary,
              ],
              onPressed: (index) {
                switch (index) {
                  case 0:
                    onExpenseTypeChanged(null);
                    break;
                  case 1:
                    onExpenseTypeChanged(ExpenseType.essential);
                    break;
                  case 2:
                    onExpenseTypeChanged(ExpenseType.discretionary);
                    break;
                }
              },
              borderRadius: BorderRadius.circular(10),
              selectedBorderColor: Theme.of(context).colorScheme.primary,
              fillColor: Theme.of(context).colorScheme.primary,
              selectedColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.onSurface,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    l10n.allExpenses,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selectedExpenseType == null
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    l10n.essentialExpense,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selectedExpenseType == ExpenseType.essential
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    l10n.discretionaryExpense,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selectedExpenseType == ExpenseType.discretionary
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      context: context,
    );
  }

  Widget _buildFormSection({
    required String label,
    required Widget child,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
