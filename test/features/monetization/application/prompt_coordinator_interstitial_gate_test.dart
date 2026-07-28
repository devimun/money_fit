import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/monetization/application/prompt_coordinator_interstitial_gate.dart';

void main() {
  test('holds the shared full-screen lease until the ad releases it', () async {
    final coordinator = PromptCoordinator();
    final gate = PromptCoordinatorInterstitialGate(coordinator);

    final lease = await gate.tryAcquireInterstitial();

    expect(lease, isNotNull);
    expect(coordinator.activeSurface, PromptSurface.interstitialAd);
    expect(await gate.tryAcquireInterstitial(), isNull);

    lease!.release();
    expect(coordinator.activeSurface, isNull);
    expect(await gate.tryAcquireInterstitial(), isNotNull);
  });
}
