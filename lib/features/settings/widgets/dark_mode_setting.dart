// Dark Mode Setting Widget - Uses themeModeProvider for state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/providers/theme_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class DarkModeSetting extends ConsumerWidget {
  const DarkModeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.watch(themeModeProvider);

    return buildSwitchItem(
      icon: Icons.dark_mode_outlined,
      iconColor: context.colors.brandPrimary,
      title: l10n.darkMode,
      value: isDarkMode,
      onChanged: (value) async {
        await ref.read(themeModeProvider.notifier).toggleDarkMode();
      },
      context: context,
    );
  }
}
