import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/core/theme/theme_provider.dart';
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
  await initializeDateFormatting('ko_KR', null);
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    Phoenix(
      child: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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
    final router = ref.watch(goRouterProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    // 기존 User.isDarkMode를 ThemeSettings로 마이그레이션
    // userSettingsProvider가 로드되면 한 번만 실행
    if (!_migrationAttempted) {
      ref.listen(userSettingsProvider, (previous, next) {
        next.whenData((user) {
          if (!_migrationAttempted) {
            _migrationAttempted = true;
            ref.read(themeModeProvider.notifier).migrateFromUserSettings(
              user.isDarkMode,
            );
          }
        });
      });
    }

    return MaterialApp.router(
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appName;
      },
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return SafeArea(child: child!);
      },
    );
  }
}
