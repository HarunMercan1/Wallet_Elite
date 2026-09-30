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
class ColorTheme extends ThemeExtension<ColorTheme> {
  // Brand Colors
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentLight;
  final Color tertiary; // New: 3rd Major Color
  final Color onTertiary; // Text on tertiary

  // Surface & Background
  final Color backgroundLight;
  final Color backgroundDark;
  final Color surfaceLight; // Generic surface
  final Color surfaceDark;

  // Specialized Component Colors
  final Color cardColor; // Main card background
  final Color subtleCardColor; // Secondary/Interactive styling
  final Color surfaceVariant; // New: Distinct surface for active elements
  final Color onSurfaceVariant;
  final Color borderColor; // Dividers, borders
  final Color outline; // New: Stronger border

  // Typography (Theme-specific overrides)
  final Color textPrimary;
  final Color textSecondary;

  // Status Colors
  final Color success;
  final Color error;

  // Meta
  final String name;
  final bool isPremium;

  const ColorTheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentLight,
    required this.tertiary,
    required this.onTertiary,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.cardColor,
    required this.subtleCardColor,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.borderColor,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.name,
    this.success = const Color(0xFF10B981),
    this.error = const Color(0xFFEF4444),
    this.isPremium = false,
  });

  @override
  ColorTheme copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? accent,
    Color? accentLight,
    Color? tertiary,
    Color? onTertiary,
    Color? backgroundLight,
    Color? backgroundDark,
    Color? surfaceLight,
    Color? surfaceDark,
    Color? cardColor,
    Color? subtleCardColor,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? borderColor,
    Color? outline,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? error,
    String? name,
    bool? isPremium,
  }) {
    return ColorTheme(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      cardColor: cardColor ?? this.cardColor,
      subtleCardColor: subtleCardColor ?? this.subtleCardColor,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      borderColor: borderColor ?? this.borderColor,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      name: name ?? this.name,
      success: success ?? this.success,
      error: error ?? this.error,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  ColorTheme lerp(ThemeExtension<ColorTheme>? other, double t) {
    if (other is! ColorTheme) {
      return this;
    }
    return ColorTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      subtleCardColor: Color.lerp(subtleCardColor, other.subtleCardColor, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      name: name,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      isPremium: isPremium,
    );
  }

  // 1. Ultra Premium (The Ultra Premium - Siyah & Altın)
  static const elite = ColorTheme(
    primary: Color(0xFFCCA43B),
    primaryLight: Color(0xFFFFD700),
    primaryDark: Color(0xFF8F7018),
    accent: Color(0xFFFFD700),
    accentLight: Color(0xFFFFF4CC),
    tertiary: Color(0xFFE5C158), // Gold Variation
    onTertiary: Colors.black,
    backgroundLight: Color(0xFFFAFAFA),
    backgroundDark: Color(0xFF000000),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF141414),
    cardColor: Color(0xFF141414),
    subtleCardColor: Color(0xFF1C1C1C),
    surfaceVariant: Color(0xFF27272A), // Lighter black
    onSurfaceVariant: Color(0xFFD4AF37), // Gold text
    borderColor: Color(0xFF27272A),
    outline: Color(0xFF3F3F46),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFA1A1AA),
    success: Color(0xFF00E676),
    error: Color(0xFFFF4D4D),
    name: 'Ultra Premium',
    isPremium: true,
  );

  // 2. Midnight Fintech (Modern Lacivert & Slate - REFINED)
  static const midnight = ColorTheme(
    primary: Color(0xFF3B82F6), // Blue 500
    primaryLight: Color(0xFF60A5FA),
    primaryDark: Color(0xFF1D4ED8),
    accent: Color(0xFF1E293B),
    accentLight: Color(0xFF334155),
    tertiary: Color(0xFF6366F1), // Indigo 500 (3rd color)
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFF8FAFC),
    backgroundDark: Color(0xFF020617), // Slate 950
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF0F172A), // Slate 900
    cardColor: Color(0xFF0F172A), // Slate 900
    subtleCardColor: Color(0xFF1E293B), // Slate 800
    surfaceVariant: Color(0xFF334155), // Slate 700 - VISIBLE BUTTONS
    onSurfaceVariant: Color(0xFFF1F5F9), // Slate 100
    borderColor: Color(0xFF1E293B), // Slate 800
    outline: Color(0xFF475569), // Slate 600
    textPrimary: Color(0xFFF8FAFC), // Slate 50
    textSecondary: Color(0xFF94A3B8), // Slate 400
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    name: 'Midnight Fintech',
    isPremium: false,
  );

  // 3. Cyber Amethyst (Tech-Vibe Mor - Derin & Asil)
  static const amethyst = ColorTheme(
    primary: Color(0xFF8B5CF6),
    primaryLight: Color(0xFFA78BFA),
    primaryDark: Color(0xFF6D28D9),
    accent: Color(0xFFC084FC),
    accentLight: Color(0xFFE9D5FF),
    tertiary: Color(0xFFD946EF), // Fuchsia
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFFAF5FF),
    backgroundDark: Color(0xFF0F0B1A),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF151026),
    cardColor: Color(0xFF151026),
    subtleCardColor: Color(0xFF2E2150),
    surfaceVariant: Color(0xFF4C1D95), // Deep Violet
    onSurfaceVariant: Color(0xFFE9D5FF),
    borderColor: Color(0xFF2E2150),
    outline: Color(0xFF5B21B6),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFE9D5FF),
    success: Color(0xFF10B981),
    error: Color(0xFFF43F5E),
    name: 'Cyber Amethyst',
    isPremium: true,
  );

  // 4. Nordic Forest (Zengin Yeşil - Organik)
  static const forest = ColorTheme(
    primary: Color(0xFF059669),
    primaryLight: Color(0xFF34D399),
    primaryDark: Color(0xFF047857),
    accent: Color(0xFFD1FAE5),
    accentLight: Color(0xFFE6FFFA),
    tertiary: Color(0xFF059669),
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFF0FDF4),
    backgroundDark: Color(0xFF01130E),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF021F16),
    cardColor: Color(0xFF021F16),
    subtleCardColor: Color(0xFF064E3B),
    surfaceVariant: Color(0xFF065F46),
    onSurfaceVariant: Color(0xFFD1FAE5),
    borderColor: Color(0xFF064E3B),
    outline: Color(0xFF047857),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFA7F3D0),
    success: Color(0xFF34D399),
    error: Color(0xFFEF4444),
    name: 'Nordic Forest',
    isPremium: true,
  );

  // 5. Blood Carbon (Güçlü & Modern Kırmızı)
  static const carbon = ColorTheme(
    primary: Color(0xFFDC2626),
    primaryLight: Color(0xFFF87171),
    primaryDark: Color(0xFFB91C1C),
    accent: Color(0xFFFDA4AF),
    accentLight: Color(0xFFFFF1F2),
    tertiary: Color(0xFF991B1B),
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFFEF2F2),
    backgroundDark: Color(0xFF0F0505),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF1A0A0A),
    cardColor: Color(0xFF1A0A0A),
    subtleCardColor: Color(0xFF2A1010),
    surfaceVariant: Color(0xFF450A0A),
    onSurfaceVariant: Color(0xFFFECACA),
    borderColor: Color(0xFF2A1010),
    outline: Color(0xFF7F1D1D),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFFECACA),
    success: Color(0xFF2DD4BF),
    error: Color(0xFFEF4444),
    name: 'Blood Carbon',
    isPremium: true,
  );

  // 6. Minimalist Ivory (Aydınlık & Temiz Zinc)
  static const ivory = ColorTheme(
    primary: Color(0xFF18181B),
    primaryLight: Color(0xFF3F3F46),
    primaryDark: Color(0xFF09090B),
    accent: Color(0xFFE4E4E7),
    accentLight: Color(0xFFFAFAFA),
    tertiary: Color(0xFF52525B),
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFFAFAFA),
    backgroundDark: Color(0xFF18181B),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF27272A),
    cardColor: Color(0xFF27272A),
    subtleCardColor: Color(0xFF3F3F46),
    surfaceVariant: Color(0xFF52525B),
    onSurfaceVariant: Colors.white,
    borderColor: Color(0xFF3F3F46),
    outline: Color(0xFF71717A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFA1A1AA),
    success: Color(0xFF059669),
    error: Color(0xFFE11D48),
    name: 'Minimalist Ivory',
    isPremium: true,
  );

  // 7. Oceanic Deep (Derin Okyanus & Camgöbeği)
  static const ocean = ColorTheme(
    primary: Color(0xFF06B6D4),
    primaryLight: Color(0xFF67E8F9),
    primaryDark: Color(0xFF0E7490),
    accent: Color(0xFF164E63),
    accentLight: Color(0xFFCFFAFE),
    tertiary: Color(0xFF0891B2),
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFECFEFF),
    backgroundDark: Color(0xFF083344),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF164E63),
    cardColor: Color(0xFF164E63),
    subtleCardColor: Color(0xFF155E75),
    surfaceVariant: Color(0xFF0E7490),
    onSurfaceVariant: Color(0xFFCFFAFE),
    borderColor: Color(0xFF155E75),
    outline: Color(0xFF155E75),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFCFFAFE),
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    name: 'Oceanic Deep',
    isPremium: true,
  );

  // 8. Royal Velvet (Lüks Bordo & Amber)
  static const velvet = ColorTheme(
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFCD34D),
    primaryDark: Color(0xFFB45309),
    accent: Color(0xFF7F1D1D),
    accentLight: Color(0xFFFEF3C7),
    tertiary: Color(0xFF92400E),
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFFEF2F2),
    backgroundDark: Color(0xFF450A0A),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF7F1D1D),
    cardColor: Color(0xFF7F1D1D),
    subtleCardColor: Color(0xFF991B1B),
    surfaceVariant: Color(0xFFB91C1C),
    onSurfaceVariant: Color(0xFFFEF3C7),
    borderColor: Color(0xFF991B1B),
    outline: Color(0xFFB91C1C),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFFEF3C7),
    success: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    name: 'Royal Velvet',
    isPremium: true,
  );

  // 9. Slate & Electric Blue (Mühendis Favorisi - Teknik & Net)
  static const slate = ColorTheme(
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFF60A5FA),
    primaryDark: Color(0xFF2563EB),
    accent: Color(0xFF94A3B8),
    accentLight: Color(0xFFE2E8F0),
    tertiary: Color(0xFF64748B),
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFF8FAFC),
    backgroundDark: Color(0xFF0F172A),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF1E293B),
    cardColor: Color(0xFF1E293B),
    subtleCardColor: Color(0xFF334155),
    surfaceVariant: Color(0xFF475569),
    onSurfaceVariant: Colors.white,
    borderColor: Color(0xFF334155),
    outline: Color(0xFF64748B),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFCBD5E1),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    name: 'Slate & Electric',
    isPremium: true,
  );

  // 10. Rose Graphite (Yumuşak Lüks - Modern & Sıcak)
  static const rose = ColorTheme(
    primary: Color(0xFFFB7185),
    primaryLight: Color(0xFFFDA4AF),
    primaryDark: Color(0xFFE11D48),
    accent: Color(0xFFE7E5E4),
    accentLight: Color(0xFFF5F5F4),
    tertiary: Color(0xFFE11D48),
    onTertiary: Colors.white,
    backgroundLight: Color(0xFFFFF1F2),
    backgroundDark: Color(0xFF1C1917),
    surfaceLight: Colors.white,
    surfaceDark: Color(0xFF292524),
    cardColor: Color(0xFF292524),
    subtleCardColor: Color(0xFF44403C),
    surfaceVariant: Color(0xFF57534E),
    onSurfaceVariant: Color(0xFFE7E5E4),
    borderColor: Color(0xFF44403C),
    outline: Color(0xFF78716C),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFE7E5E4),
    success: Color(0xFF2ECC71),
    error: Color(0xFFE11D48),
    name: 'Rose Graphite',
    isPremium: true,
  );

  static ColorTheme fromString(String scheme) {
    switch (scheme) {
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
        return elite;
      case 'midnight':
      default:
        return midnight;
    }
  }

  static List<ColorTheme> get all => [
    midnight,
    elite,
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

  // Helper getters for transaction colors
  Color get income => success;
  Color get expense => error;
  Color get cardDark => surfaceDark;
  Color get cardLight => surfaceLight;

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
    if (this == elite) return 'elite';
    // Midnight default
    return 'midnight';
  }
}
