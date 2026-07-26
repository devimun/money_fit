import 'package:sqflite/sqflite.dart';

/// The isolated v5 -> v6 ledger migration.
///
/// This deliberately does not change [DatabaseHelper] yet: production v5
/// repositories still read `users`, `categories`, and `expenses`. Keeping the
/// migration here lets the rollout wire the new repositories and `onConfigure`
/// together in one later change, without exposing a partially migrated DB to
/// the v5 code.
final class SqliteV6Migration {
  SqliteV6Migration._();

  static const version = 6;

  /// Enables FK enforcement for this connection, then performs the complete
  /// rebuild in one transaction. A validation error leaves the v5 tables and
  /// rows intact.
  static Future<void> migrate(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
    await database.transaction(migrateInTransaction);
  }

  /// Performs the migration in an existing transaction.
  ///
  /// Callers that open the production database must enable foreign keys in
  /// `onConfigure`; SQLite cannot reliably toggle that setting mid-transaction.
  static Future<void> migrateInTransaction(Transaction txn) async {
    final users = await txn.query('users');
    final categories = await txn.query('categories');
    final expenses = await txn.query('expenses');

    await txn.execute('DROP TABLE expenses');
    await txn.execute('DROP TABLE categories');
    await txn.execute('DROP TABLE users');
    await createSchema(txn);

    final owners = <String, _LegacyUser>{};
    for (final row in users) {
      final user = _LegacyUser.fromRow(row);
      if (owners.containsKey(user.id)) {
        throw FormatException('Duplicate v5 user id: ${user.id}');
      }
      owners[user.id] = user;
      await txn.insert('local_users', {
        'id': user.id,
        // v5 `email` is contact data, not a durable remote identity.
        'remote_user_id': null,
        'created_at': user.createdAt,
      });
      await txn.insert('ledger_settings', {
        'owner_id': user.id,
        'currency_code': user.currencyCode,
      });
      // A zero v5 budget means setup has not completed; v6 represents that by
      // the absence of a CurrentBudget row rather than an invalid zero amount.
      if (user.budget > 0) {
        await txn.insert('budgets', {
          'owner_id': user.id,
          'cadence': user.budgetType,
          'amount_minor': _toMinor(user.budget, user.currencyCode),
          'updated_at': user.updatedAt,
        });
      } else if (user.budget < 0) {
        throw FormatException('Negative v5 budget for owner ${user.id}');
      }
    }

    final globals = <_LegacyCategory>[];
    final ownerCategories = <String, Map<String, String>>{};
    for (final row in categories) {
      final category = _LegacyCategory.fromRow(row);
      if (category.ownerId == null) {
        globals.add(category);
        continue;
      }
      if (!owners.containsKey(category.ownerId)) {
        throw FormatException('Category ${category.id} references no owner');
      }
      final mapping = ownerCategories.putIfAbsent(
        category.ownerId!,
        () => <String, String>{},
      );
      if (mapping.containsKey(category.id)) {
        throw FormatException('Duplicate category ${category.id}');
      }
      mapping[category.id] = category.id;
      await txn.insert('categories', {
        'id': category.id,
        'owner_id': category.ownerId,
        'stable_code': null,
        'display_name': category.name,
        'spending_kind': category.spendingKind,
        'is_built_in': 0,
        'archived_at': null,
      });
    }

    // v5 global categories must become owner-scoped rows before a composite FK
    // can protect expenses. Their stable code preserves the legacy category id.
    for (final owner in owners.values) {
      final mapping = ownerCategories.putIfAbsent(
        owner.id,
        () => <String, String>{},
      );
      for (final category in globals) {
        if (mapping.containsKey(category.id)) {
          throw FormatException(
            'Owner ${owner.id} has both global and custom ${category.id}',
          );
        }
        final id = await _nextBuiltInId(txn, owner.id, category.id);
        mapping[category.id] = id;
        await txn.insert('categories', {
          'id': id,
          'owner_id': owner.id,
          'stable_code': category.id,
          'display_name': null,
          'spending_kind': category.spendingKind,
          'is_built_in': 1,
          'archived_at': null,
        });
      }
    }

    for (final row in expenses) {
      final expense = _LegacyExpense.fromRow(row);
      final owner = owners[expense.ownerId];
      if (owner == null) {
        throw FormatException('Expense ${expense.id} references no owner');
      }
      final categoryId = ownerCategories[owner.id]?[expense.categoryId];
      if (categoryId == null) {
        throw FormatException(
          'Expense ${expense.id} references missing/cross-owner category '
          '${expense.categoryId}',
        );
      }
      await txn.insert('expenses', {
        'id': expense.id,
        'owner_id': owner.id,
        'title': expense.title,
        'amount_minor': _toMinor(expense.amount, owner.currencyCode),
        'occurred_on': expense.occurredOn,
        'category_id': categoryId,
        'created_at': expense.createdAt,
        'updated_at': expense.updatedAt,
      });
    }
  }

