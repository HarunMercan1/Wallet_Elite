import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // DİKKAT: Buraya kendi URL ve KEY bilgilerini tekrar yapıştır!
    url: 'https://udekdhskflduszcoknch.supabase.co',
    anonKey: 'sb_publishable_iUxetHgqsdyb1HXu2KWGkA__k-7WKDX',
  );

  runApp(const ProviderScope(child: WalletEliteApp()));
}

// StatelessWidget -> ConsumerWidget oldu (Router'ı okumak için)
class WalletEliteApp extends ConsumerWidget {
  const WalletEliteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yeni oluşturduğumuz Router Provider'ını izle
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Wallet Elite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A1F38),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F38),
          elevation: 0,
        ),
      ),
      // Config artık provider'dan geliyor
      routerConfig: router,
    );
  }
}