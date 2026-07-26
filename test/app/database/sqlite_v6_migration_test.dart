import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/migrations/sqlite_v6_migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'v5 rows are atomically rebuilt as owner-scoped v6 ledger rows',
    () async {
      final db = await _openV5();
      addTearDown(db.close);
      await _insertTypicalRows(db);

      await SqliteV6Migration.migrate(db);

      expect(await _count(db, 'local_users'), 2);
      expect(await _count(db, 'ledger_settings'), 2);
      expect(await _count(db, 'categories'), 3);
      expect(await _count(db, 'expenses'), 3);
      expect(await _count(db, 'budgets'), 2);
      expect(
        (await db.query(
          'budgets',
          where: 'owner_id = ?',
          whereArgs: ['alice'],
        )).single['amount_minor'],
        1234,
      );
      expect(
        (await db.query(
          'budgets',
          where: 'owner_id = ?',
          whereArgs: ['bob'],
        )).single['amount_minor'],
        50000,
      );

      final migrated = await db.rawQuery('''
      SELECT e.id, e.amount_minor, e.occurred_on, c.owner_id, c.stable_code,
             c.display_name
      FROM expenses e
      JOIN categories c ON c.id = e.category_id AND c.owner_id = e.owner_id
      ORDER BY e.id
    ''');
      expect(migrated, [
        {
          'id': 'alice-food',
          'amount_minor': 1234,
          'occurred_on': '2026-07-15',
          'owner_id': 'alice',
          'stable_code': 'food',
          'display_name': null,
        },
        {
          'id': 'bob-coffee',
          'amount_minor': 4500,
          'occurred_on': '2026-07-16',
          'owner_id': 'bob',
          'stable_code': null,
          'display_name': 'Coffee shops',
        },
        {
          'id': 'bob-food',
          'amount_minor': 1200,
          'occurred_on': '2026-07-17',
          'owner_id': 'bob',
          'stable_code': 'food',
          'display_name': null,
        },
      ]);

      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index'",
      );
      expect(
        indexes.map((row) => row['name']),
        containsAll([
          'idx_expenses_owner_date',
          'idx_expenses_owner_category_date',
          'idx_categories_owner_archived',
          'idx_categories_owner_stable_code',
        ]),
      );
    },
  );

  test(
    'invalid legacy data rolls back without replacing the v5 database',
    () async {
      final db = await _openV5();
      addTearDown(db.close);
      await _insertTypicalRows(db);
      await db.insert(
        'expenses',
        _expense(id: 'orphan', userId: 'alice', categoryId: 'does-not-exist'),
      );

      await expectLater(
        SqliteV6Migration.migrate(db),
        throwsA(isA<FormatException>()),
      );

      expect(await _count(db, 'users'), 2);
      expect(await _count(db, 'categories'), 2);
      expect(await _count(db, 'expenses'), 4);
      expect(
        await db.query(
          'sqlite_master',
          where: "type = 'table' AND name = 'local_users'",
        ),
        isEmpty,
      );
    },
  );

  test(
    'v6 constraints reject cross-owner, fractional, malformed data',
    () async {
      final db = await _openV5();
      addTearDown(db.close);
      await _insertTypicalRows(db);
      await SqliteV6Migration.migrate(db);

      final aliceCategory =
          (await db.query(
                'categories',
                where: 'owner_id = ? AND stable_code = ?',
                whereArgs: ['alice', 'food'],
              )).single['id']
              as String;
      final now = '2026-07-15T12:00:00.000Z';
      final valid = <String, Object?>{
        'id': 'invalid',
        'owner_id': 'bob',
        'title': 'Invalid',
        'amount_minor': 10,
        'occurred_on': '2026-07-15',
        'category_id': aliceCategory,
        'created_at': now,
        'updated_at': now,
      };

      await expectLater(
        db.insert('expenses', valid),
        throwsA(isA<DatabaseException>()),
        reason: 'a category cannot be attached to another owner',
      );
      await expectLater(
        db.insert('expenses', {
          ...valid,
          'id': 'fractional',
          'owner_id': 'alice',
          'amount_minor': 1.5,
        }),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        db.insert('expenses', {
          ...valid,
          'id': 'bad-date',
          'owner_id': 'alice',
          'occurred_on': '2026/07/15',
        }),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        db.insert('ledger_settings', {
          'owner_id': 'alice',
          'currency_code': 'KRW',
        }),
        throwsA(isA<DatabaseException>()),
        reason: 'each owner has exactly one ledger currency',
      );
      expect(
        (await db.rawQuery('PRAGMA foreign_keys')).single['foreign_keys'],
        1,
      );
    },
  );
}

Future<Database> _openV5() async {
  return databaseFactoryFfi.openDatabase(inMemoryDatabasePath).then((db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY, email TEXT, display_name TEXT,
        budget REAL NOT NULL DEFAULT 50000.0,
        budget_type TEXT NOT NULL DEFAULT 'daily',
        is_dark_mode INTEGER NOT NULL DEFAULT 0,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        language_code TEXT NOT NULL DEFAULT 'en',
        currency_code TEXT NOT NULL DEFAULT 'USD',
        created_at TEXT NOT NULL, updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY, user_id TEXT, name TEXT NOT NULL,
        type TEXT NOT NULL, is_deletable INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY, user_id TEXT NOT NULL, name TEXT NOT NULL,
        amount REAL NOT NULL, date TEXT NOT NULL, category_id TEXT NOT NULL,
        type TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
      )
    ''');
    return db;
  });
}

Future<void> _insertTypicalRows(Database db) async {
  const now = '2026-07-15T12:00:00.000Z';
  await db.insert('users', {
    'id': 'alice',
    'budget': 12.34,
    'budget_type': 'daily',
    'currency_code': 'USD',
    'created_at': now,
    'updated_at': now,
  });
  await db.insert('users', {
    'id': 'bob',
    'budget': 50000.0,
    'budget_type': 'monthly',
    'currency_code': 'KRW',
    'created_at': now,
    'updated_at': now,
  });
  await db.insert('categories', {
    'id': 'food',
    'name': 'food',
    'type': 'essential',
    'is_deletable': 0,
  });
  await db.insert('categories', {
    'id': 'coffee-bob',
    'user_id': 'bob',
    'name': 'Coffee shops',
    'type': 'discretionary',
  });
  await db.insert(
    'expenses',
    _expense(id: 'alice-food', userId: 'alice', amount: 12.34),
  );
  await db.insert(
    'expenses',
    _expense(id: 'bob-food', userId: 'bob', amount: 1200, date: '2026-07-17'),
  );
  await db.insert(
    'expenses',
    _expense(
      id: 'bob-coffee',
      userId: 'bob',
      categoryId: 'coffee-bob',
      amount: 4500,
      date: '2026-07-16',
      type: 'discretionary',
    ),
  );
}

Map<String, Object?> _expense({
  required String id,
  required String userId,
  String categoryId = 'food',
  double amount = 12.34,
  String date = '2026-07-15',
  String type = 'essential',
}) => {
  'id': id,
  'user_id': userId,
  'name': 'Lunch',
  'amount': amount,
  'date': date,
  'category_id': categoryId,
  'type': type,
  'created_at': '2026-07-15T12:00:00.000Z',
  'updated_at': '2026-07-15T12:00:00.000Z',
};

Future<int> _count(Database db, String table) async =>
    (await db.rawQuery('SELECT COUNT(*) FROM $table')).single.values.single
        as int;
