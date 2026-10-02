// lib/features/auth/presentation/login_view.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/app_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../l10n/app_localizations.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);
    final colorTheme = ref.watch(currentColorThemeProvider);
    final responsive = ResponsiveHelper(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorTheme.primary, colorTheme.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsive.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Title
                  AppLogo(size: responsive.wp(24)),
                  SizedBox(height: responsive.hp(2)),

                  Text(
                    'Wallet Elite',
                    style: TextStyle(
                      fontSize: responsive.titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colorTheme.onPrimary,
                    ),
                  ),

                  SizedBox(height: responsive.hp(1)),

                  Text(
                    l.tagline,
                    style: TextStyle(
                      fontSize: responsive.bodyFontSize,
                      color: colorTheme.onPrimary.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: responsive.hp(4)),

                  // Form Card
                  Container(
                    padding: responsive.allPadding,
                    decoration: BoxDecoration(
                      color: colorTheme.cardColor,
                      borderRadius: responsive.borderRadiusL,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tab Selection
                          Row(
                            children: [
                              Expanded(
                                child: _buildTabButton(
                                  l.loginTab,
                                  _isLogin,
                                  () {
                                    setState(() => _isLogin = true);
                                  },
                                  colorTheme,
                                  responsive,
                                ),
                              ),
                              SizedBox(width: responsive.paddingS),
                              Expanded(
                                child: _buildTabButton(
                                  l.registerTab,
                                  !_isLogin,
                                  () {
                                    setState(() => _isLogin = false);
                                  },
                                  colorTheme,
                                  responsive,
                                ),
                              ),
                            ],
                          ),

                          responsive.verticalSpaceXL,

                          // Name field (only for registration)
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(color: colorTheme.textPrimary),
                              decoration: InputDecoration(
                                labelText: l.fullName,
                                labelStyle: TextStyle(
                                  color: colorTheme.textSecondary,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outlined,
                                  color: colorTheme.primary,
                                  size: responsive.iconL,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: responsive.borderRadiusM,
                                  borderSide: BorderSide(
                                    color: colorTheme.textMuted,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: responsive.borderRadiusM,
                                  borderSide: BorderSide(
                                    color: colorTheme.textMuted,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: responsive.borderRadiusM,
                                  borderSide: BorderSide(
                                    color: colorTheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (!_isLogin &&
                                    (value == null || value.trim().isEmpty)) {
                                  return l.enterFullName;
                                }
                                if (!_isLogin && value!.trim().length < 2) {
                                  return l.nameTooShort;
                                }
                                return null;
                              },
                            ),
                            responsive.verticalSpaceL,
                          ],

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: colorTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: l.email,
                              labelStyle: TextStyle(
                                color: colorTheme.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: colorTheme.primary,
                                size: responsive.iconL,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: responsive.borderRadiusM,
                                borderSide: BorderSide(
                                  color: colorTheme.textMuted,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: responsive.borderRadiusM,
                                borderSide: BorderSide(
                                  color: colorTheme.textMuted,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: responsive.borderRadiusM,
                                borderSide: BorderSide(
                                  color: colorTheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l.enterEmail;
                              }
                              if (!value.contains('@')) {
                                return l.validEmail;
                              }
                              return null;
                            },
                          ),

                          responsive.verticalSpaceL,

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: colorTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: l.password,
                              labelStyle: TextStyle(
                                color: colorTheme.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outlined,
                                color: colorTheme.primary,
                                size: responsive.iconL,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: colorTheme.textSecondary,
                                  size: responsive.iconL,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: responsive.borderRadiusM,
                                borderSide: BorderSide(
                                  color: colorTheme.textMuted,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: responsive.borderRadiusM,
                                borderSide: BorderSide(
                                  color: colorTheme.textMuted,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: responsive.borderRadiusM,
                                borderSide: BorderSide(
                                  color: colorTheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l.enterPassword;
                              }
                              if (value.length < 6) {
                                return l.passwordTooShort;
                              }
                              return null;
                            },
                          ),

                          if (_isLogin) ...[
                            responsive.verticalSpaceS,
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _showForgotPasswordDialog(l),
                                child: Text(l.forgotPassword),
                              ),
                            ),
                          ],

                          responsive.verticalSpaceL,

                          // Login/Register Button
                          SizedBox(
                            height: responsive.buttonHeight,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _handleEmailAuth(l),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorTheme.primary,
                                foregroundColor: colorTheme.onPrimary,
                                disabledBackgroundColor: colorTheme.primary
                                    .withValues(alpha: 0.7),
                                disabledForegroundColor: colorTheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: responsive.borderRadiusM,
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorTheme.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      _isLogin ? l.loginTab : l.registerTab,
                                      style: TextStyle(
                                        fontSize: responsive.fontL,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          responsive.verticalSpaceXL,

                          // Or divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: colorTheme.outline),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  l.orDivider,
                                  style: TextStyle(
                                    color: colorTheme.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: colorTheme.outline),
                              ),
                            ],
                          ),

                          responsive.verticalSpaceXL,

                          // Google sign-in
                          OutlinedButton.icon(
                            onPressed: (_isLoading || _isGoogleLoading)
                                ? null
                                : () async {
                                    setState(() => _isGoogleLoading = true);
                                    final errorMessage = await authController
                                        .signInWithGoogle();

                                    if (!context.mounted) return;
                                    setState(() => _isGoogleLoading = false);

                                    if (errorMessage != null &&
                                        errorMessage != 'cancelled') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _authErrorText(errorMessage, l),
                                          ),
                                          backgroundColor: colorTheme.error,
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    } else if (errorMessage == null) {
                                      // Başarılı giriş
                                      context.go('/home');
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: responsive.hp(1.5),
                              ),
                              foregroundColor: colorTheme.textPrimary,
                              side: BorderSide(color: colorTheme.textMuted),
                              shape: RoundedRectangleBorder(
                                borderRadius: responsive.borderRadiusM,
                              ),
                            ),
                            icon: _isGoogleLoading
                                ? SizedBox(
                                    width: responsive.iconM,
                                    height: responsive.iconM,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : FaIcon(
                                    FontAwesomeIcons.google,
                                    size: responsive.iconM,
                                    color: colorTheme.error,
                                  ),
                            label: Text(
                              _isGoogleLoading
                                  ? l.signingIn
                                  : l.continueWithGoogle,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: colorTheme.textPrimary,
                                fontSize: responsive.fontM,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: responsive.hp(3)),

                  // Privacy Text
                  Text(
                    l.privacyText,
                    style: TextStyle(
                      fontSize: responsive.subtitleFontSize,
                      color: colorTheme.onPrimary.withValues(alpha: 0.85),
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

  Widget _buildTabButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ColorTheme colorTheme,
    ResponsiveHelper responsive,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorTheme.primary : colorTheme.subtleCardColor,
          borderRadius: responsive.borderRadiusS,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? colorTheme.onPrimary : colorTheme.textSecondary,
            fontSize: responsive.fontM,
          ),
        ),
      ),
    );
  }

  /// Repository'den gelen hata kodunu kullanıcının dilinde metne çevir
  String _authErrorText(String? code, AppLocalizations l, {String? fallback}) {
    switch (code) {
      case 'network_error':
        return l.networkError;
      case 'invalid_credentials':
        return l.errInvalidCredentials;
      case 'email_not_confirmed':
        return l.errEmailNotConfirmed;
      case 'too_many_requests':
        return l.errTooManyRequests;
      case 'email_in_use':
        return l.errEmailInUse;
      case 'weak_password':
        return l.errWeakPassword;
      case 'invalid_email':
        return l.errInvalidEmail;
      case 'google_config':
        return l.errGoogleConfig;
      case 'play_services':
        return l.errPlayServices;
      case 'google_failed':
        return l.googleLoginFailed;
      default:
        return fallback ?? l.errorOccurred;
    }
  }

  Future<void> _handleEmailAuth(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider);
      bool success;
      String? errorMessage;

      if (_isLogin) {
        final result = await authController.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        success = result['success'] as bool;
        errorMessage = result['error'] as String?;
      } else {
        final result = await authController.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );
        success = result['success'] as bool;
        errorMessage = result['error'] as String?;
      }

      if (mounted) {
        if (success) {
          // Kayıtta e-posta onayı kapalıysa oturum hemen açılır; router
          // yeni kullanıcıyı onboarding'e yönlendirir.
          if (_isLogin ||
              Supabase.instance.client.auth.currentSession != null) {
            context.go('/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.onboardingSuccess),
                backgroundColor: context.colors.success,
              ),
            );
            setState(() {
              _isLogin = true;
              _nameController.clear();
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _authErrorText(
                  errorMessage,
                  l,
                  fallback: _isLogin ? l.loginFailed : l.registerFailed,
                ),
              ),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.errorOccurred}: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog(AppLocalizations l) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.forgotPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.forgotPasswordText),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l.email,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final authController = ref.read(authControllerProvider);
                await authController.resetPassword(emailController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.passwordResetSent),
                      backgroundColor: context.colors.success,
                    ),
                  );
                }
              }
            },
            child: Text(l.send),
          ),
        ],
      ),
    );
  }
}
