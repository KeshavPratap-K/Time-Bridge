import 'dart:math';
import 'package:flutter/material.dart';

/// A custom Material 3 logo for Dual Clock representing global time synchronization.
class AppLogo extends StatelessWidget {
  final double size;
  final bool animate;

  const AppLogo({
    super.key,
    this.size = 96,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.tertiary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Clock dial ring
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.onPrimary.withValues(alpha: 0.25),
                width: size * 0.025,
              ),
            ),
          ),
          // Clock Face Painter
          CustomPaint(
            size: Size(size * 0.82, size * 0.82),
            painter: _ClockLogoPainter(
              color: colorScheme.onPrimary,
              accentColor: colorScheme.primaryContainer,
            ),
          ),
          // Center core
          Container(
            width: size * 0.14,
            height: size * 0.14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.onPrimary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockLogoPainter extends CustomPainter {
  final Color color;
  final Color accentColor;

  _ClockLogoPainter({required this.color, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw hour tick marks
    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = size.width * 0.025
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final outer = Offset(
        center.dx + radius * 0.9 * cos(angle),
        center.dy + radius * 0.9 * sin(angle),
      );
      final inner = Offset(
        center.dx + radius * 0.76 * cos(angle),
        center.dy + radius * 0.76 * sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Hour Hand (pointing roughly to 10 o'clock)
    final hourAngle = (-60) * pi / 180;
    final hourHandPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.48 * cos(hourAngle),
        center.dy + radius * 0.48 * sin(hourAngle),
      ),
      hourHandPaint,
    );

    // Minute Hand (pointing to 2 o'clock / 10 min)
    final minuteAngle = (30) * pi / 180;
    final minuteHandPaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.68 * cos(minuteAngle),
        center.dy + radius * 0.68 * sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // Secondary Time Hand (dashed/accent for world time hand)
    final worldHandAngle = (165) * pi / 180;
    final worldHandPaint = Paint()
      ..color = accentColor
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.62 * cos(worldHandAngle),
        center.dy + radius * 0.62 * sin(worldHandAngle),
      ),
      worldHandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
