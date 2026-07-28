import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/providers/analytics_provider.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/features/settings/model/inquiry_type.dart';
import 'package:money_fit/features/settings/repository/contact_repository.dart';
import 'package:money_fit/features/settings/widgets/contact_us_dialog.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class _FakeContactRepository implements ContactSubmissionRepository {
  _FakeContactRepository({this.error, Completer<void>? completer})
    : _completer = completer;

  final Object? error;
  final Completer<void>? _completer;
  var calls = 0;

  @override
  Future<void> submit({
    required InquiryType type,
    required String email,
    required String details,
    required String locale,
  }) async {
    calls += 1;
    if (_completer != null) await _completer.future;
    if (error != null) throw error!;
  }
}

Future<void> _pumpDialog(
  WidgetTester tester,
  _FakeContactRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contactRepositoryProvider.overrideWithValue(repository),
        analyticsProvider.overrideWithValue(const NoopAnalyticsService()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const ContactUsDialog(),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Inquiry Type'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bug Report').last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(1), 'An inquiry');
  await tester.ensureVisible(find.byType(ElevatedButton).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('prevents a second submission while the first is pending', (
    tester,
  ) async {
    final completer = Completer<void>();
    final repository = _FakeContactRepository(completer: completer);
    await _pumpDialog(tester, repository);
    final submitButton = find.byType(ElevatedButton).last;

    await tester.tap(submitButton);
    await tester.pump();
    await tester.tap(submitButton);
    await tester.pump();

    expect(repository.calls, 1);
    completer.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ContactUsDialog), findsNothing);
  });

  testWidgets('keeps user input visible after a failed submission', (
    tester,
  ) async {
    final repository = _FakeContactRepository(error: StateError('offline'));
    await _pumpDialog(tester, repository);

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(find.text('An inquiry'), findsOneWidget);
    expect(find.byType(ContactUsDialog), findsOneWidget);
  });
}
