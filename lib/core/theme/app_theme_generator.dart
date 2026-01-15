// AppThemeGenerator - Factory class for generating AppThemeColors from a color seed
// Automatically creates consistent color palettes for light and dark modes
// Ensures proper contrast ratios for accessibility
import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

class AppThemeGenerator {
  /// 기본 colorSeed (현재 브라운 색상)
  static const Color defaultSeed = Color(0xFF825A3D);

  /// ColorSeed로부터 라이트 모드 테마 생성
  static AppThemeColors lightFromSeed(Color seed) {
    // 브랜드 색상
    final Color brandPrimary = seed;
    final Color brandSecondary = const Color(0xFF6B7280); // 회색 계열

    // 배경 색상
    final Color screenBackground = const Color(0xFFF8F8F8);
    final Color cardBackground = Colors.white;
    final Color inputBackground = screenBackground;
    final Color calendarCellBackground = const Color(0xFFF3F4F6);
    final Color selectedButtonBackground = brandPrimary;

    // 텍스트 색상
    final Color textPrimary = Colors.black;
    final Color textSecondary = brandSecondary;
    final Color textOnBrand = _getContrastColor(brandPrimary);
    final Color textOnCard = textPrimary;

    // 테두리 & 구분선
    final Color border = const Color(0xFFE5E7EB);
    final Color divider = brandSecondary.withValues(alpha: 0.55);
    final Color borderFocused = brandPrimary;

    // 인터랙티브 요소
    final Color navUnselected = brandSecondary;
    final Color navSelected = brandPrimary;
    final Color switchActive = brandPrimary;
    final Color switchInactiveTrack = const Color(0xFFE0E0E0);

    // 특수 색상
    final Color overlay = Colors.black.withValues(alpha: 0.3);
    final Color budgetProgress = brandPrimary;

    return AppThemeColors(
      brandPrimary: brandPrimary,
      brandSecondary: brandSecondary,
      error: const Color(0xFFEF4444),
      screenBackground: screenBackground,
      cardBackground: cardBackground,
      inputBackground: inputBackground,
      calendarCellBackground: calendarCellBackground,
      selectedButtonBackground: selectedButtonBackground,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textOnBrand: textOnBrand,
      textOnCard: textOnCard,
      border: border,
      divider: divider,
      borderFocused: borderFocused,
      navUnselected: navUnselected,
      navSelected: navSelected,
      switchActive: switchActive,
      switchInactiveTrack: switchInactiveTrack,
      overlay: overlay,
      budgetProgress: budgetProgress,
    );
  }

  /// ColorSeed로부터 다크 모드 테마 생성
  static AppThemeColors darkFromSeed(Color seed) {
    // 다크 모드에서도 원본 seed 색상 그대로 사용
    final Color brandPrimary = seed;
    final Color brandSecondary = const Color(0xFF9CA3AF);

    // 배경 색상 (어두운 톤)
    final Color screenBackground = const Color(0xFF111827);
    final Color cardBackground = const Color(0xFF1F2937);
    final Color inputBackground = cardBackground;
    final Color calendarCellBackground = const Color(0xFF374151);
    final Color selectedButtonBackground = brandPrimary;

    // 텍스트 색상 (밝은 톤)
    final Color textPrimary = const Color(0xFFF9FAFB);
    final Color textSecondary = const Color(0xFFD1D5DB);
    final Color textOnBrand = _getContrastColor(brandPrimary);
    final Color textOnCard = textPrimary;

    // 테두리 & 구분선
    final Color border = const Color(0xFF374151);
    final Color divider = brandSecondary.withValues(alpha: 0.55);
    final Color borderFocused = brandPrimary;

    // 인터랙티브 요소
    final Color navUnselected = brandSecondary;
    final Color navSelected = brandPrimary;
    final Color switchActive = brandPrimary;
    final Color switchInactiveTrack = const Color(0xFF4B5563);

    // 특수 색상
    final Color overlay = Colors.black.withValues(alpha: 0.3);
    final Color budgetProgress = brandPrimary;

    return AppThemeColors(
      brandPrimary: brandPrimary,
      brandSecondary: brandSecondary,
      error: const Color(0xFFF87171),
      screenBackground: screenBackground,
      cardBackground: cardBackground,
      inputBackground: inputBackground,
      calendarCellBackground: calendarCellBackground,
      selectedButtonBackground: selectedButtonBackground,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textOnBrand: textOnBrand,
      textOnCard: textOnCard,
      border: border,
      divider: divider,
      borderFocused: borderFocused,
      navUnselected: navUnselected,
      navSelected: navSelected,
      switchActive: switchActive,
      switchInactiveTrack: switchInactiveTrack,
      overlay: overlay,
      budgetProgress: budgetProgress,
    );
  }

  /// 배경색과 대비되는 텍스트 색상 계산
  static Color _getContrastColor(Color background) {
    final double luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
