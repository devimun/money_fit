/// 버튼 텍스트용 반응형 위젯
/// 텍스트가 길어지면 자동 축소하며, 최소 10sp까지 축소 후 말줄임표 처리
library;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 버튼 내 텍스트를 위한 반응형 위젯
///
/// 특징:
/// - 텍스트 크기 자동 축소 (최소 10sp)
/// - 단일 줄 유지
/// - 최소 크기로도 안 맞으면 말줄임표
///
/// 요구사항: 2.1, 2.2, 2.3, 2.4
class ResponsiveButtonText extends StatelessWidget {
  const ResponsiveButtonText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const double defaultFontSize = 14.0;
  static const double minFontSize = 10.0;
  static const int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return AutoSizeText(
      text,
      style: style ?? context.textTheme.bodyMedium,
      textAlign: textAlign ?? TextAlign.center,
      minFontSize: minFontSize,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
