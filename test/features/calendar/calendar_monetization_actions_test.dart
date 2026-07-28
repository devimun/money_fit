import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/features/calendar/application/calendar_projection.dart';
import 'package:money_fit/features/calendar/application/calendar_view_model.dart';
import 'package:money_fit/features/calendar/view/widgets/calendar_header.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';
import 'package:money_fit/l10n/app_localizations.dart';

void main() {
  testWidgets('calendar month navigation records exactly one typed action', (
    tester,
  ) async {
    final actions = <MeaningfulAdAction>[];
    await tester.pumpWidget(
      _testApp(
        actions: actions,
        visibleMonth: DateTime(2026, 8),
        child: CalendarHeader(stat: _stat(), day: DateTime(2026, 8)),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(CalendarHeader)),
    );
    expect(container.read(calendarVisibleMonthProvider), DateTime(2026, 7));
    expect(actions, [MeaningfulAdAction.calendarMonthChanged]);
  });

  testWidgets('calendar no-op month target records no action or safe point', (
    tester,
  ) async {
    final actions = <MeaningfulAdAction>[];
    await tester.pumpWidget(
      _testApp(
        actions: actions,
        // The header's previous-month target is July, which is already active.
        visibleMonth: DateTime(2026, 7),
        child: CalendarHeader(stat: _stat(), day: DateTime(2026, 8)),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pump();

    expect(actions, isEmpty);
  });
}

Widget _testApp({
  required List<MeaningfulAdAction> actions,
  required DateTime visibleMonth,
  required Widget child,
}) => ProviderScope(
  overrides: [
    calendarVisibleMonthProvider.overrideWith((ref) => visibleMonth),
    monetizationSafePointProvider.overrideWithValue((action) async {
      actions.add(action);
    }),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

CalendarStat _stat() => CalendarStat(
  monthlyDiscretionaryExpense: 0,
  monthlyEssentialExpense: 0,
  successfulDays: 0,
  failedDays: 0,
  consecutiveSuccessfulDays: 0,
);
