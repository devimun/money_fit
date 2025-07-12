import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/design_palette.dart';

class AppTheme {
  static BoxDecoration boxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 4,
        offset: const Offset(1, 1),
      ),
    ],
  );
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: LightAppColors.background,
      primaryColor: LightAppColors.primary,

      fontFamily: 'Pretendard Variable',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: LightAppColors.primary,
          minimumSize: const Size(double.maxFinite, 50),
          textStyle: const TextStyle(color: Colors.white),
        ),
      ),

      colorScheme: const ColorScheme.light(
        primary: LightAppColors.primary,
        secondary: LightAppColors.secondary,
        onSecondaryContainer: Color.fromARGB(255, 236, 236, 239),
        surface: LightAppColors.backgroundComponent,
        error: LightAppColors.accentRed,
        onPrimary: LightAppColors.textOnPrimary,
        onSecondary: LightAppColors.textOnSecondary,
        onSurface: LightAppColors.textPrimary,
        onError: LightAppColors.textOnPrimary,
        onSecondaryFixed: LightAppColors.textSecondary,
      ),

      textTheme: _textTheme(
        LightAppColors.textPrimary,
        LightAppColors.textSecondary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 1,
        shadowColor: Colors.white,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: LightAppColors.primary,
        ),
        iconTheme: const IconThemeData(color: LightAppColors.textPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightAppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: LightAppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: LightAppColors.accentRed),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightAppColors.backgroundComponent,
        selectedItemColor: LightAppColors.primary,
        unselectedItemColor: LightAppColors.secondary,
        selectedLabelStyle: AppTextStyles.navSelected,
        unselectedLabelStyle: AppTextStyles.nav,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DarkAppColors.background,
      primaryColor: DarkAppColors.primary,
      fontFamily: 'Pretendard Variable',

      colorScheme: const ColorScheme.dark(
        primary: DarkAppColors.primary,
        secondary: DarkAppColors.secondary,
        surface: DarkAppColors.backgroundComponent,
        error: DarkAppColors.accentRed,
        onPrimary: DarkAppColors.textOnPrimary,
        onSecondary: DarkAppColors.textOnSecondary,
        onSurface: DarkAppColors.textPrimary,
        onError: DarkAppColors.textOnPrimary,
      ),

      textTheme: _textTheme(
        DarkAppColors.textPrimary,
        DarkAppColors.textSecondary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: DarkAppColors.background,
        elevation: 1,
        shadowColor: Colors.black,
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: DarkAppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: DarkAppColors.textPrimary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkAppColors.backgroundComponent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DarkAppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DarkAppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DarkAppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DarkAppColors.accentRed),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkAppColors.backgroundComponent,
        selectedItemColor: DarkAppColors.primary,
        unselectedItemColor: DarkAppColors.secondary,
        selectedLabelStyle: AppTextStyles.navSelected,
        unselectedLabelStyle: AppTextStyles.nav,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static TextTheme _textTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      // displayLarge: Onboarding main titles, Home circular progress bar amount
      displayLarge: AppTextStyles.h1.copyWith(color: primaryColor),
      // displayMedium: Onboarding "예산 설정하기" title
      displayMedium: AppTextStyles.h2.copyWith(color: primaryColor),
      // displaySmall: AppBar logo, Calendar month display, Modal titles
      displaySmall: AppTextStyles.h3.copyWith(color: primaryColor),
      // headlineMedium: Home greeting, Settings modal titles
      headlineMedium: AppTextStyles.h4.copyWith(color: primaryColor),
      // bodyLarge: Onboarding descriptions, Settings menu items
      bodyLarge: AppTextStyles.bodyL.copyWith(color: secondaryColor),
      // bodyMedium: Home card titles, Expense list item titles, Calendar summary values, Buttons
      bodyMedium: AppTextStyles.bodyM.copyWith(color: primaryColor),
      // bodySmall: Home date, card subtitles, Expense list item subtitles, Calendar day of the week
      bodySmall: AppTextStyles.bodyS.copyWith(color: secondaryColor),
      // labelLarge: Buttons
      labelLarge: AppTextStyles.bodyM.copyWith(
        color: LightAppColors.textOnPrimary,
      ),
      labelMedium: AppTextStyles.bodyMM.copyWith(color: secondaryColor),
      // caption: Calendar price under the date
      labelSmall: AppTextStyles.caption.copyWith(color: secondaryColor),
      titleSmall: AppTextStyles.captionOnDate.copyWith(color: secondaryColor),
      // titleMedium: AppTextStyles
    );
  }
}
