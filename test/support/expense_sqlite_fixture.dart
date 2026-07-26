import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Isolated v5 expenses table for repository characterization tests.
///
/// This mirrors the current table only; it deliberately does not exercise
/// [DatabaseHelper] creation or migrations, which are covered separately.
class ExpenseSqliteFixture {
  static Future<Database> open() async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    await database.execute('''
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
    return database;
  }

  static Expense expense({
    String id = 'expense-1',
    String userId = 'user-1',
    String name = 'Lunch',
    double amount = 12.5,
    DateTime? date,
    String categoryId = 'food',
    ExpenseType type = ExpenseType.essential,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final occurredAt = date ?? DateTime(2026, 7, 15);
    final created = createdAt ?? DateTime(2026, 7, 15, 12);
    return Expense(
      id: id,
      userId: userId,
      name: name,
      amount: amount,
      date: occurredAt,
      categoryId: categoryId,
      type: type,
      createdAt: created,
      updatedAt: updatedAt ?? created,
    );
  }
}

class TestAppDatabase implements AppDatabase {
  TestAppDatabase(this.database);

  final Database database;

  @override
  Future<DatabaseExecutor> get executor async => database;

  @override
  Future<void> reset() async {}
}
