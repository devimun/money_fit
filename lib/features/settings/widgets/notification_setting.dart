import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';
import 'package:money_fit/features/notifications/application/notification_permission_prompt.dart';
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
      final request = NotificationPermissionSettingsRequestController(
        ref.read(promptCoordinatorProvider),
        quietPeriod: () => Duration(
          seconds: readValidatedProactiveFullscreenQuietSeconds(
            ref.read(remoteConfigReaderProvider),
          ),
        ),
      );
      await request.request(
        requestPermission: () => notifier.enable(
          NotificationText(
            title: l10n.notificationTitleDaily,
            morning: l10n.notificationBodyMorning,
            afternoon: l10n.notificationBodyAfternoon,
            night: l10n.notificationBodyNight,
          ),
        ),
        presentDeniedFallback: (_) =>
            _showPermissionDialog(context, notifier, l10n),
      );
    } else {
      await notifier.disable();
    }
  }

  Future<void> _showPermissionDialog(
    BuildContext context,
    NotificationController notifier,
    AppLocalizations l10n,
  ) async {
    if (!context.mounted) return;
    final action = await showDialog<_PermissionDialogAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveTitleText(text: l10n.notificationPermissionRequired),
        content: ResponsiveDescriptionText(
          text: l10n.notificationPermissionDescription,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _PermissionDialogAction.cancel),
            child: ResponsiveButtonText(text: l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _PermissionDialogAction.openSettings),
            child: ResponsiveButtonText(text: l10n.goToSettings),
          ),
        ],
      ),
    );
    if (action == _PermissionDialogAction.openSettings) {
      await notifier.openPermissionSettings();
    }
  }
}

enum _PermissionDialogAction { cancel, openSettings }
