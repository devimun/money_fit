import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class BudgetSetting extends ConsumerStatefulWidget {
  const BudgetSetting({super.key});

  @override
  ConsumerState<BudgetSetting> createState() => _BudgetSettingState();
}

class _BudgetSettingState extends ConsumerState<BudgetSetting> {
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userSettings = ref.watch(userSettingsProvider);

    return userSettings.when(
      data: (user) {
        final budgetTypeSuffix = user.budgetType == BudgetType.daily
            ? l10n.daily
            : l10n.monthly;
        return buildSettingsItem(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          title: l10n.budgetSetting,
          trailing: Text(
            '${formatCurrencyAdaptive(context, user.budget)} / $budgetTypeSuffix',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () => _showBudgetDialog(
            user,
            ref.read(userSettingsProvider.notifier),
            l10n,
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(l10n.errorWithMessage(error.toString())),
    );
  }

  Future<void> _showBudgetDialog(
    User currentUser,
    UserSettingsNotifier notifier,
    AppLocalizations l10n,
  ) async {
    _budgetController.text = NumberFormat('#,###').format(currentUser.budget);
    var selectedType = currentUser.budgetType;

    final result = await showDialog<(double, BudgetType)?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.budgetSetting),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<BudgetType>(
                    style: Theme.of(context).elevatedButtonTheme.style!
                        .copyWith(
                          side: WidgetStatePropertyAll(BorderSide(width: 0.2)),
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>((
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
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color?>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  // 선택된 버튼의 텍스트 색상
                                  return Theme.of(
                                    context,
                                  ).colorScheme.onPrimary;
                                }
                                // 선택되지 않은 버튼의 텍스트 색상
                                return Theme.of(context).colorScheme.onSurface;
                              }),
                        ),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: BudgetType.daily,
                        label: Text(l10n.daily),
                      ),
                      ButtonSegment(
                        value: BudgetType.monthly,
                        label: Text(l10n.monthly),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        selectedType = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selectedType == BudgetType.daily
                          ? l10n.daily
                          : l10n.monthly,
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
                          _budgetController
                              .selection = TextSelection.fromPosition(
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
                      Navigator.pop(context, (budget, selectedType));
                    }
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      final (newBudget, newType) = result;
      await notifier.updateBudget(newType, newBudget);
    }
  }
}
