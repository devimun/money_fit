import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/shell/app_shell.dart';

void main() {
  test('only a different primary destination is a tab transition', () {
    expect(
      isPrimaryDestinationChange(currentIndex: 2, destinationIndex: 2),
      isFalse,
    );
    expect(
      isPrimaryDestinationChange(currentIndex: 2, destinationIndex: 3),
      isTrue,
    );
  });
}
