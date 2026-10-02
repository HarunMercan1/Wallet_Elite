// lib/core/constants/app_info.dart

/// Uygulamanın mağaza ve iletişim bilgileri
class AppInfo {
  static const String packageName = 'com.mercansoftware.wallet_elite';

  /// Kullanıcıların öneri/şikayet/istek gönderdiği geliştirici adresi
  static const String developerEmail = 'mercansoftware1@gmail.com';

  static Uri get playStoreAppUri =>
      Uri.parse('market://details?id=$packageName');

  static Uri get playStoreWebUri =>
      Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
}
