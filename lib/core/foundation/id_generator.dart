import 'dart:collection';

import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String next();
}

class UuidGenerator implements IdGenerator {
  UuidGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  String next() => _uuid.v4();
}

class FakeIds implements IdGenerator {
  FakeIds(Iterable<String> values) : _values = Queue<String>.of(values);

  final Queue<String> _values;

  @override
  String next() {
    if (_values.isEmpty) {
      throw StateError('No fake IDs remain.');
    }
    return _values.removeFirst();
  }
}
