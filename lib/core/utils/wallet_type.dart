// lib/core/utils/wallet_type.dart

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Cüzdan türleri uygulamanın farklı yerlerinde oluşturulur (onboarding:
/// cash/bank/credit_card/investment, ayarlar: cash/bank/credit_card/savings).
/// Hepsinin simgesi, adı ve rengi tek yerden gelir.

IconData walletTypeIcon(String type) {
  switch (type) {
    case 'bank':
      return Icons.account_balance;
    case 'cash':
      return Icons.payments;
    case 'credit_card':
      return Icons.credit_card;
    case 'savings':
      return Icons.savings;
    case 'investment':
    case 'gold':
      return Icons.trending_up;
    default:
      return Icons.account_balance_wallet;
  }
}

String walletTypeName(String type, AppLocalizations l) {
  switch (type) {
    case 'bank':
      return l.bank;
    case 'cash':
      return l.cash;
    case 'credit_card':
      return l.creditCard;
    case 'savings':
      return l.savings;
    case 'investment':
    case 'gold':
      return l.investmentType;
    default:
      return l.wallet;
  }
}

Color walletTypeColor(String type, ColorTheme colorTheme) {
  switch (type) {
    case 'bank':
      return colorTheme.info;
    case 'cash':
      return colorTheme.success;
    case 'credit_card':
      return colorTheme.error;
    case 'savings':
    case 'investment':
    case 'gold':
      return colorTheme.warning;
    default:
      return colorTheme.primary;
  }
}
