import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';

/// AdMob 광고 서비스를 관리하는 클래스
class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._internal();

  AdService._internal();

  /// AdMob SDK 초기화
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static const Map<ScreenType, String> _androidBannerIds = {
    ScreenType.home: 'ca-app-pub-4769455621618933/8690634882',
    ScreenType.calendar: 'ca-app-pub-4769455621618933/9888166487',
    ScreenType.settings: 'ca-app-pub-4769455621618933/1690445406',
    ScreenType.expenses: 'ca-app-pub-4769455621618933/3003527071',
  };

  static const Map<ScreenType, String> _iosBannerIds = {
    ScreenType.home: 'ca-app-pub-4769455621618933/3825654152',
    ScreenType.calendar: 'ca-app-pub-4769455621618933/1870075669',
    ScreenType.settings: 'ca-app-pub-4769455621618933/9556993992',
    ScreenType.expenses: 'ca-app-pub-4769455621618933/2277269778',
  };
  static const String _testBannerAdId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosReleaseInterstitialAdId =
      'ca-app-pub-4769455621618933/7377553211';
  static const String _aosReleaseInterstitialAdId =
      'ca-app-pub-4769455621618933/8064282065';

  /// 개발/릴리스 모드에 따른 광고 ID 반환
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// 배너 광고 ID
  static String bannerId(ScreenType screenType) {
    if (isDebugMode) {
      return _testBannerAdId;
    } else {
      if (Platform.isAndroid) {
        return _androidBannerIds[screenType] ?? _testBannerAdId;
      } else if (Platform.isIOS) {
        return _iosBannerIds[screenType] ?? _testBannerAdId;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// 전면 광고 ID
  static String get interstitialAdId {
    if (Platform.isAndroid) {
      return isDebugMode ? _testInterstitialAdId : _aosReleaseInterstitialAdId;
    } else if (Platform.isIOS) {
      return isDebugMode ? _testInterstitialAdId : _iosReleaseInterstitialAdId;
    }
    throw UnsupportedError('Unsupported platform');
  }
}

/// 전면 광고 관리 클래스
class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  static InterstitialAdManager get instance =>
      _instance ??= InterstitialAdManager._internal();

  InterstitialAdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  int _showCount = 0;

  /// 전면 광고 로드
  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdService.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;

          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {},
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _isAdReady = false;
                  loadAd(); // 다음 광고 미리 로드
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _isAdReady = false;
                  loadAd(); // 재시도
                },
              );
        },
        onAdFailedToLoad: (error) {
          _isAdReady = false;
        },
      ),
    );
  }

  /// 전면 광고 표시 (조건부)
  void showAdIfReady() {
    _showCount++;

    // 3-4회 중 1회만 광고 표시
    if (_showCount % 4 == 0 && _isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  /// 리소스 정리
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
  }
}
