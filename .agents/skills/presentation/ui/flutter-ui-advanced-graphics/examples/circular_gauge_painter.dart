import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flutter_template/presentation/ui_utils/extensions/context_extensions.dart';

class CircularGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const CircularGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw active progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class CircularProgressGauge extends StatelessWidget {
  final double progress;

  const CircularProgressGauge({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(120, 120),
        painter: CircularGaugePainter(
          progress: progress,
          trackColor: colorScheme.surfaceContainerHighest,
          progressColor: colorScheme.primary,
        ),
      ),
    );
  }
}
