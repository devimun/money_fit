/// BuildContext extensions for convenient theme access
/// Provides shorthand getters for AppThemeColors, TextTheme, and brightness
library;

import 'package:flutter/material.dart';
import 'app_theme_colors.dart';
import 'app_theme_generator.dart';

extension ThemeExtensions on BuildContext {
  /// Access AppThemeColors from the current theme
  /// 
  /// Returns the custom theme colors defined in AppThemeColors.
  /// If AppThemeColors is not found in the theme, returns a default light theme.
  /// 
  /// Usage:
  /// ```dart
  /// Container(
  ///   color: context.colors.brandPrimary,
  ///   child: Text('Hello', style: TextStyle(color: context.colors.textOnBrand)),
  /// )
  /// ```
  /// 
  /// Migration from LightAppColors/DarkAppColors:
  /// - LightAppColors.primary → context.colors.brandPrimary
  /// - LightAppColors.background → context.colors.screenBackground
  /// - LightAppColors.textPrimary → context.colors.textPrimary
  /// 
  /// See design.md Migration Guide for complete mapping.
  AppThemeColors get colors {
    final themeColors = Theme.of(this).extension<AppThemeColors>();
    
    // Null safety: provide default theme if extension is missing
    if (themeColors == null) {
      debugPrint('Warning: AppThemeColors not found in theme, using default');
      return AppThemeGenerator.lightFromSeed(AppThemeGenerator.defaultSeed);
    }
    
    return themeColors;
  }
  
  /// Alias for [colors] - Access AppThemeColors from the current theme
  /// 
  /// Both `context.theme` and `context.colors` are valid and equivalent.
  /// Use whichever feels more natural in your code.
  AppThemeColors get theme => colors;
  
  /// Access TextTheme from the current theme
  /// 
  /// Provides convenient access to text styles defined in the theme.
  /// 
  /// Usage:
  /// ```dart
  /// Text('Title', style: context.textTheme.displayLarge)
  /// ```
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get the current brightness (light or dark)
  /// 
  /// Returns Brightness.light or Brightness.dark based on the current theme.
  /// 
  /// Usage:
  /// ```dart
  /// if (context.brightness == Brightness.dark) {
  ///   // Dark mode specific logic
  /// }
  /// ```
  Brightness get brightness => Theme.of(this).brightness;
  
  /// Check if the current theme is in dark mode
  /// 
  /// Returns true if the current theme brightness is dark, false otherwise.
  /// 
  /// Usage:
  /// ```dart
  /// if (context.isDarkMode) {
  ///   // Show dark mode specific UI
  /// }
  /// ```
  bool get isDarkMode => brightness == Brightness.dark;

  /// Get a standard card/box decoration with shadow
  /// 
  /// Provides a consistent BoxDecoration for cards and containers.
  /// Automatically adjusts shadow opacity for dark mode.
  /// 
  /// Usage:
  /// ```dart
  /// Container(
  ///   decoration: context.boxDecoration,
  ///   child: ...
  /// )
  /// ```
  BoxDecoration get boxDecoration {
    return BoxDecoration(
      color: colors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.25),
          blurRadius: 4,
          offset: const Offset(1, 1),
        ),
      ],
    );
  }
}

/// ThemeData extensions for adding AppThemeColors
extension ThemeDataExtensions on ThemeData {
  /// Add AppThemeColors extension to ThemeData
  /// 
  /// This method creates a new ThemeData with the AppThemeColors extension added.
  /// 
  /// Usage:
  /// ```dart
  /// final theme = ThemeData.light().withAppColors(myColors);
  /// ```
  ThemeData withAppColors(AppThemeColors colors) {
    return copyWith(
      extensions: [
        ...extensions.values.where((e) => e is! AppThemeColors),
        colors,
      ],
    );
  }
  
  /// Get AppThemeColors from ThemeData
  /// 
  /// Throws StateError if AppThemeColors is not found.
  /// Use this when you're certain the extension exists.
  /// 
  /// Usage:
  /// ```dart
  /// final colors = theme.appColors;
  /// ```
  AppThemeColors get appColors {
    final colors = extension<AppThemeColors>();
    if (colors == null) {
      throw StateError('AppThemeColors not found in theme extensions');
    }
    return colors;
  }
}
