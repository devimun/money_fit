/// Theme Provider - Manages app theme state with AppThemeColors integration
/// Provides light/dark themes using the new theme system
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/theme/app_theme_colors.dart';
import 'package:money_fit/core/theme/app_theme_generator.dart';
import 'package:money_fit/core/theme/app_text_styles.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/preferences/preferences_provider.dart';

/// Read-only projections of the one persisted theme preference.  Mutations
/// belong to [PreferencesController], avoiding three independent copies of
/// the same state.
final themeSeedColorProvider = Provider<Color>(
  (ref) => ref.watch(
    appPreferencesProvider.select((value) => value.theme.colorSeed),
  ),
);

final themeModeProvider = Provider<bool>(
  (ref) => ref.watch(
    appPreferencesProvider.select((value) => value.theme.isDarkMode),
  ),
);

final fontSizeProvider = Provider<double>(
  (ref) => ref.watch(
    appPreferencesProvider.select((value) => value.theme.fontSizeScale),
  ),
);

/// Provides the light theme with AppThemeColors extension
final lightThemeProvider = Provider<ThemeData>((ref) {
  final seedColor = ref.watch(themeSeedColorProvider);
  final fontSizeScale = ref.watch(fontSizeProvider);
  return _buildAppTheme(
    colors: AppThemeGenerator.lightFromSeed(seedColor),
    brightness: Brightness.light,
    fontSizeScale: fontSizeScale,
  );
});

/// Provides the dark theme with AppThemeColors extension
final darkThemeProvider = Provider<ThemeData>((ref) {
  final seedColor = ref.watch(themeSeedColorProvider);
  final fontSizeScale = ref.watch(fontSizeProvider);
  return _buildAppTheme(
    colors: AppThemeGenerator.darkFromSeed(seedColor),
    brightness: Brightness.dark,
    fontSizeScale: fontSizeScale,
  );
});

ThemeData _buildAppTheme({
  required AppThemeColors colors,
  required Brightness brightness,
  required double fontSizeScale,
}) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = isDark
      ? ColorScheme.dark(
          primary: colors.brandPrimary,
          secondary: colors.brandSecondary,
          surface: colors.cardBackground,
          error: colors.error,
          onPrimary: colors.textOnBrand,
          onSecondary: colors.textOnBrand,
          onSurface: colors.textPrimary,
          onError: colors.textOnBrand,
          outline: colors.border,
        )
      : ColorScheme.light(
          primary: colors.brandPrimary,
          secondary: colors.brandSecondary,
          surface: colors.cardBackground,
          error: colors.error,
          onPrimary: colors.textOnBrand,
          onSecondary: colors.textOnBrand,
          onSurface: colors.textPrimary,
          onError: colors.textOnBrand,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: colors.screenBackground,
    primaryColor: colors.brandPrimary,
    fontFamily: 'Pretendard Variable',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: colors.selectedButtonBackground,
        foregroundColor: colors.textOnBrand,
        minimumSize: const Size(double.maxFinite, 50),
      ),
    ),
    colorScheme: colorScheme,
    textTheme: _buildTextTheme(
      colors.textPrimary,
      colors.textSecondary,
      fontSizeScale,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? colors.screenBackground : colors.cardBackground,
      centerTitle: false,
      elevation: 1,
      shadowColor: isDark ? Colors.black : colors.cardBackground,
      titleTextStyle: AppTextStyles.h3.copyWith(
        color: isDark ? colors.textPrimary : colors.brandPrimary,
        fontSize: AppTextStyles.h3.fontSize! * fontSizeScale,
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? colors.cardBackground : colors.screenBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.brandPrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.error),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.cardBackground,
      selectedItemColor: colors.brandPrimary,
      unselectedItemColor: colors.brandSecondary,
      selectedLabelStyle: AppTextStyles.navSelected.copyWith(
        fontSize: AppTextStyles.navSelected.fontSize! * fontSizeScale,
      ),
      unselectedLabelStyle: AppTextStyles.nav.copyWith(
        fontSize: AppTextStyles.nav.fontSize! * fontSizeScale,
      ),
      type: BottomNavigationBarType.fixed,
    ),
  ).withAppColors(colors);
}

/// Helper function to build TextTheme with font size scale
TextTheme _buildTextTheme(
  Color primaryColor,
  Color secondaryColor,
  double fontSizeScale,
) {
  return TextTheme(
    displayLarge: AppTextStyles.h1.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h1.fontSize! * fontSizeScale,
    ),
    displayMedium: AppTextStyles.h2.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h2.fontSize! * fontSizeScale,
    ),
    displaySmall: AppTextStyles.h3.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h3.fontSize! * fontSizeScale,
    ),
    headlineMedium: AppTextStyles.h4.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h4.fontSize! * fontSizeScale,
    ),
    bodyLarge: AppTextStyles.bodyL.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.bodyL.fontSize! * fontSizeScale,
    ),
    bodyMedium: AppTextStyles.bodyM.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.bodyM.fontSize! * fontSizeScale,
    ),
    bodySmall: AppTextStyles.bodyS.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.bodyS.fontSize! * fontSizeScale,
    ),
    labelLarge: AppTextStyles.bodyM.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.bodyM.fontSize! * fontSizeScale,
    ),
    labelMedium: AppTextStyles.bodyMM.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.bodyMM.fontSize! * fontSizeScale,
    ),
    labelSmall: AppTextStyles.caption.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.caption.fontSize! * fontSizeScale,
    ),
    titleSmall: AppTextStyles.captionOnDate.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.captionOnDate.fontSize! * fontSizeScale,
    ),
    titleMedium: AppTextStyles.bodyL2.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.bodyL2.fontSize! * fontSizeScale,
    ),
  );
}
