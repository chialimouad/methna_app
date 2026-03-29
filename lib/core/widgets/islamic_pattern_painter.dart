import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  IslamicPatternPainter({required this.color, this.opacity = 0.05});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double step = 60.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, Offset(x, y), 25, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 8;
    for (int i = 0; i < points * 2; i++) {
      double r = (i.isEven) ? radius : radius * 0.5;
      double angle = i * math.pi / points;
      double x = center.dx + r * math.cos(angle);
      double y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class IslamicPatternWidget extends StatelessWidget {
  final Color? color;
  final double opacity;

  const IslamicPatternWidget({super.key, this.color, this.opacity = 0.05});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawColor = color ?? (isDark ? Colors.white : Colors.black);
    
    return CustomPaint(
      painter: IslamicPatternPainter(color: drawColor, opacity: opacity),
      child: Container(),
    );
  }
}
