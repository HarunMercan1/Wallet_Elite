// lib/features/auth/presentation/login_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Başlık
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Wallet Elite',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Finansal özgürlüğünüz, avucunuzda',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.accentLight,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  // Google Sign In Button
                  _SocialButton(
                    icon: FontAwesomeIcons.google,
                    label: 'Google ile Devam Et',
                    onPressed: () async {
                      final success = await authController.signInWithGoogle();
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Giriş başarısız oldu'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),

                  // Apple butonunu KALDIRILDI (iOS'ta test edilecek)

                  const SizedBox(height: 40),

                  // Privacy Text
                  const Text(
                    'Devam ederek Kullanım Şartları ve\nGizlilik Politikası\'nı kabul etmiş olursunuz',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.accentLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sosyal medya giriş butonu widget'ı
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: FaIcon(
          icon,
          color: backgroundColor == Colors.white ? Colors.black87 : Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: backgroundColor == Colors.white ? Colors.black87 : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}