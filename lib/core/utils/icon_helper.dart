import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconHelper {
  static IconData getIcon(String iconCode) {
    switch (iconCode) {
      case 'cartShopping': return FontAwesomeIcons.cartShopping;
      case 'fileInvoiceDollar': return FontAwesomeIcons.fileInvoiceDollar;
      case 'bus': return FontAwesomeIcons.bus;
      case 'utensils': return FontAwesomeIcons.utensils;
      case 'gamepad': return FontAwesomeIcons.gamepad;
      case 'house': return FontAwesomeIcons.house;
      case 'shirt': return FontAwesomeIcons.shirt;
      case 'heartPulse': return FontAwesomeIcons.heartPulse;
      case 'laptopCode': return FontAwesomeIcons.laptopCode;
      case 'chartLine': return FontAwesomeIcons.chartLine;
      case 'youtube': return FontAwesomeIcons.youtube;
      case 'moneyBillWave': return FontAwesomeIcons.moneyBillWave;
      default: return FontAwesomeIcons.question;
    }
  }
}