import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/migration_audit.dart';
import 'package:money_fit/app/database/legacy_database_helper.dart';
import '../../support/v5_database_fixture.dart';

void main() {
  const auditor = V5MigrationAuditor();

  test('database migration is explicitly versioned', () {
    expect(DatabaseHelper.schemaVersion, greaterThanOrEqualTo(5));
  });

  test('typical v5 fixture reports only counts and safe categories', () async {
    final database = await V5DatabaseFixture.open();
    addTearDown(database.close);
    await V5DatabaseFixture.insertTypicalRows(database);

    final report = await auditor.audit(database);

    expect(report[MigrationAuditCategory.userRows], 1);
    expect(report[MigrationAuditCategory.currencyRealAmounts], 1);
    expect(report.realAmountCountsByCurrency, {'USD': 1});
    expect(report.hasBlockingFindings, isFalse);
    expect(report.counts.keys, containsAll(MigrationAuditCategory.values));
  });

  test(
    'v5 audit identifies migration blockers without returning row values',
    () async {
      final database = await V5DatabaseFixture.open(
        duplicateGlobalCategoryIds: true,
      );
      addTearDown(database.close);
      await database.insert('expenses', {
        'id': 'bad-expense',
        'user_id': 'missing-owner',
        'name': 'Synthetic bad row',
        'amount': 0,
        'date': '2026-02-31',
        'category_id': 'missing-category',
        'type': 'unknown',
        'created_at': '2026-02-31T12:00:00.000Z',
        'updated_at': 'not-a-timestamp',
      });

      final report = await auditor.audit(database);

      expect(report[MigrationAuditCategory.orphanExpenseUsers], 1);
      expect(report[MigrationAuditCategory.missingExpenseCategories], 1);
      expect(report[MigrationAuditCategory.unknownExpenseTypes], 1);
      expect(report[MigrationAuditCategory.nonPositiveAmounts], 1);
      expect(report[MigrationAuditCategory.invalidOccurredOn], 1);
      expect(report[MigrationAuditCategory.invalidCreatedAt], 1);
      expect(report[MigrationAuditCategory.invalidUpdatedAt], 1);
      expect(report[MigrationAuditCategory.duplicateCategoryStableIds], 1);
      expect(report.hasBlockingFindings, isTrue);
    },
  );
}
