import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';

void main() {
  test('NoopAnalyticsTracker completes without SDK initialization', () async {
    await expectLater(
      const NoopAnalyticsTracker().track('ledger_opened'),
      completes,
    );
  });

  test(
    'ThrowingAnalyticsTracker exposes an analytics failure to callers',
    () async {
      final tracker = ThrowingAnalyticsTracker(StateError('offline'));

      await expectLater(tracker.track('ledger_opened'), throwsStateError);
    },
  );
}
