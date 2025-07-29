import 'package:flutter/material.dart';

// *********************************************************************************
// *                                                                               *
// *                            --- COLOR PALETTE ---                              *
// *                                                                               *
// *********************************************************************************

class LightAppColors {
  // ** Primary Colors **
  // Used for main UI elements like logos, buttons, and navigation bars.
  static const Color primary = Color(0xFF825A3D); // Main brand color
  static const Color primaryLight = Color(
    0xFFE5E7EB,
  ); // Lighter shade for backgrounds or highlights

  // ** Secondary Colors **
  // Used for accents and secondary UI elements.
  static const Color secondary = Color(0xFF6B7280); // Secondary text and icons
  static const Color secondaryLight = Color(
    0xFFF3F4F6,
  ); // Lighter shade for backgrounds or disabled states
  static const Color secondaryDark = Color(
    0xFF4B5563,
  ); // Darker shade for text or borders

  // ** Accent Colors **
  // Used for highlighting important information or actions.
  static const Color accent = Color(
    0xFF3B82F6,
  ); // Accent color for links or highlights
  static const Color accentRed = Color(
    0xFFEF4444,
  ); // Red accent for errors or warnings

  // ** Text Colors **
  // Used for all text elements in the app.
  static const Color textPrimary = Color(0xFF000000); // Primary text color
  static const Color textSecondary = Color(
    0xFF6B7280,
  ); // Secondary text color for less important information
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // Text color on primary backgrounds
  static const Color textOnSecondary = Color(
    0xFF1F2937,
  ); // Text color on secondary backgrounds

  // ** Background Colors **
  // Used for screen and component backgrounds.
  static const Color background = Color(0xFFF8F8F8); // Main background color
  static const Color backgroundComponent = Color(
    0xFFFFFFFF,
  ); // White background for cards and modals
  static const Color calendarCellColor = Color(0xffF3F4F6);
  // ** Border Colors **
  // Used for borders and dividers.
  static const Color border = Color(0xFFE5E7EB); // Default border color
  static const Color borderLight = Color(0xFFF3F4F6); // Lighter border color
  static const Color borderDark = Color(0xFFD1D5DB); // Darker border color

  // ** Other Colors **
  // Miscellaneous colors used throughout the app.
  static const Color transparent = Colors.transparent; // Transparent color
  static const Color overlay = Color(
    0x4D000000,
  ); // Overlay color for modals (30% opacity)
}

class DarkAppColors {
  // ** Primary Colors **
  static const Color primary = Color(
    0xFFB8956B,
  ); // Lighter brown with better contrast for dark mode
  static const Color primaryLight = Color(
    0xFF374151,
  ); // Darker shade for highlights

  // ** Secondary Colors **
  static const Color secondary = Color(
    0xFF9CA3AF,
  ); // Lighter grey for secondary text/icons
  static const Color secondaryLight = Color(
    0xFF4B5563,
  ); // Darker shade for disabled states
  static const Color secondaryDark = Color(
    0xFF6B7280,
  ); // Lighter shade for borders

  // ** Accent Colors **
  static const Color accent = Color(0xFF60A5FA); // A slightly lighter blue
  static const Color accentRed = Color(0xFFF87171); // A slightly lighter red

  // ** Text Colors **
  static const Color textPrimary = Color(
    0xFFF9FAFB,
  ); // Primary text color (light grey)
  static const Color textSecondary = Color(0xFFD1D5DB); // Secondary text color
  static const Color textOnPrimary = Color(
    0xFF111827,
  ); // Text on primary backgrounds
  static const Color textOnSecondary = Color(
    0xFFF9FAFB,
  ); // Text on secondary backgrounds

  // ** Background Colors **
  static const Color background = Color(0xFF111827); // Main dark background
  static const Color backgroundComponent = Color(
    0xFF1F2937,
  ); // Component background (e.g., cards)

  // ** Border Colors **
  // Used for borders and dividers.
  static const Color border = Color(0xFF374151); // Default border color
  static const Color borderLight = Color(0xFF4B5563); // Lighter border color
  static const Color borderDark = Color(0xFF6B7280); // Darker border color

  // ** Other Colors **
  // Miscellaneous colors used throughout the app.
  static const Color transparent = Colors.transparent;
  static const Color overlay = Color(0x4D000000); // Overlay can remain the same
}

// *********************************************************************************
// *                                                                               *
// *                          --- TYPOGRAPHY STYLES ---                            *
// *                                                                               *
// *********************************************************************************

class AppTextStyles {
  static const String _fontFamily = 'Pretendard Variable';

  /// **h1 (32pt, bold)**
  /// - **Home:** Circular progress bar amount "35,000원"
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
  );

  /// **h2 (24pt, bold)**
  /// - **Onboarding:** Main titles like "복잡한 가계부는 이제 그만"
  /// - **Onboarding:** "예산 설정하기" title
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// **h3 (18pt, semi-bold)**
  /// - **AppBar:** "MoneyFit" logo
  /// - **Calendar:** Month display "2025년 7월"
  /// - **Modals:** "오늘의 지출" title
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// **h4 (16pt, semi-bold)**
  /// - **Home:** "오늘도 현명한 소비 하고 계시네요! 👍"
  /// - **Settings:** Modal titles like "일일 예산 설정"
  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// **bodyL (16pt, regular)**
  /// - **Onboarding:** Descriptions like "매일의 지출을 간편하게 관리하고..."
  static const TextStyle bodyL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: LightAppColors.secondaryLight,
  );

  /// **bodyL (16pt, regular)**
  /// - **Settings:** Menu items like "일일 예산 설정", "다크 모드"
  static const TextStyle bodyL2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// **bodyM (14pt, medium)**
  /// - **Home:** Card titles "오늘의 지출 보기", "지출 등록하기"
  /// - **Expense:** List item titles "점심 식사", "스타벅스"
  /// - **Calendar:** Monthly summary values "₩320,000"
  /// - **Buttons:** "다음", "시작하기"
  static const TextStyle bodyM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle bodyMM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// **bodyS (12pt, regular)**
  /// - **Home:** Date "2025.07.04 금요일", card subtitles "총 3건의 지출이 있어요"
  /// - **Expense:** List item subtitles "필수지출 > 식사"
  /// - **Calendar:** Day of the week "일", "월", "화"...
  static const TextStyle bodyS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: LightAppColors.secondaryLight,
  );

  /// **caption (12pt, regular)**
  /// - **Calendar:** Price under the date "₩12,500"
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// **caption (10pt, regular)**
  /// - **Calendar:** Price under the date "₩12,500"
  static const TextStyle captionOnDate = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  /// **nav (12pt, light)**
  /// - **BottomNavBar:** Unselected item labels "홈", "캘린더"
  static const TextStyle nav = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );

  /// **navSelected (12pt, medium)**
  /// - **BottomNavBar:** Selected item label "지출 내역"
  static const TextStyle navSelected = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
