import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/foundation/clock.dart';
import 'package:money_fit/core/foundation/id_generator.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/providers/foundation_providers.dart';

void main() {
  test('foundation providers can be overridden without SDK access', () async {
    final clock = FakeClock(DateTime(2026, 7, 27));
    final ids = FakeIds(['expense-1']);
    const analytics = NoopAnalyticsTracker();
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(clock),
        idGeneratorProvider.overrideWithValue(ids),
        analyticsTrackerProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(clockProvider), same(clock));
    expect(container.read(idGeneratorProvider).next(), 'expense-1');
    await expectLater(
      container.read(analyticsTrackerProvider).track('test'),
      completes,
    );
  });
}
