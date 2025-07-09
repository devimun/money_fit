import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/repositories/category.dart';
import 'package:money_fit/core/widgets/base_bottom_sheet.dart';

class TodayExpenseListBottomSheet extends StatelessWidget {
  final List<Expense> expenses;
  final VoidCallback onClose;

  const TodayExpenseListBottomSheet({
    super.key,
    required this.expenses,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BaseBottomSheet(
      title: '오늘의 지출',
      onClose: onClose,
      child: expenses.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      '오늘의 지출 내역이 없습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) {
                final e = expenses[index];
                final categoryName = categoryMap[e.categoryId] ?? '기타';
                final typeLabel = e.type == ExpenseType.required
                    ? '필수 지출'
                    : '자율 지출';

                return ListTile(
                  title: Text(e.name),
                  subtitle: Text('$typeLabel · $categoryName'),
                  trailing: Text('-${numberFormatting(e.amount)}원'),
                );
              },
            ),
    );
  }
}
