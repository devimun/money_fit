import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';

void main() {
  test(
    'does not initialize the Mobile Ads SDK before UMP can request ads',
    () async {
      final sdk = _FakeConsentSdk(canRequest: false);
      final gateway = GoogleMobileAdsGateway(sdk: sdk);

      expect(await gateway.initialize(), isFalse);
      expect(sdk.calls, <String>[
        'consent_update',
        'consent_form',
        'can_request',
      ]);
      expect(sdk.mobileAdsInitialized, isFalse);
      expect(gateway.canRequestAds, isFalse);
    },
  );

  test(
    'initializes only after UMP completes and grants request permission',
    () async {
      final sdk = _FakeConsentSdk(canRequest: true);
      final gateway = GoogleMobileAdsGateway(sdk: sdk);

      expect(await gateway.initialize(), isTrue);
      expect(sdk.calls, <String>[
        'consent_update',
        'consent_form',
        'can_request',
        'mobile_ads_initialize',
      ]);
      expect(sdk.mobileAdsInitialized, isTrue);
    },
  );

  test('a UMP failure fails closed and never initializes ads', () async {
    final sdk = _FakeConsentSdk(canRequest: true, failUpdate: true);
    final gateway = GoogleMobileAdsGateway(sdk: sdk);

    expect(await gateway.initialize(), isFalse);
    expect(sdk.mobileAdsInitialized, isFalse);
  });

  test('announces when banner availability changes', () {
    final revisions = <int>[];
    void recordRevision() {
      revisions.add(AdService.bannerAvailabilityRevision.value);
    }

    final initialRevision = AdService.bannerAvailabilityRevision.value;
    AdService.bannerAvailabilityRevision.addListener(recordRevision);
    addTearDown(
      () => AdService.bannerAvailabilityRevision.removeListener(recordRevision),
    );

    AdService.announceBannerAvailabilityChanged();

    expect(revisions, [initialRevision + 1]);
  });
}

class _FakeConsentSdk implements MobileAdsConsentSdk {
  _FakeConsentSdk({required this.canRequest, this.failUpdate = false});

  final bool canRequest;
  final bool failUpdate;
  final calls = <String>[];
  bool mobileAdsInitialized = false;

  @override
  Future<bool> canRequestAds() async {
    calls.add('can_request');
    return canRequest;
  }

  @override
  Future<void> initializeMobileAds() async {
    calls.add('mobile_ads_initialize');
    mobileAdsInitialized = true;
  }

  @override
  Future<bool> isPrivacyOptionsFormAvailable() async => false;

  @override
  Future<void> loadAndShowConsentFormIfRequired() async {
    calls.add('consent_form');
  }

  @override
  Future<void> requestConsentInfoUpdate() async {
    calls.add('consent_update');
    if (failUpdate) throw StateError('UMP unavailable');
  }

  @override
  Future<void> showPrivacyOptionsForm() async {}
}
