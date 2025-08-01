import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
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

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 시간대 초기화
    tzdata.initializeTimeZones();
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

  /// 매일 세 번 알림 예약 (오전 10시, 오후 2시, 오후 8시)
  Future<void> scheduleDailyNotifications() async {
    await _scheduleNotification(
      0,
      10,
      '좋은 아침이에요 ☀️ 오늘의 첫 지출을 등록해볼까요? 작은 습관이 큰 변화를 만들어요!',
    );
    await _scheduleNotification(1, 14, '맛있는 점심 드셨나요? 🍱 이제 지출 내역을 간단히 정리해볼까요?');
    await _scheduleNotification(
      2,
      20,
      '하루가 벌써 지나갔네요 🌙 오늘의 지출을 차분히 정리하며 하루를 마무리해보세요.',
    );
    log('message: Daily notifications scheduled successfully.');
  }

  /// 개별 알림 예약
  Future<void> _scheduleNotification(int id, int hour, String body) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '일일 지출 알림',
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
