/// design_palette.dart
///
/// ⚠️ DEPRECATED: 이 파일의 LightAppColors와 DarkAppColors는 더 이상 사용되지 않습니다.
/// 새로운 테마 시스템인 AppThemeColors와 context.colors를 사용하세요.
///
/// 마이그레이션 가이드:
/// - 기존: LightAppColors.primary → 새로운: context.colors.brandPrimary
/// - 기존: DarkAppColors.primary → 새로운: context.colors.brandPrimary (다크 모드 자동 적용)
///
/// 자세한 마이그레이션 가이드는 design.md의 Migration Guide 섹션을 참조하세요.
library;

import 'package:flutter/material.dart';

// *********************************************************************************
// *                                                                               *
// *                            --- COLOR PALETTE ---                              *
// *                                                                               *
// *  ⚠️ DEPRECATED: 아래 클래스들은 하위 호환성을 위해 유지됩니다.                    *
// *  새로운 코드에서는 context.colors (AppThemeColors)를 사용하세요.                 *
// *                                                                               *
// *********************************************************************************

/// ⚠️ DEPRECATED: context.colors를 사용하세요.
///
/// ## 마이그레이션 가이드
///
/// ### 색상 매핑 테이블
/// | 기존 (LightAppColors)      | 새로운 (context.colors)              | 사용 위치                                    |
/// |---------------------------|-------------------------------------|---------------------------------------------|
/// | `primary`                 | `context.colors.brandPrimary`       | 버튼, 선택된 네비게이션, 앱바 타이틀, 아이콘    |
/// | `primaryLight`            | `context.colors.calendarCellBackground` | 캘린더 셀 배경                            |
/// | `secondary`               | `context.colors.brandSecondary`     | 보조 텍스트, 비활성 아이콘                    |
/// | `secondaryLight`          | `context.colors.textSecondary`      | 보조 텍스트 색상                             |
/// | `background`              | `context.colors.screenBackground`   | Scaffold 배경                               |
/// | `backgroundComponent`     | `context.colors.cardBackground`     | 카드, 모달, 앱바 배경                        |
/// | `textPrimary`             | `context.colors.textPrimary`        | 주요 텍스트                                  |
/// | `textSecondary`           | `context.colors.textSecondary`      | 보조 텍스트                                  |
/// | `textOnPrimary`           | `context.colors.textOnBrand`        | 브랜드 색상 위의 텍스트                       |
/// | `calendarCellColor`       | `context.colors.calendarCellBackground` | 캘린더 셀 배경                           |
/// | `border`                  | `context.colors.border`             | 기본 테두리                                  |
/// | `accentRed`               | `context.colors.error`              | 에러 색상                                    |
/// | `overlay`                 | `context.colors.overlay`            | 모달 오버레이                                |
///
/// ### Theme.of(context) 매핑 테이블
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
/// ### 사용 예시
/// ```dart
/// // Before (기존 코드)
/// Container(
///   color: LightAppColors.primary,
///   child: Text('Hello', style: TextStyle(color: LightAppColors.textOnPrimary)),
/// )
///
/// // After (새로운 코드)
/// Container(
///   color: context.colors.brandPrimary,
///   child: Text('Hello', style: TextStyle(color: context.colors.textOnBrand)),
/// )
/// ```
@Deprecated(
  'Use context.colors instead. '
  'Example: LightAppColors.primary → context.colors.brandPrimary. '
  'See design.md Migration Guide for details.',
)
class LightAppColors {
  // ** Primary Colors **
  /// @Deprecated Use context.colors.brandPrimary instead
  static const Color primary = Color(0xFF825A3D);
  /// @Deprecated Use context.colors.calendarCellBackground instead
  static const Color primaryLight = Color(0xFFE5E7EB);

  // ** Secondary Colors **
  /// @Deprecated Use context.colors.brandSecondary instead
  static const Color secondary = Color(0xFF6B7280);
  /// @Deprecated Use context.colors.textSecondary instead
  static const Color secondaryLight = Color(0xFFF3F4F6);
  /// @Deprecated Use context.colors.brandSecondary instead
  static const Color secondaryDark = Color(0xFF4B5563);

