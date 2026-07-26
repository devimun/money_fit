import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/error/app_failure.dart';
import 'package:money_fit/core/foundation/money_minor_units.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_repository.dart';

/// Compatibility adapter for the remaining presentation paths using [Expense].
class SqliteV6LegacyExpenseRepository implements IExpenseRepository {
  const SqliteV6LegacyExpenseRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> createExpense(Expense expense) =>
      _write(expense, replace: false);

  @override
  Future<void> updateExpense(Expense expense) => _write(expense, replace: true);

  @override
  Future<void> deleteExpense(String id, String userId) async {
    final db = await _database.executor;
    final changed = await db.delete(
      'expenses',
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, userId],
    );
    if (changed == 0) {
      throw NotFoundFailure(resource: 'Expense', identifier: id);
    }
  }

  @override
  Future<Expense?> findExpense(String id, String userId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    return rows.isEmpty ? null : await _fromRow(rows.single);
  }

  @override
  Future<List<Expense>> getExpensesByDate(String userId, DateTime date) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'owner_id = ? AND occurred_on = ?',
      whereArgs: [userId, _day(date)],
      orderBy: 'created_at DESC',
    );
    return Future.wait(rows.map(_fromRow));
  }

  @override
  Future<Map<DateTime, List<Expense>>> getExpensesByMonth(
    String userId,
    int year,
    int month,
  ) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'owner_id = ? AND occurred_on LIKE ?',
      whereArgs: [userId, '$year-${month.toString().padLeft(2, '0')}%'],
      orderBy: 'occurred_on DESC, created_at DESC',
    );
    final result = <DateTime, List<Expense>>{};
    for (final row in rows) {
      final expense = await _fromRow(row);
      final day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      result.putIfAbsent(day, () => []).add(expense);
    }
    return result;
  }

  @override
  Future<List<Expense>> getExpensesByUserId(String userId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'owner_id = ?',
      whereArgs: [userId],
      orderBy: 'occurred_on DESC, created_at DESC',
    );
    return Future.wait(rows.map(_fromRow));
  }

  Future<void> _write(Expense expense, {required bool replace}) async {
    final db = await _database.executor;
    final category = await db.query(
      'categories',
      columns: const ['spending_kind'],
      where: 'id = ? AND owner_id = ? AND archived_at IS NULL',
      whereArgs: [expense.categoryId, expense.userId],
      limit: 1,
    );
    if (category.isEmpty) {
      throw StateError('Unknown active category: ${expense.categoryId}');
    }
    final currency = await _currencyFor(expense.userId);
    final row = <String, Object?>{
      'id': expense.id,
      'owner_id': expense.userId,
      'title': expense.name,
      'amount_minor': MoneyMinorUnits.toMinor(expense.amount, currency),
      'occurred_on': _day(expense.date),
      'category_id': expense.categoryId,
      'created_at': expense.createdAt.toUtc().toIso8601String(),
      'updated_at': expense.updatedAt.toUtc().toIso8601String(),
    };
    if (replace) {
      final changed = await db.update(
        'expenses',
        row,
        where: 'id = ? AND owner_id = ?',
        whereArgs: [expense.id, expense.userId],
      );
      if (changed == 0) {
        throw NotFoundFailure(resource: 'Expense', identifier: expense.id);
      }
    } else {
      await db.insert('expenses', row);
    }
  }

  Future<Expense> _fromRow(Map<String, Object?> row) async {
    final ownerId = row['owner_id'] as String;
    final category = await (await _database.executor).query(
      'categories',
      columns: const ['spending_kind'],
      where: 'id = ? AND owner_id = ?',
      whereArgs: [row['category_id'], ownerId],
      limit: 1,
    );
    final currency = await _currencyFor(ownerId);
    final amount = row['amount_minor'];
    if (amount is! int || category.isEmpty) {
      throw const FormatException('Invalid v6 expense row.');
    }
    return Expense(
      id: row['id'] as String,
      userId: ownerId,
      name: row['title'] as String,
      amount: MoneyMinorUnits.fromMinor(amount, currency),
      date: DateTime.parse(row['occurred_on'] as String),
      categoryId: row['category_id'] as String,
      type: category.single['spending_kind'] == 'essential'
          ? ExpenseType.essential
          : ExpenseType.discretionary,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Future<String> _currencyFor(String ownerId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'ledger_settings',
      columns: const ['currency_code'],
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      limit: 1,
    );
    final currency = rows.isEmpty ? null : rows.single['currency_code'];
    if (currency is! String) {
      throw StateError('Missing ledger settings for $ownerId');
    }
    return currency;
  }

  String _day(DateTime date) => date.toIso8601String().substring(0, 10);
}
