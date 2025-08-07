import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:money_fit/widgets/custom_notification_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 초기화
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'daily_notification_channel_id',
        'Daily Notifications',
        description: 'Channel for daily notifications',
        importance: Importance.max,
      ),
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 시간대 초기화
    tz.initializeTimeZones();
    await _configureLocalTimezone();
  }

  Future<void> _configureLocalTimezone() async {
    final String localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));
  }

  // // 알림 등록 여부 확인을 위한 디버깅용 메서드
  // Future<void> getNotiList() async {
  //   final List<PendingNotificationRequest> pendingNotifications =
  //       await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  //   for (var notification in pendingNotifications) {
  //     log('알림 ID: ${notification.id}');
  //     log('제목: ${notification.title}');
  //     log('본문: ${notification.body}');
  //     log('페이로드: ${notification.payload}');
  //   }
  // }
  Future<void> showNotificationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomNotificationDialog(
          onConfirm: () async {
            Navigator.of(context).pop();
            await setupNotifications(l10n, ref);
          },
          onDeny: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> setupNotifications(AppLocalizations l10n, WidgetRef ref) async {
    log('Requesting notification permission...');
    final permissionStatus = await Permission.notification.request();
    log('Notification permission status: ${permissionStatus.toString()}');

    if (permissionStatus.isGranted) {
      await ref.read(userSettingsProvider.notifier).enableNotifications(l10n);
      await ref
          .read(notificationServiceProvider)
          .scheduleDailyNotifications(l10n);
    } else if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  /// 매일 세 번 알림 예약 (오전 10시, 오후 2시, 오후 8시)
  Future<void> scheduleDailyNotifications(AppLocalizations l10n) async {
    await _scheduleNotification(0, 10, l10n.notificationBodyMorning, l10n);
    await _scheduleNotification(1, 14, l10n.notificationBodyAfternoon, l10n);
    await _scheduleNotification(2, 20, l10n.notificationBodyNight, l10n);
    log('message: Daily notifications scheduled successfully.');
  }

  /// 개별 알림 예약
  Future<void> _scheduleNotification(
    int id,
    int hour,
    String body,
    AppLocalizations l10n,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      l10n.notificationTitleDaily,
      body,
      _nextInstanceOfHour(hour),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notification_channel_id',
          'Daily Notifications',
          channelDescription: 'Channel for daily notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfHour(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

/// Riverpod 프로바이더
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
