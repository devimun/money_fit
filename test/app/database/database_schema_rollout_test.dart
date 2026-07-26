import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/database_schema_rollout.dart';
import 'package:money_fit/app/database/legacy_database_helper.dart';

void main() {
  test('runtime stays on v5 until v6 repositories are composed', () {
    expect(DatabaseSchemaRollout.runtimeVersion, 5);
    expect(DatabaseHelper.schemaVersion, DatabaseSchemaRollout.runtimeVersion);
    expect(DatabaseSchemaRollout.v6RepositoriesAreActive, isFalse);
  });

  test(
    'v5 databases cannot enter the v6 migration through a version-only bump',
    () {
      expect(
        DatabaseSchemaRollout.shouldApplyV6Migration(
          oldVersion: 5,
          newVersion: DatabaseSchemaRollout.v6Version,
        ),
        isFalse,
      );
    },
  );
}
