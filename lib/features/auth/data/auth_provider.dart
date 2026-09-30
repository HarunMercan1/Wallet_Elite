import 'package:flutter/foundation.dart';
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

/// Aktif kullanıcının ID'si. Kullanıcıya ait veri provider'ları bunu `watch`
/// eder; böylece çıkış yapılıp başka hesapla girildiğinde önceki kullanıcının
/// verisi ekranda kalmaz, hepsi yeniden yüklenir. Token yenilemesi gibi aynı
/// kullanıcı için gelen olaylarda ID değişmediği için gereksiz yenileme olmaz.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(currentUserProvider);
  // Stream ilk değerini verene kadar mevcut oturumu kullan
  return authState.hasValue
      ? authState.value?.id
      : Supabase.instance.client.auth.currentUser?.id;
});

/// Kullanıcı profili provider'ı
final userProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return null;

  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.getProfile(userId);
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
      debugPrint('Email kayıt hatası: $e');
      return {'success': false, 'error': null};
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
      debugPrint('Email giriş hatası: $e');
      return {'success': false, 'error': null};
    }
  }

  /// Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.resetPassword(email);
    } catch (e) {
      debugPrint('Şifre sıfırlama hatası: $e');
      return false;
    }
  }

  /// Google ile giriş
  Future<String?> signInWithGoogle() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signInWithGoogle();
    } catch (e) {
      debugPrint('Google giriş hatası: $e');
      return 'google_failed';
    }
  }

  /// Apple ile giriş
  Future<bool> signInWithApple() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      return await authRepo.signInWithApple();
    } catch (e) {
      debugPrint('Apple giriş hatası: $e');
      return false;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
  }

  /// Hesabı ve tüm verileri kalıcı olarak sil
  Future<bool> deleteAccount() async {
    final authRepo = ref.read(authRepositoryProvider);
    return await authRepo.deleteAccount();
  }

  /// Onboarding'i tamamla
  Future<bool> completeOnboarding() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final authRepo = ref.read(authRepositoryProvider);
    return await authRepo.completeOnboarding(user.id);
  }
}
