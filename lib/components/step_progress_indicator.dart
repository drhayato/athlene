import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentSteps;
  final int goalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentSteps,
    required this.goalSteps,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (currentSteps / goalSteps).clamp(0.0, 1.0);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: CustomPaint(
            painter: ProgressPainter(
              progress: progress,
              progressColor: isDark ? AppTheme.neonCyan : AppTheme.accentBlue,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentSteps.toString(),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: AppTheme.neonCyan.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
            ),
            Text(
              "STEPS",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  ProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 10;

    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    canvas.drawCircle(center, radius, backgroundPaint);

    Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    // Glow effect
    Paint glowPaint = Paint()
      ..color = progressColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 25
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
