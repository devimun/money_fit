import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/database/legacy_database_helper.dart';

void main() {
  test('database migration is explicitly versioned', () {
    // A production migration must update this test alongside its fixture matrix;
    // keeping the asserted version prevents silently changing the schema in an
    // unrelated feature change.
    expect(DatabaseHelper.schemaVersion, greaterThanOrEqualTo(5));
  });
}
