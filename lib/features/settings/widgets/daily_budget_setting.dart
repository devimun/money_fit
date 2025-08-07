import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class DailyBudgetSetting extends ConsumerStatefulWidget {
  const DailyBudgetSetting({super.key});

  @override
  ConsumerState<DailyBudgetSetting> createState() => _DailyBudgetSettingState();
}

class _DailyBudgetSettingState extends ConsumerState<DailyBudgetSetting> {
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final userSettings = ref.watch(userSettingsProvider);

    return userSettings.when(
      data: (user) {
        return buildSettingsItem(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          title: l10n.dailyBudgetSetting,
          trailing: Text(
            '${l10n.currency}${NumberFormat.currency(locale: locale, symbol: '').format(user.dailyBudget)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () => _showDailyBudgetDialog(
            user.dailyBudget,
            ref.read(userSettingsProvider.notifier),
            l10n,
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(l10n.errorWithMessage(error.toString())),
    );
  }

  Future<void> _showDailyBudgetDialog(
    double currentBudget,
    UserSettingsNotifier notifier,
    AppLocalizations l10n,
  ) async {
    _budgetController.text = NumberFormat('#,###').format(currentBudget);

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dailyBudgetSetting),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.dailyBudgetLabel,
                hintText: l10n.enterBudgetPrompt,
              ),
              onChanged: (value) {
                // 쉼표 제거 후 숫자만 추출
                final numericValue = value.replaceAll(',', '');
                if (numericValue.isNotEmpty) {
                  final number = double.tryParse(numericValue);
                  if (number != null) {
                    _budgetController.text = NumberFormat(
                      '#,###',
                    ).format(number);
                    _budgetController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _budgetController.text.length),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final value = _budgetController.text.replaceAll(',', '');
              final budget = double.tryParse(value);
              if (budget != null && budget > 0) {
                Navigator.pop(context, budget);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result != null) {
      await notifier.updateDailyBudget(result);
    }
  }
}
