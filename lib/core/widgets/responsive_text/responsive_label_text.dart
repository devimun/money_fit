/// 라벨 텍스트용 반응형 위젯
/// 폼 라벨이나 통계 라벨에 사용
library;

import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 폼 라벨용 반응형 위젯
///
/// 특징:
/// - FittedBox로 텍스트 크기 자동 축소
/// - 단일 줄 유지
/// - IntrinsicHeight/IntrinsicWidth와 호환
///
/// 요구사항: 5.1, 5.2, 5.3
class ResponsiveLabelText extends StatelessWidget {
  const ResponsiveLabelText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: style ?? context.textTheme.labelMedium,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
