import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/features/ledger/application/ledger_currency_provider.dart';
import 'package:money_fit/features/ledger/domain/ledger_settings_repository.dart';
import 'package:money_fit/features/session/application/session_context.dart';

void main() {
  test(
    'loads the active owner currency from ledger settings, not preferences',
    () async {
      final repository = _SettingsRepository(
        const LedgerCurrency(code: 'KRW', decimalDigits: 0),
      );
      final container = ProviderContainer(
        overrides: [
          currentOwnerIdProvider.overrideWith((ref) async => 'owner'),
          ledgerSettingsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(ledgerCurrencyProvider).code, 'USD');
      await container
          .read(ledgerCurrencyCommandsProvider)
          .loadForCurrentOwner();

      expect(container.read(ledgerCurrencyProvider).code, 'KRW');
      expect(container.read(currencyDecimalDigitsProvider), 0);
      expect(repository.readOwners, ['owner']);
    },
  );

  test(
    'only changes the cached currency after the v6 command succeeds',
    () async {
      final repository = _SettingsRepository(
        const LedgerCurrency(code: 'USD', decimalDigits: 2),
      );
      final container = ProviderContainer(
        overrides: [
          currentOwnerIdProvider.overrideWith((ref) async => 'owner'),
          ledgerSettingsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(ledgerCurrencyCommandsProvider)
          .setForCurrentOwner('krw');

      expect(repository.writes.single.currency.code, 'KRW');
      expect(container.read(ledgerCurrencyProvider).code, 'KRW');
    },
  );
}

class _SettingsRepository implements LedgerSettingsRepository {
  _SettingsRepository(this.currency);

  LedgerCurrency currency;
  final List<String> readOwners = [];
  final List<({String ownerId, LedgerCurrency currency})> writes = [];

  @override
  Future<LedgerCurrency> readCurrency(String ownerId) async {
    readOwners.add(ownerId);
    return currency;
  }

  @override
  Future<void> setCurrency(String ownerId, LedgerCurrency value) async {
    writes.add((ownerId: ownerId, currency: value));
    currency = value;
  }
}
