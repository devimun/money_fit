import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class NotificationSetting extends ConsumerWidget {
  const NotificationSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final userSettings = ref.watch(userSettingsProvider);

    return userSettings.when(
      data: (user) {
        return buildSwitchItem(
          icon: Icons.notifications_active_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
          title: l10n.notificationSetting,
          value: user.notificationsEnabled,
          onChanged: (value) => _handleNotificationToggle(context, ref, value, l10n),
          context: context,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(l10n.errorWithMessage(error.toString())),
    );
  }

  Future<void> _handleNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    bool value,
    AppLocalizations l10n,
  ) async {
    final notifier = ref.read(userSettingsProvider.notifier);

    if (value) {
      // 알림 켜기: 권한 확인 필요
      final status = await Permission.notification.status;

      if (status.isDenied) {
        final result = await Permission.notification.request();
        if (result.isGranted) {
          await notifier.enableNotifications(l10n);
        } else {
          if (context.mounted) {
            _showPermissionDialog(context, l10n);
          }
        }
      } else if (status.isGranted) {
        await notifier.enableNotifications(l10n);
      } else {
        if (context.mounted) {
          _showPermissionDialog(context, l10n);
        }
      }
    } else {
      // 알림 끄기: 권한 체크 없이 바로 비활성화
      await notifier.disableNotifications();
    }
  }

  void _showPermissionDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationPermissionRequired),
        content: Text(l10n.notificationPermissionDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.goToSettings),
          ),
        ],
      ),
    );
  }
}
