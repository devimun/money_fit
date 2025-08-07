import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class DailyBudgetSetupForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController budgetController;
  final VoidCallback onSubmitted;

  const DailyBudgetSetupForm({
    super.key,
    required this.formKey,
    required this.budgetController,
    required this.onSubmitted,
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
            l10n.dailyBudgetSetupTitle,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.dailyBudgetSetupDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: budgetController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: l10n.currency,
              suffixStyle: Theme.of(context).textTheme.labelMedium,
              labelText: l10n.dailyBudgetLabel,
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
