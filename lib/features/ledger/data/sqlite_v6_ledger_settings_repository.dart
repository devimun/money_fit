import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/features/ledger/domain/ledger_settings_repository.dart';

/// SQLite implementation for the v6 `ledger_settings` source of truth.
class SqliteV6LedgerSettingsRepository implements LedgerSettingsRepository {
  const SqliteV6LedgerSettingsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<LedgerCurrency> readCurrency(String ownerId) async {
    final db = await _database.executor;
    final rows = await db.query(
      'ledger_settings',
      columns: const ['currency_code'],
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    if (rows.length != 1 || rows.single['currency_code'] is! String) {
      throw StateError('Missing ledger settings for owner: $ownerId');
    }
    return ledgerCurrencyForCode(rows.single['currency_code']! as String);
  }

  @override
  Future<void> setCurrency(String ownerId, LedgerCurrency currency) async {
    final normalized = _validatedCode(currency.code);
    final db = await _database.executor;
    final settings = await db.query(
      'ledger_settings',
      columns: const ['currency_code'],
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    if (settings.length != 1 || settings.single['currency_code'] is! String) {
      throw StateError('Missing ledger settings for owner: $ownerId');
    }
    if (settings.single['currency_code'] == normalized) return;

    // Existing values are integers in the previous currency's scale. The
    // conditional statement makes the no-records check and update atomic even
    // though AppDatabase intentionally exposes only DatabaseExecutor.
    final changed = await db.rawUpdate(
      '''
      UPDATE ledger_settings
      SET currency_code = ?
      WHERE owner_id = ?
        AND NOT EXISTS(SELECT 1 FROM expenses WHERE owner_id = ?)
        AND NOT EXISTS(SELECT 1 FROM budgets WHERE owner_id = ?)
      ''',
      [normalized, ownerId, ownerId, ownerId],
    );
    if (changed != 1) {
      throw StateError(
        'Cannot change currency after financial records exist for $ownerId.',
      );
    }
  }

  String _validatedCode(String code) {
    final normalized = code.toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalized)) {
      throw ArgumentError.value(code, 'currency.code', 'must be ISO-4217-like');
    }
    return normalized;
  }
}
