import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/router/app_router.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/providers/theme_provider.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class MoneyFitApp extends ConsumerStatefulWidget {
  const MoneyFitApp({super.key});

  @override
  ConsumerState<MoneyFitApp> createState() => _MoneyFitAppState();
}

class _MoneyFitAppState extends ConsumerState<MoneyFitApp> {
  bool _migrationAttempted = false;

  @override
  Widget build(BuildContext context) {
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
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      builder: (context, child) => SafeArea(child: child!),
    );
  }
}

class ConfigurationFailureApp extends StatelessWidget {
  const ConfigurationFailureApp({required this.failure, super.key});

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
