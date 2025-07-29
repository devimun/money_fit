import 'package:flutter/material.dart';
import 'package:money_fit/core/models/expense_model.dart';

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
    return _buildFormSection(
      label: '지출 유형',
      child: Row(
        children: [
          Expanded(
            child: ToggleButtons(
              constraints: const BoxConstraints(minHeight: 36),
              isSelected: [
                selectedExpenseType == null,
                selectedExpenseType == ExpenseType.required,
                selectedExpenseType == ExpenseType.variable,
              ],
              onPressed: (index) {
                switch (index) {
                  case 0:
                    onExpenseTypeChanged(null);
                    break;
                  case 1:
                    onExpenseTypeChanged(ExpenseType.required);
                    break;
                  case 2:
                    onExpenseTypeChanged(ExpenseType.variable);
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
                    '모든 지출',
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
                    '필수 지출',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selectedExpenseType == ExpenseType.required
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '자율 지출',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selectedExpenseType == ExpenseType.variable
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