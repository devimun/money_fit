import 'dart:async';

import 'package:money_fit/core/models/category_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton 패턴을 사용하여 앱 전체에서 단 하나의 인스턴스만 유지합니다.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static const _dbName = 'money_fit.db';
  static const _dbVersion = 1;

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
      // onUpgrade, onDowngrade 등 마이그레이션 로직은 향후 필요시 추가
    );
  }

  // 데이터베이스가 처음 생성될 때 호출됩니다.
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createTables(batch);
    _seedDatabase(batch);
    await batch.commit();
  }

  // 테이블 생성 스크립트
  void _createTables(Batch batch) {
    batch.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        display_name TEXT,
        daily_budget REAL NOT NULL DEFAULT 50000.0,
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
    // Method to reset the database

    final defaultCategories = [
      // 필수 지출
      Category(
        id: 'food',
        name: '식사',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'traffic',
        name: '교통',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'communication',
        name: '통신',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'housing',
        name: '주거/공과금',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'medical',
        name: '의료',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'insurance',
        name: '보험',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'finance',
        name: '금융',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'necessities',
        name: '생필품',
        type: CategoryType.required,
        isDeletable: false,
      ),
      Category(
        id: 'req-etc',
        name: '기타',
        type: CategoryType.required,
        isDeletable: false,
      ),

      // 자율 지출 (변동 지출)
      Category(
        id: 'eating-out',
        name: '외식',
        type: CategoryType.variable,
        isDeletable: false,
      ),
      Category(
        id: 'cafe',
        name: '카페/간식',
        type: CategoryType.variable,
        isDeletable: false,
      ),
      Category(
        id: 'shopping',
        name: '쇼핑',
        type: CategoryType.variable,
        isDeletable: false,
      ),
      Category(
        id: 'hobby',
        name: '취미/여가',
        type: CategoryType.variable,
        isDeletable: false,
      ),
      Category(
        id: 'travel',
        name: '여행/휴식',
        type: CategoryType.variable,
        isDeletable: false,
      ),
      Category(
        id: 'subscribe',
        name: '구독',
        type: CategoryType.variable,
        isDeletable: false,
      ),
      Category(
        id: 'beauty',
        name: '미용',
        type: CategoryType.variable,
        isDeletable: false,
      ),
      Category(
        id: 'var-etc',
        name: '기타',
        type: CategoryType.variable,
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
