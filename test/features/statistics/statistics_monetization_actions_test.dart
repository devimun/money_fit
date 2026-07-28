import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/features/ledger/data/legacy/expense_model.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';
import 'package:money_fit/features/statistics/application/statistics_ui_state.dart';
import 'package:money_fit/features/statistics/view/widgets/statistics_category_spending_chart.dart';
import 'package:money_fit/features/statistics/view/widgets/statistics_date_selector.dart';
import 'package:money_fit/l10n/app_localizations.dart';

void main() {
  testWidgets('selected statistics type tap records no action or safe point', (
    tester,
  ) async {
    final actions = <MeaningfulAdAction>[];

    await tester.pumpWidget(
      _testApp(
        actions: actions,
        child: const Row(
          children: [
            ExpenseTypeTab(
              title: 'Discretionary',
              type: ExpenseType.discretionary,
              selectedType: ExpenseType.discretionary,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(actions, isEmpty);
  });

  testWidgets(
    'same statistics month selection records no action or safe point',
    (tester) async {
      final actions = <MeaningfulAdAction>[];
      final data = StatisticsModel(
        year: 2026,
        month: 7,
        expenseType: ExpenseType.discretionary,
        essentialExpenses: const [],
        flexExpenses: const [],
        top3Expenses: const [],
      );

      await tester.pumpWidget(
        _testApp(
          actions: actions,
          child: StatisticsDateSelector(data: data),
        ),
      );

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(actions, isEmpty);
    },
  );
}

Widget _testApp({
  required List<MeaningfulAdAction> actions,
  required Widget child,
}) => ProviderScope(
  overrides: [
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
