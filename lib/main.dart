import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/router/app_router.dart';
import 'package:money_fit/core/services/app_initializer.dart';
import 'package:money_fit/core/theme/app_theme.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:money_fit/core/services/review_prompt_service.dart';

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

    return MaterialApp.router(
      onGenerateTitle: (context) {
        return AppLocalizations.of(context)!.appName;
      },
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        // 최초 실행 후 2일 경과 시 리뷰 요청(광고 우선 정책: 광고 노출 시 쿨다운 갱신됨)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ReviewPromptService.instance.maybePromptReview(context);
        });
        return SafeArea(child: child!);
      },
    );
  }
}
