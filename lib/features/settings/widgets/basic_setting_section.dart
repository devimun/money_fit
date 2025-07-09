import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:permission_handler/permission_handler.dart';

/// "기본 설정" 섹션 (상태 변경 UI 담당)
class BasicSettingsSection extends ConsumerStatefulWidget {
  const BasicSettingsSection({super.key});

  @override
  ConsumerState<BasicSettingsSection> createState() =>
      BasicSettingsSectionState();
}

class BasicSettingsSectionState extends ConsumerState<BasicSettingsSection> {
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _showDailyBudgetDialog(
    double currentBudget,
    UserSettingsNotifier notifier,
  ) async {
    _budgetController.text = currentBudget.toInt().toString();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '일일 예산 변경',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: '원'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                final newBudget = double.tryParse(_budgetController.text);
                if (newBudget != null) {
                  notifier.updateDailyBudget(newBudget);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = LightAppColors.primary;
    final userSettings = ref.watch(userSettingsProvider);
    final userSettingsNotifier = ref.read(userSettingsProvider.notifier);

    return userSettings.when(
      data: (user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle('기본 설정', textTheme),
          buildSettingsCard([
            buildSettingsItem(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: iconColor,
              title: '일일 예산 설정',
              onTap: () => _showDailyBudgetDialog(
                user.dailyBudget,
                userSettingsNotifier,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(user.dailyBudget)}원',
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF825A3D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
            buildSwitchItem(
              icon: Icons.dark_mode_outlined,
              iconColor: iconColor,
              title: '다크 모드',
              value: user.isDarkMode,
              onChanged: (value) async =>
                  await userSettingsNotifier.toggleDarkMode(),
            ),
            buildSettingsItem(
              icon: Icons.notifications_outlined,
              iconColor: LightAppColors.primary,
              title: '알림 설정',
              trailing: Switch(
                value: user.notificationsEnabled,
                onChanged: (value) async {
                  if (value) {
                    final status = await Permission.notification.request();
                    if (status.isGranted) {
                      await userSettingsNotifier.enableNotifications();
                    } else if (status.isPermanentlyDenied) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('알림 권한이 거부되었습니다. 설정에서 권한을 변경해주세요.'),
                          ),
                        );
                      }
                      await openAppSettings();
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('알림 권한이 필요합니다.')),
                        );
                      }
                    }
                  } else {
                    await userSettingsNotifier.disableNotifications();
                  }
                },
              ),
            ),
          ]),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
