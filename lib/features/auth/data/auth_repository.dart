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
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print('🔄 Email ile kayıt başlatılıyor: $email, fullName: $fullName');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'display_name': fullName},
      );

      print(
        '📧 Kayıt response: user=${response.user?.id}, session=${response.session != null}',
      );

      if (response.user != null) {
        print('✅ Kayıt başarılı! User ID: ${response.user!.id}');

        // Profil tablosunda full_name'i güncelle (trigger yoksa manuel)
        try {
          await _supabase.from('profiles').upsert({
            'id': response.user!.id,
            'full_name': fullName,
          });
          print('✅ Profil güncellendi: $fullName');
        } catch (e) {
          print(
            '⚠️ Profil güncellenirken hata (trigger varsa sorun değil): $e',
          );
        }

        return {'success': true};
      } else {
        print('⚠️ Kayıt response geldi ama user null');
        return {'success': false, 'error': 'Kayıt işlemi başarısız oldu'};
      }
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      print('   Status Code: ${e.statusCode}');
      String errorMessage = 'Kayıt başarısız';
      if (e.message.contains('already registered')) {
        errorMessage = 'Bu e-posta adresi zaten kullanılıyor';
      } else if (e.message.contains('weak password')) {
        errorMessage = 'Şifre çok zayıf';
      } else if (e.message.contains('invalid email')) {
        errorMessage = 'Geçersiz e-posta adresi';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('❌ Email kayıt hatası: $e');
      print('   Hata tipi: ${e.runtimeType}');
      return {'success': false, 'error': 'Bir hata oluştu: $e'};
    }
  }

  /// Email ile giriş yap
  Future<Map<String, dynamic>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      print('🔄 Email ile giriş yapılıyor: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        print('✅ Giriş başarılı! User ID: ${response.user!.id}');
        return {'success': true};
      }
      return {'success': false, 'error': 'Giriş başarısız'};
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      String errorMessage = 'Giriş başarısız';
      if (e.message.contains('Invalid login credentials')) {
        errorMessage = 'E-posta veya şifre hatalı';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'E-posta adresinizi doğrulayın';
      } else if (e.message.contains('Too many requests')) {
        errorMessage = 'Çok fazla deneme yaptınız, lütfen bekleyin';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('Email giriş hatası: $e');
      return {'success': false, 'error': 'Bir hata oluştu'};
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
