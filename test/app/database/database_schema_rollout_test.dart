import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/database_schema_rollout.dart';
import 'package:money_fit/app/database/legacy_database_helper.dart';

void main() {
  test('runtime opens v6 together with the v6 repository composition', () {
    expect(DatabaseSchemaRollout.runtimeVersion, 6);
    expect(DatabaseHelper.schemaVersion, DatabaseSchemaRollout.runtimeVersion);
    expect(DatabaseSchemaRollout.v6RepositoriesAreActive, isTrue);
  });

  test('v5 databases enter the v6 migration only with the v6 composition', () {
    expect(
      DatabaseSchemaRollout.shouldApplyV6Migration(
        oldVersion: 5,
        newVersion: DatabaseSchemaRollout.v6Version,
      ),
      isTrue,
    );
  });
}
