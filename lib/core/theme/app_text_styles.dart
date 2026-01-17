/// Typography styles for the app
/// All text styles are defined without color properties
/// Colors should be applied separately using context.colors or Theme.of(context)
library;

import 'package:flutter/material.dart';

/// Centralized text styles for the MoneyFit app
/// 
/// All styles use the Pretendard Variable font family
/// Colors are intentionally omitted to allow flexible theming
class AppTextStyles {
  static const String _fontFamily = 'Pretendard Variable';

  /// **h1 (32pt, bold)**
  /// 
  /// Usage:
  /// - **Home:** Circular progress bar amount "35,000원"
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
  );

  /// **h2 (24pt, bold)**
  /// 
  /// Usage:
  /// - **Onboarding:** Main titles like "복잡한 가계부는 이제 그만"
  /// - **Onboarding:** "예산 설정하기" title
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// **h3 (18pt, semi-bold)**
  /// 
  /// Usage:
  /// - **AppBar:** "MoneyFit" logo
  /// - **Calendar:** Month display "2025년 7월"
  /// - **Modals:** "오늘의 지출" title
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// **h4 (16pt, semi-bold)**
  /// 
  /// Usage:
  /// - **Home:** "오늘도 현명한 소비 하고 계시네요! 👍"
  /// - **Settings:** Modal titles like "일일 예산 설정"
  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// **bodyL (16pt, regular)**
  /// 
  /// Usage:
  /// - **Onboarding:** Descriptions like "매일의 지출을 간편하게 관리하고..."
  static const TextStyle bodyL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// **bodyL2 (16pt, regular)**
  /// 
  /// Usage:
  /// - **Settings:** Menu items like "일일 예산 설정", "다크 모드"
  static const TextStyle bodyL2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// **bodyM (14pt, medium)**
  /// 
  /// Usage:
  /// - **Home:** Card titles "오늘의 지출 보기", "지출 등록하기"
  /// - **Expense:** List item titles "점심 식사", "스타벅스"
  /// - **Calendar:** Monthly summary values "₩320,000"
  /// - **Buttons:** "다음", "시작하기"
  static const TextStyle bodyM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// **bodyMM (14pt, regular)**
  /// 
  /// Usage:
  /// - General body text with regular weight
  static const TextStyle bodyMM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// **bodyS (12pt, regular)**
  /// 
  /// Usage:
  /// - **Home:** Date "2025.07.04 금요일", card subtitles "총 3건의 지출이 있어요"
  /// - **Expense:** List item subtitles "필수지출 > 식사"
  /// - **Calendar:** Day of the week "일", "월", "화"...
  static const TextStyle bodyS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// **caption (12pt, regular)**
  /// 
  /// Usage:
  /// - **Calendar:** Price under the date "₩12,500"
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// **captionOnDate (10pt, regular)**
  /// 
  /// Usage:
  /// - **Calendar:** Small price text under dates
  static const TextStyle captionOnDate = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  /// **nav (12pt, light)**
  /// 
  /// Usage:
  /// - **BottomNavBar:** Unselected item labels "홈", "캘린더"
  static const TextStyle nav = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );

  /// **navSelected (12pt, medium)**
  /// 
  /// Usage:
  /// - **BottomNavBar:** Selected item label "지출 내역"
  static const TextStyle navSelected = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
