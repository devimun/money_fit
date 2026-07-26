import 'package:money_fit/app/database/migrations/sqlite_v6_migration.dart';
import 'package:money_fit/core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class V6DatabaseFixture implements AppDatabase {
  V6DatabaseFixture._(this.database);

  final Database database;

  static Future<V6DatabaseFixture> open() async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    await database.execute('PRAGMA foreign_keys = ON');
    await SqliteV6Migration.createSchema(database);
    return V6DatabaseFixture._(database);
  }

  @override
  Future<DatabaseExecutor> get executor async => database;

  @override
  Future<void> reset() async {}
}
