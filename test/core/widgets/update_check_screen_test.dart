import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/widgets/update_check_screen.dart';
import 'package:money_fit/l10n/app_localizations.dart';

void main() {
  testWidgets('waits for the bootstrap controller update decision', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/update-check',
      routes: [
        GoRoute(
          path: '/update-check',
          builder: (context, state) => const UpdateCheckScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(AppEnvironment.test()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
