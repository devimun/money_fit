import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/core/services/app_initializer.dart';
import 'package:money_fit/core/theme/app_theme.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';

Future<void> main() async {
  final container = await AppInitializer.initialize();
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
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
