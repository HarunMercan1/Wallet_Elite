// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/constants/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/app_router.dart';
import 'features/settings/data/settings_provider.dart';

void main() async {
  // Flutter Engine başlatma
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase başlatma
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    print('Supabase başlatma hatası: $e');
    // Hata olsa bile devam et, router offline durumu yönetecek
  }

  // Intl locale başlatma (Tüm diller için)
  await initializeDateFormatting(null, null);

  // Uygulamayı başlat
  runApp(const ProviderScope(child: WalletEliteApp()));
}

class WalletEliteApp extends ConsumerWidget {
  const WalletEliteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final localeCode = ref.watch(localeProvider);
    final colorSchemeId = ref.watch(colorSchemeProvider);

    // Get the selected color theme
    final colorTheme = ColorTheme.fromString(colorSchemeId);

    return MaterialApp.router(
      title: 'Wallet Elite',
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorTheme.primary,
          brightness: Brightness.light,
          primary: colorTheme.primary,
          secondary: colorTheme.accent,
        ),
        primaryColor: colorTheme.primary,
        textTheme: GoogleFonts.interTextTheme(),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorTheme.primary,
          brightness: Brightness.dark,
          primary: colorTheme.primary,
          secondary: colorTheme.accent,
        ),
        primaryColor: colorTheme.primary,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),

      themeMode: themeMode, // Settings'den gelen tema
      // Router
      routerConfig: router,
    );
  }
}
