import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_fit/app/app.dart';
import 'package:money_fit/app/composition/analytics_providers.dart';
import 'package:money_fit/app/composition/current_budget_providers.dart';
import 'package:money_fit/app/composition/database_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/budget/data/sqlite_v6_current_budget_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final environment = AppEnvironment.fromDartDefines();
  final configurationFailure = environment.localConfigurationFailure;
  if (configurationFailure != null) {
    runApp(ConfigurationFailureApp(failure: configurationFailure));
    return;
  }
  // 모든 로케일의 날짜 포맷팅 초기화
  await initializeDateFormatting();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        appEnvironmentProvider.overrideWithValue(environment),
        analyticsTrackerProvider.overrideWith(
          (ref) => ref.watch(configuredAnalyticsTrackerProvider),
        ),
        currentOwnerProvider.overrideWith(SessionCurrentOwner.new),
        currentBudgetRepositoryProvider.overrideWith(
          (ref) =>
              SqliteV6CurrentBudgetRepository(ref.read(appDatabaseProvider)),
        ),
      ],
      child: const MoneyFitApp(),
    ),
  );
}
