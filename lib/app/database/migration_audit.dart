import 'package:sqflite/sqflite.dart';

/// Non-sensitive shape categories observed before a schema migration.
///
/// The category is safe to put in a local dry-run report. It intentionally
/// contains neither a row identifier nor any user-entered value.
enum MigrationAuditCategory {
  userRows,
  anonymousUserIds,
  orphanExpenseUsers,
  missingExpenseCategories,
  crossOwnerExpenseCategories,
  unknownExpenseTypes,
  nonPositiveAmounts,
  nonFiniteAmounts,
  invalidOccurredOn,
  invalidCreatedAt,
  invalidUpdatedAt,
  duplicateCategoryStableIds,
  currencyRealAmounts,
}

/// A count-only report used to decide whether a legacy database is safe to
/// migrate. Do not add values, IDs, names, or raw SQL rows to this type.
class MigrationAuditReport {
  const MigrationAuditReport(this.counts, this.realAmountCountsByCurrency);

  final Map<MigrationAuditCategory, int> counts;

  /// Number of REAL legacy expense amounts grouped by a safe currency label.
  ///
  /// Currency is migration metadata, not a personal value. Invalid or missing
  /// codes are collapsed into a fixed category rather than echoed from the DB.
  final Map<String, int> realAmountCountsByCurrency;

  int operator [](MigrationAuditCategory category) => counts[category] ?? 0;

  bool get hasBlockingFindings => [
    MigrationAuditCategory.orphanExpenseUsers,
    MigrationAuditCategory.missingExpenseCategories,
    MigrationAuditCategory.crossOwnerExpenseCategories,
    MigrationAuditCategory.unknownExpenseTypes,
    MigrationAuditCategory.nonPositiveAmounts,
    MigrationAuditCategory.nonFiniteAmounts,
    MigrationAuditCategory.invalidOccurredOn,
    MigrationAuditCategory.invalidCreatedAt,
    MigrationAuditCategory.invalidUpdatedAt,
    MigrationAuditCategory.duplicateCategoryStableIds,
  ].any((category) => this[category] > 0);
}

/// Inspects a v5 database without exposing personal data in its result.
///
/// This is deliberately a read-only preflight. The v6 migration owns recovery
/// policy; this audit only describes legacy data shapes using counts.
class V5MigrationAuditor {
  const V5MigrationAuditor();

  Future<MigrationAuditReport> audit(DatabaseExecutor database) async {
    final counts = <MigrationAuditCategory, int>{
      for (final category in MigrationAuditCategory.values) category: 0,
    };

    Future<void> count(MigrationAuditCategory category, String sql) async {
      final rows = await database.rawQuery(sql);
      counts[category] = (rows.single['count'] as num).toInt();
    }

    await count(
      MigrationAuditCategory.userRows,
      'SELECT COUNT(*) AS count FROM users',
    );
    await count(
      MigrationAuditCategory.anonymousUserIds,
      "SELECT COUNT(*) AS count FROM users WHERE id IS NULL OR trim(id) = ''",
    );
    await count(MigrationAuditCategory.orphanExpenseUsers, '''
        SELECT COUNT(*) AS count
        FROM expenses e
        LEFT JOIN users u ON u.id = e.user_id
        WHERE u.id IS NULL
      ''');
    await count(MigrationAuditCategory.missingExpenseCategories, '''
        SELECT COUNT(*) AS count
        FROM expenses e
        LEFT JOIN categories c ON c.id = e.category_id
        WHERE c.id IS NULL
      ''');
    await count(MigrationAuditCategory.crossOwnerExpenseCategories, '''
        SELECT COUNT(*) AS count
        FROM expenses e
        JOIN categories c ON c.id = e.category_id
        WHERE c.user_id IS NOT NULL AND c.user_id != e.user_id
      ''');
    await count(
      MigrationAuditCategory.unknownExpenseTypes,
      "SELECT COUNT(*) AS count FROM expenses WHERE type NOT IN ('essential', 'discretionary')",
    );
    await count(
      MigrationAuditCategory.nonPositiveAmounts,
      'SELECT COUNT(*) AS count FROM expenses WHERE amount <= 0',
    );
    // SQLite represents NaN as NULL in some bindings. Infinity remains a REAL
    // value, so both checks are required for a portable host-side preflight.
    await count(MigrationAuditCategory.nonFiniteAmounts, '''
        SELECT COUNT(*) AS count
        FROM expenses
        WHERE amount IS NULL OR amount != amount
          OR abs(amount) > 1.7976931348623157e308
      ''');
    await count(MigrationAuditCategory.invalidOccurredOn, '''
        SELECT COUNT(*) AS count
        FROM expenses
        WHERE date IS NULL OR length(date) != 10
          OR date NOT GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
          OR date(date) IS NULL OR date(date) != date
      ''');
    await count(MigrationAuditCategory.invalidCreatedAt, '''
        SELECT COUNT(*) AS count
        FROM expenses
        WHERE created_at IS NULL OR datetime(created_at) IS NULL
          OR date(created_at) != substr(created_at, 1, 10)
      ''');
    await count(MigrationAuditCategory.invalidUpdatedAt, '''
        SELECT COUNT(*) AS count
        FROM expenses
        WHERE updated_at IS NULL OR datetime(updated_at) IS NULL
          OR date(updated_at) != substr(updated_at, 1, 10)
      ''');
    await count(MigrationAuditCategory.duplicateCategoryStableIds, '''
        SELECT COALESCE(SUM(duplicates), 0) AS count
        FROM (
          SELECT COUNT(*) - 1 AS duplicates
          FROM categories
          WHERE user_id IS NULL
          GROUP BY id
          HAVING COUNT(*) > 1
        )
      ''');
    final currencyRows = await database.rawQuery('''
      SELECT u.currency_code AS currency_code, COUNT(*) AS count
      FROM expenses e
      LEFT JOIN users u ON u.id = e.user_id
      WHERE typeof(e.amount) = 'real'
      GROUP BY u.currency_code
    ''');
    final realAmountCountsByCurrency = <String, int>{};
    for (final row in currencyRows) {
      final category = _currencyCategory(row['currency_code']);
      final count = (row['count'] as num).toInt();
      realAmountCountsByCurrency.update(
        category,
        (existing) => existing + count,
        ifAbsent: () => count,
      );
    }
    counts[MigrationAuditCategory.currencyRealAmounts] =
        realAmountCountsByCurrency.values.fold(0, (sum, count) => sum + count);

    return MigrationAuditReport(
      Map.unmodifiable(counts),
      Map.unmodifiable(realAmountCountsByCurrency),
    );
  }

  String _currencyCategory(Object? value) {
    if (value is! String || !RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
      return 'invalid-or-missing-currency';
    }
    return value;
  }
}
