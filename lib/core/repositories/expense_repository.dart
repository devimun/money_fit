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

  Future<void> getAll() async {
    final db = await _dbHelper.database;
    final data = await db.query('expenses');
    log(data.toString());
  }

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

  // /// 테스트용으로 7월 한 달 간 더미 지출 데이터를 삽입합니다.
  // Future<void> seedJulyExpenses() async {
  //   final random = math.Random();
  //   final year = 2025;
  //   final month = 7;

  //   final categoryMap = {
  //     // 필수
  //     'food': ['식사', ExpenseType.essential],
  //     'traffic': ['교통', ExpenseType.essential],
  //     'communication': ['통신', ExpenseType.essential],
  //     'housing': ['주거/공과금', ExpenseType.essential],
  //     'medical': ['의료', ExpenseType.essential],
  //     'insurance': ['보험', ExpenseType.essential],
  //     'finance': ['금융', ExpenseType.essential],
  //     'necessities': ['생필품', ExpenseType.essential],
  //     // 변동
  //     'eating-out': ['외식', ExpenseType.discretionary],
  //     'cafe': ['카페/간식', ExpenseType.discretionary],
  //     'shopping': ['쇼핑', ExpenseType.discretionary],
  //     'hobby': ['취미/여가', ExpenseType.discretionary],
  //     'travel': ['여행/휴식', ExpenseType.discretionary],
  //     'subscribe': ['구독', ExpenseType.discretionary],
  //     'beauty': ['미용', ExpenseType.discretionary],
  //   };

  //   final categoryIds = categoryMap.keys.toList();

  //   for (int day = 1; day <= 31; day++) {
  //     final date = DateTime(year, month, day);
  //     final expenseCount = random.nextInt(3) + 1;

  //     for (int i = 0; i < expenseCount; i++) {
  //       final categoryId = categoryIds[random.nextInt(categoryIds.length)];
  //       final name = categoryMap[categoryId]![0] as String;
  //       final type = categoryMap[categoryId]![1] as ExpenseType;
  //       final amount = (random.nextInt(9) + 1) * 1000 + random.nextInt(500);

  //       final expense = Expense(
  //         id: Uuid().v4(),
  //         userId: 'c8b33616-00b5-4ece-9fdd-bbc232f7b61f',
  //         name: '$name 지출',
  //         amount: amount.toDouble(),
  //         date: date,
  //         categoryId: categoryId,
  //         type: type,
  //         createdAt: date,
  //         updatedAt: date,
  //       );

  //       await createExpense(expense);
  //     }
  //   }
  // }
}
