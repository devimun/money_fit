import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/foundation/clock.dart';
import 'package:money_fit/core/foundation/id_generator.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';

/// Temporary composition seams. App composition takes ownership in PR 2.2.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

final idGeneratorProvider = Provider<IdGenerator>((ref) => UuidGenerator());

/// Remote SDK initialization is optional, so the safe baseline is no-op.
final analyticsTrackerProvider = Provider<AnalyticsTracker>(
  (ref) => const NoopAnalyticsTracker(),
);
