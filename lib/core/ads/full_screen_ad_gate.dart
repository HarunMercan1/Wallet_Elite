// lib/core/ads/full_screen_ad_gate.dart

/// Tam ekran reklamlar (geçiş, uygulama açılış, ödüllü) arasında ortak durum:
/// aynı anda yalnızca biri gösterilir ve art arda gösterim engellenir.
class FullScreenAdGate {
  /// Bir reklamın "gösteriliyor" sayılacağı en uzun süre. Kapanma bildirimi
  /// hiç gelmezse (SDK hatası) kapı sonsuza dek kilitli kalmasın.
  static const _maxShowDuration = Duration(minutes: 10);

  /// Uygulama dışı bir işe (satın alma, paylaşma, fotoğraf seçme…) çıkıldıktan
  /// sonra dönüşte açılış reklamının bastırılacağı en uzun süre
  static const _externalFlowWindow = Duration(minutes: 10);

  static DateTime? _openedAt;
  static DateTime? lastClosedAt;
  static DateTime? _externalFlowStartedAt;

  static bool get isShowing {
    final openedAt = _openedAt;
    if (openedAt == null) return false;
    if (DateTime.now().difference(openedAt) > _maxShowDuration) {
      _openedAt = null;
      return false;
    }
    return true;
  }

  static bool closedWithin(Duration duration) {
    final last = lastClosedAt;
    return last != null && DateTime.now().difference(last) < duration;
  }

  static void opened() => _openedAt = DateTime.now();

  static void closed() {
    _openedAt = null;
    lastClosedAt = DateTime.now();
  }

  /// Kullanıcı kendi başlattığı bir iş için uygulamadan çıkmak üzere (Google
  /// Play satın alma ekranı, paylaşım menüsü, galeri, e-posta uygulaması).
  /// Geri döndüğünde açılış reklamı gösterilmez; yoksa yarıda kalan işin
  /// üstüne reklam açılır.
  static void externalFlowStarted() => _externalFlowStartedAt = DateTime.now();

  /// Dönüş bir dış işten mi? Evetse işareti tüketir.
  static bool consumeExternalFlow() {
    final startedAt = _externalFlowStartedAt;
    _externalFlowStartedAt = null;
    return startedAt != null &&
        DateTime.now().difference(startedAt) < _externalFlowWindow;
  }
}
