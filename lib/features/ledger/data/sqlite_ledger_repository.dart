import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/features/ledger/data/category_row.dart';
import 'package:money_fit/features/ledger/data/expense_row.dart';
import 'package:money_fit/features/ledger/data/ledger_mapper.dart';
import 'package:money_fit/features/ledger/domain/category.dart';
import 'package:money_fit/features/ledger/domain/expense_entry.dart';
import 'package:money_fit/features/ledger/domain/ledger_repository.dart';

class SqliteLedgerRepository implements LedgerRepository {
  const SqliteLedgerRepository({
    required AppDatabase database,
    required LedgerMapper mapper,
  }) : _database = database,
       _mapper = mapper;

  final AppDatabase _database;
  final LedgerMapper _mapper;

  @override
  Future<MonthlyLedger> readMonth(ExpenseMonthKey key) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'user_id = ? AND date LIKE ?',
      whereArgs: [key.ownerId, '${key.month}%'],
      orderBy: 'date DESC, created_at DESC',
    );
    return MonthlyLedger(
      key: key,
      entries: rows
          .map((row) => _mapper.expenseFromRow(ExpenseRow.fromMap(row)))
          .toList(growable: false),
    );
  }

  @override
  Future<ExpenseEntry?> findExpense(String id, String ownerId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, ownerId],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : _mapper.expenseFromRow(ExpenseRow.fromMap(rows.single));
  }

  @override
  Future<List<LedgerCategory>> readCategories(String ownerId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'categories',
      where: 'user_id IS NULL OR user_id = ?',
      whereArgs: [ownerId],
      orderBy: 'type',
    );
    return rows
        .map(
          (row) => _mapper.categoryFromRow(CategoryRow.fromMap(row), ownerId),
        )
        .toList(growable: false);
  }

  @override
  Future<void> insertExpense(ExpenseEntry expense) => _write(expense, false);

  @override
  Future<void> replaceExpense(ExpenseEntry expense) => _write(expense, true);

  Future<void> _write(ExpenseEntry expense, bool replace) async {
    final db = await _database.executor;
    final category = await db.query(
      'categories',
      columns: const ['type'],
      where: 'id = ?',
      whereArgs: [expense.categoryId],
      limit: 1,
    );
    if (category.isEmpty) {
      throw StateError('Unknown category: ${expense.categoryId}');
    }
    final row = {
      'id': expense.id,
      'user_id': expense.ownerId,
      'name': expense.name,
      'amount': double.parse(expense.amount.toDecimalString()),
      'date': expense.occurredOn.toString(),
      'category_id': expense.categoryId,
      'type': category.single['type'],
      'created_at': expense.createdAt.toIso8601String(),
      'updated_at': expense.updatedAt.toIso8601String(),
    };
    if (replace) {
      await db.update(
        'expenses',
        row,
        where: 'id = ? AND user_id = ?',
        whereArgs: [expense.id, expense.ownerId],
      );
    } else {
      await db.insert('expenses', row);
    }
  }

  @override
  Future<void> deleteExpense(String id, String ownerId) async {
    final db = await _database.executor;
    await db.delete(
      'expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, ownerId],
    );
  }
}
