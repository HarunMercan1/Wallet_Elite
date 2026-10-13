// lib/core/utils/amount_input.dart

import 'package:flutter/services.dart';

/// Tutar alanları için: en çok iki ondalık haneli pozitif sayı. Virgül de
/// ondalık ayırıcı kabul edilir (Türkçe ve çoğu Avrupa klavyesi sayısal
/// tuş takımında nokta yerine virgül gösterir) ve noktaya çevrilir.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();

  static final _valid = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');
    if (!_valid.hasMatch(text)) return oldValue;
    return newValue.copyWith(text: text);
  }
}

/// Kullanıcının yazdığı tutarı sayıya çevirir; geçersiz ya da sıfır/negatifse
/// `null` döner.
double? parseAmount(String? input) {
  if (input == null) return null;
  final value = double.tryParse(input.trim().replaceAll(',', '.'));
  if (value == null || value <= 0) return null;
  return value;
}

/// Düzenleme alanına yazılacak tutar metni: gereksiz ".0" olmadan, en çok iki
/// ondalık (6000.0 → "6000", 12.5 → "12.5").
String amountToInputText(double amount) {
  final fixed = amount.toStringAsFixed(2);
  return fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
      : fixed;
}
