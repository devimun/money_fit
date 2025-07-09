import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/repositories/category.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';

class ExpenseAddForm extends StatefulWidget {
  final VoidCallback onClose;
  final String uid;
  final void Function(Expense expense) onSubmit;

  const ExpenseAddForm({
    super.key,
    required this.onClose,
    required this.onSubmit,
    required this.uid,
  });

  @override
  State<ExpenseAddForm> createState() => _ExpenseAddFormState();
}

class _ExpenseAddFormState extends State<ExpenseAddForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  ExpenseType _selectedType = ExpenseType.required;

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: '지출 등록',
      onClose: widget.onClose,
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await _handleSubmit(widget.uid);
          },
          child: const Text('등록하기'),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('날짜', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(DateTime.now())),

            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '지출명',
                hintText: '지출명을 입력하세요',
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '금액',
                suffixText: '원',
                hintText: '금액을 입력하세요',
              ),
            ),

            const SizedBox(height: 16),
            Text('지출 유형', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [
                _selectedType == ExpenseType.required,
                _selectedType == ExpenseType.variable,
              ],
              onPressed: (index) {
                setState(() {
                  _selectedType = index == 0
                      ? ExpenseType.required
                      : ExpenseType.variable;
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('필수 지출'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('자율 지출'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text('카테고리', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),

            // categoryMap 기반 카테고리 선택
            Wrap(
              spacing: 8,
              children: categoryMap.entries.map((entry) {
                final isSelected = entry.key == _selectedCategoryId;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryId = entry.key;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(String uid) async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final categoryId = _selectedCategoryId;

    if (name.isEmpty || amount <= 0 || categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 올바르게 입력해주세요.')));
      return;
    }

    final now = DateTime.now();
    final expense = Expense(
      id: uid,
      userId: 'user123', // 예시용, 실제로는 context에서 받아야 함
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
