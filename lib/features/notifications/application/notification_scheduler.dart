abstract interface class NotificationScheduler {
  /// Compatibility entry point for existing startup orchestration.
  Future<void> init();

  Future<void> initialize();

  Future<void> scheduleDaily({
    required String title,
    required String morning,
    required String afternoon,
    required String night,
  });

  /// Compatibility entry point for existing feature callers.
  Future<void> scheduleDailyNotificationsText({
    required String title,
    required String morning,
    required String afternoon,
    required String night,
  });

  Future<void> cancelAll();

  /// Compatibility entry point for existing reset orchestration.
  Future<void> cancelAllNotifications();
}
