import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/services/app_initializer.dart';
import 'package:money_fit/core/services/data_reset_service.dart';

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

  test(
    'current_bug_R11_reset_logs_analytics_before_database_reset_remove_in_PR_5_4',
    () async {
      final calls = <String>[];

      await DataResetService.resetAllData(
        logReset: _action(calls, 'analytics'),
        resetDatabase: _action(calls, 'database'),
      );

      expect(calls, ['analytics', 'database']);
    },
  );

  test(
    'current_bug_R11_analytics_failure_prevents_database_reset_remove_in_PR_5_4',
    () async {
      final calls = <String>[];

      await expectLater(
        DataResetService.resetAllData(
          logReset: _action(calls, 'analytics', error: 'analytics'),
          resetDatabase: _action(calls, 'database'),
        ),
        throwsA('analytics'),
      );

      expect(calls, ['analytics']);
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
