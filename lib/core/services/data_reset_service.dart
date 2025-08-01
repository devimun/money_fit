import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:money_fit/core/database/database_helper.dart';

class DataResetService {
  static Future<void> resetAllData() async {
    await FirebaseAnalytics.instance.logEvent(name: 'data_reset');
    await DatabaseHelper.instance.resetDatabase();
  }
}
