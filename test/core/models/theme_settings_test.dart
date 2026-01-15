// Property-based tests for ThemeSettings
// Feature: theme-system-refactoring
// Tests theme persistence round trip (JSON serialization/deserialization)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/models/theme_settings.dart';

void main() {
  group('ThemeSettings Property Tests', () {
    /// Helper function to generate random colors
    int randomColorValue(Random random) {
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ).toARGB32();
    }

    /// Helper function to generate random font size scale
    double randomFontSizeScale(Random random) {
      final scales = FontSizeOption.validScales;
      return scales[random.nextInt(scales.length)];
    }

    /// Helper function to generate random ThemeSettings
    ThemeSettings randomThemeSettings(Random random) {
      final numFavorites = random.nextInt(10); // 0-9 favorite colors
      final favoriteColors = List.generate(
        numFavorites,
        (_) => randomColorValue(random),
      );

      return ThemeSettings(
        isDarkMode: random.nextBool(),
        colorSeedValue: randomColorValue(random),
        favoriteColors: favoriteColors,
        fontSizeScale: randomFontSizeScale(random),
      );
    }

    test(
      'Property 3: Theme Persistence Round Trip - '
      'For any ThemeSettings, toJson -> fromJson preserves all data',
      () {
        // Feature: theme-system-refactoring, Property 3: Theme Persistence Round Trip
        // Validates: Requirements 3.3, 5.2, 5.3
        final random = Random(42); // Fixed seed for reproducibility
        const numRuns = 100;

        for (int i = 0; i < numRuns; i++) {
          // Generate random theme settings
          final original = randomThemeSettings(random);

          // Serialize to JSON
          final json = original.toJson();

          // Deserialize from JSON
          final restored = ThemeSettings.fromJson(json);

          // Verify all fields are preserved
          expect(
            restored.isDarkMode,
            equals(original.isDarkMode),
            reason: 'isDarkMode should be preserved (run $i)',
          );

          expect(
            restored.colorSeedValue,
            equals(original.colorSeedValue),
            reason: 'colorSeedValue should be preserved (run $i)',
          );

          expect(
            restored.favoriteColors,
            equals(original.favoriteColors),
            reason: 'favoriteColors should be preserved (run $i)',
          );

          expect(
            restored.fontSizeScale,
            equals(original.fontSizeScale),
            reason: 'fontSizeScale should be preserved (run $i)',
          );

          // Verify equality operator works
          expect(
            restored,
            equals(original),
            reason: 'Restored settings should equal original (run $i)',
          );

          // Verify hashCode consistency
          expect(
            restored.hashCode,
            equals(original.hashCode),
            reason: 'Hash codes should match for equal objects (run $i)',
          );
        }
      },
    );

    test(
      'Property 8: Font Size Scale Persistence Round Trip - '
      'For any valid font size scale, saving and loading preserves the value',
      () {
        // Feature: theme-system-refactoring, Property 8: Font Size Scale Persistence Round Trip
        // Validates: Requirements 8.2, 8.3
        const numRuns = 100;
        final random = Random(42);

        for (int i = 0; i < numRuns; i++) {
          final scale = randomFontSizeScale(random);
          
          final original = ThemeSettings(
            isDarkMode: random.nextBool(),
            colorSeedValue: randomColorValue(random),
            favoriteColors: [],
            fontSizeScale: scale,
          );

          final json = original.toJson();
          final restored = ThemeSettings.fromJson(json);

          expect(
            restored.fontSizeScale,
            equals(original.fontSizeScale),
            reason: 'fontSizeScale $scale should be preserved (run $i)',
          );
        }
      },
    );


    test(
      'Property 3 Edge Case: Empty favorite colors list',
      () {
        final settings = const ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [],
          fontSizeScale: 1.0,
        );

        final json = settings.toJson();
        final restored = ThemeSettings.fromJson(json);

        expect(restored, equals(settings));
        expect(restored.favoriteColors, isEmpty);
      },
    );

    test(
      'Property 3 Edge Case: Large favorite colors list',
      () {
        final favoriteColors = List.generate(100, (i) => 0xFF000000 + i);
        final settings = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: 0xFFABCDEF,
          favoriteColors: favoriteColors,
          fontSizeScale: 1.15,
        );

        final json = settings.toJson();
        final restored = ThemeSettings.fromJson(json);

        expect(restored, equals(settings));
        expect(restored.favoriteColors.length, equals(100));
      },
    );

    test(
      'Property 3 Edge Case: Extreme color values',
      () {
        final settings = const ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFFFFFFFF, // White
          favoriteColors: [
            0xFF000000, // Black
            0xFFFFFFFF, // White
            0xFF800000, // Dark red
            0xFF008000, // Dark green
          ],
          fontSizeScale: 0.85,
        );

        final json = settings.toJson();
        final restored = ThemeSettings.fromJson(json);

        expect(restored, equals(settings));
      },
    );

    test(
      'Property 3 Edge Case: Default settings round trip',
      () {
        final settings = ThemeSettings.defaultSettings();

        final json = settings.toJson();
        final restored = ThemeSettings.fromJson(json);

        expect(restored, equals(settings));
        expect(restored.isDarkMode, isFalse);
        expect(restored.colorSeedValue, equals(0xFF825A3D));
        expect(restored.favoriteColors, isEmpty);
        expect(restored.fontSizeScale, equals(1.0));
      },
    );
  });

  group('FontSizeOption Tests', () {
    test('FontSizeOption has correct scale values', () {
      expect(FontSizeOption.small.scale, equals(0.85));
      expect(FontSizeOption.medium.scale, equals(1.0));
      expect(FontSizeOption.large.scale, equals(1.15));
    });

    test('FontSizeOption.fromScale returns correct option', () {
      expect(FontSizeOption.fromScale(0.85), equals(FontSizeOption.small));
      expect(FontSizeOption.fromScale(1.0), equals(FontSizeOption.medium));
      expect(FontSizeOption.fromScale(1.15), equals(FontSizeOption.large));
    });

    test('FontSizeOption.fromScale returns medium for invalid scale', () {
      expect(FontSizeOption.fromScale(0.5), equals(FontSizeOption.medium));
      expect(FontSizeOption.fromScale(2.0), equals(FontSizeOption.medium));
      expect(FontSizeOption.fromScale(0.9), equals(FontSizeOption.medium));
    });

    test('FontSizeOption.isValidScale validates correctly', () {
      expect(FontSizeOption.isValidScale(0.85), isTrue);
      expect(FontSizeOption.isValidScale(1.0), isTrue);
      expect(FontSizeOption.isValidScale(1.15), isTrue);
      expect(FontSizeOption.isValidScale(0.5), isFalse);
      expect(FontSizeOption.isValidScale(2.0), isFalse);
    });

    test('FontSizeOption.validScales contains all valid values', () {
      expect(FontSizeOption.validScales, containsAll([0.85, 1.0, 1.15]));
      expect(FontSizeOption.validScales.length, equals(3));
    });
  });

  group('ThemeSettings JSON Robustness Tests', () {
    test(
      'fromJson handles missing fields with defaults',
      () {
        // Empty JSON
        final settings1 = ThemeSettings.fromJson({});
        expect(settings1.isDarkMode, isFalse);
        expect(settings1.colorSeedValue, equals(0xFF825A3D));
        expect(settings1.favoriteColors, isEmpty);
        expect(settings1.fontSizeScale, equals(1.0));

        // Partial JSON
        final settings2 = ThemeSettings.fromJson({'isDarkMode': true});
        expect(settings2.isDarkMode, isTrue);
        expect(settings2.colorSeedValue, equals(0xFF825A3D));
        expect(settings2.favoriteColors, isEmpty);
        expect(settings2.fontSizeScale, equals(1.0));

        // Another partial JSON
        final settings3 = ThemeSettings.fromJson({
          'colorSeedValue': 0xFF123456,
        });
        expect(settings3.isDarkMode, isFalse);
        expect(settings3.colorSeedValue, equals(0xFF123456));
        expect(settings3.favoriteColors, isEmpty);
        expect(settings3.fontSizeScale, equals(1.0));
      },
    );

    test(
      'fromJson handles null values gracefully',
      () {
        final json = {
          'isDarkMode': null,
          'colorSeedValue': null,
          'favoriteColors': null,
          'fontSizeScale': null,
        };

        final settings = ThemeSettings.fromJson(json);

        expect(settings.isDarkMode, isFalse);
        expect(settings.colorSeedValue, equals(0xFF825A3D));
        expect(settings.favoriteColors, isEmpty);
        expect(settings.fontSizeScale, equals(1.0));
      },
    );

    test(
      'fromJson handles invalid fontSizeScale values',
      () {
        // Invalid scale value should default to 1.0
        final json1 = {
          'isDarkMode': false,
          'colorSeedValue': 0xFF123456,
          'favoriteColors': <int>[],
          'fontSizeScale': 0.5, // Invalid
        };
        final settings1 = ThemeSettings.fromJson(json1);
        expect(settings1.fontSizeScale, equals(1.0));

        // String value should default to 1.0
        final json2 = {
          'isDarkMode': false,
          'colorSeedValue': 0xFF123456,
          'favoriteColors': <int>[],
          'fontSizeScale': 'large', // Invalid type
        };
        final settings2 = ThemeSettings.fromJson(json2);
        expect(settings2.fontSizeScale, equals(1.0));
      },
    );

    test(
      'fromJson handles invalid favoriteColors types',
      () {
        // Non-list favoriteColors
        final json1 = {
          'isDarkMode': false,
          'colorSeedValue': 0xFF123456,
          'favoriteColors': 'invalid',
        };

        final settings1 = ThemeSettings.fromJson(json1);
        expect(settings1.favoriteColors, isEmpty);

        // Mixed type list
        final json2 = {
          'isDarkMode': false,
          'colorSeedValue': 0xFF123456,
          'favoriteColors': [0xFF000000, 'invalid', 0xFF111111],
        };

        // This should not throw, but may filter out invalid entries
        expect(() => ThemeSettings.fromJson(json2), returnsNormally);
      },
    );
  });


  group('ThemeSettings Utility Methods Tests', () {
    test(
      'colorSeed getter returns correct Color object',
      () {
        const settings = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: 0xFF825A3D,
          favoriteColors: [],
        );

        final color = settings.colorSeed;
        expect(color.toARGB32(), equals(0xFF825A3D));
        expect((color.a * 255.0).round() & 0xff, equals(255));
        expect((color.r * 255.0).round() & 0xff, equals(0x82));
        expect((color.g * 255.0).round() & 0xff, equals(0x5A));
        expect((color.b * 255.0).round() & 0xff, equals(0x3D));
      },
    );

    test(
      'favoriteColorObjects getter returns correct Color list',
      () {
        const settings = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: 0xFF000000,
          favoriteColors: [
            0xFFFF0000, // Red
            0xFF00FF00, // Green
            0xFF0000FF, // Blue
          ],
        );

        final colors = settings.favoriteColorObjects;
        expect(colors.length, equals(3));
        expect(colors[0], equals(const Color(0xFFFF0000)));
        expect(colors[1], equals(const Color(0xFF00FF00)));
        expect(colors[2], equals(const Color(0xFF0000FF)));
      },
    );

    test(
      'fontSizeOption getter returns correct FontSizeOption',
      () {
        const settingsSmall = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: 0xFF000000,
          favoriteColors: [],
          fontSizeScale: 0.85,
        );
        expect(settingsSmall.fontSizeOption, equals(FontSizeOption.small));

        const settingsMedium = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: 0xFF000000,
          favoriteColors: [],
          fontSizeScale: 1.0,
        );
        expect(settingsMedium.fontSizeOption, equals(FontSizeOption.medium));

        const settingsLarge = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: 0xFF000000,
          favoriteColors: [],
          fontSizeScale: 1.15,
        );
        expect(settingsLarge.fontSizeOption, equals(FontSizeOption.large));
      },
    );

    test(
      'copyWith creates new instance with updated values',
      () {
        const original = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000],
          fontSizeScale: 1.0,
        );

        // Update isDarkMode only
        final updated1 = original.copyWith(isDarkMode: true);
        expect(updated1.isDarkMode, isTrue);
        expect(updated1.colorSeedValue, equals(0xFF123456));
        expect(updated1.favoriteColors, equals([0xFF000000]));
        expect(updated1.fontSizeScale, equals(1.0));

        // Update colorSeedValue only
        final updated2 = original.copyWith(colorSeedValue: 0xFFABCDEF);
        expect(updated2.isDarkMode, isFalse);
        expect(updated2.colorSeedValue, equals(0xFFABCDEF));
        expect(updated2.favoriteColors, equals([0xFF000000]));
        expect(updated2.fontSizeScale, equals(1.0));

        // Update favoriteColors only
        final updated3 = original.copyWith(favoriteColors: [0xFF111111, 0xFF222222]);
        expect(updated3.isDarkMode, isFalse);
        expect(updated3.colorSeedValue, equals(0xFF123456));
        expect(updated3.favoriteColors, equals([0xFF111111, 0xFF222222]));
        expect(updated3.fontSizeScale, equals(1.0));

        // Update fontSizeScale only
        final updated4 = original.copyWith(fontSizeScale: 1.15);
        expect(updated4.isDarkMode, isFalse);
        expect(updated4.colorSeedValue, equals(0xFF123456));
        expect(updated4.favoriteColors, equals([0xFF000000]));
        expect(updated4.fontSizeScale, equals(1.15));

        // Update all fields
        final updated5 = original.copyWith(
          isDarkMode: true,
          colorSeedValue: 0xFFFFFFFF,
          favoriteColors: [],
          fontSizeScale: 0.85,
        );
        expect(updated5.isDarkMode, isTrue);
        expect(updated5.colorSeedValue, equals(0xFFFFFFFF));
        expect(updated5.favoriteColors, isEmpty);
        expect(updated5.fontSizeScale, equals(0.85));
      },
    );

    test(
      'copyWith with no parameters returns equal instance',
      () {
        const original = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000],
          fontSizeScale: 1.15,
        );

        final copy = original.copyWith();
        expect(copy, equals(original));
        expect(copy.hashCode, equals(original.hashCode));
      },
    );

    test(
      'toString provides readable representation',
      () {
        const settings = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF825A3D,
          favoriteColors: [0xFFFF0000, 0xFF00FF00],
          fontSizeScale: 1.15,
        );

        final str = settings.toString();
        expect(str, contains('isDarkMode: true'));
        expect(str, contains('0x${0xFF825A3D.toRadixString(16)}'));
        expect(str, contains('fontSizeScale: 1.15'));
        expect(str, contains('0x${0xFFFF0000.toRadixString(16)}'));
        expect(str, contains('0x${0xFF00FF00.toRadixString(16)}'));
      },
    );
  });

  group('ThemeSettings Equality Tests', () {
    test(
      'Equality operator works correctly',
      () {
        const settings1 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000, 0xFF111111],
          fontSizeScale: 1.0,
        );

        const settings2 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000, 0xFF111111],
          fontSizeScale: 1.0,
        );

        const settings3 = ThemeSettings(
          isDarkMode: false, // Different
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000, 0xFF111111],
          fontSizeScale: 1.0,
        );

        const settings4 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000, 0xFF111111],
          fontSizeScale: 1.15, // Different
        );

        expect(settings1, equals(settings2));
        expect(settings1, isNot(equals(settings3)));
        expect(settings1, isNot(equals(settings4)));
        expect(settings1 == settings1, isTrue); // Identical
      },
    );

    test(
      'Equality handles different favorite colors order',
      () {
        const settings1 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000, 0xFF111111],
        );

        const settings2 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF111111, 0xFF000000], // Different order
        );

        expect(settings1, isNot(equals(settings2)));
      },
    );

    test(
      'Equality handles different favorite colors length',
      () {
        const settings1 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000],
        );

        const settings2 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFF123456,
          favoriteColors: [0xFF000000, 0xFF111111], // More items
        );

        expect(settings1, isNot(equals(settings2)));
      },
    );
  });
}
