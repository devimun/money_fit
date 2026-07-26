import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/foundation/money.dart';
import 'package:money_fit/features/ledger/domain/ledger_settings_repository.dart';
import 'package:money_fit/features/session/application/session_context.dart';

/// The loaded per-owner ledger currency. USD is only a rendering fallback
/// until bootstrap reads the durable v6 `ledger_settings` row.
final ledgerCurrencyProvider = StateProvider<LedgerCurrency>((ref) {
  return ledgerCurrencyForCode('USD');
});

final currencySymbolProvider = Provider<String>((ref) {
  return ledgerCurrencySymbol(ref.watch(ledgerCurrencyProvider).code);
});

final currencyDecimalDigitsProvider = Provider<int>((ref) {
  return ref.watch(ledgerCurrencyProvider).decimalDigits;
});

final ledgerSettingsRepositoryProvider = Provider<LedgerSettingsRepository>(
  (ref) => ref.watch(ledgerSettingsRepositoryCompositionProvider),
);

/// Explicit application commands for loading and safely changing the local
/// owner's ledger interpretation settings.
class LedgerCurrencyCommands {
  const LedgerCurrencyCommands(this._ref);

  final Ref _ref;

  Future<void> loadForCurrentOwner() async {
    final ownerId = await _ref.read(currentOwnerIdProvider.future);
    final currency = await _ref
        .read(ledgerSettingsRepositoryProvider)
        .readCurrency(ownerId);
    _ref.read(ledgerCurrencyProvider.notifier).state = currency;
  }

  Future<void> setForCurrentOwner(String currencyCode) async {
    final currency = ledgerCurrencyForCode(currencyCode);
    final ownerId = await _ref.read(currentOwnerIdProvider.future);
    await _ref
        .read(ledgerSettingsRepositoryProvider)
        .setCurrency(ownerId, currency);
    _ref.read(ledgerCurrencyProvider.notifier).state = currency;
  }
}

final ledgerCurrencyCommandsProvider = Provider<LedgerCurrencyCommands>(
  LedgerCurrencyCommands.new,
);
