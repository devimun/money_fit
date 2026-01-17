// Property-based tests for AppThemeColors
// Feature: theme-system-refactoring, Property 6: Lerp Interpolation Bounds
// Validates: Requirements 1.6
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/theme/app_theme_colors.dart';

void main() {
  group('AppThemeColors Property Tests', () {
    /// Helper function to create a random AppThemeColors instance
    AppThemeColors createRandomTheme(Random random) {
      Color randomColor() => Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

      return AppThemeColors(
        brandPrimary: randomColor(),
        brandSecondary: randomColor(),
        error: randomColor(),
        screenBackground: randomColor(),
        cardBackground: randomColor(),
        inputBackground: randomColor(),
        calendarCellBackground: randomColor(),
        selectedButtonBackground: randomColor(),
        textPrimary: randomColor(),
        textSecondary: randomColor(),
        textOnBrand: randomColor(),
        textOnCard: randomColor(),
        border: randomColor(),
        divider: randomColor(),
        borderFocused: randomColor(),
        navUnselected: randomColor(),
        navSelected: randomColor(),
        switchActive: randomColor(),
        switchInactiveTrack: randomColor(),
        overlay: randomColor(),
        budgetProgress: randomColor(),
      );
    }

    /// Helper function to check if a color is between two other colors
    bool isColorBetween(Color result, Color start, Color end, double t) {
      // For t=0, result should equal start
      if (t == 0.0) {
        return result.toARGB32() == start.toARGB32();
      }
      // For t=1, result should equal end
      if (t == 1.0) {
        return result.toARGB32() == end.toARGB32();
      }

      // For 0 < t < 1, each component should be between start and end
      final rMin = min((start.r * 255.0).round() & 0xff, (end.r * 255.0).round() & 0xff);
      final rMax = max((start.r * 255.0).round() & 0xff, (end.r * 255.0).round() & 0xff);
      final gMin = min((start.g * 255.0).round() & 0xff, (end.g * 255.0).round() & 0xff);
      final gMax = max((start.g * 255.0).round() & 0xff, (end.g * 255.0).round() & 0xff);
      final bMin = min((start.b * 255.0).round() & 0xff, (end.b * 255.0).round() & 0xff);
      final bMax = max((start.b * 255.0).round() & 0xff, (end.b * 255.0).round() & 0xff);
      final aMin = min((start.a * 255.0).round() & 0xff, (end.a * 255.0).round() & 0xff);
      final aMax = max((start.a * 255.0).round() & 0xff, (end.a * 255.0).round() & 0xff);

      final resultR = (result.r * 255.0).round() & 0xff;
      final resultG = (result.g * 255.0).round() & 0xff;
      final resultB = (result.b * 255.0).round() & 0xff;
      final resultA = (result.a * 255.0).round() & 0xff;

      return resultR >= rMin &&
          resultR <= rMax &&
          resultG >= gMin &&
          resultG <= gMax &&
          resultB >= bMin &&
          resultB <= bMax &&
          resultA >= aMin &&
          resultA <= aMax;
    }

    test(
      'Property 6: Lerp Interpolation Bounds - '
      'For any two AppThemeColors and t in [0,1], '
      'lerp returns colors between the two inputs',
      () {
        final random = Random(42); // Fixed seed for reproducibility
        const numRuns = 100;

        for (int i = 0; i < numRuns; i++) {
          // Generate two random themes
          final theme1 = createRandomTheme(random);
          final theme2 = createRandomTheme(random);

          // Test multiple interpolation values
          final tValues = [
            0.0,
            0.25,
            0.5,
            0.75,
            1.0,
            random.nextDouble(),
          ];

          for (final t in tValues) {
            final result = theme1.lerp(theme2, t);

            // Verify all color properties are properly interpolated
            expect(
              isColorBetween(
                  result.brandPrimary, theme1.brandPrimary, theme2.brandPrimary, t),
              isTrue,
              reason:
                  'brandPrimary should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.brandSecondary, theme1.brandSecondary,
                  theme2.brandSecondary, t),
              isTrue,
              reason:
                  'brandSecondary should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.error, theme1.error, theme2.error, t),
              isTrue,
              reason: 'error should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.screenBackground, theme1.screenBackground,
                  theme2.screenBackground, t),
              isTrue,
              reason:
                  'screenBackground should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.cardBackground, theme1.cardBackground,
                  theme2.cardBackground, t),
              isTrue,
              reason:
                  'cardBackground should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.inputBackground, theme1.inputBackground,
                  theme2.inputBackground, t),
              isTrue,
              reason:
                  'inputBackground should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.calendarCellBackground,
                  theme1.calendarCellBackground,
                  theme2.calendarCellBackground,
                  t),
              isTrue,
              reason:
                  'calendarCellBackground should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.selectedButtonBackground,
                  theme1.selectedButtonBackground,
                  theme2.selectedButtonBackground,
                  t),
              isTrue,
              reason:
                  'selectedButtonBackground should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.textPrimary, theme1.textPrimary, theme2.textPrimary, t),
              isTrue,
              reason:
                  'textPrimary should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.textSecondary, theme1.textSecondary,
                  theme2.textSecondary, t),
              isTrue,
              reason:
                  'textSecondary should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.textOnBrand, theme1.textOnBrand, theme2.textOnBrand, t),
              isTrue,
              reason:
                  'textOnBrand should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.textOnCard, theme1.textOnCard, theme2.textOnCard, t),
              isTrue,
              reason:
                  'textOnCard should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.border, theme1.border, theme2.border, t),
              isTrue,
              reason: 'border should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.divider, theme1.divider, theme2.divider, t),
              isTrue,
              reason: 'divider should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.borderFocused, theme1.borderFocused,
                  theme2.borderFocused, t),
              isTrue,
              reason:
                  'borderFocused should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.navUnselected, theme1.navUnselected,
                  theme2.navUnselected, t),
              isTrue,
              reason:
                  'navUnselected should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.navSelected, theme1.navSelected, theme2.navSelected, t),
              isTrue,
              reason:
                  'navSelected should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.switchActive, theme1.switchActive, theme2.switchActive, t),
              isTrue,
              reason:
                  'switchActive should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(
                  result.switchInactiveTrack,
                  theme1.switchInactiveTrack,
                  theme2.switchInactiveTrack,
                  t),
              isTrue,
              reason:
                  'switchInactiveTrack should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.overlay, theme1.overlay, theme2.overlay, t),
              isTrue,
              reason: 'overlay should be between start and end at t=$t (run $i)',
            );

            expect(
              isColorBetween(result.budgetProgress, theme1.budgetProgress,
                  theme2.budgetProgress, t),
              isTrue,
              reason:
                  'budgetProgress should be between start and end at t=$t (run $i)',
            );
          }
        }
      },
    );

    test('Lerp boundary conditions - t=0 returns first theme', () {
      final theme1 = AppThemeColors(
        brandPrimary: const Color(0xFF825A3D),
        brandSecondary: const Color(0xFF6B7280),
        error: const Color(0xFFEF4444),
        screenBackground: const Color(0xFFF8F8F8),
        cardBackground: Colors.white,
        inputBackground: const Color(0xFFF8F8F8),
        calendarCellBackground: const Color(0xFFF3F4F6),
        selectedButtonBackground: const Color(0xFF825A3D),
        textPrimary: Colors.black,
        textSecondary: const Color(0xFF6B7280),
        textOnBrand: Colors.white,
        textOnCard: Colors.black,
        border: const Color(0xFFE5E7EB),
        divider: const Color(0xFF6B7280),
        borderFocused: const Color(0xFF825A3D),
        navUnselected: const Color(0xFF6B7280),
        navSelected: const Color(0xFF825A3D),
        switchActive: const Color(0xFF825A3D),
        switchInactiveTrack: const Color(0xFFE0E0E0),
        overlay: Colors.black.withValues(alpha: 0.3),
        budgetProgress: const Color(0xFF825A3D),
      );

      final theme2 = AppThemeColors(
        brandPrimary: const Color(0xFFB8956B),
        brandSecondary: const Color(0xFF9CA3AF),
        error: const Color(0xFFF87171),
        screenBackground: const Color(0xFF111827),
        cardBackground: const Color(0xFF1F2937),
        inputBackground: const Color(0xFF1F2937),
        calendarCellBackground: const Color(0xFF374151),
        selectedButtonBackground: const Color(0xFFB8956B),
        textPrimary: const Color(0xFFF9FAFB),
        textSecondary: const Color(0xFFD1D5DB),
        textOnBrand: const Color(0xFF111827),
        textOnCard: const Color(0xFFF9FAFB),
        border: const Color(0xFF374151),
        divider: const Color(0xFF9CA3AF),
        borderFocused: const Color(0xFFB8956B),
        navUnselected: const Color(0xFF9CA3AF),
        navSelected: const Color(0xFFB8956B),
        switchActive: const Color(0xFFB8956B),
        switchInactiveTrack: const Color(0xFF4B5563),
        overlay: Colors.black.withValues(alpha: 0.3),
        budgetProgress: const Color(0xFFB8956B),
      );

      final result = theme1.lerp(theme2, 0.0);

      expect(result.brandPrimary, equals(theme1.brandPrimary));
      expect(result.textPrimary, equals(theme1.textPrimary));
      expect(result.screenBackground, equals(theme1.screenBackground));
    });

    test('Lerp boundary conditions - t=1 returns second theme', () {
      final theme1 = AppThemeColors(
        brandPrimary: const Color(0xFF825A3D),
        brandSecondary: const Color(0xFF6B7280),
        error: const Color(0xFFEF4444),
        screenBackground: const Color(0xFFF8F8F8),
        cardBackground: Colors.white,
        inputBackground: const Color(0xFFF8F8F8),
        calendarCellBackground: const Color(0xFFF3F4F6),
        selectedButtonBackground: const Color(0xFF825A3D),
        textPrimary: Colors.black,
        textSecondary: const Color(0xFF6B7280),
        textOnBrand: Colors.white,
        textOnCard: Colors.black,
        border: const Color(0xFFE5E7EB),
        divider: const Color(0xFF6B7280),
        borderFocused: const Color(0xFF825A3D),
        navUnselected: const Color(0xFF6B7280),
        navSelected: const Color(0xFF825A3D),
        switchActive: const Color(0xFF825A3D),
        switchInactiveTrack: const Color(0xFFE0E0E0),
        overlay: Colors.black.withValues(alpha: 0.3),
        budgetProgress: const Color(0xFF825A3D),
      );

      final theme2 = AppThemeColors(
        brandPrimary: const Color(0xFFB8956B),
        brandSecondary: const Color(0xFF9CA3AF),
        error: const Color(0xFFF87171),
        screenBackground: const Color(0xFF111827),
        cardBackground: const Color(0xFF1F2937),
        inputBackground: const Color(0xFF1F2937),
        calendarCellBackground: const Color(0xFF374151),
        selectedButtonBackground: const Color(0xFFB8956B),
        textPrimary: const Color(0xFFF9FAFB),
        textSecondary: const Color(0xFFD1D5DB),
        textOnBrand: const Color(0xFF111827),
        textOnCard: const Color(0xFFF9FAFB),
        border: const Color(0xFF374151),
        divider: const Color(0xFF9CA3AF),
        borderFocused: const Color(0xFFB8956B),
        navUnselected: const Color(0xFF9CA3AF),
        navSelected: const Color(0xFFB8956B),
        switchActive: const Color(0xFFB8956B),
        switchInactiveTrack: const Color(0xFF4B5563),
        overlay: Colors.black.withValues(alpha: 0.3),
        budgetProgress: const Color(0xFFB8956B),
      );

      final result = theme1.lerp(theme2, 1.0);

      expect(result.brandPrimary, equals(theme2.brandPrimary));
      expect(result.textPrimary, equals(theme2.textPrimary));
      expect(result.screenBackground, equals(theme2.screenBackground));
    });

    test('copyWith creates new instance with updated values', () {
      final original = AppThemeColors(
        brandPrimary: const Color(0xFF825A3D),
        brandSecondary: const Color(0xFF6B7280),
        error: const Color(0xFFEF4444),
        screenBackground: const Color(0xFFF8F8F8),
        cardBackground: Colors.white,
        inputBackground: const Color(0xFFF8F8F8),
        calendarCellBackground: const Color(0xFFF3F4F6),
        selectedButtonBackground: const Color(0xFF825A3D),
        textPrimary: Colors.black,
        textSecondary: const Color(0xFF6B7280),
        textOnBrand: Colors.white,
        textOnCard: Colors.black,
        border: const Color(0xFFE5E7EB),
        divider: const Color(0xFF6B7280),
        borderFocused: const Color(0xFF825A3D),
        navUnselected: const Color(0xFF6B7280),
        navSelected: const Color(0xFF825A3D),
        switchActive: const Color(0xFF825A3D),
        switchInactiveTrack: const Color(0xFFE0E0E0),
        overlay: Colors.black.withValues(alpha: 0.3),
        budgetProgress: const Color(0xFF825A3D),
      );

      final updated = original.copyWith(
        brandPrimary: const Color(0xFF123456),
        textPrimary: const Color(0xFF654321),
      );

      expect(updated.brandPrimary, equals(const Color(0xFF123456)));
      expect(updated.textPrimary, equals(const Color(0xFF654321)));
      expect(updated.brandSecondary, equals(original.brandSecondary));
      expect(updated.screenBackground, equals(original.screenBackground));
    });
  });
}
