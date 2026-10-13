// lib/core/widgets/google_logo.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dört renkli Google "G" simgesi ("Google ile devam et" butonu için).
/// Harici ikon paketi gerektirmeden çizilir.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    double rad(double degrees) => degrees * math.pi / 180;
    void arc(double from, double to, Color color) {
      canvas.drawArc(
        rect,
        rad(from),
        rad(to - from),
        false,
        paint..color = color,
      );
    }

    // Açılar saat yönünde, 0° = sağ. Sağ üstteki boşluk harfin ağzıdır.
    arc(0, 45, _blue);
    arc(45, 135, _green);
    arc(135, 215, _yellow);
    arc(215, 315, _red);

    // Ortadan sağa uzanan yatay çubuk
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2,
        size.height / 2 - stroke / 2,
        size.width / 2,
        stroke,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
