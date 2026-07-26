import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/category_model.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/foundation/clock.dart';
import 'package:money_fit/core/foundation/id_generator.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/features/ledger/presentation/editor/expense_add_form.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ExpenseAddForm command contract', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('does not pop before an async command completes', (
      tester,
    ) async {
      final command = Completer<void>();
      var submitCount = 0;

      await _pumpForm(
        tester,
        onSubmit: (_) async {
          submitCount++;
          await command.future;
        },
      );
      await _fillValidForm(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(submitCount, 1);
      expect(find.byType(ExpenseAddForm), findsOneWidget);

      command.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseAddForm), findsNothing);
    });

    testWidgets(
      'does not invoke a second command while the first is in flight',
      (tester) async {
        final command = Completer<void>();
        var submitCount = 0;

        await _pumpForm(
          tester,
          onSubmit: (_) async {
            submitCount++;
            await command.future;
          },
        );
        await _fillValidForm(tester);

        final register = find.widgetWithText(ElevatedButton, 'Register');
        final center = tester.getCenter(register);
        final firstGesture = await tester.startGesture(center, pointer: 1);
        final secondGesture = await tester.startGesture(center, pointer: 2);
        await firstGesture.up();
        await secondGesture.up();
        await tester.pump();

        expect(submitCount, 1);
        expect(find.byType(ExpenseAddForm), findsOneWidget);
        expect(tester.widget<ElevatedButton>(register).onPressed, isNull);

        command.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'keeps edit identity and creation fields while updating updatedAt',
      (tester) async {
        final original = Expense(
          id: 'original-expense',
          userId: 'user-1',
          name: 'Original lunch',
          amount: 12,
          date: DateTime(2020, 1, 2),
          categoryId: 'food',
          type: ExpenseType.essential,
          createdAt: DateTime(2020, 1, 2, 9),
          updatedAt: DateTime(2020, 1, 2, 9),
        );
        Expense? submitted;

        await _pumpForm(
          tester,
          initExpense: original,
          onSubmit: (expense) async {
            submitted = expense;
          },
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
        await tester.pumpAndSettle();

        expect(submitted?.id, original.id);
        expect(submitted?.date, original.date);
        expect(submitted?.createdAt, original.createdAt);
        expect(submitted?.updatedAt, DateTime(2026, 7, 27, 10));
      },
    );

    testWidgets('keeps form input and allows retry after a failed command', (
      tester,
    ) async {
      var attempts = 0;

      await _pumpForm(
        tester,
        onSubmit: (_) async {
          attempts++;
          if (attempts == 1) throw StateError('database unavailable');
        },
      );
      await _fillValidForm(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      expect(attempts, 1);
      expect(find.byType(ExpenseAddForm), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('database unavailable'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.byType(ExpenseAddForm), findsNothing);
    });
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  required Future<void> Function(Expense expense) onSubmit,
  Expense? initExpense,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryProvider.overrideWith(_TestCategoryNotifier.new),
        clockProvider.overrideWithValue(FakeClock(DateTime(2026, 7, 27, 10))),
        idGeneratorProvider.overrideWithValue(FakeIds(['new-expense'])),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SizedBox(
                      height: 640,
                      child: ExpenseAddForm(
                        uid: 'user-1',
                        initExpense: initExpense,
                        onSubmit: onSubmit,
                      ),
                    ),
                  );
                },
                child: const Text('Open expense form'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open expense form'));
  await tester.pumpAndSettle();
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'Coffee');
  await tester.enterText(find.byType(TextField).at(1), '4');
  await tester.tap(find.text('Food'));
  await tester.pumpAndSettle();
}

class _TestCategoryNotifier extends CategoryProviders {
  @override
  Future<List<Category>> build() async {
    return const [
      Category(
        id: 'food',
        name: 'Food',
        type: ExpenseType.essential,
        isDeletable: false,
      ),
    ];
  }
}
