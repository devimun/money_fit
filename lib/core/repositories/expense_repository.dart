import 'dart:developer';

import 'package:money_fit/core/database/database_helper.dart';
import 'package:money_fit/core/models/expense_model.dart';

/// ExpenseRepository의 인터페이스입니다.
abstract class IExpenseRepository {
  Future<void> createExpense(Expense expense);
  Future<List<Expense>> getExpensesByDate(String userId, DateTime date);
  Future<Map<DateTime, List<Expense>>> getExpensesByMonth(
    String userId,
    int year,
    int month,
  );
  Future<List<Expense>> getExpensesByUserId(String userId);

  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

class ExpenseRepository implements IExpenseRepository {
  final DatabaseHelper _dbHelper;

  ExpenseRepository({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  // Future<void> getAll() async {
  //   final db = await _dbHelper.database;
  //   final data = await db.query('expenses');
  //   log(data.toString());
  // }

  @override
  Future<void> createExpense(Expense expense) async {
    final db = await _dbHelper.database;
    await db.insert('expenses', expense.toJson());
  }

  @override
  Future<List<Expense>> getExpensesByUserId(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, created_at DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
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
  Future<Map<DateTime, List<Expense>>> getExpensesByMonth(
    String userId,
    int year,
    int month,
  ) async {
    try {
      final db = await _dbHelper.database;
      final monthString = '$year-${month.toString().padLeft(2, '0')}';

      final List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: 'user_id = ? AND date LIKE ?',
        whereArgs: [userId, '$monthString%'],
        orderBy: 'date DESC, created_at DESC',
      );

      // 날짜별로 그룹핑된 결과를 저장할 Map
      final Map<DateTime, List<Expense>> grouped = {};

      for (final map in maps) {
        final expense = Expense.fromJson(map);

        // 날짜만 추출 (시간 제거)
        final dateOnly = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );

        grouped.putIfAbsent(dateOnly, () => []).add(expense);
      }

      return grouped;
    } on Exception catch (e) {
      log(e.toString());
      return {};
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final db = await _dbHelper.database;
    log('Updating expense: ${expense.toJson()}');
    try {
      final data = await db.update(
        'expenses',
        expense.toJson(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [expense.id, expense.userId],
      );
      log('Rows affected: $data');
      if (data == 0) {
        final check = await db.query(
          'expenses',
          where: 'id = ? AND user_id = ?',
          whereArgs: [expense.id, expense.userId],
        );
        log('🔍 Existing row check: $check');
      }
    } catch (e) {
      log('$e');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
