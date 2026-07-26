import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/core/providers/theme_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/firebase_options.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final environment = AppEnvironment.fromDartDefines();
  final configurationFailure = environment.localConfigurationFailure;
  if (configurationFailure != null) {
    runApp(_ConfigurationFailureApp(failure: configurationFailure));
    return;
  }
  // 모든 로케일의 날짜 포맷팅 초기화
  await initializeDateFormatting();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    Phoenix(
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          appEnvironmentProvider.overrideWithValue(environment),
        ],
        child: const MyApp(),
      ),
    ),
  );

  // Remote SDKs are optional capabilities. Their initialization must not
  // prevent local UI bootstrap when configuration is absent or invalid.
  unawaited(_initializeOptionalRemoteCapabilities(environment));
}

class _ConfigurationFailureApp extends StatelessWidget {
  const _ConfigurationFailureApp({required this.failure});

  final ConfigurationFailure failure;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Configuration error: ${failure.message}'),
          ),
        ),
      ),
    );
  }
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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _migrationAttempted = false;

  @override
  Widget build(BuildContext context) {
    // 기존 User.isDarkMode를 ThemeSettings로 마이그레이션
    // userSettingsProvider가 로드되면 한 번만 실행
    // ref.listen은 build 메서드 내에서만 사용 가능
    ref.listen(userSettingsProvider, (previous, next) {
      next.whenData((user) {
        if (!_migrationAttempted) {
          _migrationAttempted = true;
          ref
              .read(themeModeProvider.notifier)
              .migrateFromUserSettings(user.isDarkMode);
        }
      });
    });

    final router = ref.watch(goRouterProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appName;
      },
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      builder: (context, child) {
        return SafeArea(child: child!);
      },
    );
  }
}
