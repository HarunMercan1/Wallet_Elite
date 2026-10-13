// lib/core/utils/app_languages.dart

/// Uygulamanın çevirisi olan diller (lib/l10n altındaki .arb dosyalarıyla
/// aynı küme). Dil seçim ekranları bu listeyi kullanır; böylece çevirisi olan
/// bir dil seçeneklerden eksik kalmaz.
class AppLanguage {
  final String code;
  final String name;
  final String flag;

  const AppLanguage(this.code, this.name, this.flag);
}

const List<AppLanguage> appLanguages = [
  AppLanguage('en', 'English', '🇬🇧'),
  AppLanguage('tr', 'Türkçe', '🇹🇷'),
  AppLanguage('de', 'Deutsch', '🇩🇪'),
  AppLanguage('es', 'Español', '🇪🇸'),
  AppLanguage('fr', 'Français', '🇫🇷'),
  AppLanguage('it', 'Italiano', '🇮🇹'),
  AppLanguage('pt', 'Português', '🇵🇹'),
  AppLanguage('nl', 'Nederlands', '🇳🇱'),
  AppLanguage('pl', 'Polski', '🇵🇱'),
  AppLanguage('ru', 'Русский', '🇷🇺'),
  AppLanguage('ar', 'العربية', '🇸🇦'),
  AppLanguage('hi', 'हिन्दी', '🇮🇳'),
  AppLanguage('id', 'Indonesia', '🇮🇩'),
  AppLanguage('vi', 'Tiếng Việt', '🇻🇳'),
  AppLanguage('th', 'ไทย', '🇹🇭'),
  AppLanguage('zh', '中文', '🇨🇳'),
  AppLanguage('ja', '日本語', '🇯🇵'),
  AppLanguage('ko', '한국어', '🇰🇷'),
];

/// Dil kodunun kendi dilindeki adı (bilinmiyorsa kodun kendisi)
String appLanguageName(String code) {
  for (final language in appLanguages) {
    if (language.code == code) return language.name;
  }
  return code.toUpperCase();
}

/// Cihaz dili destekleniyorsa o, değilse İngilizce
String defaultLanguageFor(String deviceLanguageCode) {
  for (final language in appLanguages) {
    if (language.code == deviceLanguageCode) return deviceLanguageCode;
  }
  return 'en';
}
