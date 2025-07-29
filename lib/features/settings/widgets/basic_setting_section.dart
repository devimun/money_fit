import 'package:flutter/material.dart';
import 'package:money_fit/features/settings/widgets/daily_budget_setting.dart';
import 'package:money_fit/features/settings/widgets/notification_setting.dart';
import 'package:money_fit/features/settings/widgets/dark_mode_setting.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';

/// "기본 설정" 섹션을 구성하는 위젯
class BasicSettingsSection extends StatelessWidget {
  const BasicSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('기본 설정', Theme.of(context).textTheme),
        buildSettingsCard([
          const DailyBudgetSetting(),
          const NotificationSetting(),
          const DarkModeSetting(),
        ]),
      ],
    );
  }
}