import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/ledger/presentation/history/viewmodel/expense_list_provider.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class FilterActionButtons extends ConsumerWidget {
  final DateTime selectedDate;
  final ExpenseType? selectedExpenseType;
  final String? selectedCategoryId;
  final SortType selectedSortType;
  final VoidCallback onReset;

  const FilterActionButtons({
    super.key,
    required this.selectedDate,
    required this.selectedExpenseType,
    required this.selectedCategoryId,
    required this.selectedSortType,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.isDarkMode
                  ? context.colors.inputBackground
                  : context.colors.calendarCellBackground,
            ),
            onPressed: onReset,
            child: Text(l10n.reset, style: context.textTheme.labelMedium),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.brandPrimary,
            ),
            onPressed: () {
              ref
                  .read(expenseListProvider.notifier)
                  .applyFilters(
                    searchDate: selectedDate,
                    expenseType: selectedExpenseType,
                    categoryId: selectedCategoryId,
                    sortType: selectedSortType,
                  );
              Navigator.pop(context);
              unawaited(
                ref.read(monetizationSafePointProvider)(
                  MeaningfulAdAction.expenseFilterApplied,
                ),
              );
            },
            child: Text(
              l10n.apply,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colors.textOnBrand,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
