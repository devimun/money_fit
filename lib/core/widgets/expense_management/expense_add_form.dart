import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/core/services/review_prompt_service.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';
import 'package:money_fit/core/widgets/expense_management/expense_form_fields.dart';
import 'package:money_fit/core/widgets/expense_management/category_management/category_list.dart';
import 'package:money_fit/core/widgets/expense_management/expense_form_validator.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ExpenseAddForm extends ConsumerStatefulWidget {
  final String uid;
  final void Function(Expense expense) onSubmit;
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

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
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
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          onPressed: () async {
            if (!_isFormValid) return;
            await _handleSubmit(widget.uid, l10n);
          },
          child: Text(
            l10n.register,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _isFormValid
                  ? null
                  : Theme.of(context).textTheme.labelSmall?.color,
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: ExpenseFormFields(
          nameController: _nameController,
          amountController: _amountController,
          selectedType: _selectedType,
          selectedCategoryId: _selectedCategoryId,
          onTypeChanged: () {
            setState(() {
              _selectedCategoryId = null; // 카테고리 초기화
              _selectedType = _selectedType == ExpenseType.essential
                  ? ExpenseType.discretionary
                  : ExpenseType.essential;
            });
          },
          onCategorySelected: (categoryId) {
            setState(() {
              _selectedCategoryId = categoryId;
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
                _validateForm();
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(String uid, AppLocalizations l10n) async {
    // 지출 등록 액션 기록
    await InterstitialAdManager.instance.logActionAndShowAd();
    final name = _nameController.text.trim();
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;
    final categoryId = _selectedCategoryId;
    if (name.isEmpty || amount <= 0 || categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.allFieldsRequired)));
      return;
    }

    final now = DateTime.now();
    final expense = Expense(
      id: widget.initExpense?.id ?? const Uuid().v4(),
      userId: uid,
      name: name,
      amount: amount,
      date: now,
      categoryId: categoryId,
      type: _selectedType,
      createdAt: now,
      updatedAt: now,
    );

    widget.onSubmit(expense);

    // context가 유효한 경우에만 리뷰 프롬프트 표시
    if (context.mounted) {
      await ReviewPromptService.instance.maybePromptReview(context);
    }

    // context가 여전히 유효한 경우에만 pop 실행
    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }
}
