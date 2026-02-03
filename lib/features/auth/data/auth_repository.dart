// lib/features/auth/data/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../wallet/models/profile_model.dart';

/// Auth işlemlerini yöneten repository
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Google Sign In objesini tek bir yerde, doğru config ile oluşturuyoruz
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '124406936709-pbknseqqe0hvcpbg4jehm97ulauigf05.apps.googleusercontent.com',
  );

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
      if (e.toString().contains('SocketException') ||
          e.toString().contains('host lookup') ||
          e.toString().contains('Network is unreachable')) {
        return {'success': false, 'error': 'network_error'};
      }
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
      if (e.toString().contains('SocketException') ||
          e.toString().contains('host lookup') ||
          e.toString().contains('Network is unreachable')) {
        return {'success': false, 'error': 'network_error'};
      }
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
  /// Google ile giriş yap (Hata varsa mesaj döner, yoksa null)
  Future<String?> signInWithGoogle() async {
    try {
      // Önceki oturum kalıntılarını temizle (Hesap seçiciyi zorlamak için)
      await _googleSignIn.signOut();

      // 3. Kullanıcıya Google giriş ekranını göster
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı girişi iptal etti
        return 'Giriş iptal edildi';
      }

      // 4. Authentication detaylarını al
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        return 'Google Access Token bulunamadı.';
      }
      if (idToken == null) {
        return 'Google ID Token bulunamadı.';
      }

      // 5. Supabase'e giriş yap
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 6. Profil kontrolü yap (yoksa oluştur)
      if (response.user != null) {
        final userId = response.user!.id;
        final fullName = googleUser.displayName ?? 'Google User';
        final avatarUrl = googleUser.photoUrl;

        // Mevcut profili kontrol et
        final existingProfile = await getProfile(userId);

        if (existingProfile == null) {
          // Yeni profil oluştur
          await _supabase.from('profiles').upsert({
            'id': userId,
            'full_name': fullName,
            'avatar_url': avatarUrl,
            'is_premium': false,
            'onboarding_completed': true,
          });
        }
      }

      return null; // Başarılı, hata yok
    } catch (e) {
      print('Google giriş hatası: $e');
      if (e.toString().contains('ApiException: 10')) {
        return 'Google Yapılandırma Hatası (Hata: 10).\nLütfen SHA-1 ve Paket Adını kontrol edin.';
      }
      if (e.toString().contains('ApiException: 12500')) {
        return 'Google Play Servisleri güncel değil veya cihaz desteklemiyor (Hata: 12500).';
      }
      return 'Giriş hatası: $e';
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
    try {
      await _googleSignIn
          .disconnect(); // Disconnect önemli, hesabı unutmasını sağlar
    } catch (e) {
      print('Google çıkış hatası (disconnect): $e');
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google çıkış hatası (signOut): $e');
    }
  }

  /// Kullanıcı profilini getir (yoksa oluştur)
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle(); // single() yerine maybeSingle() kullan

      if (response != null) {
        return ProfileModel.fromJson(response);
      }

      // Profil yoksa oluştur
      print('⚠️ Profil bulunamadı, yeni profil oluşturuluyor...');

      // Auth'dan kullanıcı bilgilerini al
      final user = _supabase.auth.currentUser;
      final fullName =
          user?.userMetadata?['full_name'] ??
          user?.userMetadata?['display_name'] ??
          user?.email?.split('@').first ??
          'Kullanıcı';

      // Yeni profil oluştur
      await _supabase.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
        'is_premium': false,
        'onboarding_completed': true,
      });

      print('✅ Yeni profil oluşturuldu: $fullName');

      // Oluşturulan profili getir
      final newProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(newProfile);
    } catch (e) {
      print('❌ Profil getirme/oluşturma hatası: $e');
      return null;
    }
  }

  /// Profili güncelle
  Future<bool> updateProfile(ProfileModel profile) async {
    try {
      // Sadece değiştirilebilir alanları gönder (id ve updated_at hariç)
      final updateData = <String, dynamic>{
        'full_name': profile.fullName,
        'avatar_url': profile.avatarUrl,
      };

      await _supabase.from('profiles').update(updateData).eq('id', profile.id);

      print('✅ Profil güncellendi: ${profile.fullName}');
      return true;
    } catch (e) {
      print('❌ Profil güncelleme hatası: $e');
      return false;
    }
  }

  /// Avatar yükle (Supabase Storage)
  Future<String?> uploadAvatar(String userId, List<int> imageBytes) async {
    try {
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Supabase Storage'a yükle
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            imageBytes as dynamic,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Public URL al
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Profili güncelle
      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      print('✅ Avatar yüklendi: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Avatar yükleme hatası: $e');
      return null;
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

  /// Kullanıcı tercihlerini güncelle (Supabase'e kaydet)
  Future<bool> updateUserPreferences({
    required String userId,
    String? language,
    String? theme,
    String? currency,
    bool? isDarkMode,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (language != null) updateData['preferred_language'] = language;
      if (theme != null) updateData['preferred_theme'] = theme;
      if (currency != null) updateData['preferred_currency'] = currency;
      if (isDarkMode != null) updateData['is_dark_mode'] = isDarkMode;

      if (updateData.isEmpty) return true;

      await _supabase.from('profiles').update(updateData).eq('id', userId);

      print('✅ Kullanıcı tercihleri güncellendi: $updateData');
      return true;
    } catch (e) {
      print('❌ Tercih güncelleme hatası: $e');
      return false;
    }
  }

  /// Kullanıcı tercihlerini getir (Supabase'den)
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select(
            'preferred_language, preferred_theme, preferred_currency, is_dark_mode',
          )
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Tercih getirme hatası: $e');
      return null;
    }
  }
}
