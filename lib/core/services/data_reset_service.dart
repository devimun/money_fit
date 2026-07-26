import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:money_fit/core/database/database_helper.dart';

typedef DataResetAction = Future<void> Function();

class DataResetService {
  /// Keeps the production reset sequence while allowing host tests to avoid
  /// Firebase and sqflite platform singletons.
  static Future<void> resetAllData({
    DataResetAction? logReset,
    DataResetAction? resetDatabase,
  }) async {
    await (logReset ?? _logReset)();
    await (resetDatabase ?? _resetDatabase)();
  }

  static Future<void> _logReset() {
    return FirebaseAnalytics.instance.logEvent(name: 'data_reset');
  }

  static Future<void> _resetDatabase() {
    return DatabaseHelper.instance.resetDatabase();
  }
}
