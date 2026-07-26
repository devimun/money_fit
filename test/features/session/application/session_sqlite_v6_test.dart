import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/app/database/migrations/sqlite_v6_migration.dart';
import 'package:money_fit/core/foundation/clock.dart';
import 'package:money_fit/core/foundation/id_generator.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/session/application/session_context.dart';
import 'package:money_fit/features/session/data/sqlite_v6_local_owner_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../support/expense_sqlite_fixture.dart';
import '../../../support/legacy_database_fixture.dart';

void main() {
  test('adopts the sole v5 owner from the migrated SQLite database', () async {
    final database = await LegacyDatabaseFixture.openUpgradedToV5(
      sourceVersion: 5,
    );
    addTearDown(database.close);
    await SqliteV6Migration.migrate(database);
    await database.setVersion(SqliteV6Migration.version);
    final preferences = await _preferences();
    final container = _container(
      preferences: preferences,
      database: database,
      ids: const ['unused'],
    );
    addTearDown(container.dispose);

    final state = await container.read(sessionProvider.future);

    expect((state as SessionReady).context.ownerId, 'history-owner');
    expect(preferences.getString('session.local_owner_id'), 'history-owner');
    expect(preferences.getBool('session.local_owner_migrated_v1'), isTrue);
    expect(
      await database.query(
        'local_users',
        where: 'id = ?',
        whereArgs: ['history-owner'],
      ),
      hasLength(1),
    );
  });

  test('creates a usable offline local owner in fresh v6 SQLite', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await database.execute('PRAGMA foreign_keys = ON');
    await SqliteV6Migration.createSchema(database);
    await database.setVersion(SqliteV6Migration.version);
    final preferences = await _preferences();
    final container = _container(
      preferences: preferences,
      database: database,
      ids: const ['offline-owner'],
    );
    addTearDown(container.dispose);

    final state = await container.read(sessionProvider.future);

    expect((state as SessionReady).context.ownerId, 'offline-owner');
    expect(state.context.remoteUserId, isNull);
    expect(preferences.getString('session.local_owner_id'), 'offline-owner');
    expect(
      await database.query(
        'ledger_settings',
        where: 'owner_id = ?',
        whereArgs: ['offline-owner'],
      ),
      hasLength(1),
    );
    expect(
      await database.query(
        'categories',
        where: 'owner_id = ?',
        whereArgs: ['offline-owner'],
      ),
      isNotEmpty,
    );
  });
}

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

ProviderContainer _container({
  required SharedPreferences preferences,
  required Database database,
  required List<String> ids,
}) {
  final appDatabase = TestAppDatabase(database);
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      localOwnerRepositoryProvider.overrideWithValue(
        SqliteV6LocalOwnerRepository(appDatabase),
      ),
      clockProvider.overrideWithValue(FakeClock(DateTime.utc(2026, 7, 26))),
      idGeneratorProvider.overrideWithValue(FakeIds(ids)),
    ],
  );
}
