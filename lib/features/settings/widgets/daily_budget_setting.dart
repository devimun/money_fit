import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';

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
    final userSettings = ref.watch(userSettingsProvider);

    return userSettings.when(
      data: (user) {
        return buildSettingsItem(
          icon: Icons.account_balance_wallet,
          iconColor: Theme.of(context).colorScheme.primary,
          title: '일일 예산 설정',
          trailing: Text(
            '${NumberFormat('#,###').format(user.dailyBudget)}원',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () => _showDailyBudgetDialog(
            user.dailyBudget,
            ref.read(userSettingsProvider.notifier),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('오류: $error'),
    );
  }

  Future<void> _showDailyBudgetDialog(
    double currentBudget,
    UserSettingsNotifier notifier,
  ) async {
    _budgetController.text = NumberFormat('#,###').format(currentBudget);

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일일 예산 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '일일 예산 (원)',
                hintText: '예: 30000',
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
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final value = _budgetController.text.replaceAll(',', '');
              final budget = double.tryParse(value);
              if (budget != null && budget > 0) {
                Navigator.pop(context, budget);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null) {
      await notifier.updateDailyBudget(result);
    }
  }
}
