import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class NotificationSetting extends ConsumerWidget {
  const NotificationSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationsEnabled = ref.watch(notificationControllerProvider);

    return notificationsEnabled.when(
      data: (enabled) {
        return buildSwitchItem(
          icon: Icons.notifications_active_outlined,
          iconColor: context.colors.brandPrimary,
          title: l10n.notificationSetting,
          value: enabled,
          onChanged: (value) =>
              _handleNotificationToggle(context, ref, value, l10n),
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
    final notifier = ref.read(notificationControllerProvider.notifier);

    if (value) {
      final permission = await notifier.enable(
        NotificationText(
          title: l10n.notificationTitleDaily,
          morning: l10n.notificationBodyMorning,
          afternoon: l10n.notificationBodyAfternoon,
          night: l10n.notificationBodyNight,
        ),
      );
      if (permission != NotificationPermissionResult.granted &&
          context.mounted) {
        _showPermissionDialog(context, ref, l10n);
      }
    } else {
      await notifier.disable();
    }
  }

  void _showPermissionDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveTitleText(text: l10n.notificationPermissionRequired),
        content: ResponsiveDescriptionText(
          text: l10n.notificationPermissionDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveButtonText(text: l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(notificationControllerProvider.notifier)
                  .openPermissionSettings();
            },
            child: ResponsiveButtonText(text: l10n.goToSettings),
          ),
        ],
      ),
    );
  }
}
