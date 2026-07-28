import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/monetization/application/ad_policy_service.dart';

/// Bridges the neutral app-wide prompt mutex to monetization's safe-point API.
/// The interstitial keeps this lease until the Mobile Ads dismissal callback.
class PromptCoordinatorInterstitialGate implements FullscreenExperienceGate {
  const PromptCoordinatorInterstitialGate(this._coordinator);

  final PromptCoordinator _coordinator;

  @override
  Future<FullscreenExperienceLease?> tryAcquireInterstitial() async {
    final lease = _coordinator.tryAcquire(PromptSurface.interstitialAd);
    return lease == null ? null : _PromptCoordinatorLeaseAdapter(lease);
  }
}

class _PromptCoordinatorLeaseAdapter implements FullscreenExperienceLease {
  const _PromptCoordinatorLeaseAdapter(this._lease);

  final PromptLease _lease;

  @override
  void release() => _lease.release();
}
