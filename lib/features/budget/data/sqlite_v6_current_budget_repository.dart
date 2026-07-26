import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/foundation/money_minor_units.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/features/budget/domain/current_budget.dart';
import 'package:money_fit/features/budget/domain/current_budget_repository.dart';

/// v6 current-budget storage backed by `budgets` and the owner's immutable
/// ledger currency in `ledger_settings`.
class SqliteV6CurrentBudgetRepository implements CurrentBudgetRepository {
  SqliteV6CurrentBudgetRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Future<CurrentBudget?> read(String ownerId) async {
    final db = await _database.executor;
    final rows = await db.rawQuery(
      '''
      SELECT b.amount_minor, b.cadence, s.currency_code
      FROM budgets b
      JOIN ledger_settings s ON s.owner_id = b.owner_id
      WHERE b.owner_id = ?
      ''',
      [ownerId],
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    final amountMinor = row['amount_minor'];
    final cadence = row['cadence'];
    final currencyCode = row['currency_code'];
    if (amountMinor is! int || cadence is! String || currencyCode is! String) {
      throw FormatException('Invalid v6 budget row');
    }
    return CurrentBudget(
      amount: MoneyMinorUnits.fromMinor(amountMinor, currencyCode),
      type: switch (cadence) {
        'daily' => BudgetType.daily,
        'monthly' => BudgetType.monthly,
        _ => throw FormatException('Invalid budget cadence'),
      },
    );
  }

  @override
  Future<void> save(String ownerId, CurrentBudget budget) async {
    final db = await _database.executor;
    final settings = await db.query(
      'ledger_settings',
      columns: ['currency_code'],
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    if (settings.isEmpty) {
      throw StateError('Cannot save a budget for an unknown owner: $ownerId');
    }
    final currencyCode = settings.single['currency_code'];
    if (currencyCode is! String) {
      throw FormatException('Invalid ledger currency');
    }
    final amountMinor = MoneyMinorUnits.toMinor(budget.amount, currencyCode);
    final updatedAt = _now().toUtc().toIso8601String();
    await db.rawInsert(
      '''
      INSERT INTO budgets(owner_id, cadence, amount_minor, updated_at)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(owner_id) DO UPDATE SET
        cadence = excluded.cadence,
        amount_minor = excluded.amount_minor,
        updated_at = excluded.updated_at
      ''',
      [ownerId, budget.type.name, amountMinor, updatedAt],
    );
  }
}
