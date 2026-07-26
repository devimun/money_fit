import 'package:flutter/widgets.dart';
import 'package:money_fit/core/foundation/money.dart';

/// Makes the persisted ledger currency available to formatting helpers without
/// coupling their callers to the UI language.
class LedgerCurrencyScope extends InheritedWidget {
  const LedgerCurrencyScope({
    super.key,
    required this.currency,
    required super.child,
  });

  final LedgerCurrency currency;

  static LedgerCurrency? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LedgerCurrencyScope>()
      ?.currency;

  @override
  bool updateShouldNotify(LedgerCurrencyScope oldWidget) =>
      currency != oldWidget.currency;
}
