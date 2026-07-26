import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/error/app_failure.dart';
import 'package:money_fit/core/foundation/local_date.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:sqflite/sqflite.dart';

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
  Future<Expense?> findExpense(String id, String userId);

  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id, String userId);
}

class ExpenseRepository implements IExpenseRepository {
  final AppDatabase? _appDatabase;
  final DatabaseExecutor? _databaseExecutor;

  ExpenseRepository({required AppDatabase database})
    : _appDatabase = database,
      _databaseExecutor = null;

  /// Test-only SQLite seam. App composition continues to use [DatabaseHelper]
  /// until the database boundary is extracted.
  ExpenseRepository.forTesting({required DatabaseExecutor databaseExecutor})
    : _appDatabase = null,
      _databaseExecutor = databaseExecutor;

  Future<DatabaseExecutor> get _database async =>
      _databaseExecutor ?? await _appDatabase!.executor;

  @override
  Future<void> createExpense(Expense expense) =>
      _runStorage('create expense', () async {
        final db = await _database;
        await db.insert('expenses', expense.toJson());
      });

  @override
  Future<List<Expense>> getExpensesByUserId(String userId) =>
      _runStorage('read user expenses', () async {
        final db = await _database;
        final maps = await db.query(
          'expenses',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'date DESC, created_at DESC',
        );
        return maps.map(_expenseFromRow).toList(growable: false);
      });

  @override
  Future<Expense?> findExpense(String id, String userId) =>
      _runStorage('find expense', () async {
        final db = await _database;
        final maps = await db.query(
          'expenses',
          where: 'id = ? AND user_id = ?',
          whereArgs: [id, userId],
          limit: 1,
        );
        return maps.isEmpty ? null : _expenseFromRow(maps.single);
      });

  /// 특정 날짜의 모든 지출 내역을 가져옵니다.
  @override
  Future<List<Expense>> getExpensesByDate(String userId, DateTime date) =>
      _runStorage('read daily expenses', () async {
        final db = await _database;
        final dateString = date.toIso8601String().substring(0, 10);
        final maps = await db.query(
          'expenses',
          where: 'user_id = ? AND date = ?',
          whereArgs: [userId, dateString],
          orderBy: 'created_at DESC',
        );
        return maps.map(_expenseFromRow).toList(growable: false);
      });

  /// 특정 월의 모든 지출 내역을 가져옵니다.
  @override
  Future<Map<DateTime, List<Expense>>> getExpensesByMonth(
    String userId,
    int year,
    int month,
  ) => _runStorage('read monthly expenses', () async {
    final db = await _database;
    final monthString = '$year-${month.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'expenses',
      where: 'user_id = ? AND date LIKE ?',
      whereArgs: [userId, '$monthString%'],
      orderBy: 'date DESC, created_at DESC',
    );

    final grouped = <DateTime, List<Expense>>{};

    for (final map in maps) {
      final expense = _expenseFromRow(map);
      final dateOnly = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      grouped.putIfAbsent(dateOnly, () => []).add(expense);
    }

    return grouped;
  });

  @override
  Future<void> updateExpense(Expense expense) =>
      _runStorage('update expense', () async {
        final db = await _database;
        final affectedRows = await db.update(
          'expenses',
          expense.toJson(),
          where: 'id = ? AND user_id = ?',
          whereArgs: [expense.id, expense.userId],
        );
        if (affectedRows == 0) {
          throw NotFoundFailure(resource: 'Expense', identifier: expense.id);
        }
      });

  @override
  Future<void> deleteExpense(String id, String userId) =>
      _runStorage('delete expense', () async {
        final db = await _database;
        final affectedRows = await db.delete(
          'expenses',
          where: 'id = ? AND user_id = ?',
          whereArgs: [id, userId],
        );
        if (affectedRows == 0) {
          throw NotFoundFailure(resource: 'Expense', identifier: id);
        }
      });

  Future<T> _runStorage<T>(
    String operation,
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } on AppFailure {
      rethrow;
    } catch (error, stackTrace) {
      throw StorageFailure(
        operation: operation,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Expense _expenseFromRow(Map<String, Object?> row) {
    try {
      final type = row['type'];
      if (type is! String ||
          !ExpenseType.values.any((value) => value.name == type)) {
        throw FormatException('Unknown expense type.', type);
      }

      final date = row['date'];
      if (date is! String) {
        throw FormatException('Expense date must be a string.', date);
      }
      LocalDate.parse(date);

      return Expense.fromJson(Map<String, dynamic>.from(row));
    } catch (error, stackTrace) {
      throw CorruptDataFailure(
        resource: 'expense',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
