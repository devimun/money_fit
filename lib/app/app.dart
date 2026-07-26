import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/router/app_router.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/providers/locale_provider.dart';
import 'package:money_fit/core/providers/theme_provider.dart';
import 'package:money_fit/core/widgets/ledger_currency_scope.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class MoneyFitApp extends ConsumerWidget {
  const MoneyFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);
    final currentLocale = ref.watch(currentLocaleProvider);
    final ledgerCurrency = ref.watch(ledgerCurrencyProvider);

    return LedgerCurrencyScope(
      currency: ledgerCurrency,
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        locale: currentLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedLocales,
      ),
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
