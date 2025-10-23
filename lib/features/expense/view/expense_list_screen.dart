import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/category_model.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';
import 'package:money_fit/features/expense/viewmodel/expense_list_provider.dart';
import 'package:money_fit/features/expense/view/widgets/expense_filter_bottom_sheet.dart';
import 'package:money_fit/l10n/app_localizations.dart';

// 날짜별 지출 내역을 리스트 형식으로 보여주는 뷰
// 월별 데이터를 기본으로 제공하며, 특정 월, 카테고리별, 지출별로 조회할 수 있도록 필터링 기능을 제공한다.
class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
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
              _buildHeader(
                data,
                ref,
                context,
                categoryState.value!,
                l10n,
                locale,
              ),

              const AdBannerWidget(screenType: ScreenType.expenses),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: entries.isEmpty
                      ? _buildEmptyState(context, l10n)
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            return _buildDayExpenses(
                              entries[index].key,
                              entries[index].value,
                              categoryState.value!,
                              context,
                              ref,
                              l10n,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text(l10n.errorOccurred(error.toString()))),
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
    AppLocalizations l10n,
    String locale,
  ) {
    final date = data.searchDate;

    final typeLabel = data.expenseType == null
        ? l10n.allExpenses
        : getExpenseTypeName(context, data.expenseType!);

    final categoryLabel = () {
      if (data.categoryId == null) return l10n.allCategories;
      final categoryElement = category.firstWhere(
        (c) => c.id == data.categoryId,
        orElse: () => Category(
          id: '',
          name: l10n.unknown,
          type: ExpenseType.n,
          isDeletable: false,
        ),
      );
      return ref
          .read(categoryProvider.notifier)
          .getCategoryName(context, categoryElement.id);
    }();

    final sortLabel = data.sortType == SortType.asc
        ? l10n.ascending
        : l10n.descending;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                '${l10n.yearMonth(DateFormat.MMM(locale).format(date), DateFormat.y(locale).format(date))} · $typeLabel · $categoryLabel · $sortLabel',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
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
                  height: MediaQuery.of(context).size.height * 0.65,
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
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat(l10n.dateFormat, locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateFormat.format(date),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Divider(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.55),
          thickness: 0.6,
        ),
        for (Expense e in expenses)
          _buildExpenseWidget(e, context, ref, categories, l10n),
        const SizedBox(height: 8),
      ],
    );
  }

  // 개별 지출 위젯
  Widget _buildExpenseWidget(
    Expense e,
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
    AppLocalizations l10n,
  ) {
    final categoryName = ref
        .read(categoryProvider.notifier)
        .getCategoryName(context, e.categoryId);
    final typeLabel = getExpenseTypeName(context, e.type);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(e.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        '$typeLabel · $categoryName',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      trailing: Text(
        '-${formatCurrencyAdaptive(context, e.amount)}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  // 데이터가 없을 때 보여줄 위젯
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64),
          const SizedBox(height: 16),
          Text(
            l10n.noExpenseData,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.changeFilterPrompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
