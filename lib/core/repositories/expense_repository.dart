
import 'package:money_fit/core/database/database_helper.dart';
import 'package:money_fit/core/models/expense_model.dart';

/// ExpenseRepository의 인터페이스입니다.
abstract class IExpenseRepository {
  Future<void> createExpense(Expense expense);
  Future<List<Expense>> getExpensesByDate(String userId, DateTime date);
  Future<List<Expense>> getExpensesByMonth(String userId, int year, int month);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

class ExpenseRepository implements IExpenseRepository {
  final DatabaseHelper _dbHelper;

  ExpenseRepository({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<void> createExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.insert('expenses', expense.toJson());
  }

  /// 특정 날짜의 모든 지출 내역을 가져옵니다.
  @override
  Future<List<Expense>> getExpensesByDate(String userId, DateTime date) async {
    final db = await _dbHelper.database;
    final dateString = date.toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateString],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
  }

  /// 특정 월의 모든 지출 내역을 가져옵니다.
  @override
  Future<List<Expense>> getExpensesByMonth(String userId, int year, int month) async {
    final db = await _dbHelper.database;
    // YYYY-MM 형식으로 시작하는 날짜를 찾습니다.
    final monthString = '$year-${month.toString().padLeft(2, '0')}';

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'user_id = ? AND date LIKE ?',
      whereArgs: [userId, '$monthString%'],
      orderBy: 'date DESC, created_at DESC',
    );

    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.update(
      'expenses',
      expense.toJson(),
      where: 'id = ? AND user_id = ?',
      whereArgs: [expense.id, expense.userId],
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
