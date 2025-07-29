import 'package:flutter/material.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/repositories/category.dart';

class CategoryFilterSection extends StatelessWidget {
  final ExpenseType? selectedExpenseType;
  final String? selectedCategoryId;
  final Function(String?) onCategoryChanged;

  const CategoryFilterSection({
    super.key,
    required this.selectedExpenseType,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categoryMap = selectedExpenseType == ExpenseType.required
        ? requiredCategoryMap
        : selectedExpenseType == ExpenseType.variable
            ? variableCategoryMap
            : <String, String>{...requiredCategoryMap, ...variableCategoryMap};

    return _buildFormSection(
      label: '카테고리',
      child: selectedExpenseType != null
          ? Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip(
                  context,
                  '모든 카테고리',
                  selectedCategoryId == null,
                  () => onCategoryChanged(null),
                ),
                ...categoryMap.entries.map((entry) {
                  final isSelected = selectedCategoryId == entry.key;
                  return _buildCategoryChip(
                    context,
                    entry.value,
                    isSelected,
                    () => onCategoryChanged(entry.key),
                  );
                }),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '지출 유형을 먼저 선택해주세요',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
      context: context,
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ChoiceChip(
      side: BorderSide.none,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.onSecondaryContainer,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
      showCheckmark: false,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
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