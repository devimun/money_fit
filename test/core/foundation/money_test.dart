import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/money.dart';

void main() {
  const krw = LedgerCurrency(code: 'KRW', decimalDigits: 0);
  const usd = LedgerCurrency(code: 'USD', decimalDigits: 2);

  test('parses decimal values into exact minor units', () {
    expect(Money.parse('12.34', usd).minorUnits, 1234);
    expect(Money.parse('1200', krw).minorUnits, 1200);
    expect(Money.parse('-0.50', usd).toDecimalString(), '-0.50');
  });

  test('uses an explicit rounding rule at the minor-unit boundary', () {
    expect(Money.parse('1.005', usd).toDecimalString(), '1.01');
    expect(
      Money.parse(
        '1.999',
        usd,
        rounding: MoneyRounding.floor,
      ).toDecimalString(),
      '1.99',
    );
    expect(Money.parse('12.5', krw).toDecimalString(), '13');
    expect(
      Money.parse(
        '-1.999',
        usd,
        rounding: MoneyRounding.floor,
      ).toDecimalString(),
      '-2.00',
    );
  });

  test('does not allow arithmetic across currencies', () {
    expect(
      () => Money.parse('1', usd) + Money.parse('1', krw),
      throwsArgumentError,
    );
  });
}
