import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/app/router/bootstrap_gate.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/app_update/application/update_presentation.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';
import 'package:money_fit/features/app_update/presentation/update_check_screen.dart';
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

  testWidgets('forced update keeps the gate and displays its changelog', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        bootstrapGateProvider.overrideWith(
          (ref) => _FixedGate(BootstrapGateState.forceUpdate),
        ),
        appEnvironmentProvider.overrideWithValue(AppEnvironment.test()),
      ],
    );
    addTearDown(container.dispose);
    const status = UpdateStatus(
      isForceUpdateRequired: true,
      isUpdateRecommended: false,
      messageToDisplay: '',
      storeUri: null,
      changelogLines: ['Security fixes'],
    );
    container.read(updateStatusProvider.notifier).set(status);
    var storeLaunches = 0;
    Uri? launched;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: UpdateCheckScreen(
            openStore: (uri) async {
              storeLaunches++;
              launched = uri;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Update Required'), findsOneWidget);
    expect(find.text("What's New"), findsOneWidget);
    expect(find.text('Security fixes'), findsOneWidget);
    await tester.tap(find.text('Update'));
    await tester.pump();
    expect(storeLaunches, 1);
    expect(launched, isNull);
  });

  testWidgets(
    'acquires the forced-update lease after bootstrap changes from checking',
    (tester) async {
      final coordinator = PromptCoordinator();
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(AppEnvironment.test()),
          promptCoordinatorProvider.overrideWithValue(coordinator),
        ],
      );
      addTearDown(container.dispose);
      const status = UpdateStatus(
        isForceUpdateRequired: true,
        isUpdateRecommended: false,
        messageToDisplay: '',
        storeUri: null,
        changelogLines: ['Security fixes'],
      );
      container.read(updateStatusProvider.notifier).set(status);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UpdateCheckScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(coordinator.activeSurface, isNull);

      container
          .read(bootstrapGateProvider.notifier)
          .set(BootstrapGateState.forceUpdate);
      await tester.pump();
      await tester.pump();

      expect(find.text('Update Required'), findsOneWidget);
      expect(find.text('Security fixes'), findsOneWidget);
      expect(coordinator.activeSurface, PromptSurface.update);
    },
  );
}

class _FixedGate extends BootstrapGateController {
  _FixedGate(BootstrapGateState state) {
    set(state);
  }
}
