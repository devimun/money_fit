import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Small v5-shaped databases for migration preflight and upgrade tests.
///
/// Fixtures deliberately use synthetic identifiers and text; no production
/// database snapshot is checked into the repository.
class V5DatabaseFixture {
  static Future<Database> open({
    bool duplicateGlobalCategoryIds = false,
  }) async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    await database.execute('''
      CREATE TABLE users (
        id TEXT,
        email TEXT,
        display_name TEXT,
        budget REAL NOT NULL DEFAULT 50000.0,
        budget_type TEXT NOT NULL DEFAULT 'daily',
        is_dark_mode INTEGER NOT NULL DEFAULT 0,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        language_code TEXT NOT NULL DEFAULT 'en',
        currency_code TEXT NOT NULL DEFAULT 'USD',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE categories (
        id TEXT,
        user_id TEXT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        is_deletable INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await database.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        amount REAL,
        date TEXT,
        category_id TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    if (duplicateGlobalCategoryIds) {
      await database.insert('categories', {
        'id': 'food',
        'name': 'Food',
        'type': 'essential',
      });
      await database.insert('categories', {
        'id': 'food',
        'name': 'Food duplicate',
        'type': 'essential',
      });
    }
    return database;
  }

  static const timestamp = '2026-07-20T12:00:00.000Z';

  static Future<void> insertTypicalRows(Database database) async {
    await database.insert('users', {
      'id': 'fixture-owner',
      'budget': 50.5,
      'created_at': timestamp,
      'updated_at': timestamp,
    });
    await database.insert('categories', {
      'id': 'food',
      'name': 'Food',
      'type': 'essential',
    });
    await database.insert('expenses', {
      'id': 'fixture-expense',
      'user_id': 'fixture-owner',
      'name': 'Synthetic lunch',
      'amount': 12.5,
      'date': '2026-07-20',
      'category_id': 'food',
      'type': 'essential',
      'created_at': timestamp,
      'updated_at': timestamp,
    });
  }
}
