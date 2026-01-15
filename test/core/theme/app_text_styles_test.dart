import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/theme/app_text_styles.dart';

void main() {
  group('AppTextStyles', () {
    group('Property 7: Text Style Color Removal', () {
      test('h1 should not have color property', () {
        expect(AppTextStyles.h1.color, isNull);
      });

      test('h2 should not have color property', () {
        expect(AppTextStyles.h2.color, isNull);
      });

      test('h3 should not have color property', () {
        expect(AppTextStyles.h3.color, isNull);
      });

      test('h4 should not have color property', () {
        expect(AppTextStyles.h4.color, isNull);
      });

      test('bodyL should not have color property', () {
        expect(AppTextStyles.bodyL.color, isNull);
      });

      test('bodyL2 should not have color property', () {
        expect(AppTextStyles.bodyL2.color, isNull);
      });

      test('bodyM should not have color property', () {
        expect(AppTextStyles.bodyM.color, isNull);
      });

      test('bodyMM should not have color property', () {
        expect(AppTextStyles.bodyMM.color, isNull);
      });

      test('bodyS should not have color property', () {
        expect(AppTextStyles.bodyS.color, isNull);
      });

      test('caption should not have color property', () {
        expect(AppTextStyles.caption.color, isNull);
      });

      test('captionOnDate should not have color property', () {
        expect(AppTextStyles.captionOnDate.color, isNull);
      });

      test('nav should not have color property', () {
        expect(AppTextStyles.nav.color, isNull);
      });

      test('navSelected should not have color property', () {
        expect(AppTextStyles.navSelected.color, isNull);
      });
    });

    group('Font properties preservation', () {
      test('all styles should use Pretendard Variable font', () {
        expect(AppTextStyles.h1.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.h2.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.h3.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.h4.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.bodyL.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.bodyL2.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.bodyM.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.bodyMM.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.bodyS.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.caption.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.captionOnDate.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.nav.fontFamily, 'Pretendard Variable');
        expect(AppTextStyles.navSelected.fontFamily, 'Pretendard Variable');
      });

      test('font sizes should be preserved correctly', () {
        expect(AppTextStyles.h1.fontSize, 32);
        expect(AppTextStyles.h2.fontSize, 24);
        expect(AppTextStyles.h3.fontSize, 18);
        expect(AppTextStyles.h4.fontSize, 16);
        expect(AppTextStyles.bodyL.fontSize, 16);
        expect(AppTextStyles.bodyL2.fontSize, 16);
        expect(AppTextStyles.bodyM.fontSize, 14);
        expect(AppTextStyles.bodyMM.fontSize, 14);
        expect(AppTextStyles.bodyS.fontSize, 12);
        expect(AppTextStyles.caption.fontSize, 12);
        expect(AppTextStyles.captionOnDate.fontSize, 10);
        expect(AppTextStyles.nav.fontSize, 12);
        expect(AppTextStyles.navSelected.fontSize, 12);
      });

      test('font weights should be preserved correctly', () {
        expect(AppTextStyles.h1.fontWeight, FontWeight.w900);
        expect(AppTextStyles.h2.fontWeight, FontWeight.w700);
        expect(AppTextStyles.h3.fontWeight, FontWeight.w600);
        expect(AppTextStyles.h4.fontWeight, FontWeight.w500);
        expect(AppTextStyles.bodyL.fontWeight, FontWeight.w500);
        expect(AppTextStyles.bodyL2.fontWeight, FontWeight.w500);
        expect(AppTextStyles.bodyM.fontWeight, FontWeight.w600);
        expect(AppTextStyles.bodyMM.fontWeight, FontWeight.w400);
        expect(AppTextStyles.bodyS.fontWeight, FontWeight.w400);
        expect(AppTextStyles.caption.fontWeight, FontWeight.w400);
        expect(AppTextStyles.captionOnDate.fontWeight, FontWeight.w400);
        expect(AppTextStyles.nav.fontWeight, FontWeight.w300);
        expect(AppTextStyles.navSelected.fontWeight, FontWeight.w500);
      });
    });
  });
}
