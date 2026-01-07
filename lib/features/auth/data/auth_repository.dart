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

  /// Email ile kayıt ol
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      print('🔄 Email ile kayıt başlatılıyor: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      print(
        '📧 Kayıt response: user=${response.user?.id}, session=${response.session != null}',
      );

      if (response.user != null) {
        print('✅ Kayıt başarılı! User ID: ${response.user!.id}');
        return true;
      } else {
        print('⚠️ Kayıt response geldi ama user null');
        return false;
      }
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      print('   Status Code: ${e.statusCode}');
      return false;
    } catch (e) {
      print('❌ Email kayıt hatası: $e');
      print('   Hata tipi: ${e.runtimeType}');
      return false;
    }
  }

  /// Email ile giriş yap
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Email giriş hatası: $e');
      return false;
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      print('Şifre sıfırlama hatası: $e');
      return false;
    }
  }

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
