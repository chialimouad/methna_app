// AGENTIC_STABILIZATION_V2
import 'package:flutter/material.dart';

class MihrabClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double width = size.width;
    double height = size.height;

    path.lineTo(0, height);
    path.lineTo(width, height);
    path.lineTo(width, 20); // Start of arch

    // Mihrab arch
    path.quadraticBezierTo(width * 0.9, 0, width * 0.5, 0);
    path.quadraticBezierTo(width * 0.1, 0, 0, 20);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MihrabBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  MihrabBorderPainter({required this.color, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    var path = Path();
    double width = size.width;

    path.lineTo(0, size.height);
    path.lineTo(width, size.height);
    path.lineTo(width, 20);

    path.quadraticBezierTo(width * 0.9, 0, width * 0.5, 0);
    path.quadraticBezierTo(width * 0.1, 0, 0, 20);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
