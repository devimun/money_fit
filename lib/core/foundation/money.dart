/// Currency metadata required to interpret a [Money] amount.
class LedgerCurrency {
  const LedgerCurrency({required this.code, required this.decimalDigits})
    : assert(decimalDigits >= 0 && decimalDigits <= 9);

  final String code;
  final int decimalDigits;

  String get normalizedCode => code.toUpperCase();

  @override
  bool operator ==(Object other) =>
      other is LedgerCurrency &&
      normalizedCode == other.normalizedCode &&
      decimalDigits == other.decimalDigits;

  @override
  int get hashCode => Object.hash(normalizedCode, decimalDigits);
}

enum MoneyRounding { floor, halfUp }

/// A currency amount represented as an exact integer number of minor units.
class Money implements Comparable<Money> {
  const Money({required this.minorUnits, required this.currency});

  factory Money.parse(
    String value,
    LedgerCurrency currency, {
    MoneyRounding rounding = MoneyRounding.halfUp,
  }) {
    final match = RegExp(r'^([+-]?)(\d+)(?:\.(\d+))?$').firstMatch(value);
    if (match == null) {
      throw FormatException('Expected a decimal money amount.', value);
    }

    final negative = match.group(1) == '-';
    final whole = int.parse(match.group(2)!);
    final fraction = match.group(3) ?? '';
    final scale = _powerOfTen(currency.decimalDigits);
    var minorUnits = whole * scale;

    final keptFraction = fraction
        .padRight(currency.decimalDigits, '0')
        .substring(0, currency.decimalDigits);
    if (keptFraction.isNotEmpty) {
      minorUnits += int.parse(keptFraction);
    }

    final discardedFraction = fraction.length > currency.decimalDigits
        ? fraction.substring(currency.decimalDigits)
        : '';
    if (_shouldRoundUp(discardedFraction, rounding, negative)) {
      minorUnits += 1;
    }

    return Money(
      minorUnits: negative ? -minorUnits : minorUnits,
      currency: currency,
    );
  }

  final int minorUnits;
  final LedgerCurrency currency;

  Money divide(int divisor, {MoneyRounding rounding = MoneyRounding.halfUp}) {
    if (divisor <= 0) {
      throw ArgumentError.value(divisor, 'divisor', 'Must be positive.');
    }
    final quotient = minorUnits ~/ divisor;
    final remainder = minorUnits.abs() % divisor;
    final shouldRound = switch (rounding) {
      MoneyRounding.floor => minorUnits.isNegative && remainder > 0,
      MoneyRounding.halfUp => remainder * 2 >= divisor,
    };
    final adjustment = shouldRound ? (minorUnits.isNegative ? -1 : 1) : 0;
    return Money(minorUnits: quotient + adjustment, currency: currency);
  }

  String toDecimalString() {
    final sign = minorUnits.isNegative ? '-' : '';
    final absolute = minorUnits.abs();
    final scale = _powerOfTen(currency.decimalDigits);
    final whole = absolute ~/ scale;
    if (currency.decimalDigits == 0) return '$sign$whole';
    final fraction = (absolute % scale).toString().padLeft(
      currency.decimalDigits,
      '0',
    );
    return '$sign$whole.$fraction';
  }

  @override
  int compareTo(Money other) {
    _requireSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(minorUnits: minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(minorUnits: minorUnits - other.minorUnits, currency: currency);
  }

  void _requireSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError('Money values must use the same currency.');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      minorUnits == other.minorUnits &&
      currency == other.currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);
}

bool _shouldRoundUp(
  String discardedFraction,
  MoneyRounding rounding,
  bool negative,
) {
  if (discardedFraction.isEmpty || int.parse(discardedFraction) == 0) {
    return false;
  }
  return switch (rounding) {
    MoneyRounding.floor => negative,
    MoneyRounding.halfUp =>
      discardedFraction.codeUnitAt(0) >= '5'.codeUnitAt(0),
  };
}

int _powerOfTen(int exponent) {
  var result = 1;
  for (var index = 0; index < exponent; index++) {
    result *= 10;
  }
  return result;
}
