// lib/core/utils/amount_input.dart

import 'package:flutter/services.dart';

/// Arapça (٠-٩) ve Farsça (۰-۹) rakamları ile Arapça ondalık ayırıcıyı (٫)
/// Latin karşılıklarına çevirir; bu klavyelerle de tutar yazılabilsin.
String normalizeDigits(String input) {
  final out = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      out.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      out.writeCharCode(0x30 + rune - 0x06F0);
    } else if (rune == 0x066B) {
      out.write('.');
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

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
    final text = normalizeDigits(newValue.text).replaceAll(',', '.');
    if (!_valid.hasMatch(text)) return oldValue;
    // Çeviri metin uzunluğunu değiştirmez; imleç konumu korunur
    return newValue.copyWith(text: text);
  }
}

/// Kullanıcının yazdığı tutarı sayıya çevirir; geçersiz ya da sıfır/negatifse
/// `null` döner.
double? parseAmount(String? input) {
  if (input == null) return null;
  final value = double.tryParse(
    normalizeDigits(input.trim()).replaceAll(',', '.'),
  );
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
