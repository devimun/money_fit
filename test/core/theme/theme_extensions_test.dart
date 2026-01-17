// Property-based tests for ThemeExtensions
// Feature: theme-system-refactoring, Property 5: Theme Extension Non-Null
// Validates: Requirements 4.4, 4.5
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/theme/app_theme_colors.dart';
import 'package:money_fit/core/theme/app_theme_generator.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';

void main() {
  group('ThemeExtensions Property Tests', () {
    /// Helper function to create a random color
    Color randomColor(Random random) => Color.fromARGB(
          255,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );

    /// Helper function to create a random AppThemeColors instance
    AppThemeColors createRandomTheme(Random random) {
      return AppThemeColors(
        brandPrimary: randomColor(random),
        brandSecondary: randomColor(random),
        error: randomColor(random),
        screenBackground: randomColor(random),
        cardBackground: randomColor(random),
        inputBackground: randomColor(random),
        calendarCellBackground: randomColor(random),
        selectedButtonBackground: randomColor(random),
        textPrimary: randomColor(random),
        textSecondary: randomColor(random),
        textOnBrand: randomColor(random),
        textOnCard: randomColor(random),
        border: randomColor(random),
        divider: randomColor(random),
        borderFocused: randomColor(random),
        navUnselected: randomColor(random),
        navSelected: randomColor(random),
        switchActive: randomColor(random),
        switchInactiveTrack: randomColor(random),
        overlay: randomColor(random),
        budgetProgress: randomColor(random),
      );
    }

    testWidgets(
      'Property 5: Theme Extension Non-Null - '
      'For any BuildContext with a properly configured theme, '
      'context.theme should never return null',
      (WidgetTester tester) async {
        final random = Random(42); // Fixed seed for reproducibility
        const numRuns = 100;

        for (int i = 0; i < numRuns; i++) {
          // Generate a random theme
          final randomTheme = createRandomTheme(random);
          final brightness =
              random.nextBool() ? Brightness.light : Brightness.dark;

          // Create a ThemeData with the random AppThemeColors
          final themeData = ThemeData(
            brightness: brightness,
            extensions: [randomTheme],
          );

          // Build a widget tree with the theme
          await tester.pumpWidget(
            MaterialApp(
              theme: themeData,
              home: Builder(
                builder: (context) {
                  // Test that context.theme never returns null
                  final theme = context.theme;

                  expect(theme, isNotNull,
                      reason: 'context.theme should never be null (run $i)');

                  // Verify that the returned theme is the one we set
                  expect(theme.brandPrimary, equals(randomTheme.brandPrimary),
                      reason:
                          'context.theme should return the correct theme (run $i)');

                  expect(theme.textPrimary, equals(randomTheme.textPrimary),
                      reason:
                          'context.theme should return the correct theme (run $i)');

                  expect(
                      theme.screenBackground, equals(randomTheme.screenBackground),
                      reason:
                          'context.theme should return the correct theme (run $i)');

                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        }
      },
    );

    testWidgets(
      'Property 5: Theme Extension Non-Null - '
      'When AppThemeColors is missing, context.theme returns default theme',
      (WidgetTester tester) async {
        // Create a ThemeData WITHOUT AppThemeColors extension
        final themeData = ThemeData(
          brightness: Brightness.light,
          // No extensions added
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: themeData,
            home: Builder(
              builder: (context) {
                // Test that context.theme returns a default theme instead of null
                final theme = context.theme;

                expect(theme, isNotNull,
                    reason:
                        'context.theme should return default theme when extension is missing');

                // Verify it returns the default light theme
                final defaultTheme = AppThemeGenerator.lightFromSeed(
                    AppThemeGenerator.defaultSeed);

                expect(theme.brandPrimary, equals(defaultTheme.brandPrimary),
                    reason: 'Should return default theme brandPrimary');

                expect(theme.textPrimary, equals(defaultTheme.textPrimary),
                    reason: 'Should return default theme textPrimary');

                expect(
                    theme.screenBackground, equals(defaultTheme.screenBackground),
                    reason: 'Should return default theme screenBackground');

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets(
      'context.textTheme returns non-null TextTheme',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final textTheme = context.textTheme;

                expect(textTheme, isNotNull,
                    reason: 'context.textTheme should never be null');

                // Verify it's a valid TextTheme
                expect(textTheme, isA<TextTheme>());

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets(
      'context.brightness returns valid Brightness',
      (WidgetTester tester) async {
        // Test light mode
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: Builder(
              builder: (context) {
                expect(context.brightness, equals(Brightness.light),
                    reason: 'Should return Brightness.light for light theme');

                expect(context.isDarkMode, isFalse,
                    reason: 'isDarkMode should be false for light theme');

                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Test dark mode
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: Brightness.dark),
            home: Builder(
              builder: (context) {
                expect(context.brightness, equals(Brightness.dark),
                    reason: 'Should return Brightness.dark for dark theme');

                expect(context.isDarkMode, isTrue,
                    reason: 'isDarkMode should be true for dark theme');

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets(
      'context.isDarkMode correctly identifies dark mode',
      (WidgetTester tester) async {
        final random = Random(42);
        const numRuns = 50;

        for (int i = 0; i < numRuns; i++) {
          final isDark = random.nextBool();
          final brightness = isDark ? Brightness.dark : Brightness.light;

          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: Builder(
                builder: (context) {
                  expect(context.isDarkMode, equals(isDark),
                      reason:
                          'isDarkMode should match brightness setting (run $i)');

                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        }
      },
    );
  });
}
