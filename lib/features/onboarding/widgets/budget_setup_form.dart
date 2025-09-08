import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class BudgetSetupForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController budgetController;
  final VoidCallback onSubmitted;
  final BudgetType selectedType;
  final ValueChanged<BudgetType?> onTypeChanged;

  const BudgetSetupForm({
    super.key,
    required this.formKey,
    required this.budgetController,
    required this.onSubmitted,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dailyBudgetSetupTitle, // This title might need to be more generic
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.budgetSetupDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 30),
          SegmentedButton<BudgetType>(
            showSelectedIcon: false,
            style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
              side: WidgetStatePropertyAll(BorderSide(width: 0.2)),
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  // 선택된 버튼의 배경색
                  return Theme.of(context).colorScheme.primary;
                }
                // 선택되지 않은 버튼의 배경색
                return Theme.of(context).colorScheme.surface;
              }),
              // 선택되었을 때와 아닐 때의 텍스트/아이콘 색상을 지정합니다.
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  // 선택된 버튼의 텍스트 색상
                  return Theme.of(context).colorScheme.onPrimary;
                }
                // 선택되지 않은 버튼의 텍스트 색상
                return Theme.of(context).colorScheme.onSurface;
              }),
            ),
            segments: <ButtonSegment<BudgetType>>[
              ButtonSegment<BudgetType>(
                value: BudgetType.daily,
                label: Text(l10n.daily),
              ),
              ButtonSegment<BudgetType>(
                value: BudgetType.monthly,
                label: Text(l10n.monthly),
              ),
            ],
            selected: {selectedType},
            onSelectionChanged: (newSelection) {
              onTypeChanged(newSelection.first);
            },
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: budgetController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: l10n.currency,
              suffixStyle: Theme.of(context).textTheme.labelMedium,
              labelText: selectedType == BudgetType.daily
                  ? l10n.dailyBudgetLabel
                  : l10n.monthlyBudgetLabel, // Assumes 'monthlyBudgetLabel' exists
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterBudgetPrompt;
              }
              if (double.tryParse(value) == null) {
                return l10n.enterValidNumberPrompt;
              }
              if (double.parse(value) <= 0) {
                return l10n.budgetGreaterThanZeroPrompt;
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmitted,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(
                l10n.start,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
