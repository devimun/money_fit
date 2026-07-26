import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/clock.dart';
import 'package:money_fit/core/foundation/local_date.dart';

void main() {
  test('FakeClock makes time and today deterministic', () {
    final clock = FakeClock(DateTime(2026, 7, 27, 23, 30));

    expect(clock.today(), const LocalDate(2026, 7, 27));
    clock.advance(const Duration(minutes: 45));
    expect(clock.today(), const LocalDate(2026, 7, 28));
  });
}
