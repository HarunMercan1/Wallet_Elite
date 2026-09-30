// lib/core/utils/date_utils.dart

/// Kullanıcının seçtiği tarih/saatleri (işlem tarihi, vade, ödeme tarihi)
/// uygulama saat dilimi bilgisi olmadan "duvar saati" olarak yazar
/// (`DateTime.toIso8601String()` ile, ör. `2026-09-30T23:30:00.000`).
/// Postgres bunu UTC kabul edip `...+00:00` olarak geri döner; `DateTime.parse`
/// da UTC bir DateTime üretir. Aynı alanlarla yerel DateTime'a çevirerek
/// yazılan değerin aynısını geri alırız; böylece `DateTime.now()` ile yapılan
/// karşılaştırmalar (bu ay, bugün vb.) saat farkı kadar kaymaz.
DateTime parseWallClock(String value) {
  final d = DateTime.parse(value);
  if (!d.isUtc) return d;
  return DateTime(
    d.year,
    d.month,
    d.day,
    d.hour,
    d.minute,
    d.second,
    d.millisecond,
    d.microsecond,
  );
}

/// Sunucunun `now()` ile yazdığı gerçek zaman damgaları (created_at, updated_at)
DateTime parseServerTimestamp(String value) => DateTime.parse(value).toLocal();
