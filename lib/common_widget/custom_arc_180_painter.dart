import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;
import '../common/color_extension.dart';

class CustomArcPainter extends CustomPainter {
  final double end; // 0.0 to 1.0 (percentage)
  final double width;
  final double bgWidth;
  final double blurWidth;

  CustomArcPainter({
    required this.end,
    this.width = 15,
    this.bgWidth = 10,
    this.blurWidth = 4, required double usedBudget, required double totalBudget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Paint for background arc
    final bgPaint = Paint()
      ..color = TColor.gray60.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = bgWidth
      ..strokeCap = StrokeCap.round;

    // Draw full 180° background arc
    canvas.drawArc(rect, vm.radians(180), vm.radians(180), false, bgPaint);

    if (end <= 0) return;

    final usedPercent = end.clamp(0.0, 1.0);
    final usedDegrees = 180 * usedPercent;
    
    // Define the percentage thresholds
    const safeLimit = 0.50;    // 50% - Green zone
    const warningLimit = 0.75; // 75% - Yellow zone
    
    final safeDegrees = 180 * safeLimit;
    final warningDegrees = 180 * warningLimit;

    double startAngle = vm.radians(180); // Starting from 180°

    if (usedPercent <= safeLimit) {
      // Green zone: 0% - 50%
      _drawArcSegment(
        canvas,
        rect,
        startAngle,
        vm.radians(usedDegrees),
        Colors.green,
      );
    } else if (usedPercent <= warningLimit) {
      // Draw green segment up to 50%
      _drawArcSegment(
        canvas,
        rect,
        startAngle,
        vm.radians(safeDegrees),
        Colors.green,
      );

      // Yellow zone: 50% - 75%
      final yellowStartAngle = startAngle + vm.radians(safeDegrees);
      final yellowSweepAngle = vm.radians(usedDegrees - safeDegrees);
      
      _drawArcSegment(
        canvas,
        rect,
        yellowStartAngle,
        yellowSweepAngle,
        Colors.amber,
      );
    } else {
      // Draw green segment up to 50%
      _drawArcSegment(
        canvas,
        rect,
        startAngle,
        vm.radians(safeDegrees),
        Colors.green,
      );

      // Draw yellow segment from 50% to 75%
      final yellowStartAngle = startAngle + vm.radians(safeDegrees);
      final yellowSweepAngle = vm.radians(warningDegrees - safeDegrees);
      
      _drawArcSegment(
        canvas,
        rect,
        yellowStartAngle,
        yellowSweepAngle,
        Colors.amber,
      );

      // Red zone: 75% and above
      final redStartAngle = startAngle + vm.radians(warningDegrees);
      final redSweepAngle = vm.radians(usedDegrees - warningDegrees);
      
      _drawArcSegment(
        canvas,
        rect,
        redStartAngle,
        redSweepAngle,
        Colors.red,
      );
    }
  }

  void _drawArcSegment(Canvas canvas, Rect rect, double start, double sweep, Color color) {
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + blurWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final path = Path()..addArc(rect, start, sweep);
    canvas.drawPath(path, shadowPaint);
    canvas.drawArc(rect, start, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(CustomArcPainter oldDelegate) =>
      oldDelegate.end != end;

  @override
  bool shouldRebuildSemantics(CustomArcPainter oldDelegate) => false;
}

// Helper methods for the end parameter version
class ArcHelper {
  static String getStatusFromEnd(double end) {
    final percentage = (end * 100);
    
    if (percentage <= 50) {
      return 'Safe Zone';
    } else if (percentage <= 75) {
      return 'Warning Zone';
    } else {
      return 'Critical Zone';
    }
  }
  
  static String? getNotificationFromEnd(double end) {
    final percentage = (end * 100);
    
    if (percentage > 50 && percentage <= 75) {
      return "You are approaching your budget limit.";
    } else if (percentage > 75) {
      return "You have exceeded the safe limit. Please reduce your spending.";
    }
    
    return null;
  }
}