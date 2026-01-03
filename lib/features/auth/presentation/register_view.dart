import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);

    // Küçük ekran kontrolü için ekran yüksekliğini alıyoruz
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // AppBar'ı şeffaf yapıp sadece geri butonu koyuyoruz
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      // DİNAMİK YAPI BURADA BAŞLIYOR
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Klavye açılsa bile ekranın en az tamamı kadar yer kapla
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Üstten biraz esnek boşluk
                      const Spacer(flex: 1),

                      // BAŞLIK ALANI
                      Text(
                        'Aramıza Katıl',
                        style: TextStyle(
                          fontSize: screenHeight < 600 ? 28 : 32, // Küçük ekranda fontu kıs
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Finansal özgürlüğüne giden ilk adım.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),

                      const Spacer(flex: 2), // Başlık ile form arasına geniş boşluk

                      // İSİM ALANI
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Ad Soyad',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFF1A1F38),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // EMAIL ALANI
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

                      // ŞİFRE ALANI
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

                      const Spacer(flex: 2), // Form ile buton arasına boşluk

                      // KAYIT OL BUTONU
                      ElevatedButton(
                        onPressed: isLoading ? null : () {
                          ref.read(authControllerProvider.notifier).signUp(
                            email: _emailController.text,
                            password: _passwordController.text,
                            fullName: _nameController.text,
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
                            : const Text('Kayıt Ol', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),

                      const Spacer(flex: 3), // Alttan en geniş boşluğu bırakıyoruz ki buton çok aşağı düşmesin
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