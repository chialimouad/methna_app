import 'dart:math';
import 'package:flutter/material.dart';
import 'package:methna_app/app/theme/app_colors.dart';

class RadarAnimation extends StatefulWidget {
  final double size;
  final int rings;
  final Color color;
  final List<Offset>? dots;

  const RadarAnimation({
    super.key,
    this.size = 300,
    this.rings = 4,
    this.color = AppColors.primary,
    this.dots,
  });

  @override
  State<RadarAnimation> createState() => _RadarAnimationState();
}

class _RadarAnimationState extends State<RadarAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RadarPainter(
              progress: _controller.value,
              rings: widget.rings,
              color: widget.color,
              dots: widget.dots,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final int rings;
  final Color color;
  final List<Offset>? dots;

  _RadarPainter({
    required this.progress,
    required this.rings,
    required this.color,
    this.dots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw rings
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= rings; i++) {
      final radius = maxRadius * (i / rings);
      canvas.drawCircle(center, radius, ringPaint);
    }

    // Draw cross lines
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);

    // Draw sweep
    final sweepAngle = progress * 2 * pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 0.8,
        endAngle: sweepAngle,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 1.0],
        transform: GradientRotation(sweepAngle - 0.8),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Draw sweep line
    final lineEndX = center.dx + maxRadius * cos(sweepAngle - pi / 2);
    final lineEndY = center.dy + maxRadius * sin(sweepAngle - pi / 2);
    final sweepLinePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(lineEndX, lineEndY), sweepLinePaint);

    // Draw center dot
    final centerDotPaint = Paint()..color = color;
    canvas.drawCircle(center, 5, centerDotPaint);

    // Draw user dots
    if (dots != null) {
      final dotPaint = Paint()..color = color;
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      for (final dot in dots!) {
        final x = center.dx + dot.dx * maxRadius;
        final y = center.dy + dot.dy * maxRadius;
        canvas.drawCircle(Offset(x, y), 8, glowPaint);
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
      }
    }

    // Pulse ring
    final pulseRadius = maxRadius * (0.3 + 0.7 * progress);
    final pulsePaint = Paint()
      ..color = color.withValues(alpha: 0.1 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, pulseRadius, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.dots != dots;
}
