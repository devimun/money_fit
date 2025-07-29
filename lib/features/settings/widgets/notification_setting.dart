import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/features/settings/widgets/settings_helpers.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSetting extends ConsumerWidget {
  const NotificationSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettings = ref.watch(userSettingsProvider);

    return userSettings.when(
      data: (user) {
        return buildSwitchItem(
          icon: Icons.notifications,
          iconColor: Theme.of(context).colorScheme.primary,
          title: '알림 설정',
          value: user.notificationsEnabled,
          onChanged: (value) => _handleNotificationToggle(context, ref, value),
          context: context,
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('오류: $error'),
    );
  }

  Future<void> _handleNotificationToggle(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final notifier = ref.read(userSettingsProvider.notifier);

    if (value) {
      // 알림 켜기: 권한 확인 필요
      final status = await Permission.notification.status;

      if (status.isDenied) {
        final result = await Permission.notification.request();
        if (result.isGranted) {
          await notifier.enableNotifications();
        } else {
          if (context.mounted) {
            _showPermissionDialog(context);
          }
        }
      } else if (status.isGranted) {
        await notifier.enableNotifications();
      } else {
        if (context.mounted) {
          _showPermissionDialog(context);
        }
      }
    } else {
      // 알림 끄기: 권한 체크 없이 바로 비활성화
      await notifier.disableNotifications();
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 권한 필요'),
        content: const Text('알림 기능을 사용하려면 설정에서 알림 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }
}
