import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    // Ekran boyutunu alıyoruz (Responsive tasarım için)
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // resizeToAvoidBottomInset: false yaparsak klavye açılınca ekran sıkışmaz
      // ama inputlar altta kalabilir. True en sağlıklısıdır.
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Klavye açılınca kayabilsin ama normalde tam ekran dursun diye:
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // En az ekran boyu kadar olsun
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Üstten biraz boşluk (Spacer esnek boşluktur)
                      const Spacer(flex: 2),

                      // LOGO (Ekran küçükse biraz küçülsün)
                      Icon(
                        Icons.account_balance_wallet,
                        size: screenHeight < 600 ? 60 : 80, // Küçük ekranda küçült
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'WALLET ELITE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Paranı Yönet, Geleceğini İnşa Et',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenHeight < 600 ? 14 : 16,
                        ),
                      ),

                      const Spacer(flex: 2), // Araya esnek boşluk

                      // FORM ALANLARI
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFF1A1F38),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFF1A1F38),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // GİRİŞ BUTONU
                      ElevatedButton(
                        onPressed: isLoading ? null : () {
                          ref.read(authControllerProvider.notifier).signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text('Giriş Yap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),

                      const Spacer(flex: 2), // Araya esnek boşluk

                      const Text('veya', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),

                      // SOSYAL MEDYA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialButton(
                            icon: FontAwesomeIcons.google,
                            color: Colors.red,
                            onTap: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                          ),
                          const SizedBox(width: 20),
                          _SocialButton(
                            icon: FontAwesomeIcons.apple,
                            color: Colors.white,
                            onTap: () => ref.read(authControllerProvider.notifier).signInWithApple(),
                          ),
                        ],
                      ),

                      const Spacer(flex: 1), // Alt kısımdan biraz boşluk

                      // KAYIT OL LİNKİ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Hesabın yok mu?", style: TextStyle(color: Colors.grey)),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text('Kayıt Ol', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const Spacer(flex: 1), // En altta biraz boşluk kalsın
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F38),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}