import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/theme/app_theme_colors.dart';
import 'package:money_fit/core/theme/app_theme_generator.dart';
import 'package:money_fit/core/providers/theme_provider.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Theme Providers', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('themeSeedColorProvider returns default brown color', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final seedColor = container.read(themeSeedColorProvider);

      expect(seedColor, equals(AppThemeGenerator.defaultSeed));
    });

    test('lightThemeProvider returns light theme with AppThemeColors', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(lightThemeProvider);

      expect(theme.brightness, equals(Brightness.light));
      expect(theme.extension<AppThemeColors>(), isNotNull);
    });

    test('darkThemeProvider returns dark theme with AppThemeColors', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(darkThemeProvider);

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.extension<AppThemeColors>(), isNotNull);
    });

    test('light and dark themes have consistent hue', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final lightTheme = container.read(lightThemeProvider);
      final darkTheme = container.read(darkThemeProvider);

      final lightColors = lightTheme.extension<AppThemeColors>()!;
      final darkColors = darkTheme.extension<AppThemeColors>()!;

      final lightHue = HSLColor.fromColor(lightColors.brandPrimary).hue;
      final darkHue = HSLColor.fromColor(darkColors.brandPrimary).hue;

      expect((lightHue - darkHue).abs(), lessThan(5.0));
    });

    test('light theme has proper component styling', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(lightThemeProvider);

      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.appBarTheme.backgroundColor, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.bottomNavigationBarTheme.type, 
        equals(BottomNavigationBarType.fixed));
    });

    test('dark theme has proper component styling', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(darkThemeProvider);

      expect(theme.elevatedButtonTheme.style, isNotNull);
      expect(theme.appBarTheme.backgroundColor, isNotNull);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.bottomNavigationBarTheme.type, 
        equals(BottomNavigationBarType.fixed));
    });
  });

  group('ThemeModeProvider', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('themeModeProvider returns false by default', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final isDarkMode = container.read(themeModeProvider);

      expect(isDarkMode, isFalse);
    });

    test('toggleDarkMode changes state from false to true', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), isFalse);

      await container.read(themeModeProvider.notifier).toggleDarkMode();

      expect(container.read(themeModeProvider), isTrue);
    });

    test('toggleDarkMode changes state from true to false', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      // First toggle to true
      await container.read(themeModeProvider.notifier).toggleDarkMode();
      expect(container.read(themeModeProvider), isTrue);

      // Toggle back to false
      await container.read(themeModeProvider.notifier).toggleDarkMode();
      expect(container.read(themeModeProvider), isFalse);
    });

    test('setDarkMode sets specific value', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).setDarkMode(true);
      expect(container.read(themeModeProvider), isTrue);

      await container.read(themeModeProvider.notifier).setDarkMode(false);
      expect(container.read(themeModeProvider), isFalse);
    });

    test('dark mode state persists across provider recreations', () async {
      // First container - set dark mode
      final container1 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      
      await container1.read(themeModeProvider.notifier).setDarkMode(true);
      container1.dispose();

      // Second container - should load persisted state
      final container2 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container2.dispose);

      expect(container2.read(themeModeProvider), isTrue);
    });
  });
}