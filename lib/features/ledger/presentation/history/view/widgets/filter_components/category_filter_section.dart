import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class CategoryFilterSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoryState = ref.watch(categoryProvider);

    if (selectedExpenseType == null) {
      return _buildFormSection(
        label: l10n.category,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.inputBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.selectExpenseTypeFirst,
            style: context.textTheme.labelSmall,
          ),
        ),
        context: context,
      );
    }

    if (categoryState.isLoading) {
      return _buildFormSection(
        label: l10n.category,
        child: const Center(child: CircularProgressIndicator()),
        context: context,
      );
    }

    if (categoryState.hasError || categoryState.value == null) {
      return _buildFormSection(
        label: l10n.category,
        child: Text(
          l10n.errorLoadingCategories,
          style: context.textTheme.labelSmall,
        ),
        context: context,
      );
    }

    final filteredCategories = categoryState.value!
        .where((c) => c.type == selectedExpenseType)
        .toList();

    return _buildFormSection(
      label: l10n.category,
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildCategoryChip(
            context,
            l10n.allCategories,
            selectedCategoryId == null,
            () => onCategoryChanged(null),
          ),
          ...filteredCategories.map((c) {
            final isSelected = selectedCategoryId == c.id;
            String label = ref
                .read(categoryProvider.notifier)
                .getCategoryName(context, c.id);
            return _buildCategoryChip(
              context,
              label,
              isSelected,
              () => onCategoryChanged(c.id),
            );
          }),
        ],
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
      backgroundColor: context.isDarkMode
          ? context.colors.inputBackground
          : context.colors.calendarCellBackground,
      selectedColor: context.colors.brandPrimary,
      labelStyle: context.textTheme.labelMedium?.copyWith(
        color: isSelected ? context.colors.textOnBrand : null,
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
        Text(label, style: context.textTheme.labelMedium),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
