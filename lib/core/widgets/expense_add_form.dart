// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/repositories/category.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';
import 'package:uuid/uuid.dart';

class ExpenseAddForm extends StatefulWidget {
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
  State<ExpenseAddForm> createState() => _ExpenseAddFormState();
}

class _ExpenseAddFormState extends State<ExpenseAddForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isFormValid = false;
  String? _selectedCategoryId;
  ExpenseType _selectedType = ExpenseType.required;
  @override
  void initState() {
    super.initState();

    if (widget.initExpense != null) {
      final expense = widget.initExpense!;
      _nameController.text = expense.name;
      _amountController.text = numberFormatting(expense.amount);
      _selectedCategoryId = expense.categoryId;
      _selectedType = expense.type;
      _isFormValid = true;
    }

    _nameController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
  }

  void _validateForm() {
    final name = _nameController.text.trim();
    final rawAmount = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(rawAmount) ?? 0;

    String? error;

    if (name.isEmpty) {
      error = '이름이 비어 있습니다.';
    } else if (rawAmount.isEmpty || amount <= 0) {
      error = '금액이 올바르지 않거나 0 이하입니다.';
    } else if (_selectedCategoryId == null) {
      error = '카테고리를 선택하지 않았습니다.';
    }

    final isValid = error == null;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }

    if (error != null) {
      debugPrint('폼 유효성 오류: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: '지출 등록',
      onClose: () {
        //데이터 초기화
        _nameController.clear();
        _amountController.clear();
        _selectedCategoryId = null;
        _selectedType = ExpenseType.required;
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
            await _handleSubmit(widget.uid);
          },
          child: Text(
            '등록하기',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _isFormValid
                  ? null
                  : Theme.of(context).textTheme.labelSmall?.color,
            ),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection(
              label: '날짜',
              child: Text(
                dateFormatting(DateTime.now()),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              context: context,
            ),
            _buildFormSection(
              label: '지출명',
              child: TextField(
                onChanged: (value) => _validateForm(),
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '지출명을 입력해주세요',
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                ),
              ),

              context: context,
            ),
            _buildFormSection(
              label: '금액',
              child: TextField(
                onChanged: (value) {
                  value = value.replaceAll(' ', '');
                  if (value.isEmpty) {
                    _amountController.text = '';
                  } else {
                    double pay = double.parse(value.replaceAll(',', ''));
                    _amountController.text = numberFormatting(pay);
                  }
                  _validateForm();
                },
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '지출 금액을 입력해주세요',
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              context: context,
            ),
            _buildFormSection(
              label: '지출 유형',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ToggleButtons(
                          constraints: BoxConstraints(minHeight: 36),
                          isSelected: [
                            _selectedType == ExpenseType.required,
                            _selectedType == ExpenseType.variable,
                          ],
                          onPressed: (index) {
                            setState(() {
                              _selectedCategoryId = null; // 카테고리 초기화
                              _selectedType = index == 0
                                  ? ExpenseType.required
                                  : ExpenseType.variable;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),

                          selectedBorderColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          fillColor: Theme.of(context).colorScheme.primary,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface, // 기본 텍스트 색
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '필수 지출',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color:
                                          _selectedType == ExpenseType.required
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                          : null,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                '자율 지출',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color:
                                          _selectedType == ExpenseType.variable
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                          : null,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8,
                          children:
                              (_selectedType == ExpenseType.required
                                      ? requiredCategoryMap
                                      : variableCategoryMap)
                                  .entries
                                  .map((entry) {
                                    final isSelected =
                                        entry.key == _selectedCategoryId;
                                    return ChoiceChip(
                                      side: BorderSide(
                                        width: 0.5,
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Theme.of(context).brightness ==
                                                  Brightness.dark
                                            ? Theme.of(context)
                                                      .inputDecorationTheme
                                                      .enabledBorder
                                                      ?.borderSide
                                                      .color ??
                                                  Colors.grey
                                            : Colors.black.withValues(
                                                alpha: 0.15,
                                              ),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer,
                                      selectedColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary
                                                : null,
                                          ),

                                      showCheckmark: false,
                                      label: Text(entry.value),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          _selectedCategoryId = entry.key;
                                          _validateForm();
                                        });
                                      },
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(String uid) async {
    final name = _nameController.text.trim();
    final amount =
        double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;
    final categoryId = _selectedCategoryId;
    if (name.isEmpty || amount <= 0 || categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 올바르게 입력해주세요.')));
      return;
    }

    final now = DateTime.now();
    final expense = Expense(
      id: widget.initExpense?.id ?? Uuid().v4(),
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
    Navigator.pop(context);
  }
}

_buildFormSection({
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
