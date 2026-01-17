/// ThemeSettings - Data model for persisting theme preferences
/// Stores dark mode state, color seed, favorite colors, and font size scale
library;

import 'package:flutter/material.dart';

/// Font size scale options
/// - Small: 0.85 (85% of base size)
/// - Medium: 1.0 (100% - default)
/// - Large: 1.15 (115% of base size)
enum FontSizeOption {
  small(0.85, 'Small'),
  medium(1.0, 'Medium'),
  large(1.15, 'Large');

  const FontSizeOption(this.scale, this.label);
  final double scale;
  final String label;

  /// Find option by scale value
  static FontSizeOption fromScale(double scale) {
    return FontSizeOption.values.firstWhere(
      (option) => option.scale == scale,
      orElse: () => FontSizeOption.medium,
    );
  }

  /// Valid scale values
  static const List<double> validScales = [0.85, 1.0, 1.15];

  /// Check if a scale value is valid
  static bool isValidScale(double scale) => validScales.contains(scale);
}

/// Theme settings data model for persistence
/// 
/// Stores user's theme preferences including:
/// - Dark mode state
/// - Selected color seed value
/// - List of favorite colors
/// - Font size scale
class ThemeSettings {
  /// Whether dark mode is enabled
  final bool isDarkMode;

  /// Color seed value (ARGB format)
  final int colorSeedValue;

  /// List of favorite color values (ARGB format)
  final List<int> favoriteColors;

  /// Font size scale (0.85, 1.0, or 1.15)
  final double fontSizeScale;

  const ThemeSettings({
    required this.isDarkMode,
    required this.colorSeedValue,
    required this.favoriteColors,
    this.fontSizeScale = 1.0,
  });

  /// Default theme settings
  /// - Light mode
  /// - Default brown color (0xFF825A3D)
  /// - Empty favorites list
  /// - Medium font size (1.0)
  factory ThemeSettings.defaultSettings() {
    return const ThemeSettings(
      isDarkMode: false,
      colorSeedValue: 0xFF825A3D, // Default brown from AppThemeGenerator
      favoriteColors: [],
      fontSizeScale: 1.0,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'colorSeedValue': colorSeedValue,
      'favoriteColors': favoriteColors,
      'fontSizeScale': fontSizeScale,
    };
  }

  /// Create from JSON
  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    // Safely parse favoriteColors
    List<int> parsedFavorites = [];
    final favoritesJson = json['favoriteColors'];
    if (favoritesJson is List) {
      parsedFavorites = favoritesJson
          .whereType<int>() // Filter only int values
          .toList();
    }

    // Safely parse fontSizeScale with validation
    double parsedFontSize = 1.0;
    final fontSizeJson = json['fontSizeScale'];
    if (fontSizeJson is num) {
      final scale = fontSizeJson.toDouble();
      parsedFontSize = FontSizeOption.isValidScale(scale) ? scale : 1.0;
    }

    return ThemeSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      colorSeedValue: json['colorSeedValue'] as int? ?? 0xFF825A3D,
      favoriteColors: parsedFavorites,
      fontSizeScale: parsedFontSize,
    );
  }

  /// Get color seed as Color object
  Color get colorSeed => Color(colorSeedValue);

  /// Get favorite colors as Color objects
  List<Color> get favoriteColorObjects =>
      favoriteColors.map((value) => Color(value)).toList();

  /// Get current font size option
  FontSizeOption get fontSizeOption => FontSizeOption.fromScale(fontSizeScale);

  /// Create a copy with updated values
  ThemeSettings copyWith({
    bool? isDarkMode,
    int? colorSeedValue,
    List<int>? favoriteColors,
    double? fontSizeScale,
  }) {
    return ThemeSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      colorSeedValue: colorSeedValue ?? this.colorSeedValue,
      favoriteColors: favoriteColors ?? this.favoriteColors,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ThemeSettings) return false;

    return isDarkMode == other.isDarkMode &&
        colorSeedValue == other.colorSeedValue &&
        fontSizeScale == other.fontSizeScale &&
        _listEquals(favoriteColors, other.favoriteColors);
  }

  @override
  int get hashCode =>
      Object.hash(isDarkMode, colorSeedValue, fontSizeScale, Object.hashAll(favoriteColors));

  /// Helper to compare lists
  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ThemeSettings(isDarkMode: $isDarkMode, '
        'colorSeedValue: 0x${colorSeedValue.toRadixString(16)}, '
        'fontSizeScale: $fontSizeScale, '
        'favoriteColors: ${favoriteColors.map((c) => '0x${c.toRadixString(16)}').toList()})';
  }
}
