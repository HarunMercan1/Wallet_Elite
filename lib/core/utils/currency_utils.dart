// lib/core/utils/currency_utils.dart

class CurrencyUtils {
  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'TRY':
        return '₺';
      case 'JPY':
        return '¥';
      case 'RUB':
        return '₽';
      default:
        // Simgesi bilinmeyen para birimi: kod ile tutar bitişmesin
        return '$currencyCode ';
    }
  }
}
