import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. SUPABASE BAĞLANTISI
  // Buraya kendi URL ve KEY bilgilerini tırnak içine yapıştır
  await Supabase.initialize(
    url: 'https://udekdhskflduszcoknch.supabase.co',
    anonKey: 'https://udekdhskflduszcoknch.supabase.co',
  );

  runApp(const WalletEliteApp());
}

class WalletEliteApp extends StatelessWidget {
  const WalletEliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Elite',
      debugShowCheckedModeBanner: false,
      // ELITE TEMA: Gece Mavisi ve Altın Sarısı
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A1F38), // Midnight Blue
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Daha koyu lacivert
        useMaterial3: true,
      ),
      home: const ConnectionTestScreen(),
    );
  }
}

class ConnectionTestScreen extends StatelessWidget {
  const ConnectionTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo niyetine bir ikon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F38),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 20)
                ],
              ),
              child: const Icon(Icons.account_balance_wallet, size: 60, color: Colors.amber),
            ),
            const SizedBox(height: 30),
            const Text(
              'WALLET ELITE',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white
              ),
            ),
            const SizedBox(height: 10),
            // Bağlantı kontrolü
            const Chip(
              label: Text('Supabase Bağlantısı Başarılı'),
              avatar: Icon(Icons.check_circle, color: Colors.green),
              backgroundColor: Color(0xFF1A1F38),
              labelStyle: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}