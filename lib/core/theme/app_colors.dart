// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Color scheme types available in the app
enum ColorSchemeType {
  elite, // Original - Midnight Blue & Gold
  ocean, // Teal & Coral
  forest, // Green & Amber
  rose, // Rose & Purple
}

/// Application color palettes
class AppColors {
  // === ELITE THEME (Midnight Blue & Gold) - DEFAULT ===
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E293B);
  static const Color accent = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFF4CC);

  // Background - shared across all themes
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  // Surface - shared across all themes
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);

  // Text - shared across all themes
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDark = Color(0xFFF1F5F9);

  // Status - shared across all themes
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}

/// Color theme definitions for different palettes
class ColorTheme {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentLight;
  final String name;

  const ColorTheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentLight,
    required this.name,
  });

  // Elite Theme
  static const elite = ColorTheme(
    primary: Color(0xFF1E3A8A),
    primaryLight: Color(0xFF3B82F6),
    primaryDark: Color(0xFF1E293B),
    accent: Color(0xFFFFD700),
    accentLight: Color(0xFFFFF4CC),
    name: 'Elite',
  );

  // Ocean Theme
  static const ocean = ColorTheme(
    primary: Color(0xFF0D9488),
    primaryLight: Color(0xFF14B8A6),
    primaryDark: Color(0xFF115E59),
    accent: Color(0xFFF97316),
    accentLight: Color(0xFFFED7AA),
    name: 'Ocean',
  );

  // Forest Theme
  static const forest = ColorTheme(
    primary: Color(0xFF059669),
    primaryLight: Color(0xFF10B981),
    primaryDark: Color(0xFF064E3B),
    accent: Color(0xFFF59E0B),
    accentLight: Color(0xFFFEF3C7),
    name: 'Forest',
  );

  // Rose Theme
  static const rose = ColorTheme(
    primary: Color(0xFFE11D48),
    primaryLight: Color(0xFFFB7185),
    primaryDark: Color(0xFF9F1239),
    accent: Color(0xFF8B5CF6),
    accentLight: Color(0xFFDDD6FE),
    name: 'Rose',
  );

  static ColorTheme fromString(String scheme) {
    switch (scheme) {
      case 'ocean':
        return ocean;
      case 'forest':
        return forest;
      case 'rose':
        return rose;
      case 'elite':
      default:
        return elite;
    }
  }

  static List<ColorTheme> get all => [elite, ocean, forest, rose];

  String get id {
    if (this == elite) return 'elite';
    if (this == ocean) return 'ocean';
    if (this == forest) return 'forest';
    if (this == rose) return 'rose';
    return 'elite';
  }
}
