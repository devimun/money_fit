import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/ledger/presentation/categories/category_list.dart';
import 'package:money_fit/features/ledger/presentation/editor/expense_form_fields.dart';
import 'package:money_fit/features/ledger/presentation/editor/expense_form_validator.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class ExpenseAddForm extends ConsumerStatefulWidget {
  final String uid;
  final Future<void> Function(Expense expense) onSubmit;
  final Expense? initExpense;
  const ExpenseAddForm({
    super.key,
    required this.onSubmit,
    required this.uid,
    this.initExpense,
  });

  @override
  ConsumerState<ExpenseAddForm> createState() => _ExpenseAddFormState();
}

class _ExpenseAddFormState extends ConsumerState<ExpenseAddForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isFormValid = false;
  bool _isSaving = false;
  Object? _submitError;
  String? _newExpenseId;
  String? _selectedCategoryId;
  ExpenseType _selectedType = ExpenseType.essential;

  @override
  void initState() {
    super.initState();

    if (widget.initExpense != null) {
      final expense = widget.initExpense!;
      _nameController.text = expense.name;
      _amountController.text = expense.amount.toString();
      _selectedCategoryId = expense.categoryId;
      _selectedType = expense.type;
      _isFormValid = true;
    }

    _nameController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
  }

  void _validateForm() {
    final name = _nameController.text;
    final rawAmount = _amountController.text;

    final isValid = ExpenseFormValidator.validateForm(
      name: name,
      rawAmount: rawAmount,
      selectedCategoryId: _selectedCategoryId,
    );

    if (_isFormValid != isValid || _submitError != null) {
      setState(() {
        _isFormValid = isValid;
        _submitError = null;
      });
    }

    final error = ExpenseFormValidator.getErrorMessage(
      name: name,
      rawAmount: rawAmount,
      selectedCategoryId: _selectedCategoryId,
    );

    if (error != null) {
      debugPrint(error);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BaseBottomSheet(
      title: l10n.registerExpense,
      onClose: () {
        //데이터 초기화
        _nameController.clear();
        _amountController.clear();
        _selectedCategoryId = null;
        _selectedType = ExpenseType.essential;
        _isFormValid = false;
        _validateForm();
        Navigator.pop(context);
      },
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid
                ? context.colors.brandPrimary
                : context.colors.calendarCellBackground,
          ),
          onPressed: !_isFormValid || _isSaving
              ? null
              : () async {
                  await _handleSubmit(widget.uid, l10n);
                },
          child: ResponsiveButtonText(
            text: l10n.register,
            style: context.textTheme.labelLarge?.copyWith(
              color: _isFormValid && !_isSaving
                  ? context.colors.textOnBrand
                  : context.colors.textSecondary,
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (_submitError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.errorOccurred(_submitError.toString()),
                  style: TextStyle(color: context.colors.error),
                ),
              ),
            IgnorePointer(
              ignoring: _isSaving,
              child: ExpenseFormFields(
                nameController: _nameController,
                amountController: _amountController,
                selectedType: _selectedType,
                selectedCategoryId: _selectedCategoryId,
                displayDate:
                    widget.initExpense?.date ?? ref.read(clockProvider).now(),
                enabled: !_isSaving,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedCategoryId = null;
                    _selectedType = type;
                    _submitError = null;
                  });
                },
                onCategorySelected: (categoryId) {
                  setState(() {
                    _selectedCategoryId = categoryId;
                    _submitError = null;
                    _validateForm();
                  });
                },
                categoryList: CategoryList(
                  uid: widget.uid,
                  selectedType: _selectedType,
                  selectedCategoryId: _selectedCategoryId,
                  onSelected: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                      _submitError = null;
                      _validateForm();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(String uid, AppLocalizations l10n) async {
    if (_isSaving) return;
    final name = _nameController.text.trim();
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;
    final categoryId = _selectedCategoryId;
    if (name.isEmpty || amount <= 0 || categoryId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.allFieldsRequired)));
      return;
    }

    setState(() {
      _isSaving = true;
      _submitError = null;
    });

    final now = ref.read(clockProvider).now();
    final existing = widget.initExpense;
    final expense = existing == null
        ? Expense(
            id: _newExpenseId ??= ref.read(idGeneratorProvider).next(),
            userId: uid,
            name: name,
            amount: amount,
            date: now,
            categoryId: categoryId,
            type: _selectedType,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            name: name,
            amount: amount,
            categoryId: categoryId,
            type: _selectedType,
            updatedAt: now,
          );

    try {
      await widget.onSubmit(expense);
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _submitError = error;
        });
      }
      return;
    }

    if (!mounted) return;
    // The presenting screen waits for this sheet to close before it considers
    // optional full-screen experiences. Do not place prompts over this editor.
    if (mounted) Navigator.pop(context, true);
  }
}
