import 'package:flutter/foundation.dart';
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
      debugPrint(
        '🔄 Email ile kayıt başlatılıyor: $email, fullName: $fullName',
      );

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'display_name': fullName},
      );

      debugPrint(
        '📧 Kayıt response: user=${response.user?.id}, session=${response.session != null}',
      );

      if (response.user != null) {
        debugPrint('✅ Kayıt başarılı! User ID: ${response.user!.id}');

        // Profil tablosunda full_name'i güncelle (trigger yoksa manuel)
        try {
          await _supabase.from('profiles').upsert({
            'id': response.user!.id,
            'full_name': fullName,
          });
          debugPrint('✅ Profil güncellendi: $fullName');
        } catch (e) {
          debugPrint(
            '⚠️ Profil güncellenirken hata (trigger varsa sorun değil): $e',
          );
        }

        return {'success': true};
      } else {
        debugPrint('⚠️ Kayıt response geldi ama user null');
        return {'success': false, 'error': null};
      }
    } on AuthException catch (e) {
      debugPrint('❌ AuthException: ${e.message}');
      debugPrint('   Status Code: ${e.statusCode}');
      return {'success': false, 'error': _authErrorCode(e)};
    } catch (e) {
      debugPrint('❌ Email kayıt hatası: $e');
      debugPrint('   Hata tipi: ${e.runtimeType}');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('host lookup') ||
          e.toString().contains('Network is unreachable')) {
        return {'success': false, 'error': 'network_error'};
      }
      return {'success': false, 'error': null};
    }
  }

  /// Supabase AuthException'ı ekranda çevrilecek bir hata koduna dönüştür.
  /// Kodlar: invalid_credentials, email_not_confirmed, too_many_requests,
  /// email_in_use, weak_password, invalid_email; null = genel hata.
  String? _authErrorCode(AuthException e) {
    final code = e.code ?? '';
    final msg = e.message.toLowerCase();
    if (code == 'invalid_credentials' ||
        msg.contains('invalid login credentials')) {
      return 'invalid_credentials';
    }
    if (code == 'email_not_confirmed' || msg.contains('email not confirmed')) {
      return 'email_not_confirmed';
    }
    if (code == 'over_request_rate_limit' ||
        code == 'over_email_send_rate_limit' ||
        e.statusCode == '429' ||
        msg.contains('too many requests')) {
      return 'too_many_requests';
    }
    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        msg.contains('already registered')) {
      return 'email_in_use';
    }
    if (code == 'weak_password' ||
        msg.contains('weak password') ||
        msg.contains('password should be')) {
      return 'weak_password';
    }
    if (code == 'email_address_invalid' ||
        msg.contains('invalid email') ||
        msg.contains('invalid format')) {
      return 'invalid_email';
    }
    return null;
  }

  /// Email ile giriş yap
  Future<Map<String, dynamic>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔄 Email ile giriş yapılıyor: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        debugPrint('✅ Giriş başarılı! User ID: ${response.user!.id}');
        return {'success': true};
      }
      return {'success': false, 'error': null};
    } on AuthException catch (e) {
      debugPrint('❌ AuthException: ${e.message}');
      return {'success': false, 'error': _authErrorCode(e)};
    } catch (e) {
      debugPrint('Email giriş hatası: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('host lookup') ||
          e.toString().contains('Network is unreachable')) {
        return {'success': false, 'error': 'network_error'};
      }
      return {'success': false, 'error': null};
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      debugPrint('Şifre sıfırlama hatası: $e');
      return false;
    }
  }

  /// Google ile giriş yap. Başarılıysa null, değilse hata kodu döner:
  /// cancelled, google_config, play_services, network_error, google_failed
  Future<String?> signInWithGoogle() async {
    try {
      // Önceki oturum kalıntılarını temizle (Hesap seçiciyi zorlamak için)
      await _googleSignIn.signOut();

      // 3. Kullanıcıya Google giriş ekranını göster
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı girişi iptal etti
        return 'cancelled';
      }

      // 4. Authentication detaylarını al
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        return 'google_failed';
      }
      if (idToken == null) {
        return 'google_failed';
      }

      // 5. Supabase'e giriş yap
      // Profil, DB'deki handle_new_user trigger'ı ile onboarding_completed=false
      // olarak oluşturulur; router yeni kullanıcıyı onboarding'e yönlendirir.
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return null; // Başarılı, hata yok
    } catch (e) {
      debugPrint('Google giriş hatası: $e');
      final err = e.toString();
      if (err.contains('ApiException: 10')) return 'google_config';
      if (err.contains('ApiException: 12500')) return 'play_services';
      if (err.contains('SocketException') ||
          err.contains('host lookup') ||
          err.contains('Network is unreachable')) {
        return 'network_error';
      }
      return 'google_failed';
    }
  }

  /// Apple ile giriş yap
  Future<bool> signInWithApple() async {
    // TODO: iOS cihazda test edilecek
    debugPrint('Apple Sign-In şu an sadece iOS cihazlarda çalışır');
    return false;
  }

  /// Çıkış yap
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    try {
      await _googleSignIn
          .disconnect(); // Disconnect önemli, hesabı unutmasını sağlar
    } catch (e) {
      debugPrint('Google çıkış hatası (disconnect): $e');
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google çıkış hatası (signOut): $e');
    }
  }

  /// Hesabı ve tüm verileri kalıcı olarak sil (delete_my_account RPC)
  Future<bool> deleteAccount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    // Profil fotoğraflarını sil (Storage dosyaları veritabanı silmesiyle gitmez)
    await _removeAvatarFiles(userId);

    try {
      await _supabase.rpc('delete_my_account');
    } catch (e) {
      debugPrint('❌ Hesap silme hatası: $e');
      return false;
    }

    // Kullanıcı sunucuda silindi; oturumu yalnızca yerelde kapat
    // (sunucuya logout isteği artık geçersiz token ile hata verir).
    try {
      await _supabase.auth.signOut(scope: SignOutScope.local);
    } catch (e) {
      debugPrint('Yerel oturum kapatma hatası: $e');
    }
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('Google disconnect hatası: $e');
    }
    return true;
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
      debugPrint('⚠️ Profil bulunamadı, yeni profil oluşturuluyor...');

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
        'onboarding_completed': false,
      });

      debugPrint('✅ Yeni profil oluşturuldu: $fullName');

      // Oluşturulan profili getir
      final newProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(newProfile);
    } catch (e) {
      debugPrint('❌ Profil getirme/oluşturma hatası: $e');
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

      debugPrint('✅ Profil güncellendi: ${profile.fullName}');
      return true;
    } catch (e) {
      debugPrint('❌ Profil güncelleme hatası: $e');
      return false;
    }
  }

  /// Avatar yükle (Supabase Storage)
  Future<String?> uploadAvatar(String userId, Uint8List imageBytes) async {
    try {
      final fileName =
          '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Supabase Storage'a yükle
      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // Eski avatarları temizle (her yüklemede yeni dosya adı kullanılıyor)
      await _removeAvatarFiles(userId, except: fileName);

      // Public URL al
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Profili güncelle
      await _supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      debugPrint('✅ Avatar yüklendi: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Avatar yükleme hatası: $e');
      return null;
    }
  }

  /// Kullanıcının avatars/{userId}/ klasöründeki dosyaları sil
  Future<void> _removeAvatarFiles(String userId, {String? except}) async {
    try {
      final files = await _supabase.storage.from('avatars').list(path: userId);
      final paths = files
          .map((f) => '$userId/${f.name}')
          .where((p) => p != except)
          .toList();
      if (paths.isNotEmpty) {
        await _supabase.storage.from('avatars').remove(paths);
      }
    } catch (e) {
      debugPrint('Avatar temizleme hatası: $e');
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
      debugPrint('Onboarding güncelleme hatası: $e');
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

      debugPrint('✅ Kullanıcı tercihleri güncellendi: $updateData');
      return true;
    } catch (e) {
      debugPrint('❌ Tercih güncelleme hatası: $e');
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
      debugPrint('❌ Tercih getirme hatası: $e');
      return null;
    }
  }
}
