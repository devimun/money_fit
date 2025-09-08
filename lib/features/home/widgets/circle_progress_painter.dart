import 'package:flutter/material.dart';

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({required this.progress, required this.color});

  @override
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    const double fullCircle = 2 * 3.141592;
    const double gapRatio = 0.06;
    final gap = fullCircle * gapRatio;

    double startAngle = -3.141592 / 2 + gap / 2;
    double sweepAngle;

    if (progress > 0.96) {
      // 꽉 찼을 때 gap 두기
      sweepAngle = fullCircle - gap;
    } else {
      // 진행도에 따라 gap 포함 비율 맞추기
      sweepAngle = fullCircle * progress;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
