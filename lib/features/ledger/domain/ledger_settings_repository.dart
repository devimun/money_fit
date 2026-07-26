import 'package:money_fit/core/foundation/money.dart';

/// Owns the immutable interpretation settings for one local ledger.
///
/// Unlike presentation preferences, a ledger setting changes the scale used to
/// read persisted integer amounts. Implementations must therefore reject a
/// currency change after financial records have been written.
abstract interface class LedgerSettingsRepository {
  Future<LedgerCurrency> readCurrency(String ownerId);

  Future<void> setCurrency(String ownerId, LedgerCurrency currency);
}
