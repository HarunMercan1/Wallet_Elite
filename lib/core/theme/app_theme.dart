import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData create({
    required ColorTheme colorTheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    // Adapt colorTheme for light mode automatically
    final activeTheme = isDark
        ? colorTheme
        : colorTheme.copyWith(
            textPrimary: const Color(0xFF0F172A), // Dark slate text
            textSecondary: const Color(0xFF64748B), // Medium slate text
            cardColor: Colors.white, // White cards
            subtleCardColor: const Color(0xFFF8FAFC), // Very light slate
            surfaceVariant: const Color(0xFFF1F5F9), // Light slate background
            onSurfaceVariant: const Color(0xFF0F172A),
            borderColor: const Color(0xFFE2E8F0), // Light borders
            outline: const Color(0xFFCBD5E1),
          );

    // Determine background and surface colors based on brightness
    final backgroundColor = isDark
        ? activeTheme.backgroundDark
        : activeTheme.backgroundLight;
    final surfaceColor = isDark
        ? activeTheme.surfaceDark
        : activeTheme.surfaceLight;
    final textColor = activeTheme.textPrimary;

    // Base theme data
    final baseTheme = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: activeTheme.primary,
        brightness: brightness,
        primary: activeTheme.primary,
        secondary: activeTheme.accent,
        surface: surfaceColor,
        error: activeTheme.error,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: activeTheme.primary,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: activeTheme.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: activeTheme.borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: activeTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: activeTheme.primary),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        baseTheme.textTheme,
      ).apply(bodyColor: textColor, displayColor: textColor),

      // Extensions
      extensions: [
        activeTheme, // Inject the dynamically adjusted color theme
      ],
    );
  }
}
