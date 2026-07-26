import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/category_model.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/core/widgets/expense_management/expense_add_form.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ExpenseAddForm current behavior', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
      'current_bug_R05_submit_does_not_await_command_before_pop_remove_in_pr_1_2',
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

        await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
        await tester.pumpAndSettle();

        expect(submitCount, 1);
        expect(find.byType(ExpenseAddForm), findsNothing);

        command.complete();
      },
    );

    testWidgets(
      'current_bug_R05_duplicate_submit_is_limited_only_by_immediate_pop_remove_in_pr_1_2',
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
        await tester.pumpAndSettle();

        // There is no in-flight command state. The first submit closes the
        // sheet before a second concurrent gesture can invoke the callback.
        expect(submitCount, 1);
        expect(find.byType(ExpenseAddForm), findsNothing);

        command.complete();
      },
    );

    testWidgets(
      'current_bug_R06_edit_overwrites_date_and_created_at_remove_in_pr_1_2',
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
          onSubmit: (expense) => submitted = expense,
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
        await tester.pumpAndSettle();

        expect(submitted?.id, original.id);
        expect(submitted?.date, isNot(original.date));
        expect(submitted?.createdAt, isNot(original.createdAt));
        expect(submitted?.updatedAt, isNot(original.updatedAt));
      },
    );
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  required void Function(Expense expense) onSubmit,
  Expense? initExpense,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [categoryProvider.overrideWith(_TestCategoryNotifier.new)],
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
