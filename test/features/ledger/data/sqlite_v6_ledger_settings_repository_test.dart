import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/features/ledger/data/sqlite_v6_ledger_settings_repository.dart';
import 'package:money_fit/features/session/data/sqlite_v6_local_owner_repository.dart';
import 'package:money_fit/features/session/domain/local_owner_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../support/v6_database_fixture.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'reads and changes the per-owner v6 ledger currency before records',
    () async {
      final fixture = await V6DatabaseFixture.open();
      addTearDown(fixture.database.close);
      await SqliteV6LocalOwnerRepository(
        fixture,
      ).create(LocalOwner(id: 'owner', createdAt: DateTime.utc(2026)));
      final settings = SqliteV6LedgerSettingsRepository(fixture);

      expect((await settings.readCurrency('owner')).code, 'USD');
      await settings.setCurrency(
        'owner',
        const LedgerCurrency(code: 'KRW', decimalDigits: 0),
      );

      expect((await settings.readCurrency('owner')).code, 'KRW');
    },
  );

  test(
    'does not reinterpret an owner ledger after an expense exists',
    () async {
      final fixture = await V6DatabaseFixture.open();
      addTearDown(fixture.database.close);
      await SqliteV6LocalOwnerRepository(
        fixture,
      ).create(LocalOwner(id: 'owner', createdAt: DateTime.utc(2026)));
      final settings = SqliteV6LedgerSettingsRepository(fixture);
      final category = (await fixture.database.query(
        'categories',
        where: 'owner_id = ?',
        whereArgs: ['owner'],
      )).first;
      await fixture.database.insert('expenses', {
        'id': 'expense',
        'owner_id': 'owner',
        'title': 'Lunch',
        'amount_minor': 1250,
        'occurred_on': '2026-07-26',
        'category_id': category['id']! as String,
        'created_at': '2026-07-26T00:00:00.000Z',
        'updated_at': '2026-07-26T00:00:00.000Z',
      });

      await expectLater(
        settings.setCurrency(
          'owner',
          const LedgerCurrency(code: 'KRW', decimalDigits: 0),
        ),
        throwsStateError,
      );
      expect((await settings.readCurrency('owner')).code, 'USD');
    },
  );
}
