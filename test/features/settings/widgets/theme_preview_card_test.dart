import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/theme/app_theme_generator.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/theme_preview_card.dart';

void main() {
  group('ThemePreviewCard', () {
    testWidgets('renders with initial light mode', (tester) async {
      const Color testSeed = Color(0xFF1976D2); // Blue

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: testSeed),
          ),
        ),
      );

      // Should show preview header
      expect(find.text('Preview'), findsOneWidget);

      // Should show light mode icon highlighted
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Should show sample UI elements
      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card content with secondary text'), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Primary Text'), findsOneWidget);
      expect(find.text('Secondary Text'), findsOneWidget);
    });

    testWidgets('toggles between light and dark mode', (tester) async {
      const Color testSeed = Color(0xFF1976D2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: testSeed),
          ),
        ),
      );

      // Find the switch
      final Finder switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Initial state should be light mode (switch off)
      Switch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, false);

      // Tap the switch to toggle to dark mode
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Switch should now be on (dark mode)
      switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, true);

      // Tap again to toggle back to light mode
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Switch should be off again (light mode)
      switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, false);
    });

    testWidgets('updates preview when seed color changes', (tester) async {
      const Color initialSeed = Color(0xFF1976D2); // Blue
      const Color newSeed = Color(0xFFD32F2F); // Red

      // Generate expected colors
      final initialTheme = AppThemeGenerator.lightFromSeed(initialSeed);
      final newTheme = AppThemeGenerator.lightFromSeed(newSeed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: initialSeed),
          ),
        ),
      );

      // Verify initial theme color is applied
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  initialTheme.brandPrimary,
        ),
        findsOneWidget,
      );

      // Update with new seed color
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: newSeed),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify new theme color is applied
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color ==
                  newTheme.brandPrimary,
        ),
        findsOneWidget,
      );

      // Verify colors are different
      expect(initialTheme.brandPrimary, isNot(equals(newTheme.brandPrimary)));
    });

    testWidgets('displays correct theme colors in light mode', (tester) async {
      const Color testSeed = Color(0xFF1976D2);
      final lightTheme = AppThemeGenerator.lightFromSeed(testSeed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: testSeed),
          ),
        ),
      );

      // Find the button container
      final Container buttonContainer = tester.widget(
        find.descendant(
          of: find.byType(ThemePreviewCard),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color ==
                    lightTheme.brandPrimary,
          ),
        ),
      );

      final BoxDecoration decoration =
          buttonContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(lightTheme.brandPrimary));
    });

    testWidgets('displays correct theme colors in dark mode', (tester) async {
      const Color testSeed = Color(0xFF1976D2);
      final darkTheme = AppThemeGenerator.darkFromSeed(testSeed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: testSeed),
          ),
        ),
      );

      // Toggle to dark mode
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Find the button container with dark theme color
      final Container buttonContainer = tester.widget(
        find.descendant(
          of: find.byType(ThemePreviewCard),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color ==
                    darkTheme.brandPrimary,
          ),
        ),
      );

      final BoxDecoration decoration =
          buttonContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(darkTheme.brandPrimary));
    });

    testWidgets('shows all required UI elements', (tester) async {
      const Color testSeed = Color(0xFF1976D2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: testSeed),
          ),
        ),
      );

      // Check for all required elements
      expect(find.text('Preview'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Sample card elements
      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card content with secondary text'), findsOneWidget);

      // Sample button
      expect(find.text('Primary Button'), findsOneWidget);

      // Sample text
      expect(find.text('Primary Text'), findsOneWidget);
      expect(find.text('Secondary Text'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (tester) async {
      const Color testSeed = Color(0xFF1976D2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemePreviewCard(seedColor: testSeed),
          ),
        ),
      );

      // Should have main container
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).borderRadius != null,
        ),
        findsWidgets,
      );

      // Should have proper spacing
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
