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

/// Bir temanın tek bir parlaklık (koyu/açık) için renkleri.
///
/// Her temanın koyu ve açık olmak üzere iki paleti vardır; ekranda kullanılan
/// palet [forBrightness] ile seçilir. Paletler WCAG kontrast oranlarına göre
/// denetlenmiştir; bir rengi değiştirirken şu kurallar korunmalıdır:
///  * [primary], [accent], [tertiary], [success], [error], [warning], [info]
///    kart ve arka plan üzerinde en az 3:1 (simge/yazı olarak görünür),
///  * [onPrimary] → [primary] üzerinde en az 4:1, gradyan uçlarında
///    ([primaryLight], [primaryDark]) en az 3:1,
///  * [onTertiary] → [tertiary] üzerinde en az 4.5:1,
///  * [success] ve [error] üzerinde beyaz yazı en az 3:1 (dolu butonlar),
///  * [textSecondary] kart/arka plan üzerinde en az 4.5:1.
class ColorTheme extends ThemeExtension<ColorTheme> {
  // Meta
  final String id;
  final String name;
  final bool isPremium;
  final Brightness brightness;

  // Brand Colors
  final Color primary;
  final Color primaryLight; // Gradyanın açık ucu
  final Color primaryDark; // Gradyanın koyu ucu
  final Color onPrimary; // primary (ve gradyanı) üzerindeki yazı/simge
  final Color accent; // Yüzeyler üzerinde vurgu simgesi/yazısı
  final Color accentLight; // Yumuşak vurgu zemini
  final Color tertiary; // 3. renk (rozet, ikincil vurgu)
  final Color onTertiary; // tertiary üzerindeki yazı

  // Surface & Background (her iki parlaklıkta aynı değerler)
  final Color backgroundLight;
  final Color backgroundDark;
  final Color surfaceLight;
  final Color surfaceDark;

  // Specialized Component Colors (bu parlaklık için)
  final Color cardColor; // Ana kart zemini
  final Color subtleCardColor; // İkincil/etkileşimli zemin
  final Color surfaceVariant; // Belirgin zemin (seçili/aktif öğeler)
  final Color onSurfaceVariant;
  final Color borderColor; // Ayırıcılar, ince kenarlıklar
  final Color outline; // Daha belirgin kenarlık

  // Typography
  final Color textPrimary;
  final Color textSecondary;

