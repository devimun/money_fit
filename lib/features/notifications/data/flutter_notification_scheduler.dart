import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:money_fit/features/notifications/application/notification_scheduler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FlutterNotificationScheduler implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 초기화
  @override
  Future<void> initialize() async {
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
          AndroidFlutterLocalNotificationsPlugin
        >()
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

  @override
  Future<void> init() => initialize();

  Future<void> _configureLocalTimezone() async {
    final String localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone));
  }

  @override
  Future<void> scheduleDaily({
    required String title,
    required String morning,
    required String afternoon,
    required String night,
  }) async {
    await _scheduleNotification(0, 10, title, morning);
    await _scheduleNotification(1, 14, title, afternoon);
    await _scheduleNotification(2, 20, title, night);
    log('message: Daily notifications scheduled successfully.');
  }

  @override
  Future<void> scheduleDailyNotificationsText({
    required String title,
    required String morning,
    required String afternoon,
    required String night,
  }) {
    return scheduleDaily(
      title: title,
      morning: morning,
      afternoon: afternoon,
      night: night,
    );
  }

  /// 개별 알림 예약
  Future<void> _scheduleNotification(
    int id,
    int hour,
    String title,
    String body,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
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
  @override
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> cancelAllNotifications() => cancelAll();
}
