import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';

/// Clears engagement state whose policy must not outlive an explicit reset.
/// Review keys intentionally remain here (rather than a presentation class) so
/// the reset covers every decision and counter even when no dialog is built.
class EngagementResetter {
  const EngagementResetter(this._ref);

  static const _reviewKeys = <String>[
    'review_first_run_at',
    'review_opted_out',
    'review_last_prompt_at',
    'review_prompt_count',
    'review_snooze_until',
  ];

  final Ref _ref;

  Future<void> clear() async {
    final preferences = _ref.read(sharedPreferencesProvider);
    for (final key in _reviewKeys) {
      await preferences.remove(key);
    }
    InterstitialAdManager.instance.resetCounters();
  }
}

final engagementResetterProvider = Provider<EngagementResetter>(
  EngagementResetter.new,
);
