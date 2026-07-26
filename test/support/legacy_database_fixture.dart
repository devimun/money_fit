import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Builds synthetic databases matching each released schema generation.
///
/// The fixtures intentionally construct historical shapes instead of checking
/// in customer database copies. [openUpgradedToV5] applies the same v4/v5
/// table evolution that the production helper applies before the v6 gate.
class LegacyDatabaseFixture {
  static const timestamp = '2026-07-20T12:00:00.000Z';

  static Future<Database> openUpgradedToV5({
    required int sourceVersion,
    String? path,
  }) async {
    if (sourceVersion < 1 || sourceVersion > 5) {
      throw ArgumentError.value(sourceVersion, 'sourceVersion', 'Expected 1-5');
    }
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      path ?? inMemoryDatabasePath,
    );
    await _createSchema(database, sourceVersion);
    await _seed(database, sourceVersion);
    await _upgradeToV5(database, sourceVersion);
    await database.execute('PRAGMA user_version = 5');
    return database;
  }

  static Future<void> _createSchema(Database database, int version) async {
    final hasV4UserShape = version >= 4;
    await database.execute(
      hasV4UserShape
          ? '''
          CREATE TABLE users (
            id TEXT PRIMARY KEY, email TEXT, display_name TEXT,
            budget REAL NOT NULL DEFAULT 50000.0,
            budget_type TEXT NOT NULL DEFAULT 'daily',
            is_dark_mode INTEGER NOT NULL DEFAULT 0,
            notifications_enabled INTEGER NOT NULL DEFAULT 1,
            ${version >= 5 ? "language_code TEXT NOT NULL DEFAULT 'en', currency_code TEXT NOT NULL DEFAULT 'USD'," : ''}
            created_at TEXT NOT NULL, updated_at TEXT NOT NULL
          )
        '''
          : '''
          CREATE TABLE users (
            id TEXT PRIMARY KEY, email TEXT, display_name TEXT,
            daily_budget REAL NOT NULL DEFAULT 50000.0,
            is_dark_mode INTEGER NOT NULL DEFAULT 0,
            notifications_enabled INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL, updated_at TEXT NOT NULL
          )
        ''',
    );
    await database.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY, user_id TEXT, name TEXT NOT NULL,
        type TEXT NOT NULL, is_deletable INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await database.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY, user_id TEXT NOT NULL, name TEXT NOT NULL,
        amount REAL NOT NULL, date TEXT NOT NULL, category_id TEXT NOT NULL,
        type TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _seed(Database database, int version) async {
    final historicKind = version <= 2 ? 'required' : 'essential';
    await database.insert('users', {
      'id': 'history-owner',
      if (version >= 4) 'budget': 12.34 else 'daily_budget': 12.34,
      if (version >= 4) 'budget_type': 'daily',
      if (version >= 5) 'currency_code': 'USD',
      'created_at': timestamp,
      'updated_at': timestamp,
    });
    await database.insert('categories', {
      'id': 'food',
      'name': 'Food',
      'type': historicKind,
      'is_deletable': 0,
    });
    await database.insert('expenses', {
      'id': 'history-expense',
      'user_id': 'history-owner',
      'name': 'Synthetic lunch',
      'amount': 12.34,
      'date': '2026-07-20',
      'category_id': 'food',
      'type': historicKind,
      'created_at': timestamp,
      'updated_at': timestamp,
    });
  }

  static Future<void> _upgradeToV5(Database database, int sourceVersion) async {
    if (sourceVersion < 4) {
      await database.execute('ALTER TABLE users RENAME TO users_old');
      await database.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY, email TEXT, display_name TEXT,
          budget REAL NOT NULL DEFAULT 50000.0,
          budget_type TEXT NOT NULL DEFAULT 'daily',
          is_dark_mode INTEGER NOT NULL DEFAULT 0,
          notifications_enabled INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL, updated_at TEXT NOT NULL
        )
      ''');
      await database.execute('''
        INSERT INTO users (
          id, email, display_name, budget, is_dark_mode,
          notifications_enabled, created_at, updated_at
        )
        SELECT id, email, display_name, daily_budget, is_dark_mode,
          notifications_enabled, created_at, updated_at FROM users_old
      ''');
      await database.execute('DROP TABLE users_old');
    }
    if (sourceVersion < 5) {
      await database.execute(
        "ALTER TABLE users ADD COLUMN language_code TEXT NOT NULL DEFAULT 'en'",
      );
      await database.execute(
        "ALTER TABLE users ADD COLUMN currency_code TEXT NOT NULL DEFAULT 'USD'",
      );
    }
  }
}
