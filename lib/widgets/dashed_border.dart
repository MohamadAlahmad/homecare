import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:homecare/core/theme/themes.dart';

class DashedBorder extends StatelessWidget {
  final Widget child;

  const DashedBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = HomeCareTheme.primaryColor // Border color
      ..strokeWidth = 1 // Border thickness
      ..style = PaintingStyle.stroke;

    final double dashWidth = 6; // Width of a dash
    final double dashSpace = 4; // Space between dashes
    double startX = 0;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(20), // Rounded corners
        ),
      );

    final PathMetrics pathMetrics = path.computeMetrics();

    for (final PathMetric metric in pathMetrics) {
      while (startX < metric.length) {
        canvas.drawPath(
          metric.extractPath(startX, startX + dashWidth),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
      startX = 0; // Reset for other sides of the path
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}