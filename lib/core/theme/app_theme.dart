import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData create({
    required ColorTheme colorTheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    // Temanın bu parlaklık için tanımlı paleti
    final c = colorTheme.forBrightness(brightness);
    final textColor = c.textPrimary;

    // Base theme data
    final baseTheme = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: c.primary,
          brightness: brightness,
        ).copyWith(
          primary: c.primary,
          onPrimary: c.onPrimary,
          primaryContainer: c.accentLight,
          onPrimaryContainer: c.accent,
          secondary: c.accent,
          onSecondary: isDark ? c.backgroundDark : Colors.white,
          secondaryContainer: c.surfaceVariant,
          onSecondaryContainer: c.onSurfaceVariant,
          tertiary: c.tertiary,
          onTertiary: c.onTertiary,
          error: c.error,
          onError: Colors.white,
          surface: c.cardColor,
          onSurface: textColor,
          onSurfaceVariant: c.textSecondary,
          surfaceContainerLowest: c.background,
          surfaceContainerLow: c.cardColor,
          surfaceContainer: c.cardColor,
          surfaceContainerHigh: c.subtleCardColor,
          surfaceContainerHighest: c.surfaceVariant,
          surfaceTint: Colors.transparent,
          outline: c.outline,
          outlineVariant: c.borderColor,
        );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final buttonTextStyle = GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c.outline),
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.cardColor,
      primaryColor: c.primary,
      dividerColor: c.borderColor,
      splashFactory: InkSparkle.splashFactory,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        actionsIconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: c.cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.borderColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.surfaceVariant,
          disabledForegroundColor: c.textSecondary,
          elevation: 0,
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: buttonTextStyle,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.surfaceVariant,
          disabledForegroundColor: c.textSecondary,
          shape: buttonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.outline),
          shape: buttonShape,
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 2,
      ),

      // Icons & list tiles
      iconTheme: IconThemeData(color: textColor),
      listTileTheme: ListTileThemeData(
        iconColor: c.primary,
        textColor: textColor,
        subtitleTextStyle: GoogleFonts.inter(
          color: c.textSecondary,
          fontSize: 13,
        ),
      ),
      dividerTheme: DividerThemeData(color: c.borderColor, thickness: 1),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: c.textMuted),
        labelStyle: TextStyle(color: c.textSecondary),
        floatingLabelStyle: TextStyle(color: c.primary),
        prefixIconColor: c.textSecondary,
        suffixIconColor: c.textSecondary,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primary.withValues(alpha: 0.3),
        selectionHandleColor: c.primary,
      ),

      // Selection controls
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.onPrimary
              : c.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.primary
              : c.surfaceVariant,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : c.outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        side: BorderSide(color: c.outline, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.primary
              : c.textSecondary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceVariant,
        circularTrackColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: c.surfaceVariant,
        thumbColor: c.primary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.subtleCardColor,
        selectedColor: c.primary,
        side: BorderSide(color: c.borderColor),
        labelStyle: TextStyle(color: textColor),
      ),

      // Surfaces that float above the page
      dialogTheme: DialogThemeData(
        backgroundColor: c.cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: c.textSecondary,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.cardColor,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.cardColor,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.cardColor,
        surfaceTintColor: Colors.transparent,
        textStyle: GoogleFonts.inter(color: textColor, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.borderColor),
        ),
      ),
      // Her iki modda koyu zemin + beyaz yazı: ekranlar başarı/hata rengini
      // zemin olarak verdiğinde de yazı okunur kalır.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? c.surfaceVariant : c.textPrimary,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        actionTextColor: isDark ? c.accent : c.accentLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.cardColor,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: c.primary,
        headerForegroundColor: c.onPrimary,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.primary,
        unselectedLabelColor: c.textSecondary,
        indicatorColor: c.primary,
        dividerColor: Colors.transparent,
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        baseTheme.textTheme,
      ).apply(bodyColor: textColor, displayColor: textColor),

      // Extensions
      extensions: [
        c, // Bu parlaklığın paleti; `context.colors` ile okunur
      ],
    );
  }
}
