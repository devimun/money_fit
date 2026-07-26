import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/providers/category_providers.dart';
// import 'package:money_fit/core/database/database_seeder.dart';
// import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/core/services/ad_policy_service.dart';
import 'package:money_fit/core/providers/prompt_providers.dart';
import 'package:money_fit/core/config/ad_policy_config.dart';
import 'package:money_fit/core/providers/analytics_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';

final appInitializerProvider = FutureProvider<void>((ref) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  await ref.read(remoteConfigServiceProvider).initialize();
  await ref.read(promptStateRepositoryProvider).initializeSession();
  final policy = AdPolicyService(
    ref.read(sharedPreferencesProvider),
    () =>
        AdPolicyConfig.fromRemoteConfig(ref.read(remoteConfigServiceProvider)),
  );
  await policy.initializeSession();
  final analytics = ref.read(analyticsProvider);
  AdService.configurePolicy(() => policy.policy);
  AdService.configureAnalytics(analytics);
  InterstitialAdManager.instance.configure(
    policy: policy,
    analytics: analytics,
  );
  AppOpenAdManager.instance.configure(policy: policy, analytics: analytics);
  for (final key in policy.policy.invalidKeys) {
    unawaited(
      analytics.track(AnalyticsEvent.adConfigInvalid, {
        'key': key,
        'value_source': 'remote_config',
        'ad_policy_version': policy.policy.policyVersion,
      }),
    );
  }

  // UMP determines whether the SDK may initialize or receive any request.
  final adsReady = await AdService.initialize();

  // App Open Ad 선로딩
  // await AppOpenAdManager.instance.loadAd();

  if (adsReady) await InterstitialAdManager.instance.loadAd();

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
