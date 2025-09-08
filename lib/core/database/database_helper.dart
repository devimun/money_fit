import 'dart:async';

import 'package:money_fit/core/models/category_model.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton 패턴을 사용하여 앱 전체에서 단 하나의 인스턴스만 유지합니다.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const _dbName = 'money_fit.db';
  static const _dbVersion = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 데이터베이스가 처음 생성될 때 호출됩니다.
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createTables(batch);
    _seedDatabase(batch);
    await batch.commit();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
        "UPDATE expenses SET type = 'essential' WHERE type = 'essential'",
      );
      await db.execute(
        "UPDATE expenses SET type = 'discretionary' WHERE type = 'discretionary'",
      );
      await db.execute(
        "UPDATE categories SET type = 'essential' WHERE type = 'essential'",
      );
      await db.execute(
        "UPDATE categories SET type = 'discretionary' WHERE type = 'discretionary'",
      );
      await db.execute(
        "INSERT INTO categories (id, name, type, is_deletable) SELECT 'insurance', 'insurance', 'essential', 0 WHERE NOT EXISTS (SELECT 1 FROM categories WHERE id = 'insurance')",
      );
      await db.execute(
        "INSERT INTO categories (id, name, type, is_deletable) SELECT 'necessities', 'necessities', 'essential', 0 WHERE NOT EXISTS (SELECT 1 FROM categories WHERE id = 'necessities')",
      );
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE users RENAME TO users_old');
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT,
          display_name TEXT,
          budget REAL NOT NULL DEFAULT 50000.0,
          budget_type TEXT NOT NULL DEFAULT 'daily',
          is_dark_mode INTEGER NOT NULL DEFAULT 0,
          notifications_enabled INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        INSERT INTO users (id, email, display_name, budget, is_dark_mode, notifications_enabled, created_at, updated_at)
        SELECT id, email, display_name, daily_budget, is_dark_mode, notifications_enabled, created_at, updated_at FROM users_old
      ''');
      await db.execute('DROP TABLE users_old');
    }
  }

  // 테이블 생성 스크립트
  void _createTables(Batch batch) {
    batch.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        display_name TEXT,
        budget REAL NOT NULL DEFAULT 50000.0,
        budget_type TEXT NOT NULL DEFAULT 'daily',
        is_dark_mode INTEGER NOT NULL DEFAULT 0,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        user_id TEXT, -- NULL이면 기본 카테고리
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        is_deletable INTEGER NOT NULL DEFAULT 1
      )
    ''');

    batch.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category_id TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> resetDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = null;
  }

  // 기본 데이터(Seed) 삽입
  void _seedDatabase(Batch batch) {
    final defaultCategories = [
      // 필수 지출
      Category(
        id: 'food',
        name: 'food',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
      Category(
        id: 'traffic',
        name: 'traffic',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
      Category(
        id: 'communication',
        name: 'communication',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
      Category(
        id: 'housing',
        name: 'housing',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
      Category(
        id: 'medical',
        name: 'medical',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
      Category(
        id: 'insurance',
        name: 'insurance',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
      Category(
        id: 'necessities',
        name: 'necessities',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
      Category(
        id: 'finance',
        name: 'finance',
        type: ExpenseType.essential,
        isDeletable: false,
      ),

      // 자율 지출 (변동 지출)
      Category(
        id: 'eating-out',
        name: 'eating-out',
        type: ExpenseType.discretionary,
        isDeletable: false,
      ),
      Category(
        id: 'cafe',
        name: 'cafe',
        type: ExpenseType.discretionary,
        isDeletable: false,
      ),
      Category(
        id: 'shopping',
        name: 'shopping',
        type: ExpenseType.discretionary,
        isDeletable: false,
      ),
      Category(
        id: 'hobby',
        name: 'hobby',
        type: ExpenseType.discretionary,
        isDeletable: false,
      ),
      Category(
        id: 'travel',
        name: 'travel',
        type: ExpenseType.discretionary,
        isDeletable: false,
      ),
      Category(
        id: 'subscribe',
        name: 'subscribe',
        type: ExpenseType.discretionary,
        isDeletable: false,
      ),
      Category(
        id: 'beauty',
        name: 'beauty',
        type: ExpenseType.discretionary,
        isDeletable: false,
      ),
    ];

    for (final category in defaultCategories) {
      batch.insert(
        'categories',
        category.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}