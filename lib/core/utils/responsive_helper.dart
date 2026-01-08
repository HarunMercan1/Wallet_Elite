// lib/core/utils/responsive_helper.dart

import 'package:flutter/material.dart';

/// Responsive tasarım için yardımcı sınıf
/// Ekran boyutuna göre dinamik değerler döndürür
class ResponsiveHelper {
  final BuildContext context;
  late final Size _screenSize;
  late final double _width;
  late final double _height;

  ResponsiveHelper(this.context) {
    _screenSize = MediaQuery.of(context).size;
    _width = _screenSize.width;
    _height = _screenSize.height;
  }

  // ========== Ekran Boyutları ==========
  double get screenWidth => _width;
  double get screenHeight => _height;

  /// Ekran genişliğinin yüzdesi
  double wp(double percentage) => _width * (percentage / 100);

  /// Ekran yüksekliğinin yüzdesi
  double hp(double percentage) => _height * (percentage / 100);

  // ========== Cihaz Tipi ==========
  bool get isMobile => _width < 600;
  bool get isTablet => _width >= 600 && _width < 1024;
  bool get isDesktop => _width >= 1024;

  bool get isSmallPhone => _width < 360;
  bool get isNormalPhone => _width >= 360 && _width < 400;
  bool get isLargePhone => _width >= 400 && _width < 600;

  // ========== Dinamik Font Boyutları ==========
  double get fontXS => _scaledFont(10);
  double get fontS => _scaledFont(12);
  double get fontM => _scaledFont(14);
  double get fontL => _scaledFont(16);
  double get fontXL => _scaledFont(18);
  double get fontXXL => _scaledFont(20);
  double get fontTitle => _scaledFont(24);
  double get fontHeading => _scaledFont(28);
  double get fontHero => _scaledFont(32);

  double _scaledFont(double baseSize) {
    // 375 genişlik referans alınarak ölçeklenir
    final scale = _width / 375;
    final scaledSize = baseSize * scale;
    // Min ve max sınırları
    return scaledSize.clamp(baseSize * 0.8, baseSize * 1.3);
  }

  /// Özel font boyutu
  double fontSize(double size) => _scaledFont(size);

  // Eski uyumluluk için alias'lar
  double get titleFontSize => fontTitle;
  double get bodyFontSize => fontM;
  double get subtitleFontSize => fontL;
  double get largeIconSize => iconXL;

  // ========== Dinamik Padding/Margin ==========
  double get paddingXS => wp(1.5); // ~6px on 400px screen
  double get paddingS => wp(2.5); // ~10px
  double get paddingM => wp(4); // ~16px
  double get paddingL => wp(5); // ~20px
  double get paddingXL => wp(6); // ~24px

  /// Özel padding değeri (ekran yüzdesi)
  double padding(double percentage) => wp(percentage);

  EdgeInsets get horizontalPadding =>
      EdgeInsets.symmetric(horizontal: paddingM);
  EdgeInsets get allPadding => EdgeInsets.all(paddingM);

  // ========== Dinamik Spacing ==========
  double get spaceXS => hp(0.5); // ~4px
  double get spaceS => hp(1); // ~8px
  double get spaceM => hp(1.5); // ~12px
  double get spaceL => hp(2); // ~16px
  double get spaceXL => hp(3); // ~24px
  double get spaceXXL => hp(4); // ~32px

  SizedBox get verticalSpaceXS => SizedBox(height: spaceXS);
  SizedBox get verticalSpaceS => SizedBox(height: spaceS);
  SizedBox get verticalSpaceM => SizedBox(height: spaceM);
  SizedBox get verticalSpaceL => SizedBox(height: spaceL);
  SizedBox get verticalSpaceXL => SizedBox(height: spaceXL);

  // ========== Dinamik Icon Boyutları ==========
  double get iconS => _scaledFont(16);
  double get iconM => _scaledFont(20);
  double get iconL => _scaledFont(24);
  double get iconXL => _scaledFont(28);

  // ========== Dinamik Border Radius ==========
  double get radiusS => wp(2); // ~8px
  double get radiusM => wp(3); // ~12px
  double get radiusL => wp(4); // ~16px
  double get radiusXL => wp(6); // ~24px

  BorderRadius get borderRadiusS => BorderRadius.circular(radiusS);
  BorderRadius get borderRadiusM => BorderRadius.circular(radiusM);
  BorderRadius get borderRadiusL => BorderRadius.circular(radiusL);

  // ========== Dinamik Buton Boyutları ==========
  double get buttonHeight => hp(6); // ~48px
  double get buttonHeightSmall => hp(5); // ~40px
  double get buttonHeightLarge => hp(7); // ~56px

  // ========== Bottom Navigation ==========
  double get navIconSize => _scaledFont(22);
  double get navFontSize => _scaledFont(10);
  double get navItemWidth => wp(16); // her item için genişlik

  // ========== Card Boyutları ==========
  double get cardPadding => paddingM;
  double get cardRadius => radiusL;

  // ========== Bottom Sheet ==========
  double get bottomSheetRadius => radiusXL;
  double get bottomSheetMaxHeight => hp(92);

  // ========== Statik Erişim ==========
  static ResponsiveHelper of(BuildContext context) => ResponsiveHelper(context);
}

/// Extension method for easy access
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}
