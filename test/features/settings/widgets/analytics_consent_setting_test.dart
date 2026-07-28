import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/platform/analytics_consent_repository.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/features/settings/widgets/analytics_consent_setting.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('persists analytics consent and updates live collection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final tracker = _RecordingAnalyticsTracker();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          analyticsTrackerProvider.overrideWithValue(tracker),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: AnalyticsConsentSetting()),
        ),
      ),
    );

    expect(find.text('Analytics collection'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(
      preferences.getBool(AnalyticsConsentRepository.collectionKey),
      isFalse,
    );
    expect(tracker.collectionEnabled, [false]);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });
}

class _RecordingAnalyticsTracker implements AnalyticsTracker {
  final collectionEnabled = <bool>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled.add(enabled);
  }

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {}

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {}
}
