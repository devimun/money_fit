/// 타이틀 텍스트용 반응형 위젯
/// 화면 타이틀에 사용하며, 최대 2줄까지 허용
library;

import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 화면 타이틀용 반응형 위젯
///
/// 특징:
/// - FittedBox로 텍스트 크기 자동 축소
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

  static const int maxLines = 2;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: style ?? context.textTheme.displaySmall,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
