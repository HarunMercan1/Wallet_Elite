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
      await _authRepository.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      state = false;
    }
  }

  Future<void> signUp({required String email, required String password, required String fullName}) async {
    state = true;
    try {
      await _authRepository.signUp(email: email, password: password, fullName: fullName);
    } finally {
      state = false;
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