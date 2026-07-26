import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/local_date.dart';

void main() {
  test('preserves calendar components without a timezone conversion', () {
    final date = LocalDate.fromDateTime(DateTime(2026, 2, 28, 23, 59));

    expect(date, const LocalDate(2026, 2, 28));
    expect(date.toString(), '2026-02-28');
  });

  test('parses only real canonical ISO calendar dates', () {
    expect(LocalDate.parse('2024-02-29'), const LocalDate(2024, 2, 29));
    expect(() => LocalDate.parse('2025-02-29'), throwsFormatException);
    expect(() => LocalDate.parse('2024-2-9'), throwsFormatException);
  });

  test('adds days across a month boundary', () {
    expect(
      const LocalDate(2026, 1, 31).addDays(1),
      const LocalDate(2026, 2, 1),
    );
  });
}
