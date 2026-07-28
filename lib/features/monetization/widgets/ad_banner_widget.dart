import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/features/monetization/application/ad_telemetry.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';

export 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart'
    show AdPlacement;

/// Visible-only anchored adaptive banner. A slot is added only for a loaded
/// creative, using the size returned by the adaptive-ad request.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key, required this.placement});

  final AdPlacement placement;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  static const _retryDelay = Duration(seconds: 30);

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _retryTimer;
  String? _lastSuppression;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  Future<void> _loadAd() async {
    if (!mounted || _bannerAd != null) return;
    if (!AdService.bannerEnabled) {
      _reportSuppression();
      _scheduleRetry();
      return;
    }

    final startedAt = DateTime.now();
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null) return;
    // Consent/policy may change while adaptive size is resolving.
    if (!AdService.bannerEnabled) {
      _reportSuppression();
      _scheduleRetry();
      return;
    }

    _lastSuppression = null;
    final banner = BannerAd(
      adUnitId: AdService.bannerId(widget.placement),
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          unawaited(
            AdService.track(AdTelemetryEvent.loadCompleted, <String, Object>{
              'ad_format': 'banner',
              'placement': widget.placement.name,
              'result': 'success',
              'latency_ms': DateTime.now().difference(startedAt).inMilliseconds,
            }),
          );
          if (!mounted || !identical(ad, _bannerAd)) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (identical(ad, _bannerAd)) _bannerAd = null;
          unawaited(
            AdService.track(AdTelemetryEvent.loadCompleted, <String, Object>{
              'ad_format': 'banner',
              'placement': widget.placement.name,
              'result': 'failure',
              'latency_ms': DateTime.now().difference(startedAt).inMilliseconds,
              'error_code': error.code,
              'error_domain': error.domain,
            }),
          );
          if (mounted) {
            setState(() => _isLoaded = false);
            _scheduleRetry();
          }
        },
        onAdImpression: (_) => unawaited(
          AdService.track(AdTelemetryEvent.impression, <String, Object>{
            'ad_format': 'banner',
            'placement': widget.placement.name,
          }),
        ),
        onAdClicked: (_) => unawaited(
          AdService.track(AdTelemetryEvent.clicked, <String, Object>{
            'ad_format': 'banner',
            'placement': widget.placement.name,
          }),
        ),
        onPaidEvent: (_, value, precision, currencyCode) => unawaited(
          AdService.track(AdTelemetryEvent.revenueTracked, <String, Object>{
            'ad_format': 'banner',
            'placement': widget.placement.name,
            'value_micros': value,
            'currency_code': currencyCode,
            'precision': precision.name,
          }),
        ),
      ),
    );
    _bannerAd = banner;
    unawaited(
      AdService.track(AdTelemetryEvent.request, <String, Object>{
        'ad_format': 'banner',
        'placement': widget.placement.name,
      }),
    );
    banner.load();
  }

  void _reportSuppression() {
    final reason = AdService.bannerSuppressionReason;
    if (reason == null || reason.value == _lastSuppression) return;
    _lastSuppression = reason.value;
    unawaited(
      AdService.track(AdTelemetryEvent.opportunity, <String, Object>{
        'opportunity': 'banner_visible_slot',
        'eligible': false,
        'suppress_reason': reason.value,
      }),
    );
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, _loadAd);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;
    if (!_isLoaded || banner == null) {
      // No creative is visible yet, so do not reserve a fixed slot that could
      // be shorter than an adaptive creative on a compact device.
      return const SizedBox.shrink();
    }
    final height = adaptiveBannerSlotHeight(banner.size);
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ],
      ),
    );
  }
}

/// Anchored adaptive banners report their actual creative dimensions. Reserve
/// exactly that height (plus the deliberate top gap) so the creative cannot
/// be clipped when Google returns a size taller than the legacy 50px banner.
double adaptiveBannerSlotHeight(AdSize size) => size.height.toDouble() + 8;
