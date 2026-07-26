import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/local_date.dart';
import 'package:money_fit/core/foundation/year_month.dart';

void main() {
  test('handles leap-year boundaries and month arithmetic', () {
    final february = YearMonth.parse('2024-02');

    expect(february.daysInMonth, 29);
    expect(february.firstDay, const LocalDate(2024, 2, 1));
    expect(february.lastDay, const LocalDate(2024, 2, 29));
    expect(february.addMonths(11), const YearMonth(2025, 1));
  });

  test('rejects malformed and impossible month values', () {
    expect(() => YearMonth.parse('2024-00'), throwsFormatException);
    expect(() => YearMonth.parse('2024-13'), throwsFormatException);
    expect(() => YearMonth.parse('2024-2'), throwsFormatException);
  });
}
