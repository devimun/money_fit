import 'package:money_fit/core/database/app_database.dart';
import 'package:money_fit/core/foundation/money_minor_units.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/repositories/user_repository.dart';
import 'package:sqflite/sqflite.dart';

/// Compatibility projection of a v6 local ledger owner into the historical
/// `IUserRepository` contract.
///
/// Email, display name, theme, language and notification intent are no longer
/// financial columns in v6. Callers that need those values should use their
/// feature-owned repositories; this adapter exists for the remaining settings
/// screen while the public API is migrated.
class SqliteV6UserRepository implements IUserRepository {
  const SqliteV6UserRepository({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<void> createUser(User user) async {
    if (user.id.trim().isEmpty) {
      throw ArgumentError.value(user.id, 'user.id', 'must not be blank');
    }
    final db = await _database.executor;
    final batch = db.batch();
    batch.insert('local_users', {
      'id': user.id,
      'remote_user_id': null,
      'created_at': user.createdAt.toUtc().toIso8601String(),
    });
    batch.insert('ledger_settings', {
      'owner_id': user.id,
      'currency_code': _currencyCode(user.currencyCode),
    });
    if (user.budget > 0) {
      batch.insert('budgets', {
        'owner_id': user.id,
        'cadence': user.budgetType.name,
        'amount_minor': MoneyMinorUnits.toMinor(
          user.budget,
          _currencyCode(user.currencyCode),
        ),
        'updated_at': user.updatedAt.toUtc().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await _database.executor;
    await db.delete('local_users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<User>> getAllUsers() async {
    final db = await _database.executor;
    final rows = await _queryUsers(db);
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<User?> getUser(String id) async {
    final db = await _database.executor;
    final rows = await _queryUsers(db, id: id);
    return rows.isEmpty ? null : _fromRow(rows.single);
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await _database.executor;
    final requestedCurrencyCode = _currencyCode(user.currencyCode);
    final owner = await db.query(
      'local_users',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [user.id],
    );
    if (owner.isEmpty) {
      throw StateError('Cannot update a missing owner: ${user.id}');
    }

    final settings = await db.query(
      'ledger_settings',
      columns: const ['currency_code'],
      where: 'owner_id = ?',
      whereArgs: [user.id],
    );
    if (settings.length != 1 || settings.single['currency_code'] is! String) {
      throw StateError('Missing ledger settings for owner: ${user.id}');
    }
    final currencyCode = settings.single['currency_code']! as String;
    if (currencyCode != requestedCurrencyCode) {
      throw StateError(
        'Ledger currency must be changed through LedgerCurrencyCommands.',
      );
    }
    if (user.budget <= 0) {
      await db.delete('budgets', where: 'owner_id = ?', whereArgs: [user.id]);
      return;
    }
    await db.rawInsert(
      '''
      INSERT INTO budgets(owner_id, cadence, amount_minor, updated_at)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(owner_id) DO UPDATE SET
        cadence = excluded.cadence,
        amount_minor = excluded.amount_minor,
        updated_at = excluded.updated_at
      ''',
      [
        user.id,
        user.budgetType.name,
        MoneyMinorUnits.toMinor(user.budget, currencyCode),
        user.updatedAt.toUtc().toIso8601String(),
      ],
    );
  }

  Future<List<Map<String, Object?>>> _queryUsers(
    DatabaseExecutor db, {
    String? id,
  }) {
    return db.rawQuery('''
      SELECT u.id, u.created_at, s.currency_code, b.cadence, b.amount_minor,
             b.updated_at AS budget_updated_at
      FROM local_users u
      JOIN ledger_settings s ON s.owner_id = u.id
      LEFT JOIN budgets b ON b.owner_id = u.id
      ${id == null ? '' : 'WHERE u.id = ?'}
      ORDER BY u.created_at ASC, u.id ASC
      ''', id == null ? null : [id]);
  }

  User _fromRow(Map<String, Object?> row) {
    final id = row['id'];
    final createdAt = row['created_at'];
    final currencyCode = row['currency_code'];
    if (id is! String || createdAt is! String || currencyCode is! String) {
      throw FormatException('Invalid v6 user row');
    }
    final parsedCreatedAt = DateTime.tryParse(createdAt);
    if (parsedCreatedAt == null) {
      throw FormatException('Invalid user creation time');
    }
    final cadence = row['cadence'];
    final amountMinor = row['amount_minor'];
    final updatedAt = row['budget_updated_at'];
    return User(
      id: id,
      budget: amountMinor is int
          ? MoneyMinorUnits.fromMinor(amountMinor, currencyCode)
          : 0,
      budgetType: cadence == 'monthly' ? BudgetType.monthly : BudgetType.daily,
      isDarkMode: false,
      notificationsEnabled: false,
      createdAt: parsedCreatedAt.toUtc(),
      updatedAt: updatedAt is String
          ? DateTime.parse(updatedAt).toUtc()
          : parsedCreatedAt.toUtc(),
      currencyCode: currencyCode,
    );
  }

  String _currencyCode(String value) {
    final normalized = value.toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalized)) {
      throw ArgumentError.value(value, 'currencyCode', 'must be ISO-4217-like');
    }
    return normalized;
  }
}
