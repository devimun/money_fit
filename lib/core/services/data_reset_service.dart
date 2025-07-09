import 'package:money_fit/core/database/database_helper.dart';

class DataResetService {
  static Future<void> resetAllData() async {
    await DatabaseHelper.instance.resetDatabase();
  }
}
