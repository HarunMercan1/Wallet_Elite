import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State Management
import 'package:supabase_flutter/supabase_flutter.dart'; // Veritabanı
import 'core/app_router.dart'; // Trafik Polisi (Router)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. SUPABASE BAĞLANTISI (Burası Çok Önemli!)
  await Supabase.initialize(
    // DİKKAT: Buraya kendi proje URL'ini yaz (Doğru görünüyor)
    url: 'https://udekdhskflduszcoknch.supabase.co',

    // DİKKAT: Buraya 'anon public key' gelecek.
    // Sen URL'yi tekrar yazmışsın, o yanlış. Supabase panelinden 'Project Settings > API' kısmından kopyala.
    anonKey: 'sb_publishable_iUxetHgqsdyb1HXu2KWGkA__k-7WKDX',
  );

  // 2. UYGULAMAYI BAŞLAT (Riverpod Kapsayıcısı ile)
  runApp(const ProviderScope(child: WalletEliteApp()));
}

class WalletEliteApp extends StatelessWidget {
  const WalletEliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 3. ROUTER KURULUMU
    return MaterialApp.router(
      title: 'Wallet Elite',
      debugShowCheckedModeBanner: false,

      // ELITE TEMA AYARLARI
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A1F38), // Midnight Blue
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Koyu Lacivert
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F38),
          elevation: 0,
        ),
      ),

      // Trafik polisini (Router) buraya bağlıyoruz
      routerConfig: router,
    );
  }
}