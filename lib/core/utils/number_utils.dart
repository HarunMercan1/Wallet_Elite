// lib/core/utils/number_utils.dart

import 'package:intl/intl.dart';

/// Yüzdeyi uygulama diline göre yazar: Türkçe "%12", İngilizce "12%".
/// [value] 0–100 ölçeğindedir (12.5 → %12,5).
String formatPercent(num value, {int decimals = 0}) {
  return NumberFormat.decimalPercentPattern(
    decimalDigits: decimals,
  ).format(value / 100);
}

/// Yalnızca gün bilgisi (saat 00:00)
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
