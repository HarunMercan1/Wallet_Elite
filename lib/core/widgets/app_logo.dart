// lib/core/widgets/app_logo.dart

import 'package:flutter/material.dart';

/// Uygulama logosu (altın para + taç), simge gibi yuvarlatılmış köşelerle.
class AppLogo extends StatelessWidget {
  /// Logonun altın tonu; logonun etrafındaki parıltı için.
  static const glowColor = Color(0xFFE39A1C);

  final double size;

  const AppLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.23),
      child: Image.asset(
        'assets/icon/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
