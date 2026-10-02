// lib/core/utils/category_l10n.dart

import '../../features/wallet/models/category_model.dart';
import '../../l10n/app_localizations.dart';

/// Kategori adını kullanıcının dilinde döndürür: önce translation_key, yoksa
/// bilinen varsayılan adlardan tahmin, o da yoksa kullanıcının verdiği ad.
String? localizedCategoryName(CategoryModel? category, AppLocalizations l) {
  if (category == null) return null;

  if (category.translationKey != null) {
    switch (category.translationKey) {
      case 'cat_food':
        return l.cat_food;
      case 'cat_transport':
        return l.cat_transport;
      case 'cat_shopping':
        return l.cat_shopping;
      case 'cat_clothing':
        return l.cat_clothing;
      case 'cat_entertainment':
        return l.cat_entertainment;
      case 'cat_bills':
        return l.cat_bills;
      case 'cat_health':
        return l.cat_health;
      case 'cat_education':
        return l.cat_education;
      case 'cat_rent':
        return l.cat_rent;
      case 'cat_taxes':
        return l.cat_taxes;
      case 'cat_salary':
        return l.cat_salary;
      case 'cat_freelance':
        return l.cat_freelance;
      case 'cat_investment':
        return l.cat_investment;
      case 'cat_gift':
        return l.cat_gift;
      case 'cat_pets':
        return l.cat_pets;
      case 'cat_groceries':
        return l.cat_groceries;
      case 'cat_electronics':
        return l.cat_electronics;
      case 'cat_charity':
        return l.cat_charity;
      case 'cat_insurance':
        return l.cat_insurance;
      case 'cat_gym':
        return l.cat_gym;
      case 'cat_other':
      case 'cat_others':
        return l.cat_other;
      case 'cat_travel':
        return l.cat_travel;
    }
  }

  // Fallback Check
  final name = category.name.toLowerCase();
  if (name.contains('food') || name.contains('yemek')) return l.cat_food;
  if (name.contains('pet') || name.contains('evcil')) return l.cat_pets;
  if (name.contains('grocer') || name.contains('market')) {
    return l.cat_groceries;
  }
  if (name.contains('electronic')) return l.cat_electronics;
  if (name.contains('charity') || name.contains('bağış')) {
    return l.cat_charity;
  }
  if (name.contains('insuranc') || name.contains('sigorta')) {
    return l.cat_insurance;
  }
  if (name.contains('gym') || name.contains('spor')) return l.cat_gym;
  if (name.contains('health')) return l.cat_health;
  if (name.contains('gift')) return l.cat_gift;
  if (name.contains('bill')) return l.cat_bills;
  if (name.contains('educat')) return l.cat_education;
  if (name.contains('entert')) return l.cat_entertainment;
  if (name.contains('cloth') || name.contains('giyim')) {
    return l.cat_clothing;
  }
  if (name.contains('shop')) return l.cat_shopping;
  if (name.contains('transport')) return l.cat_transport;
  if (name.contains('travel') || name.contains('seyahat')) {
    return l.cat_travel;
  }

  return category.name;
}
