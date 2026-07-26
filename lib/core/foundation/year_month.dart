import 'local_date.dart';

/// A calendar month used for ledger query identity.
class YearMonth implements Comparable<YearMonth> {
  const YearMonth(this.year, this.month)
    : assert(year >= 1),
      assert(month >= 1 && month <= 12);

  factory YearMonth.fromDateTime(DateTime value) =>
      YearMonth(value.year, value.month);

  factory YearMonth.fromLocalDate(LocalDate value) =>
      YearMonth(value.year, value.month);

  factory YearMonth.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Expected an ISO year-month (YYYY-MM).', value);
    }
    final month = int.parse(match.group(2)!);
    if (month < 1 || month > 12) {
      throw FormatException('Month must be between 01 and 12.', value);
    }
    return YearMonth(int.parse(match.group(1)!), month);
  }

  final int year;
  final int month;

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  LocalDate get firstDay => LocalDate(year, month, 1);

  LocalDate get lastDay => LocalDate(year, month, daysInMonth);

  YearMonth addMonths(int months) {
    final totalMonths = year * 12 + month - 1 + months;
    return YearMonth(totalMonths ~/ 12, totalMonths % 12 + 1);
  }

  bool contains(LocalDate date) => date.year == year && date.month == month;

  @override
  int compareTo(YearMonth other) {
    final yearComparison = year.compareTo(other.year);
    return yearComparison != 0 ? yearComparison : month.compareTo(other.month);
  }

  @override
  bool operator ==(Object other) =>
      other is YearMonth && year == other.year && month == other.month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}
