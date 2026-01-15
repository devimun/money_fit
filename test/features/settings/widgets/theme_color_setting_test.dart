/// Tests for ThemeColorSetting widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/theme/theme_provider.dart';
import 'package:money_fit/features/settings/widgets/theme_color_setting.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/color_picker_dialog.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeColorSetting Widget Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('displays theme color setting with current color',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: ThemeColorSetting(),
            ),
          ),
        ),
      );

      // Verify the widget displays
      expect(find.byType(ThemeColorSetting), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
      expect(find.text('Theme Color'), findsOneWidget);
    });

    testWidgets('shows color picker dialog when tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: ThemeColorSetting(),
            ),
          ),
        ),
      );

      // Tap the setting item
      await tester.tap(find.byType(ThemeColorSetting));
      await tester.pumpAndSettle();

      // Verify ColorPickerDialog is shown
      expect(find.byType(ColorPickerDialog), findsOneWidget);
      expect(find.text('테마 색상 선택'), findsOneWidget);
    });

    testWidgets('displays color indicator circle', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: ThemeColorSetting(),
            ),
          ),
        ),
      );

      // Find the color indicator container
      final containerFinder = find.descendant(
        of: find.byType(ThemeColorSetting),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );

      expect(containerFinder, findsOneWidget);
    });
  });
}
