import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_fit/app/app.dart';
import 'package:money_fit/app/composition/current_budget_providers.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/firebase_options.dart';
import 'package:money_fit/features/budget/application/current_budget_provider.dart';
import 'package:money_fit/features/budget/data/legacy_current_budget_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        currentOwnerProvider.overrideWith(SessionCurrentOwner.new),
        currentBudgetRepositoryProvider.overrideWith(
          (ref) =>
              LegacyCurrentBudgetRepository(ref.read(userRepositoryProvider)),
        ),
      ],
      child: const MoneyFitApp(),
    ),
  );

  // Remote SDKs are optional capabilities. Their initialization must not
  // prevent local UI bootstrap when configuration is absent or invalid.
  unawaited(_initializeOptionalRemoteCapabilities(environment));
}

Future<void> _initializeOptionalRemoteCapabilities(
  AppEnvironment environment,
) async {
  await Future.wait([
    _initializeFirebase(environment),
    _initializeSupabase(environment),
  ]);
}

Future<void> _initializeFirebase(AppEnvironment environment) async {
  if (!environment.firebase.isAvailable) {
    debugPrint(
      'Firebase unavailable: ${environment.firebase.unavailable?.message}',
    );
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error\n$stackTrace');
  }
}

Future<void> _initializeSupabase(AppEnvironment environment) async {
  final configuration = environment.supabase.value;
  if (configuration == null) {
    debugPrint(
      'Supabase unavailable: ${environment.supabase.unavailable?.message}',
    );
    return;
  }

  try {
    await Supabase.initialize(
      url: configuration.url.toString(),
      anonKey: configuration.anonKey,
    );
  } catch (error, stackTrace) {
    debugPrint('Supabase initialization failed: $error\n$stackTrace');
  }
}