  // ** Accent Colors **
  /// @Deprecated Use context.colors.brandPrimary instead
  static const Color accent = Color(0xFF3B82F6);
  /// @Deprecated Use context.colors.error instead
  static const Color accentRed = Color(0xFFEF4444);

  // ** Text Colors **
  /// @Deprecated Use context.colors.textPrimary instead
  static const Color textPrimary = Color(0xFF000000);
  /// @Deprecated Use context.colors.textSecondary instead
  static const Color textSecondary = Color(0xFF6B7280);
  /// @Deprecated Use context.colors.textOnBrand instead
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  /// @Deprecated Use context.colors.textOnCard instead
  static const Color textOnSecondary = Color(0xFF1F2937);

  // ** Background Colors **
  /// @Deprecated Use context.colors.screenBackground instead
  static const Color background = Color(0xFFF8F8F8);
  /// @Deprecated Use context.colors.cardBackground instead
  static const Color backgroundComponent = Color(0xFFFFFFFF);
  /// @Deprecated Use context.colors.calendarCellBackground instead
  static const Color calendarCellColor = Color(0xffF3F4F6);

  // ** Border Colors **
  /// @Deprecated Use context.colors.border instead
  static const Color border = Color(0xFFE5E7EB);
  /// @Deprecated Use context.colors.border instead
  static const Color borderLight = Color(0xFFF3F4F6);
  /// @Deprecated Use context.colors.border instead
  static const Color borderDark = Color(0xFFD1D5DB);

  // ** Other Colors **
  static const Color transparent = Colors.transparent;
  /// @Deprecated Use context.colors.overlay instead
  static const Color overlay = Color(0x4D000000);
}

/// ⚠️ DEPRECATED: context.colors를 사용하세요.
/// 다크 모드는 ThemeNotifier에서 자동으로 처리됩니다.
@Deprecated(
  'Use context.colors instead. Dark mode is handled automatically. '
  'Example: DarkAppColors.primary → context.colors.brandPrimary. '
  'See design.md Migration Guide for details.',
)
class DarkAppColors {
  // ** Primary Colors **
  /// @Deprecated Use context.colors.brandPrimary instead
  static const Color primary = Color(0xFFB8956B);
  /// @Deprecated Use context.colors.calendarCellBackground instead
  static const Color primaryLight = Color(0xFF374151);

  // ** Secondary Colors **
  /// @Deprecated Use context.colors.brandSecondary instead
  static const Color secondary = Color(0xFF9CA3AF);
  /// @Deprecated Use context.colors.textSecondary instead
  static const Color secondaryLight = Color(0xFF4B5563);
  /// @Deprecated Use context.colors.brandSecondary instead
  static const Color secondaryDark = Color(0xFF6B7280);

  // ** Accent Colors **
  /// @Deprecated Use context.colors.brandPrimary instead
  static const Color accent = Color(0xFF60A5FA);
  /// @Deprecated Use context.colors.error instead
  static const Color accentRed = Color(0xFFF87171);

  // ** Text Colors **
  /// @Deprecated Use context.colors.textPrimary instead
  static const Color textPrimary = Color(0xFFF9FAFB);
  /// @Deprecated Use context.colors.textSecondary instead
  static const Color textSecondary = Color(0xFFD1D5DB);
  /// @Deprecated Use context.colors.textOnBrand instead
  static const Color textOnPrimary = Color(0xFF111827);
  /// @Deprecated Use context.colors.textOnCard instead
  static const Color textOnSecondary = Color(0xFFF9FAFB);

  // ** Background Colors **
  /// @Deprecated Use context.colors.screenBackground instead
  static const Color background = Color(0xFF111827);
  /// @Deprecated Use context.colors.cardBackground instead
  static const Color backgroundComponent = Color(0xFF1F2937);

  // ** Border Colors **
  /// @Deprecated Use context.colors.border instead
  static const Color border = Color(0xFF374151);
  /// @Deprecated Use context.colors.border instead
  static const Color borderLight = Color(0xFF4B5563);
  /// @Deprecated Use context.colors.border instead
  static const Color borderDark = Color(0xFF6B7280);

  // ** Other Colors **
  static const Color transparent = Colors.transparent;
  /// @Deprecated Use context.colors.overlay instead
  static const Color overlay = Color(0x4D000000);
}
