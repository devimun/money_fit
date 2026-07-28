import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/app_update/application/update_presentation.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';
import 'package:money_fit/features/app_update/presentation/recommended_update_prompt.dart';
import 'package:money_fit/l10n/app_localizations.dart';

void main() {
  testWidgets('recommended notification opens the changelog callback', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const status = UpdateStatus(
      isForceUpdateRequired: false,
      isUpdateRecommended: true,
      messageToDisplay: '',
      storeUri: null,
      changelogLines: ['Faster startup'],
    );
    container.read(updateStatusProvider.notifier).set(status);
    UpdateStatus? shownStatus;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RecommendedUpdatePrompt(
            presentDetails: (context, status) async {
              shownStatus = status;
            },
            child: const Scaffold(body: SizedBox()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text(
        'A new version is available. Enjoy the latest features and improvements.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Details'));
    await tester.pump();

    expect(shownStatus?.changelogLines, ['Faster startup']);
  });

  testWidgets(
    'retries the advisory Snackbar once after a competing lease releases',
    (tester) async {
      final coordinator = PromptCoordinator();
      final competingLease = coordinator.tryAcquire(PromptSurface.review)!;
      final container = ProviderContainer(
        overrides: [promptCoordinatorProvider.overrideWithValue(coordinator)],
      );
      addTearDown(container.dispose);
      const status = UpdateStatus(
        isForceUpdateRequired: false,
        isUpdateRecommended: true,
        messageToDisplay: '',
        storeUri: null,
        changelogLines: [],
      );
      container.read(updateStatusProvider.notifier).set(status);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecommendedUpdatePrompt(
              retryDelay: Duration(milliseconds: 10),
              child: Scaffold(body: SizedBox()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(
          'A new version is available. Enjoy the latest features and improvements.',
        ),
        findsNothing,
      );

      competingLease.release(applyQuietPeriod: false);
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text(
          'A new version is available. Enjoy the latest features and improvements.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('store-launch failure leaves the update details sheet usable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const status = UpdateStatus(
      isForceUpdateRequired: false,
      isUpdateRecommended: true,
      messageToDisplay: '',
      storeUri: null,
      changelogLines: ['Faster startup'],
    );
    container.read(updateStatusProvider.notifier).set(status);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RecommendedUpdatePrompt(
            openStore: (_) =>
                Future<void>.error(StateError('store unavailable')),
            child: const Scaffold(body: SizedBox()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.widgetWithText(TextButton, 'Details'));
    await tester.pumpAndSettle();
    expect(find.text('Update Info'), findsOneWidget);
    expect(find.text('Faster startup'), findsOneWidget);

    final updateButton = find.widgetWithText(ElevatedButton, 'Go to Update');
    await tester.ensureVisible(updateButton);
    await tester.pumpAndSettle();
    await tester.tap(updateButton);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Update Info'), findsOneWidget);
    expect(find.text('Faster startup'), findsOneWidget);
  });
}
