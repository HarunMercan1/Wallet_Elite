// lib/features/premium/data/premium_constants.dart

/// RevenueCat ve ücretsiz sürüm sınırları.
class PremiumConstants {
  /// RevenueCat "Wallet Elite" projesi, Play Store uygulaması public SDK
  /// anahtarı. Boş bırakılırsa satın alma devre dışı kalır ve herkes ücretsiz
  /// kullanıcı sayılır.
  /// (Public SDK anahtarı istemciye gömülmek üzere tasarlanmıştır, gizli değildir.)
  static const String revenueCatGoogleApiKey =
      'goog_PaGnFOfVtTISqqvNzpVdjdzFynt';

  /// RevenueCat entitlement kimliği
  static const String entitlementId = 'premium';

  /// Ücretsiz sürümde en fazla cüzdan / aktif bütçe sayısı
  static const int freeWalletLimit = 2;
  static const int freeBudgetLimit = 2;

  /// Ödüllü reklamla açılan premium temanın süresi
  static const Duration rewardedThemeDuration = Duration(hours: 24);
}
