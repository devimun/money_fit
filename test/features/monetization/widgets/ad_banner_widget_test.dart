import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/features/monetization/application/ad_telemetry.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';
import 'package:money_fit/features/monetization/widgets/ad_banner_widget.dart';

void main() {
  test('reserves the expected height for each banner placement', () {
    expect(bannerSlotHeight(AdPlacement.home), 50);
    expect(bannerSlotHeight(AdPlacement.calendar), 60);
    expect(bannerSlotHeight(AdPlacement.stats), 50);
    expect(bannerSlotHeight(AdPlacement.expenses), 60);
    expect(bannerSlotHeight(AdPlacement.settings), 50);
  });

  test('expands a fixed slot for a taller valid adaptive creative', () {
    expect(bannerRenderHeight(AdPlacement.home, AdSize.banner), 50);
    expect(bannerRenderHeight(AdPlacement.calendar, AdSize.banner), 60);
    expect(bannerRenderHeight(AdPlacement.home, AdSize.largeBanner), 100);
  });

  testWidgets('keeps its fixed slot and does not resolve ads while disabled', (
    tester,
  ) async {
    await _configureAds(canRequestAds: false);
    var resolverCalls = 0;

    await _pumpBanner(
      tester,
      resolver: (width) async {
        resolverCalls++;
        return AdSize.banner;
      },
    );
    await tester.pump();

    expect(resolverCalls, 0);
    expect(tester.getSize(find.byType(AdBannerWidget)).height, 50);
  });

  testWidgets('retries a failed adaptive-size lookup without losing its slot', (
    tester,
  ) async {
    await _configureAds(canRequestAds: true);
    var resolverCalls = 0;

    await _pumpBanner(
      tester,
      retryDelay: const Duration(milliseconds: 10),
      resolver: (width) async {
        resolverCalls++;
        throw StateError('adaptive size unavailable');
      },
    );
    await tester.pump();

    expect(resolverCalls, 1);
    expect(tester.getSize(find.byType(AdBannerWidget)).height, 50);

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump();

    expect(resolverCalls, 2);
  });

  testWidgets('starts immediately after an availability revision enables ads', (
    tester,
  ) async {
    await _configureAds(canRequestAds: false);
    var resolverCalls = 0;

    await _pumpBanner(
      tester,
      resolver: (width) async {
        resolverCalls++;
        return null;
      },
    );
    await tester.pump();

    expect(resolverCalls, 0);

    await _configureAds(canRequestAds: true);
    await tester.pump();

    expect(resolverCalls, 1);
  });

  testWidgets('retries immediately on availability revision without overlap', (
    tester,
  ) async {
    await _configureAds(canRequestAds: true);
    var resolverCalls = 0;
    final firstLookup = Completer<AdSize?>();

    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpBanner(
      tester,
      retryDelay: const Duration(days: 1),
      resolver: (width) {
        resolverCalls++;
        return resolverCalls == 1
            ? firstLookup.future
            : Future<AdSize?>.value(null);
      },
    );
    await tester.pump();

    expect(resolverCalls, 1);

    AdService.announceBannerAvailabilityChanged();
    AdService.announceBannerAvailabilityChanged();
    await tester.pump();

    expect(resolverCalls, 1);

    await tester.binding.setSurfaceSize(const Size(480, 800));
    await tester.pump();

    expect(resolverCalls, 1);

    firstLookup.complete(null);
    await tester.pump();
    await tester.pump();

    expect(resolverCalls, 2);
  });
}

Future<void> _configureAds({required bool canRequestAds}) async {
  AdService.configure(
    gateway: GoogleMobileAdsGateway(
      sdk: _FakeConsentSdk(requestAllowed: canRequestAds),
    ),
    policy: () => AdPolicy.defaults,
    telemetry: const NoopAdTelemetry(),
  );
  await AdService.initialize();
}

Future<void> _pumpBanner(
  WidgetTester tester, {
  required AnchoredAdaptiveBannerSizeResolver resolver,
  Duration retryDelay = const Duration(days: 1),
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AdBannerWidget(
          placement: AdPlacement.home,
          adaptiveSizeResolver: resolver,
          retryDelay: retryDelay,
        ),
      ),
    ),
  );
}

class _FakeConsentSdk implements MobileAdsConsentSdk {
  _FakeConsentSdk({required this.requestAllowed});

  final bool requestAllowed;

  @override
  Future<bool> canRequestAds() async => requestAllowed;

  @override
  Future<void> initializeMobileAds() async {}

  @override
  Future<bool> isPrivacyOptionsFormAvailable() async => false;

  @override
  Future<void> loadAndShowConsentFormIfRequired() async {}

  @override
  Future<void> requestConsentInfoUpdate() async {}

  @override
  Future<void> showPrivacyOptionsForm() async {}
}
