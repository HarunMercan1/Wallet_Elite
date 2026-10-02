// lib/core/widgets/app_logo.dart

import 'package:flutter/material.dart';

/// Uygulama logosu (taçlı cüzdan), simge gibi yuvarlatılmış köşelerle.
class AppLogo extends StatelessWidget {
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
