import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';
import 'package:money_fit/features/expense/viewmodel/expense_list_provider.dart';
import 'package:money_fit/features/expense/view/widgets/filter_components/date_filter_section.dart';
import 'package:money_fit/features/expense/view/widgets/filter_components/expense_type_filter_section.dart';
import 'package:money_fit/features/expense/view/widgets/filter_components/category_filter_section.dart';
import 'package:money_fit/features/expense/view/widgets/filter_components/sort_filter_section.dart';
import 'package:money_fit/features/expense/view/widgets/filter_components/filter_action_buttons.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class ExpenseFilterBottomSheet extends ConsumerStatefulWidget {
  final ExpensesListState currentState;

  const ExpenseFilterBottomSheet({super.key, required this.currentState});

  @override
  ConsumerState<ExpenseFilterBottomSheet> createState() =>
      _ExpenseFilterBottomSheetState();
}

class _ExpenseFilterBottomSheetState
    extends ConsumerState<ExpenseFilterBottomSheet> {
  late DateTime _selectedDate;
  late ExpenseType? _selectedExpenseType;
  late String? _selectedCategoryId;
  late SortType _selectedSortType;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentState.searchDate;
    _selectedExpenseType = widget.currentState.expenseType;
    _selectedCategoryId = widget.currentState.categoryId;
    _selectedSortType = widget.currentState.sortType;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BaseBottomSheet(
      title: l10n.filterSettings,
      onClose: () => Navigator.pop(context),
      footer: FilterActionButtons(
        selectedDate: _selectedDate,
        selectedExpenseType: _selectedExpenseType,
        selectedCategoryId: _selectedCategoryId,
        selectedSortType: _selectedSortType,
        onReset: _resetFilters,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateFilterSection(
              selectedDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: 20),
            ExpenseTypeFilterSection(
              selectedExpenseType: _selectedExpenseType,
              onExpenseTypeChanged: (type) {
                setState(() {
                  _selectedExpenseType = type;
                  _selectedCategoryId = null; // 카테고리 초기화
                });
              },
            ),
            const SizedBox(height: 20),
            CategoryFilterSection(
              selectedExpenseType: _selectedExpenseType,
              selectedCategoryId: _selectedCategoryId,
              onCategoryChanged: (categoryId) {
                setState(() {
                  _selectedCategoryId = categoryId;
                });
              },
            ),
            const SizedBox(height: 20),
            SortFilterSection(
              selectedSortType: _selectedSortType,
              onSortTypeChanged: (sortType) {
                setState(() {
                  _selectedSortType = sortType;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedDate = DateTime.now();
      _selectedExpenseType = null;
      _selectedCategoryId = null;
      _selectedSortType = SortType.desc;
    });
  }
}