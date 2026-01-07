// lib/core/widgets/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/login_view.dart';
import '../../features/auth/presentation/onboarding_view.dart';
import '../../features/home/presentation/main_shell.dart';

/// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/auth',
    debugLogDiagnostics: true,

    redirect: (context, state) async {
      // Kullanıcının auth durumunu kontrol et
      final session = supabase.auth.currentSession;
      final isLoggedIn = session != null;

      final isGoingToAuth = state.matchedLocation == '/auth';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      // Giriş yapmamış ve auth'a gitmiyorsa → auth'a yönlendir
      if (!isLoggedIn && !isGoingToAuth) {
        return '/auth';
      }

      // Giriş yapmış ise profili kontrol et
      if (isLoggedIn) {
        try {
          // Profil bilgisini al
          final profileResponse = await supabase
              .from('profiles')
              .select('onboarding_completed')
              .eq('id', session.user.id)
              .maybeSingle();

          if (profileResponse == null) {
            // Profil henüz oluşmamış, onboarding'e git
            if (!isGoingToOnboarding) return '/onboarding';
            return null;
          }

          final onboardingCompleted =
              profileResponse['onboarding_completed'] as bool? ?? false;

          // Onboarding tamamlanmamış ve onboarding'e gitmiyorsa → onboarding'e yönlendir
          if (!onboardingCompleted && !isGoingToOnboarding) {
            return '/onboarding';
          }

          // Onboarding tamamlanmış ve auth/onboarding sayfasındaysa → home'a yönlendir
          if (onboardingCompleted && (isGoingToAuth || isGoingToOnboarding)) {
            return '/home';
          }
        } catch (e) {
          print('Router profil kontrolü hatası: $e');
          // Hata varsa onboarding'e yönlendir
          if (!isGoingToOnboarding) return '/onboarding';
        }
      }

      // Diğer durumlarda olduğu gibi devam et
      return null;
    },

    routes: [
      // Auth Routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginView(),
      ),

      // Onboarding Route
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingView(),
      ),

      // Home Routes - MainShell ile bottom navigation
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainShell(),
      ),
    ],
  );
});
