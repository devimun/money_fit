import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/database/database_helper.dart';

class DataResetService {
  static Future<void> resetAllData(AnalyticsService analytics) async {
    // Analytics is best-effort and must never prevent the requested reset.
    await analytics.track(AnalyticsEvent.dataReset, {
      'scope': 'local_database',
    });
    await DatabaseHelper.instance.resetDatabase();
  }
}
