import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/core/providers/theme_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/core/providers/analytics_provider.dart';
import 'package:money_fit/core/providers/prompt_providers.dart';
import 'package:money_fit/core/config/remote_config_service.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/config/analytics_config.dart';
import 'package:money_fit/core/repositories/analytics_consent_repository.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/firebase_options.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 모든 로케일의 날짜 포맷팅 초기화
  await initializeDateFormatting();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  final remoteConfig = RemoteConfigService(FirebaseRemoteConfig.instance);
  await remoteConfig.initialize();
  final analytics = DualAnalyticsService(AnalyticsConfig.fromEnvironment());
  final consent = AnalyticsConsentRepository(sharedPreferences);
  await analytics.setCollectionEnabled(
    consent.isEnabled && remoteConfig.boolValue('amplitude_collection_enabled'),
  );
  await analytics.initialize();
  remoteConfig.updates.listen((_) {
    analytics.setCollectionEnabled(
      consent.isEnabled &&
          remoteConfig.boolValue('amplitude_collection_enabled'),
    );
  });

  runApp(
    Phoenix(
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          remoteConfigServiceProvider.overrideWithValue(remoteConfig),
          analyticsProvider.overrideWithValue(analytics),
        ],
        child: const MyApp(),
      ),
    ),
  );
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
        ref.read(analyticsProvider).setUserId(user.id);
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
