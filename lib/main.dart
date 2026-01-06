// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/supabase_config.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/app_router.dart';

void main() async {
  // Flutter Engine başlatma
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase başlatma
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Uygulamayı başlat
  runApp(
    const ProviderScope(
      child: WalletEliteApp(),
    ),
  );
}

class WalletEliteApp extends ConsumerWidget {
  const WalletEliteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Wallet Elite',
      debugShowCheckedModeBanner: false,

      // Tema Ayarları
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),

      themeMode: ThemeMode.system, // Sistem temasını takip et

      // Router
      routerConfig: router,
    );
  }
}