import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// 지출 등록 폼의 필드들을 관리하는 위젯
class ExpenseFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final ExpenseType selectedType;
  final String? selectedCategoryId;
  final VoidCallback onTypeChanged;
  final void Function(String categoryId) onCategorySelected;
  final Widget categoryList;

  const ExpenseFormFields({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.selectedType,
    required this.selectedCategoryId,
    required this.onTypeChanged,
    required this.onCategorySelected,
    required this.categoryList,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormSection(
          label: l10n.date,
          child: Text(
            dateFormatting(context, DateTime.now()),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          context: context,
        ),
        _buildFormSection(
          label: l10n.expenseName,
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: l10n.enterExpenseName,
              hintStyle: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          context: context,
        ),
        _buildFormSection(
          label: l10n.amount,
          child: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l10n.enterExpenseAmount,
              hintStyle: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          context: context,
        ),
        _buildFormSection(
          label: l10n.expenseType,
          child: Column(
            children: [
              _buildExpenseTypeToggle(context, l10n),
              const SizedBox(height: 10),
              categoryList,
            ],
          ),
          context: context,
        ),
      ],
    );
  }

  Widget _buildExpenseTypeToggle(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: ToggleButtons(
            constraints: const BoxConstraints(minHeight: 36),
            isSelected: [
              selectedType == ExpenseType.essential,
              selectedType == ExpenseType.discretionary,
            ],
            onPressed: (index) {
              onTypeChanged();
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
                  l10n.essentialExpense,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selectedType == ExpenseType.essential
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
                    color: selectedType == ExpenseType.discretionary
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        const SizedBox(height: 20),
      ],
    );
  }
}
