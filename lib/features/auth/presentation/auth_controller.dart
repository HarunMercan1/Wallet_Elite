import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- İŞTE EKSİK OLAN SATIR BU!
import '../data/auth_provider.dart';
import '../data/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(false);

  Future<void> signIn({required String email, required String password}) async {
    state = true;
    try {
      print("🚀 Giriş deneniyor... Email: $email");
      await _authRepository.signIn(email: email, password: password);
      print("✅ GİRİŞ BAŞARILI! Yönlendirme bekleniyor...");
    } catch (e) {
      print("🛑 GİRİŞ HATASI: $e"); // <-- Hatayı burada göreceğiz
    } finally {
      state = false;
    }
  }

  // auth_controller.dart içindeki signUp fonksiyonunu bununla değiştir:

  Future<void> signUp({required String email, required String password, required String fullName}) async {
    state = true; // Yükleniyor simgesi dönsün
    try {
      print("🚀 Sinyal gönderiliyor... Hedef: Supabase");
      print("📧 Email: $email");

      await _authRepository.signUp(email: email, password: password, fullName: fullName);

      print("✅ OPERASYON BAŞARILI! Kullanıcı oluştu.");
    } catch (e) {
      print("🛑 HATA TESPİT EDİLDİ: $e"); // <-- İşte katili bize burası söyleyecek
    } finally {
      state = false; // İşlem bitti
    }
  }

  Future<void> signInWithGoogle() async {
    state = true;
    try {
      await _authRepository.signInWithGoogle();
    } finally {
      state = false;
    }
  }

  Future<void> signInWithApple() async {
    state = true;
    try {
      await _authRepository.signInWithApple();
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}