import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/services/ad_policy_service.dart';
import 'package:money_fit/core/services/ad_service.dart';

enum ScreenType { home, calendar, expenses, stats, settings }

/// Visible-only anchored adaptive banner with a fixed pre-load reservation.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key, required this.screenType});
  final ScreenType screenType;

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  String? _bannerId;
  Timer? _retryTimer;
  AdSuppressionReason? _lastSuppression;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAd());
  }

  Future<void> _loadAd() async {
    if (!mounted || _bannerAd != null) return;
    if (!AdService.bannerEnabled) {
      _reportSuppressed();
      _scheduleRetry();
      return;
    }
    final startedAt = DateTime.now();
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null) return;
    if (!AdService.bannerEnabled) {
      _reportSuppressed();
      _scheduleRetry();
      return;
    }
    _lastSuppression = null;
    _bannerId = AdService.bannerId(widget.screenType);
    _bannerAd = BannerAd(
      adUnitId: _bannerId!,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AdService.track(AnalyticsEvent.adLoadCompleted, {
            'ad_format': 'banner',
            'placement': widget.screenType.name,
            'result': 'success',
            'latency_ms': DateTime.now().difference(startedAt).inMilliseconds,
          });
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          AdService.track(AnalyticsEvent.adLoadCompleted, {
            'ad_format': 'banner',
            'placement': widget.screenType.name,
            'result': 'failure',
            'latency_ms': DateTime.now().difference(startedAt).inMilliseconds,
            'error_code': error.code,
            'error_domain': error.domain,
          });
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
            // Keep the fixed reservation, then retry only while this screen
            // remains visible. UMP/Remote Config are checked again in _loadAd.
            _scheduleRetry();
          }
        },
        onAdImpression: (ad) => AdService.track(AnalyticsEvent.adImpression, {
          'ad_format': 'banner',
          'placement': widget.screenType.name,
        }),
        onAdClicked: (ad) => AdService.track(AnalyticsEvent.adClicked, {
          'ad_format': 'banner',
          'placement': widget.screenType.name,
        }),
        onPaidEvent: (ad, value, precision, currencyCode) {
          AdService.track(AnalyticsEvent.adRevenueTracked, {
            'ad_format': 'banner',
            'placement': widget.screenType.name,
            'value_micros': value,
            'currency_code': currencyCode,
            'precision': precision.name,
          });
        },
      ),
    );
    AdService.track(AnalyticsEvent.adRequest, {
      'ad_format': 'banner',
      'placement': widget.screenType.name,
    });
    _bannerAd!.load();
  }

  void _reportSuppressed() {
    final reason = AdService.bannerSuppressionReason;
    if (reason == null || reason == _lastSuppression) return;
    _lastSuppression = reason;
    AdService.track(AnalyticsEvent.adOpportunity, {
      'opportunity': 'banner_visible_slot',
      'eligible': false,
      'suppress_reason': reason.value,
    });
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 30), _loadAd);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(
        height: 58,
      ); // Prevent controls shifting during load.
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ],
    );
  }
}
