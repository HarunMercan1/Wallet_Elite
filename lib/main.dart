// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/constants/supabase_config.dart';
import 'core/theme/color_theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_router.dart';
import 'core/services/support_actions.dart';
import 'features/settings/data/settings_provider.dart';

void main() async {
  // Flutter Engine başlatma
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences başlatma
  final sharedPrefs = await SharedPreferences.getInstance();

  // Supabase başlatma
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase başlatma hatası: $e');
    // Hata olsa bile devam et, router offline durumu yönetecek
  }

  // Intl locale başlatma (Tüm diller için)
  await initializeDateFormatting(null, null);

  // Uygulamayı başlat
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const WalletEliteApp(),
    ),
  );
}

class WalletEliteApp extends ConsumerWidget {
  const WalletEliteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final localeCode = ref.watch(localeProvider);
    // Seçili tema (premium hakkı yoksa ücretsiz temaya düşer)
    final colorTheme = ref.watch(currentColorThemeProvider);

    // Uygulama adı ülkeye göre değişir (android/.../res/values-*/strings.xml);
    // son uygulamalar ekranında da aynı ad görünsün.
    final appName =
        ref.watch(packageInfoProvider).valueOrNull?.appName ?? 'Wallet Elite';

    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      locale: Locale(localeCode),

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // Tema Ayarları - Dynamic based on selected color scheme
      theme: AppTheme.create(
        colorTheme: colorTheme,
        brightness: Brightness.light,
      ),

      darkTheme: AppTheme.create(
        colorTheme: colorTheme,
        brightness: Brightness.dark,
      ),

      themeMode: themeMode, // Settings'den gelen tema
      // Router
      routerConfig: router,
    );
  }
}
