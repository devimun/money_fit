import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/ledger/application/legacy/category_providers.dart';
// import 'package:money_fit/core/database/database_seeder.dart';
// import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';

typedef AppInitializerAction = Future<void> Function();

/// Runs the current startup sequence.
///
/// The callback parameters keep the service's existing production wiring while
/// allowing its ordering and failure behaviour to be characterized without
/// invoking platform plugin singletons in a host test.
Future<void> runAppInitializer({
  required AppInitializerAction configureRemoteConfig,
  required AppInitializerAction initializeMobileAds,
  required AppInitializerAction preloadInterstitialAd,
  required AppInitializerAction initializeNotifications,
  required AppInitializerAction preloadHome,
  required AppInitializerAction preloadCategories,
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Remote Config 초기가능(선택)
  try {
    await configureRemoteConfig();
  } catch (_) {}
  // AdMob 초기화
  await initializeMobileAds();

  // App Open Ad 선로딩
  // await AppOpenAdManager.instance.loadAd();

  await preloadInterstitialAd();

  await initializeNotifications();

  // 기존 데이터 상태 초기화
  await preloadHome();
  await preloadCategories();
}

final appInitializerProvider = FutureProvider<void>((ref) async {
  await runAppInitializer(
    configureRemoteConfig: () async {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 30),
        ),
      );
    },
    initializeMobileAds: AdService.initialize,
    preloadInterstitialAd: InterstitialAdManager.instance.loadAd,
    initializeNotifications: () async {
      await ref.read(notificationServiceProvider).init();
    },
    preloadHome: () async {
      await ref.read(homeViewModelProvider.future);
    },
    preloadCategories: () async {
      await ref.read(categoryProvider.future);
    },
  );

  // 개발 모드에서만 더미 데이터 생성
  // if (kDebugMode) {
  //   final expenseRepository = ref.read(expenseRepositoryProvider);
  //   final expenses = await expenseRepository.getExpensesByUserId(UserIDD.id);
  //   if (expenses.isEmpty) {
  //     final seeder = DatabaseSeeder(expenseRepository: expenseRepository);
  //     log('Seeding database with dummy data...');
  //     await seeder.seedJulyExpenses(locale: 'ms');
  //     log('Database seeding complete.');
  //   }
  // }
});
