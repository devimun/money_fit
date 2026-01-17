/// 메시지 텍스트용 위젯
/// ConstrainedBox로 높이 제한하여 UI 침범 방지
library;

import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

/// 알림/메시지용 반응형 위젯 (홈 화면 상태 메시지 등)
///
/// 특징:
/// - ConstrainedBox로 높이 제한 (minHeight: 40, maxHeight: 60)
/// - FittedBox로 텍스트 크기 자동 축소
/// - 최대 2줄까지 허용
/// - UI 침범 방지
///
/// 요구사항: 6.1, 6.2, 6.3, 6.4
class ResponsiveMessageText extends StatelessWidget {
  const ResponsiveMessageText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  static const int maxLines = 2;
  static const double minHeight = 40.0;
  static const double maxHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: style ?? context.textTheme.bodyLarge,
          textAlign: textAlign ?? TextAlign.center,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
