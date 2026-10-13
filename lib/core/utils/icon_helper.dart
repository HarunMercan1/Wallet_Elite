// lib/core/utils/icon_helper.dart

import 'package:flutter/material.dart';

/// Kategori kaydındaki ikon adını (categories.icon) IconData'ya çevirir.
/// Tüm ekranlar bunu kullanır; böylece aynı kategori her yerde aynı ikonla
/// görünür.
IconData categoryIcon(String? iconName) {
  switch (iconName) {
    case 'wallet':
      return Icons.wallet;
    case 'laptop':
      return Icons.laptop;
    case 'trending_up':
      return Icons.trending_up;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'attach_money':
      return Icons.attach_money;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'directions_car':
      return Icons.directions_car;
    case 'receipt':
      return Icons.receipt;
    case 'movie':
      return Icons.movie;
    case 'restaurant':
      return Icons.restaurant;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'checkroom':
      return Icons.checkroom;
    case 'school':
      return Icons.school;
    case 'flight':
      return Icons.flight;
    case 'more_horiz':
      return Icons.more_horiz;
    default:
      return Icons.category;
  }
}
