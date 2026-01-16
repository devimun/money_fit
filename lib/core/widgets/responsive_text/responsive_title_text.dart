/// 타이틀 텍스트용 반응형 위젯
/// 화면 타이틀에 사용하며, 최대 2줄까지 허용
library;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 화면 타이틀용 반응형 위젯
///
/// 특징:
/// - 텍스트 크기 자동 축소 (최소 12sp)
/// - 최대 2줄까지 허용
/// - 2줄로도 안 맞으면 말줄임표
///
/// 요구사항: 3.1, 3.2, 3.3, 3.4
class ResponsiveTitleText extends StatelessWidget {
  const ResponsiveTitleText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const double defaultFontSize = 18.0;
  static const double minFontSize = 12.0;
  static const int maxLines = 2;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return AutoSizeText(
      text,
      style: style ?? context.textTheme.displaySmall,
      textAlign: textAlign,
      minFontSize: minFontSize,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
