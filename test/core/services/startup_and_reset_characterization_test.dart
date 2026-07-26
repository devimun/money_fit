import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/bootstrap/app_initializer.dart';

void main() {
  test(
    'current_bug_R13_remote_config_failure_is_ignored_but_startup_continues_remove_in_PR_6_1',
    () async {
      final calls = <String>[];

      await runAppInitializer(
        configureRemoteConfig: _action(calls, 'remote-config', error: 'remote'),
        initializeMobileAds: _action(calls, 'mobile-ads'),
        preloadInterstitialAd: _action(calls, 'interstitial'),
        initializeNotifications: _action(calls, 'notifications'),
        preloadHome: _action(calls, 'home'),
        preloadCategories: _action(calls, 'categories'),
      );

      expect(calls, [
        'remote-config',
        'mobile-ads',
        'interstitial',
        'notifications',
        'home',
        'categories',
      ]);
    },
  );

  test(
    'current_bug_R13_mobile_ads_failure_aborts_startup_remove_in_PR_6_1',
    () async {
      final calls = <String>[];

      await expectLater(
        runAppInitializer(
          configureRemoteConfig: _action(calls, 'remote-config'),
          initializeMobileAds: _action(calls, 'mobile-ads', error: 'ads'),
          preloadInterstitialAd: _action(calls, 'interstitial'),
          initializeNotifications: _action(calls, 'notifications'),
          preloadHome: _action(calls, 'home'),
          preloadCategories: _action(calls, 'categories'),
        ),
        throwsA('ads'),
      );

      expect(calls, ['remote-config', 'mobile-ads']);
    },
  );

  test(
    'current_bug_R13_notification_failure_aborts_local_preloads_remove_in_PR_6_1',
    () async {
      final calls = <String>[];

      await expectLater(
        runAppInitializer(
          configureRemoteConfig: _action(calls, 'remote-config'),
          initializeMobileAds: _action(calls, 'mobile-ads'),
          preloadInterstitialAd: _action(calls, 'interstitial'),
          initializeNotifications: _action(
            calls,
            'notifications',
            error: 'notifications',
          ),
          preloadHome: _action(calls, 'home'),
          preloadCategories: _action(calls, 'categories'),
        ),
        throwsA('notifications'),
      );

      expect(calls, [
        'remote-config',
        'mobile-ads',
        'interstitial',
        'notifications',
      ]);
    },
  );
}

Future<void> Function() _action(
  List<String> calls,
  String name, {
  Object? error,
}) {
  return () async {
    calls.add(name);
    if (error != null) {
      throw error;
    }
  };
}
