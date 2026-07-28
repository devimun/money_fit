import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/features/monetization/application/ad_telemetry.dart';
import 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart';

export 'package:money_fit/features/monetization/data/google_mobile_ads_gateway.dart'
    show AdPlacement;

typedef AnchoredAdaptiveBannerSizeResolver =
    Future<AdSize?> Function(int width);

/// Anchored adaptive banner with a pre-reserved, placement-specific slot.
///
/// The empty slot stays fixed at the placement minimum. A valid adaptive
/// creative may grow that minimum when the SDK returns a taller size; rejecting
/// it would leave a permanent blank slot on larger devices or after rotation.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({
    super.key,
    required this.placement,
    @visibleForTesting this.adaptiveSizeResolver,
    @visibleForTesting this.retryDelay = const Duration(seconds: 30),
  });

  final AdPlacement placement;

  /// Test seam for exercising retry and resize behavior without a platform ad
  /// view. Production always uses the Google Mobile Ads adaptive-size API.
  @visibleForTesting
  final AnchoredAdaptiveBannerSizeResolver? adaptiveSizeResolver;

  @visibleForTesting
  final Duration retryDelay;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _retryTimer;
  String? _lastSuppression;
  int? _requestedWidth;
  int? _resolvingWidth;
  var _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    AdService.bannerAvailabilityRevision.addListener(
      _onBannerAvailabilityChanged,
    );
  }

  void _onBannerAvailabilityChanged() {
    _retryTimer?.cancel();
    final width = _requestedWidth;
    if (width != null) _startLoadIfIdle(width);
  }

  void _requestAdForWidth(int width) {
    if (width <= 0 || _requestedWidth == width) return;
    _requestedWidth = width;
    _loadGeneration++;
    _retryTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _requestedWidth != width) return;
      _bannerAd?.dispose();
      _bannerAd = null;
      if (_isLoaded) setState(() => _isLoaded = false);
      _startLoadIfIdle(width);
    });
  }

  /// The adaptive-size lookup is asynchronous. Keep one lookup in flight and
  /// let its completion start the newest width, rather than racing multiple
  /// banner loads when startup, consent, and orientation updates overlap.
  void _startLoadIfIdle(int width) {
    if (!mounted || _bannerAd != null || _resolvingWidth != null) return;
    unawaited(_loadAd(width));
  }

  Future<void> _loadAd(int width) async {
    if (!mounted ||
        _bannerAd != null ||
        _resolvingWidth != null ||
        _requestedWidth != width) {
      return;
    }
    if (!AdService.bannerEnabled) {
      _reportSuppression();
      _scheduleRetry();
      return;
    }

    _resolvingWidth = width;
    final generation = _loadGeneration;
    final startedAt = DateTime.now();
    AdSize? size;
    try {
      final resolver =
          widget.adaptiveSizeResolver ??
          AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize;
      size = await resolver(width);
    } catch (_) {
      if (mounted &&
          generation == _loadGeneration &&
          _requestedWidth == width) {
        _scheduleRetry();
      }
      return;
    } finally {
      _resolvingWidth = null;
      // A width/orientation change that arrived while the old adaptive query
      // was in flight must begin a fresh request as soon as the old one exits.
      final nextWidth = _requestedWidth;
      if (mounted &&
          _bannerAd == null &&
          nextWidth != null &&
          nextWidth != width) {
        _startLoadIfIdle(nextWidth);
      }
    }

    if (!mounted ||
        generation != _loadGeneration ||
        _requestedWidth != width ||
        size == null) {
      if (mounted &&
          generation == _loadGeneration &&
          _requestedWidth == width) {
        _scheduleRetry();
      }
      return;
    }
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
          if (!mounted ||
              generation != _loadGeneration ||
              !identical(ad, _bannerAd)) {
            ad.dispose();
            return;
          }
          unawaited(
            AdService.track(AdTelemetryEvent.loadCompleted, <String, Object>{
              'ad_format': 'banner',
              'placement': widget.placement.name,
              'result': 'success',
              'latency_ms': DateTime.now().difference(startedAt).inMilliseconds,
            }),
          );
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted ||
              generation != _loadGeneration ||
              !identical(ad, _bannerAd)) {
            return;
          }
          _bannerAd = null;
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
          setState(() => _isLoaded = false);
          _scheduleRetry();
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
    _retryTimer = Timer(widget.retryDelay, () {
      final width = _requestedWidth;
      if (width != null) _startLoadIfIdle(width);
    });
  }

  @override
  void dispose() {
    AdService.bannerAvailabilityRevision.removeListener(
      _onBannerAvailabilityChanged,
    );
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.truncate()
            : MediaQuery.sizeOf(context).width.truncate();
        _requestAdForWidth(width);

        return SizedBox(
          height: _isLoaded && banner != null
              ? bannerRenderHeight(widget.placement, banner.size)
              : bannerSlotHeight(widget.placement),
          width: double.infinity,
          child: _isLoaded && banner != null
              ? Center(
                  child: SizedBox(
                    width: banner.size.width.toDouble(),
                    height: banner.size.height.toDouble(),
                    child: AdWidget(ad: banner),
                  ),
                )
              : const SizedBox.expand(),
        );
      },
    );
  }
}

/// The empty slot height chosen for each route. Settings shares the same
/// padded width as statistics.
double bannerSlotHeight(AdPlacement placement) => switch (placement) {
  AdPlacement.home || AdPlacement.stats || AdPlacement.settings => 50,
  AdPlacement.calendar || AdPlacement.expenses => 60,
};

/// Keeps the approved fixed blank slot while never clipping or silently
/// rejecting a valid adaptive creative on a larger device.
double bannerRenderHeight(AdPlacement placement, AdSize creativeSize) {
  final slot = bannerSlotHeight(placement);
  return creativeSize.height > slot ? creativeSize.height.toDouble() : slot;
}
