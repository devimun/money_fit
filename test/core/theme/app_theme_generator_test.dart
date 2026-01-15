// Property-based tests for AppThemeGenerator
// Feature: theme-system-refactoring
// Tests color consistency and contrast ratio validation
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/theme/app_theme_generator.dart';

void main() {
  group('AppThemeGenerator Property Tests', () {
    /// Helper function to generate random colors
    Color randomColor(Random random) {
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    }

    test(
      'Property 1: Theme Color Consistency - '
      'For any colorSeed, light and dark themes maintain hue consistency',
      () {
        // Feature: theme-system-refactoring, Property 1: Theme Color Consistency
        // Validates: Requirements 2.2, 2.3
        final random = Random(42); // Fixed seed for reproducibility
        const numRuns = 100;

        for (int i = 0; i < numRuns; i++) {
          // Generate random color seed
          final seed = randomColor(random);

          // Generate light and dark themes
          final lightTheme = AppThemeGenerator.lightFromSeed(seed);
          final darkTheme = AppThemeGenerator.darkFromSeed(seed);

          // Extract hue from primary colors
          final lightHue = HSLColor.fromColor(lightTheme.brandPrimary).hue;
          final darkHue = HSLColor.fromColor(darkTheme.brandPrimary).hue;

          // Hue should be consistent (within 10 degrees tolerance for rounding)
          final hueDifference = (lightHue - darkHue).abs();

          expect(
            hueDifference,
            lessThan(10),
            reason:
                'Hue difference should be less than 10 degrees (run $i, seed: 0x${seed.toARGB32().toRadixString(16)})\n'
                'Light hue: $lightHue, Dark hue: $darkHue, Difference: $hueDifference',
          );

          // Verify that lightness differs appropriately
          final lightLightness =
              HSLColor.fromColor(lightTheme.brandPrimary).lightness;
          final darkLightness =
              HSLColor.fromColor(darkTheme.brandPrimary).lightness;

          // Dark mode should have higher lightness for the primary color
          // (to be visible on dark backgrounds)
          expect(
            darkLightness,
            greaterThan(lightLightness),
            reason:
                'Dark mode primary should be lighter than light mode primary (run $i)',
          );
        }
      },
    );

    test(
      'Property 1 Edge Case: Default seed maintains hue consistency',
      () {
        final lightTheme =
            AppThemeGenerator.lightFromSeed(AppThemeGenerator.defaultSeed);
        final darkTheme =
            AppThemeGenerator.darkFromSeed(AppThemeGenerator.defaultSeed);

        final lightHue = HSLColor.fromColor(lightTheme.brandPrimary).hue;
        final darkHue = HSLColor.fromColor(darkTheme.brandPrimary).hue;

        final hueDifference = (lightHue - darkHue).abs();

        expect(
          hueDifference,
          lessThan(10),
          reason: 'Default seed should maintain hue consistency',
        );
      },
    );

    test(
      'Property 1 Edge Case: Pure colors maintain hue consistency',
      () {
        final pureColors = [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
          Colors.cyan,
          Colors.pink,
        ];

        for (final seed in pureColors) {
          final lightTheme = AppThemeGenerator.lightFromSeed(seed);
          final darkTheme = AppThemeGenerator.darkFromSeed(seed);

          final lightHue = HSLColor.fromColor(lightTheme.brandPrimary).hue;
          final darkHue = HSLColor.fromColor(darkTheme.brandPrimary).hue;

          final hueDifference = (lightHue - darkHue).abs();

          expect(
            hueDifference,
            lessThan(10),
            reason:
                'Pure color 0x${seed.toARGB32().toRadixString(16)} should maintain hue consistency',
          );
        }
      },
    );
  });

  group('AppThemeGenerator Contrast Ratio Tests', () {
    /// Helper function to generate random colors
    Color randomColor(Random random) {
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    }

    test(
      'Property 2: Contrast Ratio Validation - '
      'For any background color, onBackground colors provide sufficient contrast',
      () {
        // Feature: theme-system-refactoring, Property 2: Contrast Ratio Validation
        // Validates: Requirements 2.4
        final random = Random(42); // Fixed seed for reproducibility
        const numRuns = 100;

        for (int i = 0; i < numRuns; i++) {
          // Generate random color seed
          final seed = randomColor(random);

          // Test both light and dark themes
          final themes = [
            AppThemeGenerator.lightFromSeed(seed),
            AppThemeGenerator.darkFromSeed(seed),
          ];

          for (final theme in themes) {
            // Test contrast between brandPrimary and textOnBrand
            final primaryLuminance = theme.brandPrimary.computeLuminance();
            final onBrandLuminance = theme.textOnBrand.computeLuminance();
            final primaryContrast = (primaryLuminance - onBrandLuminance).abs();

            expect(
              primaryContrast,
              greaterThan(0.3),
              reason:
                  'brandPrimary and textOnBrand should have sufficient contrast (run $i, seed: 0x${seed.toARGB32().toRadixString(16)})\n'
                  'Primary luminance: $primaryLuminance, OnBrand luminance: $onBrandLuminance, Contrast: $primaryContrast',
            );

            // Test contrast between screenBackground and textPrimary
            final bgLuminance = theme.screenBackground.computeLuminance();
            final textLuminance = theme.textPrimary.computeLuminance();
            final bgContrast = (bgLuminance - textLuminance).abs();

            expect(
              bgContrast,
              greaterThan(0.3),
              reason:
                  'screenBackground and textPrimary should have sufficient contrast (run $i, seed: 0x${seed.toARGB32().toRadixString(16)})\n'
                  'Background luminance: $bgLuminance, Text luminance: $textLuminance, Contrast: $bgContrast',
            );

            // Test contrast between cardBackground and textOnCard
            final cardLuminance = theme.cardBackground.computeLuminance();
            final onCardLuminance = theme.textOnCard.computeLuminance();
            final cardContrast = (cardLuminance - onCardLuminance).abs();

            expect(
              cardContrast,
              greaterThan(0.3),
              reason:
                  'cardBackground and textOnCard should have sufficient contrast (run $i, seed: 0x${seed.toARGB32().toRadixString(16)})\n'
                  'Card luminance: $cardLuminance, OnCard luminance: $onCardLuminance, Contrast: $cardContrast',
            );
          }
        }
      },
    );

    test(
      'Property 2 Edge Case: Default seed provides sufficient contrast',
      () {
        final lightTheme =
            AppThemeGenerator.lightFromSeed(AppThemeGenerator.defaultSeed);
        final darkTheme =
            AppThemeGenerator.darkFromSeed(AppThemeGenerator.defaultSeed);

        for (final theme in [lightTheme, darkTheme]) {
          // Test brandPrimary contrast
          final primaryLuminance = theme.brandPrimary.computeLuminance();
          final onBrandLuminance = theme.textOnBrand.computeLuminance();
          final primaryContrast = (primaryLuminance - onBrandLuminance).abs();

          expect(
            primaryContrast,
            greaterThan(0.3),
            reason: 'Default seed should provide sufficient contrast',
          );

          // Test screenBackground contrast
          final bgLuminance = theme.screenBackground.computeLuminance();
          final textLuminance = theme.textPrimary.computeLuminance();
          final bgContrast = (bgLuminance - textLuminance).abs();

          expect(
            bgContrast,
            greaterThan(0.3),
            reason: 'Default seed should provide sufficient background contrast',
          );
        }
      },
    );

    test(
      'Property 2 Edge Case: Extreme colors provide sufficient contrast',
      () {
        final extremeColors = [
          Colors.black,
          Colors.white,
          const Color(0xFF000001), // Almost black
          const Color(0xFFFFFFFE), // Almost white
        ];

        for (final seed in extremeColors) {
          final lightTheme = AppThemeGenerator.lightFromSeed(seed);
          final darkTheme = AppThemeGenerator.darkFromSeed(seed);

          for (final theme in [lightTheme, darkTheme]) {
            // Test brandPrimary contrast
            final primaryLuminance = theme.brandPrimary.computeLuminance();
            final onBrandLuminance = theme.textOnBrand.computeLuminance();
            final primaryContrast = (primaryLuminance - onBrandLuminance).abs();

            expect(
              primaryContrast,
              greaterThan(0.3),
              reason:
                  'Extreme color 0x${seed.toARGB32().toRadixString(16)} should provide sufficient contrast',
            );
          }
        }
      },
    );

    test(
      '_getContrastColor returns black for light backgrounds',
      () {
        final lightColors = [
          Colors.white,
          const Color(0xFFF0F0F0),
          const Color(0xFFE0E0E0),
          Colors.yellow,
        ];

        for (final color in lightColors) {
          final lightTheme = AppThemeGenerator.lightFromSeed(color);
          // For light backgrounds, textOnBrand should be dark
          final luminance = lightTheme.brandPrimary.computeLuminance();
          if (luminance > 0.5) {
            expect(
              lightTheme.textOnBrand.computeLuminance(),
              lessThan(0.5),
              reason:
                  'Light background should have dark text (0x${color.toARGB32().toRadixString(16)})',
            );
          }
        }
      },
    );

    test(
      '_getContrastColor returns white for dark backgrounds',
      () {
        final darkColors = [
          Colors.black,
          const Color(0xFF101010),
          const Color(0xFF202020),
          Colors.blue.shade900,
        ];

        for (final color in darkColors) {
          final lightTheme = AppThemeGenerator.lightFromSeed(color);
          // For dark backgrounds, textOnBrand should be light
          final luminance = lightTheme.brandPrimary.computeLuminance();
          if (luminance <= 0.5) {
            expect(
              lightTheme.textOnBrand.computeLuminance(),
              greaterThan(0.5),
              reason:
                  'Dark background should have light text (0x${color.toARGB32().toRadixString(16)})',
            );
          }
        }
      },
    );
  });
}
