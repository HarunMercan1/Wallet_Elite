// lib/core/utils/icon_helper.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Kategori ikonlarını string'den IconData'ya çeviren helper
class IconHelper {
  static IconData getIcon(String? iconName) {
    if (iconName == null) return FontAwesomeIcons.circleQuestion;

    switch (iconName) {
    // Gider İkonları
      case 'cartShopping':
        return FontAwesomeIcons.cartShopping;
      case 'utensils':
        return FontAwesomeIcons.utensils;
      case 'bus':
        return FontAwesomeIcons.bus;
      case 'fileInvoiceDollar':
        return FontAwesomeIcons.fileInvoiceDollar;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'heartPulse':
        return FontAwesomeIcons.heartPulse;
      case 'gamepad':
        return FontAwesomeIcons.gamepad;
      case 'shirt':
        return FontAwesomeIcons.shirt;

    // Gelir İkonları
      case 'moneyBillWave':
        return FontAwesomeIcons.moneyBillWave;
      case 'laptopCode':
        return FontAwesomeIcons.laptopCode;
      case 'chartLine':
        return FontAwesomeIcons.chartLine;
      case 'moneyBill':
        return FontAwesomeIcons.moneyBill;

      default:
        return FontAwesomeIcons.circleQuestion;
    }
  }
}