  static Future<void> createSchema(DatabaseExecutor executor) async {
    await executor.execute('''
      CREATE TABLE local_users (
        id TEXT PRIMARY KEY,
        remote_user_id TEXT UNIQUE,
        created_at TEXT NOT NULL CHECK (
          created_at GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*Z'
        )
      )
    ''');
    await executor.execute('''
      CREATE TABLE ledger_settings (
        owner_id TEXT PRIMARY KEY,
        currency_code TEXT NOT NULL CHECK (
          length(currency_code) = 3 AND currency_code GLOB '[A-Z][A-Z][A-Z]'
        ),
        FOREIGN KEY (owner_id) REFERENCES local_users(id) ON DELETE CASCADE
      )
    ''');
    await executor.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        stable_code TEXT,
        display_name TEXT,
        spending_kind TEXT NOT NULL CHECK (
          spending_kind IN ('essential', 'discretionary')
        ),
        is_built_in INTEGER NOT NULL CHECK (
          typeof(is_built_in) = 'integer' AND is_built_in IN (0, 1)
        ),
        archived_at TEXT CHECK (
          archived_at IS NULL OR archived_at GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*Z'
        ),
        FOREIGN KEY (owner_id) REFERENCES local_users(id) ON DELETE CASCADE,
        UNIQUE (id, owner_id),
        CHECK (
          (is_built_in = 1 AND stable_code IS NOT NULL AND display_name IS NULL)
          OR
          (is_built_in = 0 AND stable_code IS NULL AND display_name IS NOT NULL)
        )
      )
    ''');
    await executor.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        owner_id TEXT NOT NULL,
        title TEXT NOT NULL CHECK (length(trim(title)) > 0),
        amount_minor INTEGER NOT NULL CHECK (
          typeof(amount_minor) = 'integer' AND amount_minor > 0
        ),
        occurred_on TEXT NOT NULL CHECK (
          length(occurred_on) = 10
          AND occurred_on GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
        ),
        category_id TEXT NOT NULL,
        created_at TEXT NOT NULL CHECK (
          created_at GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*Z'
        ),
        updated_at TEXT NOT NULL CHECK (
          updated_at GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*Z'
        ),
        FOREIGN KEY (owner_id) REFERENCES local_users(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id, owner_id)
          REFERENCES categories(id, owner_id) ON DELETE RESTRICT
      )
    ''');
    await executor.execute('''
      CREATE TABLE budgets (
        owner_id TEXT PRIMARY KEY,
        cadence TEXT NOT NULL CHECK (cadence IN ('daily', 'monthly')),
        amount_minor INTEGER NOT NULL CHECK (
          typeof(amount_minor) = 'integer' AND amount_minor > 0
        ),
        updated_at TEXT NOT NULL CHECK (
          updated_at GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]*Z'
        ),
        FOREIGN KEY (owner_id) REFERENCES local_users(id) ON DELETE CASCADE
      )
    ''');
    await executor.execute(
      'CREATE INDEX idx_expenses_owner_date ON expenses(owner_id, occurred_on)',
    );
    await executor.execute('''
      CREATE INDEX idx_expenses_owner_category_date
      ON expenses(owner_id, category_id, occurred_on)
    ''');
    await executor.execute('''
      CREATE INDEX idx_categories_owner_archived
      ON categories(owner_id, archived_at)
    ''');
    await executor.execute('''
      CREATE UNIQUE INDEX idx_categories_owner_stable_code
      ON categories(owner_id, stable_code) WHERE stable_code IS NOT NULL
    ''');
  }

  static Future<String> _nextBuiltInId(
    DatabaseExecutor executor,
    String ownerId,
    String stableCode,
  ) async {
    final base = 'builtin:$ownerId:$stableCode';
    var candidate = base;
    var suffix = 1;
    while ((await executor.query(
      'categories',
      where: 'id = ?',
      whereArgs: [candidate],
    )).isNotEmpty) {
      candidate = '$base#$suffix';
      suffix++;
    }
    return candidate;
  }
}

