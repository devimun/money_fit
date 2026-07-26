/// Converts persisted integer minor units without letting floating point values
/// leak into SQLite rows.
abstract final class MoneyMinorUnits {
  static int fractionDigits(String currencyCode) =>
      switch (currencyCode.toUpperCase()) {
        'BHD' || 'IQD' || 'JOD' || 'KWD' || 'LYD' || 'OMR' || 'TND' => 3,
        'CLP' || 'IDR' || 'JPY' || 'KRW' || 'VND' => 0,
        _ => 2,
      };

  static int toMinor(double amount, String currencyCode) {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'must be finite and positive',
      );
    }
    final scale = _powerOfTen(fractionDigits(currencyCode));
    final minor = (amount * scale).round();
    if (minor <= 0 || minor > 9223372036854775807) {
      throw ArgumentError.value(amount, 'amount', 'is outside SQLite range');
    }
    return minor;
  }

  static double fromMinor(int amountMinor, String currencyCode) {
    if (amountMinor <= 0) {
      throw ArgumentError.value(amountMinor, 'amountMinor', 'must be positive');
    }
    return amountMinor / _powerOfTen(fractionDigits(currencyCode));
  }

  static int _powerOfTen(int exponent) => switch (exponent) {
    0 => 1,
    2 => 100,
    3 => 1000,
    _ => throw ArgumentError.value(exponent),
  };
}
