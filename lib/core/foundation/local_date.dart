/// A calendar date without a time or timezone.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day)
    : assert(year >= 1),
      assert(month >= 1 && month <= 12),
      assert(day >= 1 && day <= 31);

  factory LocalDate.fromDateTime(DateTime value) {
    return LocalDate(value.year, value.month, value.day);
  }

  factory LocalDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Expected an ISO local date (YYYY-MM-DD).', value);
    }

    final date = LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    if (date.toDateTime().year != date.year ||
        date.toDateTime().month != date.month ||
        date.toDateTime().day != date.day) {
      throw FormatException('Invalid calendar date.', value);
    }
    return date;
  }

  final int year;
  final int month;
  final int day;

  DateTime toDateTime() => DateTime(year, month, day);

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(toDateTime().add(Duration(days: days)));

  @override
  int compareTo(LocalDate other) {
    final yearComparison = year.compareTo(other.year);
    if (yearComparison != 0) return yearComparison;
    final monthComparison = month.compareTo(other.month);
    if (monthComparison != 0) return monthComparison;
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
