import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_view.dart';
import '../features/auth/presentation/register_view.dart'; // <-- Bunu Ekle

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginView(),
    ),
    // AŞAĞIDAKİ KISMI EKLE:
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),
  ],
);