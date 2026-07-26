import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/id_generator.dart';

void main() {
  test('FakeIds returns supplied values in order and fails when exhausted', () {
    final ids = FakeIds(['first', 'second']);

    expect(ids.next(), 'first');
    expect(ids.next(), 'second');
    expect(ids.next, throwsStateError);
  });
}
