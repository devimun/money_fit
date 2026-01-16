/// 네비게이션 라벨용 반응형 위젯
/// 하단 네비게이션 바의 라벨에 사용
library;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 하단 네비게이션 라벨용 반응형 위젯
///
/// 특징:
/// - 텍스트 크기 자동 축소 (최소 8sp)
/// - 단일 줄 유지
/// - 최소 크기로도 안 맞으면 말줄임표
///
/// 요구사항: 7.1, 7.2, 7.3
class ResponsiveNavText extends StatelessWidget {
  const ResponsiveNavText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const double defaultFontSize = 12.0;
  static const double minFontSize = 8.0;
  static const int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return AutoSizeText(
      text,
      style: style ?? context.textTheme.labelSmall,
      textAlign: textAlign,
      minFontSize: minFontSize,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
