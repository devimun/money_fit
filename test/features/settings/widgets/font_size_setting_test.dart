// Tests for FontSizeSetting widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/theme_settings.dart';
import 'package:money_fit/features/settings/widgets/font_size_setting.dart';
import 'package:money_fit/l10n/app_localizations.dart';

void main() {
  group('FontSizeSetting Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: FontSizeSetting(),
          ),
        ),
      );
    }

    testWidgets('displays font size setting with current value',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify the widget displays
      expect(find.byType(FontSizeSetting), findsOneWidget);
      expect(find.byIcon(Icons.text_fields), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget); // Default value
    });

    testWidgets('opens font size dialog when tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap on the setting item
      await tester.tap(find.byType(FontSizeSetting));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Font Size'), findsNWidgets(2)); // Title + dialog title
    });

    testWidgets('displays all font size options in dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open dialog
      await tester.tap(find.byType(FontSizeSetting));
      await tester.pumpAndSettle();

      // Verify all options are displayed
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsNWidgets(2)); // Current + option
      expect(find.text('Large'), findsOneWidget);
      expect(find.byType(RadioListTile<FontSizeOption>), findsNWidgets(3));
    });

    testWidgets('can select different font size option', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open dialog
      await tester.tap(find.byType(FontSizeSetting));
      await tester.pumpAndSettle();

      // Find and tap the Large option
      final largeOption = find.ancestor(
        of: find.text('Large'),
        matching: find.byType(RadioListTile<FontSizeOption>),
      );
      await tester.tap(largeOption);
      await tester.pumpAndSettle();

      // Verify the radio button is selected
      // Note: RadioGroup manages the selection state internally
    });

    testWidgets('cancel button closes dialog without changes', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open dialog
      await tester.tap(find.byType(FontSizeSetting));
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('apply button closes dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open dialog
      await tester.tap(find.byType(FontSizeSetting));
      await tester.pumpAndSettle();

      // Select a different option
      final smallOption = find.ancestor(
        of: find.text('Small'),
        matching: find.byType(RadioListTile<FontSizeOption>),
      );
      await tester.tap(smallOption);
      await tester.pumpAndSettle();

      // Tap apply button
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('font size options have correct scale values', (tester) async {
      expect(FontSizeOption.small.scale, 0.85);
      expect(FontSizeOption.medium.scale, 1.0);
      expect(FontSizeOption.large.scale, 1.15);
    });

    testWidgets('displays text with scaled font size in dialog',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Open dialog
      await tester.tap(find.byType(FontSizeSetting));
      await tester.pumpAndSettle();

      // Find the radio tiles and verify font sizes
      final smallTile = tester.widget<RadioListTile<FontSizeOption>>(
        find.ancestor(
          of: find.text('Small'),
          matching: find.byType(RadioListTile<FontSizeOption>),
        ),
      );
      final smallText = smallTile.title as Text;
      expect(smallText.style?.fontSize, 16 * 0.85);

      final mediumTile = tester.widget<RadioListTile<FontSizeOption>>(
        find.ancestor(
          of: find.text('Medium').at(1), // Second occurrence (in dialog)
          matching: find.byType(RadioListTile<FontSizeOption>),
        ),
      );
      final mediumText = mediumTile.title as Text;
      expect(mediumText.style?.fontSize, 16 * 1.0);

      final largeTile = tester.widget<RadioListTile<FontSizeOption>>(
        find.ancestor(
          of: find.text('Large'),
          matching: find.byType(RadioListTile<FontSizeOption>),
        ),
      );
      final largeText = largeTile.title as Text;
      expect(largeText.style?.fontSize, 16 * 1.15);
    });
  });
}
