import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/expense_model.dart';

import 'package:money_fit/core/repositories/category.dart';
import 'package:money_fit/features/expense/viewmodel/expense_list_provider.dart';

// 날짜별 지출 내역을 리스트 형식으로 보여주는 뷰
// 월별 데이터를 기본으로 제공하며, 특정 월, 카테고리별, 지출별로 조회할 수 있도록 필터링 기능을 제공한다.
class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expenseListProvider);

    return Scaffold(
      body: expensesState.when(
        data: (data) {
          final entries = data.expenses.entries.toList();

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildHeader(data, ref),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return _buildDayExpenses(
                        entries[index].key,
                        entries[index].value,
                        context,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text('에러가 발생했습니다 : $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // 날짜 헤더와 필터 상태 보여주는 위젯
  Widget _buildHeader(ExpensesListState data, WidgetRef ref) {
    final year = data.searchDate.year.toString().substring(2); // e.g. 25
    final month = data.searchDate.month.toString().padLeft(2, '0'); // e.g. 07

    final typeLabel = data.expenseType == null
        ? '모든 지출'
        : data.expenseType == ExpenseType.required
        ? '필수 지출'
        : '자율 지출';

    final categoryLabel = () {
      if (data.categoryId == null) return '모든 카테고리';
      final map = data.expenseType == ExpenseType.required
          ? requiredCategoryMap
          : variableCategoryMap;
      return map[data.categoryId] ?? '알 수 없음';
    }();

    final sortLabel = data.sortType == SortType.asc ? '오름차순' : '내림차순';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$year년 $month월 · $typeLabel · $categoryLabel · $sortLabel'),
        IconButton(
          icon: const Icon(Icons.manage_search),
          onPressed: () {
            // TODO: 바텀시트 열기 (필터 변경)
          },
        ),
      ],
    );
  }

  // 하루치 지출 내역을 보여주는 섹션
  Widget _buildDayExpenses(
    DateTime date,
    List<Expense> expenses,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateFormatting(date),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        for (Expense e in expenses) _buildExpenseWidget(e, context),
        const SizedBox(height: 16),
      ],
    );
  }

  // 개별 지출 위젯
  Widget _buildExpenseWidget(Expense e, BuildContext context) {
    final categoryName = e.type == ExpenseType.required
        ? requiredCategoryMap[e.categoryId]
        : variableCategoryMap[e.categoryId];
    final typeLabel = e.type == ExpenseType.required ? '필수 지출' : '자율 지출';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(e.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        '$typeLabel · $categoryName',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Text(
        '-${numberFormatting(e.amount)}원',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
