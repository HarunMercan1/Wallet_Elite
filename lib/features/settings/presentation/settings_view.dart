// lib/features/settings/presentation/settings_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/theme/premium_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/settings_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/account_model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final accounts = ref.watch(accountsProvider);
    final colorTheme = ref.watch(currentColorThemeProvider);

    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profil Kartı
            _buildProfileCard(context, user, l, isDark, colorTheme),

            const SizedBox(height: 24),

            // Görünüm Ayarları
            _buildSectionTitle(l.appearance, isDark),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                _buildThemeTile(context, ref, themeMode, l, isDark, colorTheme),
                Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.grey[200],
                ),
                _buildColorSchemeTile(context, ref, l, isDark, colorTheme),
                Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.grey[200],
                ),
                _buildLanguageTile(context, ref, locale, l, isDark, colorTheme),
              ],
            ),

            const SizedBox(height: 24),

            // Cüzdan Ayarları
            _buildSectionTitle(l.wallets, isDark),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color: isDark ? colorTheme.accent : colorTheme.primary,
                  ),
                  title: Text(
                    l.manageWallets,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: accounts.when(
                    data: (list) => Text(
                      '${list.length} ${l.wallet.toLowerCase()}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    loading: () => Text(
                      l.loading,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    error: (_, __) => Text(
                      l.error,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  onTap: () =>
                      _showWalletsSheet(context, ref, l, isDark, colorTheme),
                ),
                Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.grey[200],
                ),
                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: isDark ? colorTheme.accent : Colors.green,
                  ),
                  title: Text(
                    l.addWallet,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  onTap: () =>
                      _showAddWalletDialog(context, ref, l, isDark, colorTheme),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hesap Ayarları
            _buildSectionTitle(l.account, isDark),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    l.signOut,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () => _showSignOutDialog(context, l, colorTheme),
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

  Widget _buildProfileCard(
    BuildContext context,
    User? user,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorTheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colorTheme.accent,
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
                      l.user,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
    required bool isDark,
    required ColorTheme colorTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    String themeName;
    IconData themeIcon;

    switch (themeMode) {
      case ThemeMode.light:
        themeName = l.light;
        themeIcon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        themeName = l.dark;
        themeIcon = Icons.dark_mode;
        break;
      case ThemeMode.system:
        themeName = l.system;
        themeIcon = Icons.settings_suggest;
        break;
    }

    return ListTile(
      leading: Icon(
        themeIcon,
        color: isDark ? colorTheme.accent : colorTheme.primary,
      ),
      title: Text(
        l.theme,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        themeName,
        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      onTap: () =>
          _showThemeDialog(context, ref, themeMode, l, isDark, colorTheme),
    );
  }

  Widget _buildColorSchemeTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final colorScheme = ref.watch(colorSchemeProvider);
    final theme = ColorTheme.fromString(colorScheme);

    return ListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primary, theme.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      title: Text(
        _getColorSchemeLabel(l),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        theme.name,
        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      onTap: () => _showColorSchemeDialog(
        context,
        ref,
        colorScheme,
        l,
        isDark,
        colorTheme,
      ),
    );
  }

  String _getColorSchemeLabel(AppLocalizations l) {
    // Use translation if available, fallback to English
    try {
      return l.colorScheme;
    } catch (_) {
      return 'Color Scheme';
    }
  }

  void _showColorSchemeDialog(
    BuildContext context,
    WidgetRef ref,
    String current,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getColorSchemeLabel(l),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: ColorTheme.all
                    .map(
                      (theme) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildColorSchemeOption(
                          context,
                          ref,
                          theme,
                          current,
                          isDark,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSchemeOption(
    BuildContext context,
    WidgetRef ref,
    ColorTheme theme,
    String current,
    bool isDark,
  ) {
    final isSelected = theme.id == current;
    final isUnlocked = ref.watch(canUseThemeProvider(theme.id));
    final isLocked = theme.isPremium && !isUnlocked;

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          // Show unlock dialog for premium themes
          _showUnlockThemeDialog(context, ref, theme, isDark);
        } else {
          ref.read(colorSchemeProvider.notifier).setColorScheme(theme.id);
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withOpacity(0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Theme color preview
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primary, theme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLocked
                  ? Center(
                      child: Icon(
                        Icons.lock,
                        color: Colors.white.withOpacity(0.9),
                        size: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        theme.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      if (theme.isPremium) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isLocked)
                    Text(
                      'Reklam izle ve aç',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.primary, size: 24)
            else if (isLocked)
              Icon(Icons.play_circle_outline, color: theme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  void _showUnlockThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ColorTheme theme,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? theme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.primary, theme.accent]),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${theme.name} Temasını Aç',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Bu premium temayı kalıcı olarak açmak için kısa bir reklam izleyin.',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Vazgeç', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // TODO: Show rewarded ad here
              // For now, unlock directly for testing
              await ref
                  .read(unlockedThemesProvider.notifier)
                  .unlockTheme(theme.id);

              // Set as current theme
              ref.read(colorSchemeProvider.notifier).setColorScheme(theme.id);

              // Close the color scheme sheet
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Reklam İzle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    String locale,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return ListTile(
      leading: Icon(
        Icons.language,
        color: isDark ? colorTheme.accent : colorTheme.primary,
      ),
      title: Text(
        l.language,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      subtitle: Text(
        _getLanguageName(locale),
        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      onTap: () =>
          _showLanguageDialog(context, ref, locale, l, isDark, colorTheme),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ru':
        return 'Русский';
      case 'ar':
        return 'العربية';
      case 'pt':
        return 'Português';
      case 'it':
        return 'Italiano';
      case 'id':
        return 'Indonesia';
      case 'ko':
        return '한국어';
      default:
        return code.toUpperCase();
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              l.selectTheme,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildThemeOption(
                    context,
                    ref,
                    l.light,
                    Icons.light_mode,
                    ThemeMode.light,
                    current,
                    isDark,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    ref,
                    l.dark,
                    Icons.dark_mode,
                    ThemeMode.dark,
                    current,
                    isDark,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    ref,
                    l.system,
                    Icons.settings_suggest,
                    ThemeMode.system,
                    current,
                    isDark,
                    color: colorTheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    ThemeMode mode,
    ThemeMode current,
    bool isDark, {
    required Color color,
  }) {
    final isSelected = mode == current;
    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).setTheme(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String current,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
      {'code': 'id', 'name': 'Indonesia', 'flag': '🇮🇩'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.selectLanguage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: languages.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  return _buildLanguageOption(
                    context,
                    ref,
                    lang['name']!,
                    lang['flag']!,
                    lang['code']!,
                    current,
                    isDark,
                    colorTheme,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    String flag,
    String localeCode,
    String current,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final isSelected = localeCode == current;
    return GestureDetector(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(localeCode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorTheme.primary.withOpacity(0.1)
              : (isDark ? Colors.grey[850] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorTheme.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  void _showWalletsSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final accounts = ref.watch(accountsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? colorTheme.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: isDark ? colorTheme.accent : colorTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.wallets,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: isDark ? colorTheme.accent : Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddWalletDialog(context, ref, l, isDark, colorTheme);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: accounts.when(
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.noWallets,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final account = list[index];
                      return Dismissible(
                        key: Key(account.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: isDark
                                      ? colorTheme.surfaceDark
                                      : Colors.white,
                                  title: Text(
                                    l.deleteWallet,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  content: Text(
                                    l.deleteWalletConfirm,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(l.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(
                                        l.delete,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (direction) async {
                          await ref
                              .read(walletControllerProvider)
                              .deleteAccount(account.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.walletDeleted)),
                            );
                          }
                        },
                        child: GestureDetector(
                          onTap: () => _showEditWalletDialog(
                            context,
                            ref,
                            account,
                            l,
                            isDark,
                            colorTheme,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colorTheme.surfaceDark
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _getWalletColor(
                                      account.type,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getWalletIcon(account.type),
                                    color: _getWalletColor(account.type),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getWalletTypeName(account.type, l),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark
                                        ? colorTheme.accent
                                        : colorTheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${l.error}: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    String selectedType = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
          title: Text(
            l.addWallet,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: l.walletName,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.walletType,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip(
                      'cash',
                      l.cash,
                      Icons.payments,
                      selectedType,
                      isDark,
                      colorTheme,
                      (v) => setState(() => selectedType = v),
                    ),
                    _buildTypeChip(
                      'bank',
                      l.bank,
                      Icons.account_balance,
                      selectedType,
                      isDark,
                      colorTheme,
                      (v) => setState(() => selectedType = v),
                    ),
                    _buildTypeChip(
                      'credit_card',
                      l.creditCard,
                      Icons.credit_card,
                      selectedType,
                      isDark,
                      colorTheme,
                      (v) => setState(() => selectedType = v),
                    ),
                    _buildTypeChip(
                      'savings',
                      l.savings,
                      Icons.savings,
                      selectedType,
                      isDark,
                      colorTheme,
                      (v) => setState(() => selectedType = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: l.initialBalance,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    prefixText: '₺ ',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                Navigator.pop(context);

                final walletController = ref.read(walletControllerProvider);
                final success = await walletController.createAccount(
                  name: nameController.text.trim(),
                  type: selectedType,
                  initialBalance: double.tryParse(balanceController.text) ?? 0,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? l.walletAdded : l.error),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTheme.primary,
              ),
              child: Text(l.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWalletDialog(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final nameController = TextEditingController(text: account.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
        title: Text(
          l.editWallet,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: l.walletName,
            labelStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              Navigator.pop(dialogContext);

              final success = await ref
                  .read(walletControllerProvider)
                  .updateAccountName(account.id, nameController.text.trim());

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? l.walletUpdated : l.error),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorTheme.primary,
            ),
            child: Text(l.save),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    String value,
    String label,
    IconData icon,
    String selected,
    bool isDark,
    ColorTheme colorTheme,
    Function(String) onTap,
  ) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorTheme.primary
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colorTheme.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(
    BuildContext context,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final router = GoRouter.of(context); // Capture router before dialog

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
        title: Text(
          l.signOut,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          l.signOutConfirm,
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await Supabase.instance.client.auth.signOut();
              router.go('/auth'); // Use captured router
            },
            child: Text(l.signOut, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getWalletIcon(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance;
      case 'cash':
        return Icons.payments;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getWalletColor(String type) {
    switch (type) {
      case 'bank':
        return Colors.blue;
      case 'cash':
        return Colors.green;
      case 'credit_card':
        return Colors.red;
      case 'savings':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getWalletTypeName(String type, AppLocalizations l) {
    switch (type) {
      case 'bank':
        return l.bank;
      case 'cash':
        return l.cash;
      case 'credit_card':
        return l.creditCard;
      case 'savings':
        return l.savings;
      default:
        return l.wallet;
    }
  }
}
