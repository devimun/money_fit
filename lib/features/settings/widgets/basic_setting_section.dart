import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/features/settings/widgets/budget_setting.dart';
import 'package:money_fit/features/settings/widgets/font_size_setting.dart';
import 'package:money_fit/features/settings/widgets/language_setting.dart';
import 'package:money_fit/features/settings/widgets/notification_setting.dart';
import 'package:money_fit/features/settings/widgets/dark_mode_setting.dart';
import 'package:money_fit/features/settings/widgets/theme_color_setting.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

/// "기본 설정" 섹션을 구성하는 위젯
class BasicSettingsSection extends StatelessWidget {
  const BasicSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(l10n.basicSettings, context.textTheme),
        buildSettingsCard([
          const BudgetSetting(),
          const NotificationSetting(),
          const LanguageSetting(),
          const DarkModeSetting(),
          const ThemeColorSetting(),
          const FontSizeSetting()
        ]),
      ],
    );
  }
}
