/// 설명 텍스트용 위젯
/// 폰트 크기 고정, 자연 줄바꿈 사용
library;

import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 설명 텍스트용 위젯 (폰트 축소 없음)
///
/// 특징:
/// - 폰트 크기 고정 (축소하지 않음)
/// - 자연 줄바꿈 사용 (softWrap: true)
/// - 줄 수 제한 없음 (스크롤 컨테이너 내에서 사용)
///
/// 요구사항: 4.1, 4.2, 4.3, 4.4
class ResponsiveDescriptionText extends StatelessWidget {
  const ResponsiveDescriptionText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const double defaultFontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Text(
      text,
      style: style ?? context.textTheme.bodyLarge,
      textAlign: textAlign,
      softWrap: true,
    );
  }
}
