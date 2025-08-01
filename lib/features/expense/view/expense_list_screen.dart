import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/category_model.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/features/expense/viewmodel/expense_list_provider.dart';
import 'package:money_fit/features/expense/view/widgets/expense_filter_bottom_sheet.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';

// 날짜별 지출 내역을 리스트 형식으로 보여주는 뷰
// 월별 데이터를 기본으로 제공하며, 특정 월, 카테고리별, 지출별로 조회할 수 있도록 필터링 기능을 제공한다.
class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expenseListProvider);
    final categoryState = ref.watch(categoryProvider);

    if (categoryState.isLoading || categoryState.hasError) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: expensesState.when(
        data: (data) {
          final entries = data.expenses.entries.toList();
          // sortType에 따라 날짜(key)를 기준으로 오름차순/내림차순 정렬
          entries.sort((a, b) {
            return data.sortType == SortType.asc
                ? a.key.compareTo(b.key)
                : b.key.compareTo(a.key);
          });

          return Column(
            children: [
              _buildHeader(data, ref, context, categoryState.value!),

              const AdBannerWidget(screenType: ScreenType.expenses),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: entries.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            return _buildDayExpenses(
                              entries[index].key,
                              entries[index].value,
                              categoryState.value!,
                              context,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text('에러가 발생했습니다 : $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // 날짜 헤더와 필터 상태 보여주는 위젯
  Widget _buildHeader(
    ExpensesListState data,
    WidgetRef ref,
    BuildContext context,
    List<Category> category,
  ) {
    final year = data.searchDate.year.toString().substring(2); // e.g. 25
    final month = data.searchDate.month.toString().padLeft(2, '0'); // e.g. 07

    final typeLabel = data.expenseType == null
        ? '모든 지출'
        : data.expenseType == ExpenseType.required
        ? '필수 지출'
        : '자율 지출';

    final categoryLabel = () {
      if (data.categoryId == null) return '모든 카테고리';
      final categoryElement = category.firstWhere(
        (c) => c.id == data.categoryId,
        orElse: () => Category(
          id: '',
          name: '알 수 없음',
          type: ExpenseType.n,
          isDeletable: false,
        ),
      );
      return categoryElement.name;
    }();

    final sortLabel = data.sortType == SortType.asc ? '오름차순' : '내림차순';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$year년 $month월 · $typeLabel · $categoryLabel · $sortLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.manage_search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: ExpenseFilterBottomSheet(currentState: data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 하루치 지출 내역을 보여주는 섹션
  Widget _buildDayExpenses(
    DateTime date,
    List<Expense> expenses,
    List<Category> categories,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateFormatting(date),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Divider(color: Theme.of(context).colorScheme.primary, thickness: 0.5),
        for (Expense e in expenses) _buildExpenseWidget(e, context, categories),
        const SizedBox(height: 8),
      ],
    );
  }

  // 개별 지출 위젯
  Widget _buildExpenseWidget(
    Expense e,
    BuildContext context,
    List<Category> categories,
  ) {
    final categoryName = categories
        .firstWhere(
          (c) => c.id == e.categoryId,
          orElse: () => Category(
            id: '',
            name: '알 수 없음',
            type: ExpenseType.n,
            isDeletable: false,
          ),
        )
        .name;
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

  // 데이터가 없을 때 보여줄 위젯
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            '지출 내역이 존재하지 않습니다',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '필터 조건을 변경하거나\n새로운 지출을 추가해보세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
