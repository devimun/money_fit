/// 버튼 텍스트용 반응형 위젯
/// 텍스트가 길어지면 자동 축소하며, 말줄임표 처리
library;

import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 버튼 내 텍스트를 위한 반응형 위젯
///
/// 특징:
/// - FittedBox로 텍스트 크기 자동 축소
/// - 단일 줄 유지
/// - IntrinsicWidth/SegmentedButton 등과 호환
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

  static const int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        // 부모 위젯(SegmentedButton 등)의 foregroundColor를 상속받기 위해
        // DefaultTextStyle을 기본값으로 사용
        style: style ?? DefaultTextStyle.of(context).style,
        textAlign: textAlign ?? TextAlign.center,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
