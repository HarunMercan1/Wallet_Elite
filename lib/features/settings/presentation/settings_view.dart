// lib/features/settings/presentation/settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/settings_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profil Kartı
            _buildProfileCard(context, user, locale),

            const SizedBox(height: 24),

            // Görünüm Ayarları
            _buildSectionTitle(locale == 'tr' ? 'Görünüm' : 'Appearance'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                _buildThemeTile(context, ref, themeMode, locale),
                const Divider(height: 1),
                _buildLanguageTile(context, ref, locale),
              ],
            ),

            const SizedBox(height: 24),

            // Hesap Ayarları
            _buildSectionTitle(locale == 'tr' ? 'Hesap' : 'Account'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    locale == 'tr' ? 'Çıkış Yap' : 'Sign Out',
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: () => _showSignOutDialog(context, locale),
                ),
              ],
            ),

            const SizedBox(height: 32),
            // Uygulama Bilgisi
            Center(
              child: Text(
                'Wallet Elite v1.0.0',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, User? user, String locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.accent,
            backgroundImage: user?.userMetadata?['avatar_url'] != null
                ? NetworkImage(user!.userMetadata!['avatar_url'])
                : null,
            child: user?.userMetadata?['avatar_url'] == null
                ? Text(
                    (user?.email?.substring(0, 1) ?? 'U').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.userMetadata?['full_name'] ??
                      user?.email?.split('@').first ??
                      (locale == 'tr' ? 'Kullanıcı' : 'User'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    String locale,
  ) {
    String themeName;
    IconData themeIcon;

    switch (themeMode) {
      case ThemeMode.light:
        themeName = locale == 'tr' ? 'Açık' : 'Light';
        themeIcon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        themeName = locale == 'tr' ? 'Koyu' : 'Dark';
        themeIcon = Icons.dark_mode;
        break;
      case ThemeMode.system:
        themeName = locale == 'tr' ? 'Sistem' : 'System';
        themeIcon = Icons.settings_suggest;
        break;
    }

    return ListTile(
      leading: Icon(themeIcon, color: AppColors.primary),
      title: Text(locale == 'tr' ? 'Tema' : 'Theme'),
      subtitle: Text(themeName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, ref, themeMode, locale),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    String locale,
  ) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.primary),
      title: Text(locale == 'tr' ? 'Dil' : 'Language'),
      subtitle: Text(locale == 'tr' ? 'Türkçe' : 'English'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, ref, locale),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
    String locale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale == 'tr' ? 'Tema Seçin' : 'Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(locale == 'tr' ? 'Açık' : 'Light'),
              value: ThemeMode.light,
              groupValue: current,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(locale == 'tr' ? 'Koyu' : 'Dark'),
              value: ThemeMode.dark,
              groupValue: current,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setTheme(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(locale == 'tr' ? 'Sistem' : 'System'),
              value: ThemeMode.system,
              groupValue: current,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).setTheme(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(current == 'tr' ? 'Dil Seçin' : 'Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Türkçe'),
              value: 'tr',
              groupValue: current,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: current,
              onChanged: (value) {
                ref.read(localeProvider.notifier).setLocale(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale == 'tr' ? 'Çıkış Yap' : 'Sign Out'),
        content: Text(
          locale == 'tr'
              ? 'Çıkış yapmak istediğinizden emin misiniz?'
              : 'Are you sure you want to sign out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(locale == 'tr' ? 'İptal' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: Text(
              locale == 'tr' ? 'Çıkış Yap' : 'Sign Out',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