  // Status Colors
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  const ColorTheme({
    required this.id,
    required this.name,
    required this.isPremium,
    required this.brightness,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.onPrimary,
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
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Bu parlaklıktaki sayfa arka planı
  Color get background => isDark ? backgroundDark : backgroundLight;

  /// Kapalı/pasif simgeler ve ipuçları için soluk yazı rengi
  Color get textMuted => textSecondary.withValues(alpha: 0.7);

  /// Aynı temanın istenen parlaklıktaki paleti
  ColorTheme forBrightness(Brightness brightness) {
    if (brightness == this.brightness) return this;
    final palettes = brightness == Brightness.dark ? _dark : _light;
    return palettes[id] ?? this;
  }

  @override
  ColorTheme copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? onPrimary,
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
    Color? warning,
    Color? info,
  }) {
    return ColorTheme(
      id: id,
      name: name,
      isPremium: isPremium,
      brightness: brightness,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
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
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ColorTheme lerp(ThemeExtension<ColorTheme>? other, double t) {
    if (other is! ColorTheme) {
      return this;
    }
    final target = t < 0.5 ? this : other;
    return ColorTheme(
      id: target.id,
      name: target.name,
      isPremium: target.isPremium,
      brightness: target.brightness,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
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
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }

  // ========== Paletler (koyu: herkese açık ad, açık: _<ad>Light) ==========

  static const midnight = ColorTheme(
    id: 'midnight',
    name: 'Midnight Fintech',
    isPremium: false,
    brightness: Brightness.dark,
    primary: Color(0xFF3577F0),
    primaryLight: Color(0xFF4F8AF7),
    primaryDark: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF93C5FD),
    accentLight: Color(0xFF1E3A5F),
    tertiary: Color(0xFF818CF8),
    onTertiary: Color(0xFF0B1026),
    backgroundLight: Color(0xFFF8FAFC),
    backgroundDark: Color(0xFF020617),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF0F172A),
    cardColor: Color(0xFF0F172A),
    subtleCardColor: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    onSurfaceVariant: Color(0xFFF1F5F9),
    borderColor: Color(0xFF1E293B),
    outline: Color(0xFF334155),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _midnightLight = ColorTheme(
    id: 'midnight',
    name: 'Midnight Fintech',
    isPremium: false,
    brightness: Brightness.light,
    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFF3B82F6),
    primaryDark: Color(0xFF1D4ED8),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF1D4ED8),
    accentLight: Color(0xFFDBEAFE),
    tertiary: Color(0xFF4F46E5),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFF8FAFC),
    backgroundDark: Color(0xFF020617),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF0F172A),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFF1F5F9),
    surfaceVariant: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF0F172A),
    borderColor: Color(0xFFE2E8F0),
    outline: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const elite = ColorTheme(
    id: 'elite',
    name: 'Ultra Premium',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFFD4AF37),
    primaryLight: Color(0xFFF2D675),
    primaryDark: Color(0xFFB8922A),
    onPrimary: Color(0xFF1A1400),
    accent: Color(0xFFF2D675),
    accentLight: Color(0xFF3A2F0B),
    tertiary: Color(0xFFF5E6B3),
    onTertiary: Color(0xFF1A1400),
    backgroundLight: Color(0xFFFAF8F2),
    backgroundDark: Color(0xFF000000),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF141414),
    cardColor: Color(0xFF141414),
    subtleCardColor: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF2A2A2A),
    onSurfaceVariant: Color(0xFFF2D675),
    borderColor: Color(0xFF262626),
    outline: Color(0xFF3A3A3A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA1A1AA),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _eliteLight = ColorTheme(
    id: 'elite',
    name: 'Ultra Premium',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFF8F6F12),
    primaryLight: Color(0xFFA8851F),
    primaryDark: Color(0xFF75590B),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF75590B),
    accentLight: Color(0xFFF5ECCB),
    tertiary: Color(0xFF57534E),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFFAF8F2),
    backgroundDark: Color(0xFF000000),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF141414),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFF5F1E6),
    surfaceVariant: Color(0xFFEBE4D0),
    onSurfaceVariant: Color(0xFF1A1814),
    borderColor: Color(0xFFE9E2CF),
    outline: Color(0xFFD6CBA8),
    textPrimary: Color(0xFF1A1814),
    textSecondary: Color(0xFF6B6658),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const amethyst = ColorTheme(
    id: 'amethyst',
    name: 'Cyber Amethyst',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFF8B5CF6),
    primaryLight: Color(0xFF9A70F7),
    primaryDark: Color(0xFF7C3AED),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFC4B5FD),
    accentLight: Color(0xFF2E1F5E),
    tertiary: Color(0xFFE879F9),
    onTertiary: Color(0xFF2A0A30),
    backgroundLight: Color(0xFFFAF7FF),
    backgroundDark: Color(0xFF0D0A17),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF171128),
    cardColor: Color(0xFF171128),
    subtleCardColor: Color(0xFF241A3D),
    surfaceVariant: Color(0xFF34265A),
    onSurfaceVariant: Color(0xFFE9D5FF),
    borderColor: Color(0xFF241A3D),
    outline: Color(0xFF3B2C66),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB3A8D1),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _amethystLight = ColorTheme(
    id: 'amethyst',
    name: 'Cyber Amethyst',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFF7C3AED),
    primaryLight: Color(0xFF8B5CF6),
    primaryDark: Color(0xFF6D28D9),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF6D28D9),
    accentLight: Color(0xFFEDE9FE),
    tertiary: Color(0xFFC026D3),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFFAF7FF),
    backgroundDark: Color(0xFF0D0A17),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF171128),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFF3EEFE),
    surfaceVariant: Color(0xFFE9E0FD),
    onSurfaceVariant: Color(0xFF1E1433),
    borderColor: Color(0xFFE6DDF7),
    outline: Color(0xFFD0C2EE),
    textPrimary: Color(0xFF1E1433),
    textSecondary: Color(0xFF6B5F85),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const forest = ColorTheme(
    id: 'forest',
    name: 'Nordic Forest',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFF34D399),
    primaryDark: Color(0xFF059669),
    onPrimary: Color(0xFF022C22),
    accent: Color(0xFF6EE7B7),
    accentLight: Color(0xFF0F3D30),
    tertiary: Color(0xFFFCD34D),
    onTertiary: Color(0xFF2A1F00),
    backgroundLight: Color(0xFFF3FBF7),
    backgroundDark: Color(0xFF03120D),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF0A1F18),
    cardColor: Color(0xFF0A1F18),
    subtleCardColor: Color(0xFF123026),
    surfaceVariant: Color(0xFF1B4336),
    onSurfaceVariant: Color(0xFFD1FAE5),
    borderColor: Color(0xFF123026),
    outline: Color(0xFF1F4D3E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9CC4B3),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _forestLight = ColorTheme(
    id: 'forest',
    name: 'Nordic Forest',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFF047857),
    primaryLight: Color(0xFF059669),
    primaryDark: Color(0xFF065F46),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF065F46),
    accentLight: Color(0xFFD1FAE5),
    tertiary: Color(0xFFA16207),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFF3FBF7),
    backgroundDark: Color(0xFF03120D),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF0A1F18),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFE8F5EE),
    surfaceVariant: Color(0xFFD5ECDF),
    onSurfaceVariant: Color(0xFF0B2A1F),
    borderColor: Color(0xFFD5E8DD),
    outline: Color(0xFFB5D6C4),
    textPrimary: Color(0xFF0B2A1F),
    textSecondary: Color(0xFF547466),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const carbon = ColorTheme(
    id: 'carbon',
    name: 'Blood Carbon',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFFE5383B),
    primaryLight: Color(0xFFEC5050),
    primaryDark: Color(0xFFC81E1E),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFFCA5A5),
    accentLight: Color(0xFF4A1414),
    tertiary: Color(0xFFFB923C),
    onTertiary: Color(0xFF2B1000),
    backgroundLight: Color(0xFFFDF6F6),
    backgroundDark: Color(0xFF0C0606),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF190D0D),
    cardColor: Color(0xFF190D0D),
    subtleCardColor: Color(0xFF261414),
    surfaceVariant: Color(0xFF3A1D1D),
    onSurfaceVariant: Color(0xFFFECACA),
    borderColor: Color(0xFF261414),
    outline: Color(0xFF472424),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFC7A8A8),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _carbonLight = ColorTheme(
    id: 'carbon',
    name: 'Blood Carbon',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFFC81E1E),
    primaryLight: Color(0xFFDC2626),
    primaryDark: Color(0xFFA31515),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFA31515),
    accentLight: Color(0xFFFEE2E2),
    tertiary: Color(0xFFC2410C),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFFDF6F6),
    backgroundDark: Color(0xFF0C0606),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF190D0D),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFFAECEC),
    surfaceVariant: Color(0xFFF3DADA),
    onSurfaceVariant: Color(0xFF2A1010),
    borderColor: Color(0xFFF0D9D9),
    outline: Color(0xFFE0BABA),
    textPrimary: Color(0xFF2A1010),
    textSecondary: Color(0xFF7A5C5C),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const ivory = ColorTheme(
    id: 'ivory',
    name: 'Minimalist Ivory',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFFE4E4E7),
    primaryLight: Color(0xFFFAFAFA),
    primaryDark: Color(0xFFA1A1AA),
    onPrimary: Color(0xFF18181B),
    accent: Color(0xFFFAFAFA),
    accentLight: Color(0xFF3F3F46),
    tertiary: Color(0xFFA1A1AA),
    onTertiary: Color(0xFF18181B),
    backgroundLight: Color(0xFFFAFAFA),
    backgroundDark: Color(0xFF0F0F10),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF1C1C1F),
    cardColor: Color(0xFF1C1C1F),
    subtleCardColor: Color(0xFF27272A),
    surfaceVariant: Color(0xFF3F3F46),
    onSurfaceVariant: Color(0xFFFAFAFA),
    borderColor: Color(0xFF27272A),
    outline: Color(0xFF3F3F46),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA1A1AA),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _ivoryLight = ColorTheme(
    id: 'ivory',
    name: 'Minimalist Ivory',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFF18181B),
    primaryLight: Color(0xFF3F3F46),
    primaryDark: Color(0xFF09090B),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF3F3F46),
    accentLight: Color(0xFFE4E4E7),
    tertiary: Color(0xFF52525B),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFFAFAFA),
    backgroundDark: Color(0xFF0F0F10),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF1C1C1F),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFF4F4F5),
    surfaceVariant: Color(0xFFE4E4E7),
    onSurfaceVariant: Color(0xFF18181B),
    borderColor: Color(0xFFE4E4E7),
    outline: Color(0xFFD4D4D8),
    textPrimary: Color(0xFF18181B),
    textSecondary: Color(0xFF71717A),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const ocean = ColorTheme(
    id: 'ocean',
    name: 'Oceanic Deep',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFF06B6D4),
    primaryLight: Color(0xFF22D3EE),
    primaryDark: Color(0xFF0891B2),
    onPrimary: Color(0xFF03222B),
    accent: Color(0xFF67E8F9),
    accentLight: Color(0xFF0E3F4F),
    tertiary: Color(0xFF5EEAD4),
    onTertiary: Color(0xFF03241F),
    backgroundLight: Color(0xFFF2FBFD),
    backgroundDark: Color(0xFF04161F),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF0A2530),
    cardColor: Color(0xFF0A2530),
    subtleCardColor: Color(0xFF103544),
    surfaceVariant: Color(0xFF174A5E),
    onSurfaceVariant: Color(0xFFCFFAFE),
    borderColor: Color(0xFF103544),
    outline: Color(0xFF1B5268),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF93C0CC),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _oceanLight = ColorTheme(
    id: 'ocean',
    name: 'Oceanic Deep',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFF0E7490),
    primaryLight: Color(0xFF0891B2),
    primaryDark: Color(0xFF155E75),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF155E75),
    accentLight: Color(0xFFCFFAFE),
    tertiary: Color(0xFF0F766E),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFF2FBFD),
    backgroundDark: Color(0xFF04161F),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF0A2530),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFE3F5F9),
    surfaceVariant: Color(0xFFCDEBF2),
    onSurfaceVariant: Color(0xFF082F3D),
    borderColor: Color(0xFFCFE7EE),
    outline: Color(0xFFA9D3DF),
    textPrimary: Color(0xFF082F3D),
    textSecondary: Color(0xFF4F7682),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const velvet = ColorTheme(
    id: 'velvet',
    name: 'Royal Velvet',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFCD34D),
    primaryDark: Color(0xFFD97706),
    onPrimary: Color(0xFF2A1400),
    accent: Color(0xFFFCD34D),
    accentLight: Color(0xFF4A2A0A),
    tertiary: Color(0xFFFDA4AF),
    onTertiary: Color(0xFF3A0A14),
    backgroundLight: Color(0xFFFDF6F4),
    backgroundDark: Color(0xFF14060A),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF240C12),
    cardColor: Color(0xFF240C12),
    subtleCardColor: Color(0xFF34121A),
    surfaceVariant: Color(0xFF4A1A25),
    onSurfaceVariant: Color(0xFFFEF3C7),
    borderColor: Color(0xFF34121A),
    outline: Color(0xFF55202C),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFD4B0AA),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _velvetLight = ColorTheme(
    id: 'velvet',
    name: 'Royal Velvet',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFF9F1239),
    primaryLight: Color(0xFFBE123C),
    primaryDark: Color(0xFF881337),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF881337),
    accentLight: Color(0xFFFFE4E6),
    tertiary: Color(0xFFB45309),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFFDF6F4),
    backgroundDark: Color(0xFF14060A),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF240C12),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFF9EBE8),
    surfaceVariant: Color(0xFFF1D9D4),
    onSurfaceVariant: Color(0xFF2E0D14),
    borderColor: Color(0xFFEFD8D3),
    outline: Color(0xFFDDB9B1),
    textPrimary: Color(0xFF2E0D14),
    textSecondary: Color(0xFF80605C),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const slate = ColorTheme(
    id: 'slate',
    name: 'Slate & Electric',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFF38BDF8),
    primaryLight: Color(0xFF7DD3FC),
    primaryDark: Color(0xFF0EA5E9),
    onPrimary: Color(0xFF06202E),
    accent: Color(0xFF7DD3FC),
    accentLight: Color(0xFF1E4258),
    tertiary: Color(0xFFA78BFA),
    onTertiary: Color(0xFF160A33),
    backgroundLight: Color(0xFFF5F7FA),
    backgroundDark: Color(0xFF0F172A),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF1E293B),
    cardColor: Color(0xFF1E293B),
    subtleCardColor: Color(0xFF2A3649),
    surfaceVariant: Color(0xFF3B4A61),
    onSurfaceVariant: Color(0xFFF1F5F9),
    borderColor: Color(0xFF2A3649),
    outline: Color(0xFF475569),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA9B6C9),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _slateLight = ColorTheme(
    id: 'slate',
    name: 'Slate & Electric',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFF0369A1),
    primaryLight: Color(0xFF0284C7),
    primaryDark: Color(0xFF075985),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF075985),
    accentLight: Color(0xFFE0F2FE),
    tertiary: Color(0xFF6D28D9),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFF5F7FA),
    backgroundDark: Color(0xFF0F172A),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF1E293B),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFEEF2F6),
    surfaceVariant: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF1E293B),
    borderColor: Color(0xFFDDE3EA),
    outline: Color(0xFFC3CCD8),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF5B6B80),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const rose = ColorTheme(
    id: 'rose',
    name: 'Rose Graphite',
    isPremium: true,
    brightness: Brightness.dark,
    primary: Color(0xFFFB7185),
    primaryLight: Color(0xFFFDA4AF),
    primaryDark: Color(0xFFF43F5E),
    onPrimary: Color(0xFF3B0A16),
    accent: Color(0xFFFDA4AF),
    accentLight: Color(0xFF4A1F28),
    tertiary: Color(0xFFFDBA74),
    onTertiary: Color(0xFF2B1400),
    backgroundLight: Color(0xFFFFF5F6),
    backgroundDark: Color(0xFF141110),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF211C1A),
    cardColor: Color(0xFF211C1A),
    subtleCardColor: Color(0xFF2E2725),
    surfaceVariant: Color(0xFF443B38),
    onSurfaceVariant: Color(0xFFF5F5F4),
    borderColor: Color(0xFF2E2725),
    outline: Color(0xFF4A403D),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFBFB3AE),
    success: Color(0xFF17A84D),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF60A5FA),
  );

  static const _roseLight = ColorTheme(
    id: 'rose',
    name: 'Rose Graphite',
    isPremium: true,
    brightness: Brightness.light,
    primary: Color(0xFFE11D48),
    primaryLight: Color(0xFFF43F5E),
    primaryDark: Color(0xFFBE123C),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFBE123C),
    accentLight: Color(0xFFFFE4E6),
    tertiary: Color(0xFFC2410C),
    onTertiary: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFFFF5F6),
    backgroundDark: Color(0xFF141110),
    surfaceLight: Color(0xFFFFFFFF),
    surfaceDark: Color(0xFF211C1A),
    cardColor: Color(0xFFFFFFFF),
    subtleCardColor: Color(0xFFFDECEE),
    surfaceVariant: Color(0xFFFAD9DD),
    onSurfaceVariant: Color(0xFF2B1519),
    borderColor: Color(0xFFF5D7DB),
    outline: Color(0xFFE8B9C0),
    textPrimary: Color(0xFF2B1519),
    textSecondary: Color(0xFF85656B),
    success: Color(0xFF15803D),
    error: Color(0xFFDC2626),
    warning: Color(0xFFB45309),
    info: Color(0xFF2563EB),
  );

  static const Map<String, ColorTheme> _dark = {
    'midnight': midnight,
    'elite': elite,
    'amethyst': amethyst,
    'forest': forest,
    'carbon': carbon,
    'ivory': ivory,
    'ocean': ocean,
    'velvet': velvet,
    'slate': slate,
    'rose': rose,
  };

  static const Map<String, ColorTheme> _light = {
    'midnight': _midnightLight,
    'elite': _eliteLight,
    'amethyst': _amethystLight,
    'forest': _forestLight,
    'carbon': _carbonLight,
    'ivory': _ivoryLight,
    'ocean': _oceanLight,
    'velvet': _velvetLight,
    'slate': _slateLight,
    'rose': _roseLight,
  };

  /// Kimlikten temayı (koyu paletiyle) döndürür; bilinmeyen kimlik → midnight.
  /// Ekranda kullanılacak palet için [forBrightness] çağrılmalıdır.
  static ColorTheme fromString(String scheme) => _dark[scheme] ?? midnight;

  static List<ColorTheme> get all => const [
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
}

/// `context.colors` → etkin temanın bu parlaklıktaki paleti
extension ColorThemeContext on BuildContext {
  ColorTheme get colors => Theme.of(this).extension<ColorTheme>()!;
}
