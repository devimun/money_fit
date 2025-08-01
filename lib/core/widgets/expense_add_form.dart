// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/category_model.dart' as category_model;
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';
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
                          constraints: const BoxConstraints(minHeight: 36),
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
                        child: CategoryList(
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

        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: [
            ...filtered.map((e) {
              final isSelected = e.id == selectedCategoryId;

              return InputChip(
                onDeleted: e.isDeletable
                    ? () {
                        _showDeleteConfirmDialog(context, ref, e);
                      }
                    : null,
                label: Text(e.name),
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
                await _showAddCategoryDialog(context, ref, selectedType, uid);
              },
              showCheckmark: false,
              side: BorderSide(width: 0.5, color: notSelectedBorderColor),
              backgroundColor: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.onSecondaryContainer,
              labelStyle: theme.textTheme.labelMedium,
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    ExpenseType type,
    String uid,
  ) async {
    final TextEditingController categoryNameController =
        TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 카테고리 추가'),
          content: TextField(
            controller: categoryNameController,
            decoration: const InputDecoration(labelText: '카테고리 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final categoryName = categoryNameController.text.trim();
                if (categoryName.isNotEmpty) {
                  final newCategory = category_model.Category(
                    id: const Uuid().v4(),
                    userId: uid,
                    name: categoryName,
                    type: type,
                    isDeletable: true,
                  );
                  await ref
                      .read(categoryProvider.notifier)
                      .createCategory(newCategory);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    category_model.Category category,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('카테고리 삭제'),
          content: Text('\'${category.name}\' 카테고리를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(categoryProvider.notifier)
                    .deleteCategory(category);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
