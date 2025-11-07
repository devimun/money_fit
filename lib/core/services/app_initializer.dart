import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/providers/category_providers.dart';
// import 'package:money_fit/core/database/database_seeder.dart';
// import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';

final appInitializerProvider = FutureProvider<void>((ref) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Remote Config 초기가능(선택)
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 30),
      ),
    );
  } catch (_) {}
  // AdMob 초기화
  await AdService.initialize();

  // App Open Ad 선로딩
  // await AppOpenAdManager.instance.loadAd();

  await InterstitialAdManager.instance.loadAd();

  await ref.read(notificationServiceProvider).init();

  // 기존 데이터 상태 초기화
  await ref.read(homeViewModelProvider.future);
  await ref.read(categoryProvider.future);

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
