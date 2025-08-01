import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';

class DarkModeSetting extends ConsumerWidget {
  const DarkModeSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettings = ref.watch(userSettingsProvider);

    return userSettings.when(
      data: (user) {
        return buildSwitchItem(
          icon: Icons.dark_mode_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          title: '다크 모드',
          value: user.isDarkMode,
          onChanged: (value) async {
            await ref.read(userSettingsProvider.notifier).toggleDarkMode();
          },
          context: context,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('오류: $error'),
    );
  }
}
