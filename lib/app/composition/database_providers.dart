import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class LegacySqfliteAppDatabase implements AppDatabase {
  const LegacySqfliteAppDatabase(this._helper);

  final DatabaseHelper _helper;

  @override
  Future<DatabaseExecutor> get executor => _helper.database;

  @override
  Future<void> reset() => _helper.resetDatabase();
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return LegacySqfliteAppDatabase(DatabaseHelper.instance);
});
