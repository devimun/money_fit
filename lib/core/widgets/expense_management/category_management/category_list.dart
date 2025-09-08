import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/widgets/expense_management/category_management/category_dialogs.dart';

/// 카테고리 목록을 표시하는 위젯
class CategoryList extends ConsumerWidget {
  final String uid;
  final ExpenseType selectedType;
  final String? selectedCategoryId;
  final void Function(String categoryId) onSelected;

  const CategoryList({
    super.key,
    required this.uid,
    required this.selectedType,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryProvider);

    return categoryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('$error,$stackTrace')),
      data: (categories) {
        // 필터링
        final filtered = categories
            .where((e) => e.type == selectedType)
            .toList();

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final inputBorderColor =
            theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
            Colors.grey;
        final notSelectedBorderColor = isDark
            ? inputBorderColor
            : Colors.black.withAlpha(38);

        return SizedBox(
          width: double.maxFinite,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              ...filtered.map((e) {
                final isSelected = e.id == selectedCategoryId;

                return InputChip(
                  onDeleted: e.isDeletable
                      ? () {
                          CategoryDialogs.showDeleteConfirmDialog(
                            context,
                            ref,
                            e,
                          );
                        }
                      : null,
                  label: Text(
                    ref
                        .read(categoryProvider.notifier)
                        .getCategoryName(context, e.id),
                  ),
                  selected: isSelected,
                  onSelected: (_) => onSelected(e.id),
                  showCheckmark: false,
                  side: BorderSide(
                    width: 0.5,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : notSelectedBorderColor,
                  ),
                  backgroundColor: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.onSecondaryContainer,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? theme.colorScheme.onPrimary : null,
                  ),
                );
              }),
              ChoiceChip(
                label: const Icon(Icons.add, size: 15.0),
                selected: false,
                onSelected: (_) async {
                  await CategoryDialogs.showAddCategoryDialog(
                    context,
                    ref,
                    selectedType,
                    uid,
                  );
                },
                showCheckmark: false,
                side: BorderSide(width: 0.5, color: notSelectedBorderColor),
                backgroundColor: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.onSecondaryContainer,
                labelStyle: theme.textTheme.labelMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
