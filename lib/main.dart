import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/core/theme/app_theme.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  FlutterError.onError = (e) {
    log(e.toString());
  };
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final isDarkMode = ref
        .watch(userSettingsProvider)
        .when(
          data: (user) => user.isDarkMode,
          loading: () => false,
          error: (err, st) => false,
        );

    return SafeArea(
      child: MaterialApp.router(
        title: 'MoneyFit',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
