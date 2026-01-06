// lib/features/auth/data/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../wallet/models/profile_model.dart';

/// Auth işlemlerini yöneten repository
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mevcut kullanıcı var mı?
  User? get currentUser => _supabase.auth.currentUser;

  /// Auth state değişikliklerini dinle
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Google ile giriş yap
  // lib/features/auth/data/auth_repository.dart

  /// Google ile giriş yap
  // lib/features/auth/data/auth_repository.dart (DÜZELTME)

  /// Google ile giriş yap
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.walletelite://login-callback',
      );
      return true;
    } catch (e) {
      print('Google giriş hatası: $e');
      return false;
    }
  }

  /// Apple ile giriş yap
  Future<bool> signInWithApple() async {
    // TODO: iOS cihazda test edilecek
    print('Apple Sign-In şu an sadece iOS cihazlarda çalışır');
    return false;

    /* ÖNCEKİ KOD:
  try {
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.walletelite://login-callback',
    );
    return true;
  } catch (e) {
    print('Apple giriş hatası: $e');
    return false;
  }
  */
  }

  /// Çıkış yap
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Kullanıcı profilini getir
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      print('Profil getirme hatası: $e');
      return null;
    }
  }

  /// Profili güncelle
  Future<bool> updateProfile(ProfileModel profile) async {
    try {
      await _supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
      return true;
    } catch (e) {
      print('Profil güncelleme hatası: $e');
      return false;
    }
  }

  /// Onboarding'i tamamla
  Future<bool> completeOnboarding(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({'onboarding_completed': true})
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Onboarding güncelleme hatası: $e');
      return false;
    }
  }
}