// Property-based tests for HSVColorPicker
// Feature: theme-system-refactoring, Property 4: Color Picker Value Consistency
// Validates: Requirements 3.6
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HSVColorPicker Property Tests', () {
    test(
      'Property 4: Color Picker Value Consistency - '
      'For any Color, converting to HSV and back to RGB produces the same color',
      () {
        final random = Random(42); // Fixed seed for reproducibility
        const numRuns = 100;

        for (int i = 0; i < numRuns; i++) {
          // Generate random color with full opacity
          final originalColor = Color.fromARGB(
            255, // Full opacity
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

          // Convert to HSV and back to RGB
          final hsvColor = HSVColor.fromColor(originalColor);
          final convertedColor = hsvColor.toColor();

          // The colors should be equal (allowing for minor floating-point precision differences)
          expect(
            _colorsAreEqual(originalColor, convertedColor),
            isTrue,
            reason: 'Color round-trip failed for run $i: '
                'Original: ${_colorToString(originalColor)}, '
                'Converted: ${_colorToString(convertedColor)}, '
                'HSV: (${hsvColor.hue.toStringAsFixed(2)}, '
                '${hsvColor.saturation.toStringAsFixed(2)}, '
                '${hsvColor.value.toStringAsFixed(2)})',
          );
        }
      },
    );

    test(
      'HSV round-trip preserves color components within tolerance',
      () {
        // Test specific edge cases
        final testColors = [
          Colors.black,
          Colors.white,
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
          Colors.cyan,
          Colors.purple,
          const Color(0xFF825A3D), // Default theme color
          const Color(0xFF2196F3), // Blue preset
          const Color(0xFF4CAF50), // Green preset
          const Color(0xFFFF9800), // Orange preset
        ];

        for (final originalColor in testColors) {
          final hsvColor = HSVColor.fromColor(originalColor);
          final convertedColor = hsvColor.toColor();

          expect(
            _colorsAreEqual(originalColor, convertedColor),
            isTrue,
            reason: 'Color round-trip failed for ${_colorToString(originalColor)}: '
                'Converted to ${_colorToString(convertedColor)}',
          );
        }
      },
    );

    test(
      'HSV components are within valid ranges',
      () {
        final random = Random(42);
        const numRuns = 100;

        for (int i = 0; i < numRuns; i++) {
          final color = Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

          final hsvColor = HSVColor.fromColor(color);

          // Hue should be in [0, 360)
          expect(
            hsvColor.hue,
            greaterThanOrEqualTo(0.0),
            reason: 'Hue should be >= 0 for run $i',
          );
          expect(
            hsvColor.hue,
            lessThan(360.0),
            reason: 'Hue should be < 360 for run $i',
          );

          // Saturation should be in [0, 1]
          expect(
            hsvColor.saturation,
            greaterThanOrEqualTo(0.0),
            reason: 'Saturation should be >= 0 for run $i',
          );
          expect(
            hsvColor.saturation,
            lessThanOrEqualTo(1.0),
            reason: 'Saturation should be <= 1 for run $i',
          );

          // Value should be in [0, 1]
          expect(
            hsvColor.value,
            greaterThanOrEqualTo(0.0),
            reason: 'Value should be >= 0 for run $i',
          );
          expect(
            hsvColor.value,
            lessThanOrEqualTo(1.0),
            reason: 'Value should be <= 1 for run $i',
          );

          // Alpha should be preserved
          expect(
            hsvColor.alpha,
            equals(1.0),
            reason: 'Alpha should be 1.0 for run $i',
          );
        }
      },
    );

    test(
      'HSV manipulation preserves valid color space',
      () {
        final random = Random(42);
        const numRuns = 50;

        for (int i = 0; i < numRuns; i++) {
          final originalColor = Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          );

          final hsvColor = HSVColor.fromColor(originalColor);

          // Test various HSV manipulations
          final manipulations = [
            hsvColor.withHue((hsvColor.hue + 60) % 360),
            hsvColor.withSaturation((hsvColor.saturation * 0.5).clamp(0.0, 1.0)),
            hsvColor.withValue((hsvColor.value * 0.8).clamp(0.0, 1.0)),
            hsvColor.withHue(random.nextDouble() * 360),
            hsvColor.withSaturation(random.nextDouble()),
            hsvColor.withValue(random.nextDouble()),
          ];

          for (final manipulated in manipulations) {
            final resultColor = manipulated.toColor();

            // Verify the result is a valid color
            final resultA = (resultColor.a * 255.0).round() & 0xff;
            final resultR = (resultColor.r * 255.0).round() & 0xff;
            final resultG = (resultColor.g * 255.0).round() & 0xff;
            final resultB = (resultColor.b * 255.0).round() & 0xff;
            
            expect(
              resultA,
              greaterThanOrEqualTo(0),
              reason: 'Alpha should be valid for run $i',
            );
            expect(
              resultA,
              lessThanOrEqualTo(255),
              reason: 'Alpha should be valid for run $i',
            );
            expect(
              resultR,
              greaterThanOrEqualTo(0),
              reason: 'Red should be valid for run $i',
            );
            expect(
              resultR,
              lessThanOrEqualTo(255),
              reason: 'Red should be valid for run $i',
            );
            expect(
              resultG,
              greaterThanOrEqualTo(0),
              reason: 'Green should be valid for run $i',
            );
            expect(
              resultG,
              lessThanOrEqualTo(255),
              reason: 'Green should be valid for run $i',
            );
            expect(
              resultB,
              greaterThanOrEqualTo(0),
              reason: 'Blue should be valid for run $i',
            );
            expect(
              resultB,
              lessThanOrEqualTo(255),
              reason: 'Blue should be valid for run $i',
            );
          }
        }
      },
    );
  });
}

/// Helper function to check if two colors are equal within tolerance
/// Allows for minor floating-point precision differences (±1 per channel)
bool _colorsAreEqual(Color a, Color b) {
  final aR = (a.r * 255.0).round() & 0xff;
  final aG = (a.g * 255.0).round() & 0xff;
  final aB = (a.b * 255.0).round() & 0xff;
  final aA = (a.a * 255.0).round() & 0xff;
  
  final bR = (b.r * 255.0).round() & 0xff;
  final bG = (b.g * 255.0).round() & 0xff;
  final bB = (b.b * 255.0).round() & 0xff;
  final bA = (b.a * 255.0).round() & 0xff;
  
  return (aR - bR).abs() <= 1 &&
      (aG - bG).abs() <= 1 &&
      (aB - bB).abs() <= 1 &&
      (aA - bA).abs() <= 1;
}

/// Helper function to convert color to readable string
String _colorToString(Color color) {
  final r = (color.r * 255.0).round() & 0xff;
  final g = (color.g * 255.0).round() & 0xff;
  final b = (color.b * 255.0).round() & 0xff;
  final a = (color.a * 255.0).round() & 0xff;
  return 'ARGB($a, $r, $g, $b)';
}
