import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/theme/design_palette.dart';
import 'package:money_fit/features/home/widgets/circle_progress_painter.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class AnimatedCircularBudget extends StatelessWidget {
  final double ratio; // 0.0 ~ 1.0
  final Color color;
  final double remainingAmount;
  final bool isMonthly; // 월간 모드인지 여부

  const AnimatedCircularBudget({
    super.key,
    required this.ratio,
    required this.color,
    required this.remainingAmount,
    this.isMonthly = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size.width * 0.55;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 500),
      builder: (context, animatedRatio, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: CircleProgressPainter(
                  progress: animatedRatio,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.remainingAmount,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(color: LightAppColors.textSecondary),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formatCurrencyAdaptive(context, remainingAmount),
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
