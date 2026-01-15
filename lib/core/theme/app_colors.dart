// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Color scheme types available in the app
enum ColorSchemeType {
  elite,
  midnight,
  amethyst,
  forest,
  carbon,
  ivory,
  ocean,
  velvet,
  slate,
  rose,
}

/// Application color palettes
class AppColors {
  // Shared functional colors (defaults, might be overridden by themes)
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Legacy text colors (prefer using theme text colors)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
}

/// Color theme definitions for different palettes
class ColorTheme {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentLight;
  final Color backgroundLight;
  final Color backgroundDark;
  final Color surfaceLight;
  final Color surfaceDark;
  final Color success;
  final Color error;
  final String name;
  final bool isPremium;

  const ColorTheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentLight,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.name,
    this.success = const Color(0xFF10B981),
    this.error = const Color(0xFFEF4444),
    this.isPremium = false,
  });

  // 1. Ultra Premium (The Ultra Premium - Siyah & Altın)
  static const elite = ColorTheme(
    primary: Color(0xFFD4AF37), // Gold
    primaryLight: Color(0xFFFFD700),
    primaryDark: Color(0xFFB4941F),
    accent: Color(0xFFFFD700),
    accentLight: Color(0xFFFFF4CC),
    backgroundLight: Color(0xFFFAFAFA), // Fallback for light mode if used
    backgroundDark: Color(0xFF000000), // Tam Siyah (OLED)
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF121212), // Hafif Gri-Siyah
    success: Color(0xFF00E676),
    error: Color(0xFFFF4D4D),
    name: 'Ultra Premium',
    isPremium: false, // Default theme can remain free
  );

  // 2. Midnight Fintech (Modern Lacivert)
  static const midnight = ColorTheme(
    primary: Color(0xFF007BFF), // Canlı Saf Mavi
    primaryLight: Color(0xFF3395FF),
    primaryDark: Color(0xFF0056B3),
    accent: Color(0xFFE0E7FF),
    accentLight: Color(0xFFF0F4FF),
    backgroundLight: Color(0xFFF8FAFC),
    backgroundDark: Color(0xFF0B0E14), // Çok Koyu Lacivert
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF1A1F2B), // Mavimsi Gri Kartlar
    success: Color(0xFF34D399),
    error: Color(0xFFFB7185),
    name: 'Midnight Fintech',
    isPremium: true,
  );

  // 3. Cyber Amethyst (Tech-Vibe Mor)
  static const amethyst = ColorTheme(
    primary: Color(0xFF8B5CF6), // Canlı Mor
    primaryLight: Color(0xFFA78BFA),
    primaryDark: Color(0xFF7C3AED),
    accent: Color(0xFFC084FC),
    accentLight: Color(0xFFE9D5FF),
    backgroundLight: Color(0xFFF3E8FF),
    backgroundDark: Color(0xFF0F172A),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF1E293B),
    success: Color(0xFF10B981),
    error: Color(0xFFF43F5E),
    name: 'Cyber Amethyst',
    isPremium: true,
  );

  // 4. Nordic Forest (Zengin Yeşil)
  static const forest = ColorTheme(
    primary: Color(0xFF10B981), // Zümrüt
    primaryLight: Color(0xFF34D399),
    primaryDark: Color(0xFF059669),
    accent: Color(0xFFD1FAE5),
    accentLight: Color(0xFFE6FFFA),
    backgroundLight: Color(0xFFECFDF5),
    backgroundDark: Color(0xFF022C22), // Koyu Orman Yeşili
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF064E3B),
    success: Color(0xFF34D399),
    error: Color(0xFFEF4444),
    name: 'Nordic Forest',
    isPremium: true,
  );

  // 5. Blood Carbon (Agresif & Güçlü)
  static const carbon = ColorTheme(
    primary: Color(0xFFE11D48), // Vişne Kırmızısı
    primaryLight: Color(0xFFFB7185),
    primaryDark: Color(0xFF9F1239),
    accent: Color(0xFFFDA4AF),
    accentLight: Color(0xFFFFF1F2),
    backgroundLight: Color(0xFFFFF5F5),
    backgroundDark: Color(0xFF111111),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF1F1F1F),
    success: Color(0xFF2DD4BF),
    error: Color(0xFFFB7185),
    name: 'Blood Carbon',
    isPremium: true,
  );

  // 6. Minimalist Ivory (Aydınlık Elite)
  static const ivory = ColorTheme(
    primary: Color(0xFF18181B), // Koyu Zinc
    primaryLight: Color(0xFF3F3F46),
    primaryDark: Color(0xFF09090B),
    accent: Color(0xFFE4E4E7),
    accentLight: Color(0xFFFAFAFA),
    backgroundLight: Color(0xFFFAFAFA), // Kırık Beyaz
    backgroundDark: Color(0xFF18181B), // Fallback
    surfaceLight: Color(0xFFFFFFFF), // Bembeyaz Kartlar
    surfaceDark: Color(0xFF27272A),
    success: Color(0xFF059669),
    error: Color(0xFFE11D48),
    name: 'Minimalist Ivory',
    isPremium: true,
  );

  // 7. Oceanic Deep (Turkuaz & Gece)
  static const ocean = ColorTheme(
    primary: Color(0xFF22D3EE), // Turkuaz
    primaryLight: Color(0xFF67E8F9),
    primaryDark: Color(0xFF0E7490),
    accent: Color(0xFF94A3B8),
    accentLight: Color(0xFFCBD5E1),
    backgroundLight: Color(0xFFECFEFF),
    backgroundDark: Color(0xFF020617),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF0F172A),
    success: Color(0xFF4ADE80),
    error: Color(0xFFF87171),
    name: 'Oceanic Deep',
    isPremium: true,
  );

  // 8. Royal Velvet (Asil Bordo)
  static const velvet = ColorTheme(
    primary: Color(0xFFFDE047), // Mat Sarı
    primaryLight: Color(0xFFFEF08A),
    primaryDark: Color(0xFFEAB308),
    accent: Color(0xFF7F1D1D),
    accentLight: Color(0xFF991B1B),
    backgroundLight: Color(0xFFFEF2F2),
    backgroundDark: Color(0xFF450A0A), // Çok Koyu Bordo
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF7F1D1D),
    success: Color(0xFFFDE047), // Gelir için Sarı (User spec)
    error: Color(0xFFF87171),
    name: 'Royal Velvet',
    isPremium: true,
  );

  // 9. Slate & Electric Blue (Mühendis Favorisi)
  static const slate = ColorTheme(
    primary: Color(0xFF3B82F6), // Elektrik Mavisi
    primaryLight: Color(0xFF60A5FA),
    primaryDark: Color(0xFF2563EB),
    accent: Color(0xFF94A3B8),
    accentLight: Color(0xFFE2E8F0),
    backgroundLight: Color(0xFFF8FAFC),
    backgroundDark: Color(0xFF0F172A),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF1E293B),
    success: Color(0xFF22C55E),
    error: Color(
      0xFFEF4444,
    ), // Warning specified as F59E0B, keep error red unless typical
    name: 'Slate & Electric',
    isPremium: true,
  );

  // 10. Rose Graphite (Yumuşak Lüks)
  static const rose = ColorTheme(
    primary: Color(0xFFFB7185), // Gül Kurusu
    primaryLight: Color(0xFFFDA4AF),
    primaryDark: Color(0xFFE11D48),
    accent: Color(0xFFE4E4E7), // Grey-ish
    accentLight: Color(0xFFF4F4F5),
    backgroundLight: Color(0xFFFFF1F2),
    backgroundDark: Color(0xFF18181B),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF27272A),
    success: Color(0xFF2ECC71),
    error: Color(0xFFE11D48),
    name: 'Rose Graphite',
    isPremium: true,
  );

  static ColorTheme fromString(String scheme) {
    switch (scheme) {
      case 'midnight':
        return midnight;
      case 'amethyst':
        return amethyst;
      case 'forest':
        return forest;
      case 'carbon':
        return carbon;
      case 'ivory':
        return ivory;
      case 'ocean':
        return ocean;
      case 'velvet':
        return velvet;
      case 'slate':
        return slate;
      case 'rose':
        return rose;
      case 'elite':
      default:
        return elite;
    }
  }

  static List<ColorTheme> get all => [
    elite,
    midnight,
    amethyst,
    forest,
    carbon,
    ivory,
    ocean,
    velvet,
    slate,
    rose,
  ];

  static List<ColorTheme> get freeThemes =>
      all.where((t) => !t.isPremium).toList();

  static List<ColorTheme> get premiumThemes =>
      all.where((t) => t.isPremium).toList();

  String get id {
    if (this == midnight) return 'midnight';
    if (this == amethyst) return 'amethyst';
    if (this == forest) return 'forest';
    if (this == carbon) return 'carbon';
    if (this == ivory) return 'ivory';
    if (this == ocean) return 'ocean';
    if (this == velvet) return 'velvet';
    if (this == slate) return 'slate';
    if (this == rose) return 'rose';
    // Elite default
    return 'elite';
  }
}
