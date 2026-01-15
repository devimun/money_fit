/// app_theme.dart
///
/// ⚠️ DEPRECATED: 이 파일은 마이그레이션 참조용으로만 유지됩니다.
/// 새로운 테마 시스템인 theme_provider.dart의 lightThemeProvider와 darkThemeProvider를 사용하세요.
///
/// 마이그레이션 가이드:
/// - 기존: AppTheme.lightTheme → 새로운: ref.watch(lightThemeProvider)
/// - 기존: AppTheme.darkTheme → 새로운: ref.watch(darkThemeProvider)
/// - 기존: AppTheme.getBoxDecoration(context) → 새로운: context.boxDecoration
///
/// ### Theme.of(context) → context.colors 매핑
/// | 기존 (Theme.of(context))                    | 새로운 (context.colors)              |
/// |--------------------------------------------|-------------------------------------|
/// | `colorScheme.primary`                      | `context.colors.brandPrimary`       |
/// | `colorScheme.secondary`                    | `context.colors.brandSecondary`     |
/// | `colorScheme.surface`                      | `context.colors.cardBackground`     |
/// | `colorScheme.error`                        | `context.colors.error`              |
/// | `colorScheme.onPrimary`                    | `context.colors.textOnBrand`        |
/// | `colorScheme.onSurface`                    | `context.colors.textPrimary`        |
/// | `colorScheme.onSecondaryFixed`             | `context.colors.textSecondary`      |
/// | `scaffoldBackgroundColor`                  | `context.colors.screenBackground`   |
///
/// 자세한 마이그레이션 가이드는 design.md의 Migration Guide 섹션을 참조하세요.
library;

import 'package:flutter/material.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/core/theme/app_text_styles.dart';

/// ⚠️ DEPRECATED: theme_provider.dart의 lightThemeProvider/darkThemeProvider를 사용하세요.
///
/// 이 클래스는 마이그레이션 참조용으로만 유지됩니다.
/// 새로운 코드에서는 Riverpod provider를 사용하세요.
///
/// ### 마이그레이션 예시
/// ```dart
/// // Before (기존 코드)
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
/// )
///
/// // After (새로운 코드)
/// Consumer(
///   builder: (context, ref, _) {
///     final lightTheme = ref.watch(lightThemeProvider);
///     final darkTheme = ref.watch(darkThemeProvider);
///     return MaterialApp(
///       theme: lightTheme,
///       darkTheme: darkTheme,
///     );
///   },
/// )
/// ```
@Deprecated(
  'This class is kept for migration reference only. '
  'Use lightThemeProvider/darkThemeProvider from theme_provider.dart instead.',
)
class AppTheme {
  /// @Deprecated Use context.boxDecoration instead
  @Deprecated('Use context.boxDecoration instead')
  static BoxDecoration getBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.25),
          blurRadius: 4,
          offset: const Offset(1, 1),
        ),
      ],
    );
  }

  /// @Deprecated Use lightThemeProvider from theme_provider.dart instead
  @Deprecated(
    'Use lightThemeProvider from theme_provider.dart instead. '
    'See design.md Migration Guide for details.',
  )
  // ignore: deprecated_member_use_from_same_package
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
        onSecondaryContainer: LightAppColors.calendarCellColor,
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
        backgroundColor: LightAppColors.backgroundComponent,
        centerTitle: false,
        elevation: 1,
        shadowColor: LightAppColors.backgroundComponent,
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

  /// @Deprecated Use darkThemeProvider from theme_provider.dart instead
  @Deprecated(
    'Use darkThemeProvider from theme_provider.dart instead. '
    'See design.md Migration Guide for details.',
  )
  // ignore: deprecated_member_use_from_same_package
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
        outline: DarkAppColors.borderLight,
        onSecondaryContainer: DarkAppColors.border,
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
      displayLarge: AppTextStyles.h1.copyWith(color: primaryColor),
      displayMedium: AppTextStyles.h2.copyWith(color: primaryColor),
      displaySmall: AppTextStyles.h3.copyWith(color: primaryColor),
      headlineMedium: AppTextStyles.h4.copyWith(color: primaryColor),
      bodyLarge: AppTextStyles.bodyL.copyWith(color: secondaryColor),
      bodyMedium: AppTextStyles.bodyM.copyWith(color: primaryColor),
      bodySmall: AppTextStyles.bodyS.copyWith(color: secondaryColor),
      labelLarge: AppTextStyles.bodyM.copyWith(color: primaryColor),
      labelMedium: AppTextStyles.bodyMM.copyWith(color: secondaryColor),
      labelSmall: AppTextStyles.caption.copyWith(color: secondaryColor),
      titleSmall: AppTextStyles.captionOnDate.copyWith(color: secondaryColor),
      titleMedium: AppTextStyles.bodyL2.copyWith(color: primaryColor),
    );
  }
}
