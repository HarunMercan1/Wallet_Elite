// lib/features/settings/data/preferences_sync.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_languages.dart';
import '../../auth/data/auth_provider.dart';
import 'settings_provider.dart';

/// Tercihler (dil, renk teması, para birimi) cihazda saklanır; onboarding'de
/// ayrıca profile yazılır. Uygulama yeniden kurulduğunda ya da başka bir
/// cihazda giriş yapıldığında, bu cihazda henüz seçilmemiş olanlar profilden
/// geri yüklenir. Cihazdaki seçim her zaman önceliklidir.
final preferencesRestoreProvider = FutureProvider<void>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return;

  final prefs = ref.read(sharedPreferencesProvider);
  final needsLanguage = !prefs.containsKey('locale');
  final needsTheme = !prefs.containsKey('color_scheme');
  final needsCurrency = !prefs.containsKey('currency');
  if (!needsLanguage && !needsTheme && !needsCurrency) return;

  try {
    final remote = await Supabase.instance.client
        .from('profiles')
        .select(
          'onboarding_completed, preferred_language, preferred_theme, '
          'preferred_currency',
        )
        .eq('id', userId)
        .maybeSingle();
    // Onboarding bitmeden profildeki değerler yalnızca tablo varsayılanıdır
    if (remote == null || remote['onboarding_completed'] != true) return;

    final language = remote['preferred_language'] as String?;
    if (needsLanguage &&
        language != null &&
        appLanguages.any((l) => l.code == language)) {
      ref.read(localeProvider.notifier).setLocale(language);
    }

    final theme = remote['preferred_theme'] as String?;
    if (needsTheme && theme != null) {
      ref.read(colorSchemeProvider.notifier).setColorScheme(theme);
    }

    final currency = remote['preferred_currency'] as String?;
    if (needsCurrency && currency != null) {
      ref.read(currencyProvider.notifier).setCurrency(currency);
    }
  } catch (e) {
    debugPrint('Tercihler geri yüklenemedi: $e');
  }
});

/// Ayarlardan değiştirilen tercihi profile de yazar (başarısız olursa cihazdaki
/// değer yine geçerlidir; yalnızca başka cihaza taşınmaz).
Future<void> savePreferenceToProfile(
  WidgetRef ref, {
  String? language,
  String? currency,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return;
  await ref
      .read(authRepositoryProvider)
      .updateUserPreferences(
        userId: userId,
        language: language,
        currency: currency,
      );
}
