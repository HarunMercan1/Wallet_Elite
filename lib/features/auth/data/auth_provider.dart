// lib/features/auth/data/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';
import '../../wallet/models/profile_model.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Mevcut kullanıcı provider'ı
final currentUserProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges.map((state) => state.session?.user);
});

/// Kullanıcı profili provider'ı
final userProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return null;

  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.getProfile(user.id);
});

/// Auth Controller (İşlemleri yöneten)
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;

  AuthController(this.ref);

  /// Email ile kayıt
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
    } catch (e) {
      print('Email kayıt hatası: $e');
      return {'success': false, 'error': 'Bir hata oluştu: $e'};
    }
  }

  /// Email ile giriş
  Future<Map<String, dynamic>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signInWithEmail(email, password);
    } catch (e) {
      print('Email giriş hatası: $e');
      return {'success': false, 'error': 'Bir hata oluştu: $e'};
    }
  }

  /// Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.resetPassword(email);
    } catch (e) {
      print('Şifre sıfırlama hatası: $e');
      return false;
    }
  }

  /// Google ile giriş
  Future<String?> signInWithGoogle() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signInWithGoogle();
    } catch (e) {
      print('Google giriş hatası: $e');
      return 'Bilinmeyen bir hata oluştu: $e';
    }
  }

  /// Apple ile giriş
  Future<bool> signInWithApple() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signInWithApple();
    } catch (e) {
      print('Apple giriş hatası: $e');
      return false;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
  }

  /// Onboarding'i tamamla
  Future<bool> completeOnboarding() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final authRepo = ref.read(authRepositoryProvider);
    return await authRepo.completeOnboarding(user.id);
  }
}
