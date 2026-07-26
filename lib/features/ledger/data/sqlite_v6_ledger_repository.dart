import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/foundation/local_date.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/features/ledger/domain/category.dart';
import 'package:money_fit/features/ledger/domain/expense_entry.dart';
import 'package:money_fit/features/ledger/domain/ledger_repository.dart';

/// Ledger adapter for the owner-scoped v6 SQLite schema.
///
/// This intentionally implements the same public [LedgerRepository] contract
/// as the v5 adapter. The application can therefore switch its database
/// rollout and repository composition together, without exposing v6 column
/// names or minor-unit storage to presentation code.
class SqliteV6LedgerRepository implements LedgerRepository {
  const SqliteV6LedgerRepository({
    required AppDatabase database,
    required LedgerCurrency currency,
  }) : _database = database,
       _currency = currency;

  final AppDatabase _database;
  final LedgerCurrency _currency;

  @override
  Future<MonthlyLedger> readMonth(ExpenseMonthKey key) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'owner_id = ? AND occurred_on LIKE ?',
      whereArgs: [key.ownerId, '${key.month}%'],
      orderBy: 'occurred_on DESC, created_at DESC',
    );
    return MonthlyLedger(
      key: key,
      entries: rows.map(_expenseFromRow).toList(growable: false),
    );
  }

  @override
  Future<ExpenseEntry?> findExpense(String id, String ownerId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'expenses',
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, ownerId],
      limit: 1,
    );
    return rows.isEmpty ? null : _expenseFromRow(rows.single);
  }

  @override
  Future<List<LedgerCategory>> readCategories(String ownerId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'categories',
      where: 'owner_id = ? AND archived_at IS NULL',
      whereArgs: [ownerId],
      orderBy: 'spending_kind, is_built_in DESC, stable_code, display_name',
    );
    return rows.map(_categoryFromRow).toList(growable: false);
  }

  @override
  Future<void> insertExpense(ExpenseEntry expense) => _write(expense, false);

  @override
  Future<void> replaceExpense(ExpenseEntry expense) => _write(expense, true);

  Future<void> _write(ExpenseEntry expense, bool replace) async {
    _requireRepositoryCurrency(expense.amount);
    final db = await _database.executor;
    final category = await db.query(
      'categories',
      columns: const ['id'],
      where: 'id = ? AND owner_id = ? AND archived_at IS NULL',
      whereArgs: [expense.categoryId, expense.ownerId],
      limit: 1,
    );
    if (category.isEmpty) {
      throw StateError(
        'Unknown active category ${expense.categoryId} for ${expense.ownerId}',
      );
    }

    final row = <String, Object?>{
      'id': expense.id,
      'owner_id': expense.ownerId,
      'title': expense.name,
      'amount_minor': expense.amount.minorUnits,
      'occurred_on': expense.occurredOn.toString(),
      'category_id': expense.categoryId,
      'created_at': expense.createdAt.toUtc().toIso8601String(),
      'updated_at': expense.updatedAt.toUtc().toIso8601String(),
    };
    if (replace) {
      await db.update(
        'expenses',
        row,
        where: 'id = ? AND owner_id = ?',
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
      where: 'id = ? AND owner_id = ?',
      whereArgs: [id, ownerId],
    );
  }

  ExpenseEntry _expenseFromRow(Map<String, Object?> row) => ExpenseEntry(
    id: row['id'] as String,
    ownerId: row['owner_id'] as String,
    name: row['title'] as String,
    amount: Money(minorUnits: row['amount_minor'] as int, currency: _currency),
    occurredOn: LocalDate.parse(row['occurred_on'] as String),
    categoryId: row['category_id'] as String,
    createdAt: DateTime.parse(row['created_at'] as String),
    updatedAt: DateTime.parse(row['updated_at'] as String),
  );

  LedgerCategory _categoryFromRow(Map<String, Object?> row) {
    final kind = switch (row['spending_kind'] as String) {
      'essential' => SpendingKind.essential,
      'discretionary' => SpendingKind.discretionary,
      final value => throw FormatException('Unknown category kind.', value),
    };
    final isBuiltIn = row['is_built_in'] == 1;
    final name = isBuiltIn
        ? row['stable_code'] as String?
        : row['display_name'] as String?;
    if (name == null || name.isEmpty) {
      throw FormatException('Invalid v6 category name.', row['id']);
    }
    return LedgerCategory(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: name,
      kind: kind,
      isBuiltIn: isBuiltIn,
    );
  }

  void _requireRepositoryCurrency(Money amount) {
    if (amount.currency != _currency) {
      throw ArgumentError.value(
        amount.currency,
        'expense.amount.currency',
        'The amount currency must match the owner ledger currency.',
      );
    }
  }
}
