import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class DarkModeSetting extends ConsumerWidget {
  const DarkModeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userSettings = ref.watch(userSettingsProvider);

    return userSettings.when(
      data: (user) {
        return buildSwitchItem(
          icon: Icons.dark_mode_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          title: l10n.darkMode,
          value: user.isDarkMode,
          onChanged: (value) async {
            await ref.read(userSettingsProvider.notifier).toggleDarkMode();
          },
          context: context,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(l10n.errorWithMessage(error.toString())),
    );
  }
}
