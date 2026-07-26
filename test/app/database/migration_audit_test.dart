import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/migration_audit.dart';
import 'package:money_fit/app/database/legacy_database_helper.dart';
import '../../support/v5_database_fixture.dart';

void main() {
  const auditor = V5MigrationAuditor();

  test('database migration is explicitly versioned', () {
    expect(DatabaseHelper.schemaVersion, greaterThanOrEqualTo(5));
  });

  test(
    'typical persisted v5 fixture reports only counts and safe categories',
    () async {
      final database = await V5DatabaseFixture.openNamed('v5_typical');
      addTearDown(database.close);

      final report = await auditor.audit(database);

      expect(report[MigrationAuditCategory.userRows], 1);
      expect(report[MigrationAuditCategory.currencyRealAmounts], 1);
      expect(report.realAmountCountsByCurrency, {'USD': 1});
      expect(report.hasBlockingFindings, isFalse);
      expect(report.counts.keys, containsAll(MigrationAuditCategory.values));
    },
  );

  test(
    'orphaned persisted fixture identifies migration blockers without values',
    () async {
      final database = await V5DatabaseFixture.openNamed('v5_orphaned');
      addTearDown(database.close);

      final report = await auditor.audit(database);

      expect(report[MigrationAuditCategory.orphanExpenseUsers], 1);
      expect(report[MigrationAuditCategory.missingExpenseCategories], 1);
      expect(report[MigrationAuditCategory.duplicateCategoryStableIds], 1);
      expect(report.hasBlockingFindings, isTrue);
    },
  );

  test(
    'edge amount fixture exposes every unsafe amount and date shape',
    () async {
      final database = await V5DatabaseFixture.openNamed('v5_edge_amounts');
      addTearDown(database.close);

      final report = await auditor.audit(database);

      expect(report[MigrationAuditCategory.nonPositiveAmounts], 2);
      expect(report[MigrationAuditCategory.nonFiniteAmounts], 1);
      expect(report[MigrationAuditCategory.unknownExpenseTypes], 1);
      expect(report[MigrationAuditCategory.invalidOccurredOn], 1);
      expect(report[MigrationAuditCategory.invalidCreatedAt], 1);
      expect(report[MigrationAuditCategory.invalidUpdatedAt], 1);
      expect(report.hasBlockingFindings, isTrue);
    },
  );

  test('empty persisted v5 fixture has no migration blockers', () async {
    final database = await V5DatabaseFixture.openNamed('v5_empty');
    addTearDown(database.close);

    final report = await auditor.audit(database);

    expect(report.hasBlockingFindings, isFalse);
    expect(report[MigrationAuditCategory.userRows], 0);
  });
}
