import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/config/analytics_config.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/core/repositories/analytics_consent_repository.dart';

final analyticsConsentRepositoryProvider = Provider<AnalyticsConsentRepository>(
  (ref) => AnalyticsConsentRepository(ref.watch(sharedPreferencesProvider)),
);

final analyticsProvider = Provider<AnalyticsService>((ref) {
  final service = DualAnalyticsService(AnalyticsConfig.fromEnvironment());
  final consent = ref.watch(analyticsConsentRepositoryProvider);
  service.setCollectionEnabled(consent.isEnabled);
  return service;
});
