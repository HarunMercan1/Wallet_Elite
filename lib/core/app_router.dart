import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Session kontrolü için
import '../features/auth/presentation/login_view.dart';
import '../features/auth/presentation/register_view.dart';
import '../features/wallet/presentation/wallet_view.dart';
import '../features/auth/data/auth_provider.dart'; // Auth durumunu dinlemek için
import '../features/home/presentation/dashboard_view.dart';

// Router'ı artık bir Provider olarak tanımlıyoruz (Çünkü durumu dinleyecek)
final appRouterProvider = Provider<GoRouter>((ref) {
  // Auth durumundaki değişiklikleri anlık takip et
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login', // Başlangıçta login'e gitmeye çalışsın (Redirect çözecek)
    // refreshListenable: Bu, authState değişince router'ı tetikler (Stream olduğu için manuel yapıyoruz)
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/', // Ana Sayfa (Cüzdan)
        builder: (context, state) => const DashboardView(),
      ),
    ],

    // --- İŞTE SİHİRLİ KISIM: YÖNLENDİRME MANTIĞI ---
    redirect: (context, state) {
      // 1. Kullanıcı oturum açmış mı?
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      // 2. Şu an hangi sayfada?
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      // SENARYO A: Kullanıcı giriş yapmamış ama Ana Sayfaya girmeye çalışıyor
      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login'; // Dur hemşehrim, önce giriş yap!
      }

      // SENARYO B: Kullanıcı zaten giriş yapmış ama hala Login ekranında takılıyor
      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/'; // Sen bizdensin, geç Cüzdan ekranına!
      }

      // Diğer durumlarda karışma, nereye gidiyorsa gitsin
      return null;
    },
  );
});