final class _LegacyUser {
  const _LegacyUser({
    required this.id,
    required this.budget,
    required this.budgetType,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _LegacyUser.fromRow(Map<String, Object?> row) {
    final currencyCode = _currency(row['currency_code']);
    return _LegacyUser(
      id: _text(row['id'], 'user id'),
      budget: _number(row['budget'], 'user budget'),
      budgetType: _cadence(row['budget_type']),
      currencyCode: currencyCode,
      createdAt: _utcInstant(row['created_at'], 'user created_at'),
      updatedAt: _utcInstant(row['updated_at'], 'user updated_at'),
    );
  }

  final String id;
  final double budget;
  final String budgetType;
  final String currencyCode;
  final String createdAt;
  final String updatedAt;
}

final class _LegacyCategory {
  const _LegacyCategory({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.spendingKind,
  });

  factory _LegacyCategory.fromRow(Map<String, Object?> row) => _LegacyCategory(
    id: _text(row['id'], 'category id'),
    ownerId: row['user_id'] as String?,
    name: _text(row['name'], 'category name'),
    spendingKind: _spendingKind(row['type'], 'category type'),
  );

  final String id;
  final String? ownerId;
  final String name;
  final String spendingKind;
}

final class _LegacyExpense {
  const _LegacyExpense({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.amount,
    required this.occurredOn,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _LegacyExpense.fromRow(Map<String, Object?> row) => _LegacyExpense(
    id: _text(row['id'], 'expense id'),
    ownerId: _text(row['user_id'], 'expense user_id'),
    title: _text(row['name'], 'expense name'),
    amount: _number(row['amount'], 'expense amount'),
    occurredOn: _localDate(row['date'], 'expense date'),
    categoryId: _text(row['category_id'], 'expense category_id'),
    createdAt: _utcInstant(row['created_at'], 'expense created_at'),
    updatedAt: _utcInstant(row['updated_at'], 'expense updated_at'),
  );

  final String id;
  final String ownerId;
  final String title;
  final double amount;
  final String occurredOn;
  final String categoryId;
  final String createdAt;
  final String updatedAt;
}

String _text(Object? value, String label) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Invalid $label');
  }
  return value;
}

double _number(Object? value, String label) {
  if (value is! num || !value.isFinite) {
    throw FormatException('Invalid $label');
  }
  return value.toDouble();
}

String _currency(Object? value) {
  final code = _text(value, 'currency code').toUpperCase();
  if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
    throw FormatException('Invalid currency code');
  }
  return code;
}

String _cadence(Object? value) {
  if (value == 'daily' || value == 'monthly') return value! as String;
  throw FormatException('Invalid budget cadence');
}

String _spendingKind(Object? value, String label) {
  if (value == 'essential' || value == 'discretionary') return value! as String;
  throw FormatException('Invalid $label');
}

String _localDate(Object? value, String label) {
  final date = _text(value, label);
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(date);
  if (match == null) throw FormatException('Invalid $label');
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final parsed = DateTime.utc(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    throw FormatException('Invalid $label');
  }
  return date;
}

String _utcInstant(Object? value, String label) {
  final raw = _text(value, label);
  final parsed = DateTime.tryParse(raw);
  if (parsed == null || !raw.contains('T')) {
    throw FormatException('Invalid $label');
  }
  return parsed.toUtc().toIso8601String();
}

int _toMinor(double major, String currencyCode) {
  if (!major.isFinite || major <= 0) {
    throw FormatException('Amount must be finite and positive');
  }
  final digits = switch (currencyCode) {
    'BHD' || 'IQD' || 'JOD' || 'KWD' || 'LYD' || 'OMR' || 'TND' => 3,
    'CLP' || 'IDR' || 'JPY' || 'KRW' || 'VND' => 0,
    _ => 2,
  };
  final minor = (major * _powerOfTen(digits)).round();
  if (minor <= 0 || minor > 9223372036854775807) {
    throw FormatException('Amount is outside SQLite integer range');
  }
  return minor;
}

int _powerOfTen(int exponent) => switch (exponent) {
  0 => 1,
  2 => 100,
  3 => 1000,
  _ => throw ArgumentError.value(exponent),
};
