// AppThemeColors - ThemeExtension for managing all app colors
// Provides semantic color definitions that map to actual UI elements
// Supports light/dark mode and smooth theme transitions via lerp
import 'package:flutter/material.dart';

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  // === Brand & Accent ===
  /// 브랜드 메인 색상 (버튼, 선택된 네비게이션, 앱바 타이틀, 아이콘)
  final Color brandPrimary;

  /// 브랜드 보조 색상 (보조 텍스트, 비활성 아이콘)
  final Color brandSecondary;

  /// 에러/경고 색상
  final Color error;

  // === Backgrounds ===
  /// 화면 배경색 (Scaffold)
  final Color screenBackground;

  /// 카드/모달 배경색 (Container, Card, Dialog)
  final Color cardBackground;

  /// 입력 필드 배경색
  final Color inputBackground;

  /// 캘린더 셀 배경색
  final Color calendarCellBackground;

  /// 선택된 버튼 배경색
  final Color selectedButtonBackground;

  // === Text Colors ===
  /// 주요 텍스트 색상 (제목, 본문)
  final Color textPrimary;

  /// 보조 텍스트 색상 (설명, 부제목)
  final Color textSecondary;

  /// 브랜드 색상 위의 텍스트 (버튼 텍스트, 선택된 탭)
  final Color textOnBrand;

  /// 카드 배경 위의 텍스트
  final Color textOnCard;

  // === Borders & Dividers ===
  /// 기본 테두리 색상
  final Color border;

  /// 구분선 색상
  final Color divider;

  /// 포커스된 입력 필드 테두리
  final Color borderFocused;

  // === Interactive Elements ===
  /// 선택되지 않은 네비게이션 아이템
  final Color navUnselected;

  /// 선택된 네비게이션 아이템
  final Color navSelected;

  /// 스위치 활성 색상
  final Color switchActive;

  /// 스위치 비활성 트랙 색상
  final Color switchInactiveTrack;

  // === Special ===
  /// 오버레이 색상 (모달 배경)
  final Color overlay;

  /// 예산 진행률 색상 (동적으로 변경됨)
  final Color budgetProgress;

  const AppThemeColors({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.error,
    required this.screenBackground,
    required this.cardBackground,
    required this.inputBackground,
    required this.calendarCellBackground,
    required this.selectedButtonBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnBrand,
    required this.textOnCard,
    required this.border,
    required this.divider,
    required this.borderFocused,
    required this.navUnselected,
    required this.navSelected,
    required this.switchActive,
    required this.switchInactiveTrack,
    required this.overlay,
    required this.budgetProgress,
  });

  @override
  AppThemeColors copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? error,
    Color? screenBackground,
    Color? cardBackground,
    Color? inputBackground,
    Color? calendarCellBackground,
    Color? selectedButtonBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnBrand,
    Color? textOnCard,
    Color? border,
    Color? divider,
    Color? borderFocused,
    Color? navUnselected,
    Color? navSelected,
    Color? switchActive,
    Color? switchInactiveTrack,
    Color? overlay,
    Color? budgetProgress,
  }) {
    return AppThemeColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      error: error ?? this.error,
      screenBackground: screenBackground ?? this.screenBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      calendarCellBackground:
          calendarCellBackground ?? this.calendarCellBackground,
      selectedButtonBackground:
          selectedButtonBackground ?? this.selectedButtonBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      textOnCard: textOnCard ?? this.textOnCard,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      borderFocused: borderFocused ?? this.borderFocused,
      navUnselected: navUnselected ?? this.navUnselected,
      navSelected: navSelected ?? this.navSelected,
      switchActive: switchActive ?? this.switchActive,
      switchInactiveTrack: switchInactiveTrack ?? this.switchInactiveTrack,
      overlay: overlay ?? this.overlay,
      budgetProgress: budgetProgress ?? this.budgetProgress,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      screenBackground: Color.lerp(screenBackground, other.screenBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      calendarCellBackground:
          Color.lerp(calendarCellBackground, other.calendarCellBackground, t)!,
      selectedButtonBackground: Color.lerp(
          selectedButtonBackground, other.selectedButtonBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      textOnCard: Color.lerp(textOnCard, other.textOnCard, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      switchActive: Color.lerp(switchActive, other.switchActive, t)!,
      switchInactiveTrack:
          Color.lerp(switchInactiveTrack, other.switchInactiveTrack, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      budgetProgress: Color.lerp(budgetProgress, other.budgetProgress, t)!,
    );
  }
}
