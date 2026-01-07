// lib/core/utils/responsive_helper.dart

import 'package:flutter/material.dart';

/// Ekran boyutuna göre responsive değerler döndüren helper
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  /// Ekran genişliği
  double get width => MediaQuery.of(context).size.width;

  /// Ekran yüksekliği
  double get height => MediaQuery.of(context).size.height;

  /// Ekran genişliğine göre yüzde hesapla
  double wp(double percentage) => width * percentage / 100;

  /// Ekran yüksekliğine göre yüzde hesapla
  double hp(double percentage) => height * percentage / 100;

  /// Ekran tipini belirle
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 900;
  bool get isDesktop => width >= 900;

  /// Dinamik font size
  double get titleFontSize {
    if (width < 360) return 24; // Çok küçük ekranlar (SE)
    if (width < 400) return 28; // Küçük ekranlar
    if (width < 600) return 32; // Normal telefonlar
    return 36; // Tabletler
  }

  double get bodyFontSize {
    if (width < 360) return 13;
    if (width < 400) return 14;
    if (width < 600) return 16;
    return 18;
  }

  double get subtitleFontSize {
    if (width < 360) return 11;
    if (width < 400) return 12;
    if (width < 600) return 14;
    return 16;
  }

  /// Dinamik padding
  double get horizontalPadding {
    if (width < 360) return 16;
    if (width < 600) return 24;
    return 32;
  }

  double get verticalPadding {
    if (height < 600) return 16;
    if (height < 800) return 24;
    return 32;
  }

  /// Dinamik icon size
  double get largeIconSize {
    if (width < 360) return 60;
    if (width < 600) return 80;
    return 100;
  }

  double get normalIconSize {
    if (width < 360) return 20;
    if (width < 600) return 24;
    return 28;
  }
}