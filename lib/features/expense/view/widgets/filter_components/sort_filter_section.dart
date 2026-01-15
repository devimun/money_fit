import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/expense/viewmodel/expense_list_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class SortFilterSection extends StatelessWidget {
  final SortType selectedSortType;
  final Function(SortType) onSortTypeChanged;

  const SortFilterSection({
    super.key,
    required this.selectedSortType,
    required this.onSortTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildFormSection(
      label: l10n.sort,
      child: Row(
        children: [
          Expanded(
            child: ToggleButtons(
              constraints: const BoxConstraints(minHeight: 36),
              isSelected: [
                selectedSortType == SortType.desc,
                selectedSortType == SortType.asc,
              ],
              onPressed: (index) {
                onSortTypeChanged(index == 0 ? SortType.desc : SortType.asc);
              },
              borderRadius: BorderRadius.circular(10),
              selectedBorderColor: context.colors.brandPrimary,
              fillColor: context.colors.brandPrimary,
              selectedColor: context.colors.brandPrimary,
              color: context.colors.textPrimary,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    l10n.latest,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: selectedSortType == SortType.desc
                          ? context.colors.textOnBrand
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    l10n.oldest,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: selectedSortType == SortType.asc
                          ? context.colors.textOnBrand
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
        Text(label, style: context.textTheme.labelMedium),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}