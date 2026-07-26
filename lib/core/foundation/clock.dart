import 'local_date.dart';

abstract class Clock {
  const Clock();

  DateTime now();

  LocalDate today() => LocalDate.fromDateTime(now());
}

class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

class FakeClock extends Clock {
  FakeClock(DateTime initial) : _now = initial;

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime value) => _now = value;

  void advance(Duration duration) => _now = _now.add(duration);
}
