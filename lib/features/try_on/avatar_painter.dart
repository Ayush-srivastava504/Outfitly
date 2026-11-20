import 'package:flutter/material.dart';

enum BodyShape {
  slim('Slim', 0.86),
  regular('Regular', 1.0),
  curvy('Curvy', 1.14);

  const BodyShape(this.label, this.width);
  final String label;

  /// Horizontal scale applied to torso, hips and limbs.
  final double width;
}

const kSkinTones = <Color>[Color(0xFFF6DCC8), Color(0xFFE9BE9C), Color(0xFFD29C74), Color(0xFFAE7651), Color(0xFF85573A), Color(0xFF5C3B27)];

/// Stylised front-facing mannequin drawn in a 300×600 design space and scaled to fit.
/// Garment layer anchors (see try_on_screen.dart) use the same normalised coordinates.
class AvatarPainter extends CustomPainter {
  const AvatarPainter({required this.skin, required this.shape, required this.outline});

  final Color skin;
  final BodyShape shape;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 300, sy = size.height / 600;
    canvas.save();
    canvas.scale(sx, sy);

    final w = shape.width;
    final shade = Color.lerp(skin, Colors.black, 0.12)!;
    final fill = Paint()
      ..shader = LinearGradient(
        colors: [skin, shade],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(0, 0, 300, 600));
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = outline.withValues(alpha: 0.35);

    double x(double v) => 150 + (v - 150) * w; // widen around the centre line

    // Legs.
    for (final side in [-1.0, 1.0]) {
      final leg = Path()
        ..moveTo(x(150 + side * 8), 330)
        ..lineTo(x(150 + side * 44), 330)
        ..quadraticBezierTo(x(150 + side * 46), 450, x(150 + side * 34), 552)
        ..lineTo(x(150 + side * 16), 552)
        ..quadraticBezierTo(x(150 + side * 12), 450, x(150 + side * 8), 330)
        ..close();
      canvas.drawPath(leg, fill);
      canvas.drawPath(leg, stroke);
      // Feet.
      final foot = RRect.fromRectAndRadius(
        Rect.fromLTRB(x(150 + side * (side < 0 ? 40 : 12)), 548, x(150 + side * (side < 0 ? 12 : 40)), 566),
        const Radius.circular(8),
      );
      canvas.drawRRect(foot, fill);
    }

    // Arms.
    for (final side in [-1.0, 1.0]) {
      final arm = Path()
        ..moveTo(x(150 + side * 58), 132)
        ..quadraticBezierTo(x(150 + side * 82), 140, x(150 + side * 84), 200)
        ..lineTo(x(150 + side * 82), 318)
        ..quadraticBezierTo(x(150 + side * 76), 330, x(150 + side * 68), 318)
        ..lineTo(x(150 + side * 64), 210)
        ..close();
      canvas.drawPath(arm, fill);
      canvas.drawPath(arm, stroke);
    }

    // Torso (shoulders → waist → hips).
    final torso = Path()
      ..moveTo(x(92), 132)
      ..quadraticBezierTo(x(150), 112, x(208), 132)
      ..quadraticBezierTo(x(212), 200, x(196), 250)
      ..quadraticBezierTo(x(206), 300, x(196), 340)
      ..lineTo(x(104), 340)
      ..quadraticBezierTo(x(94), 300, x(104), 250)
      ..quadraticBezierTo(x(88), 200, x(92), 132)
      ..close();
    canvas.drawPath(torso, fill);
    canvas.drawPath(torso, stroke);

    // Neck + head.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(136, 92, 28, 30), const Radius.circular(8)), fill);
    final head = Rect.fromCenter(center: const Offset(150, 64), width: 62, height: 76);
    canvas.drawOval(head, fill);
    canvas.drawOval(head, stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(AvatarPainter old) => old.skin != skin || old.shape != shape || old.outline != outline;
}
