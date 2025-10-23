import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class BudgetModeTabs extends ConsumerWidget {
  const BudgetModeTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeStateAsync = ref.watch(homeViewModelProvider);

    if (homeStateAsync.isLoading || !homeStateAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final homeState = homeStateAsync.value!;
    final isMonthly = homeState.budgetDisplayMode == BudgetDisplayMode.monthly;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildBudgetModeTab(
                context,
                AppLocalizations.of(context)!.daily,
                BudgetDisplayMode.daily,
                !isMonthly,
                ref,
              ),
              _buildBudgetModeTab(
                context,
                AppLocalizations.of(context)!.monthly,
                BudgetDisplayMode.monthly,
                isMonthly,
                ref,
              ),
            ],
          ),

          Divider(
            height: 0,
            thickness: 0.2,
            color: Theme.of(context).colorScheme.onSecondaryFixed,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBudgetModeTab(
    BuildContext context,
    String title,
    BudgetDisplayMode mode,
    bool isSelected,
    WidgetRef ref,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          ref
              .read(homeViewModelProvider.notifier)
              .toggleBudgetDisplayMode(mode);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.only(
              topLeft: mode == BudgetDisplayMode.daily
                  ? const Radius.circular(16)
                  : Radius.zero,
              topRight: mode == BudgetDisplayMode.monthly
                  ? const Radius.circular(16)
                  : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).unselectedWidgetColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
