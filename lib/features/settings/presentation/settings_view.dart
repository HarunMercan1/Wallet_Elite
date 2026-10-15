// lib/features/settings/presentation/settings_view.dart

import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/sheet_surface.dart';
import '../../../core/utils/app_languages.dart';
import '../../../core/utils/wallet_type.dart';
import '../data/preferences_sync.dart';
import '../../../core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../data/settings_provider.dart';
import 'theme_picker_sheet.dart';
import '../../../core/widgets/hero_surface.dart';
import '../../../core/ads/ads_providers.dart';
import '../../premium/data/premium_provider.dart';
import '../../premium/data/premium_constants.dart';
import '../../premium/presentation/paywall_view.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../premium/data/export_service.dart';
import '../../premium/presentation/summary_image_sheet.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/services/support_actions.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/account_model.dart';
import '../../recurring/presentation/recurring_transactions_view.dart';
import '../../budgets/presentation/budgets_view.dart';
import '../../auth/presentation/profile_edit_sheet.dart';
import '../../auth/data/auth_provider.dart';
import '../../wallet/models/profile_model.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final userProfile = ref.watch(userProfileProvider);
    final accounts = ref.watch(accountsProvider);
    final colorTheme = context.colors; // Tema geçişinde animasyonlu

    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profil Kartı
            _buildProfileCard(context, userProfile, l, isDark, colorTheme),

            const SizedBox(height: 16),

            // Premium Kartı
            _buildPremiumCard(context, ref, l, isDark, colorTheme),

            const SizedBox(height: 24),

            // Görünüm Ayarları
            _buildSectionTitle(l.appearance, colorTheme),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                _buildThemeTile(context, ref, themeMode, l, isDark, colorTheme),
                Divider(height: 1, color: colorTheme.borderColor),
                _buildColorSchemeTile(context, ref, l, isDark, colorTheme),
                Divider(height: 1, color: colorTheme.borderColor),
                _buildLanguageTile(context, ref, locale, l, isDark, colorTheme),
                Divider(height: 1, color: colorTheme.borderColor),
                _buildCurrencyTile(context, ref, l, colorTheme),
              ],
            ),

            const SizedBox(height: 24),

            // Uygulama Ayarları
            _buildSectionTitle(l.appSettingsSection, colorTheme),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.play_circle_outline,
                    color: colorTheme.primary,
                  ),
                  title: Text(
                    l.replayAppTour,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  subtitle: Text(
                    l.replayAppTourDesc,
                    style: TextStyle(color: colorTheme.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: () => context.push('/onboarding-preview'),
                ),
                Divider(height: 1, color: colorTheme.borderColor),
                ListTile(
                  leading: Icon(
                    Icons.file_download_outlined,
                    color: colorTheme.primary,
                  ),
                  title: Text(
                    l.exportData,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  subtitle: Text(
                    l.exportDataDesc,
                    style: TextStyle(color: colorTheme.textSecondary),
                  ),
                  trailing: ref.watch(isPremiumProvider)
                      ? Icon(Icons.chevron_right, color: colorTheme.textMuted)
                      : const Icon(Icons.lock_outline, size: 20),
                  onTap: () => _exportData(context, ref, l),
                ),
                Divider(height: 1, color: colorTheme.borderColor),
                ListTile(
                  leading: Icon(
                    Icons.image_outlined,
                    color: colorTheme.primary,
                  ),
                  title: Text(
                    l.summaryImage,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  subtitle: Text(
                    l.summaryImageDesc,
                    style: TextStyle(color: colorTheme.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: () => showSummaryImageSheet(context),
                ),
                if (ref.watch(
                  adConsentProvider.select((c) => c.isPrivacyOptionsRequired),
                )) ...[
                  Divider(height: 1, color: colorTheme.borderColor),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: colorTheme.primary,
                    ),
                    title: Text(
                      l.adPrivacySettings,
                      style: TextStyle(color: colorTheme.textPrimary),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorTheme.textMuted,
                    ),
                    onTap: () =>
                        ref.read(adConsentProvider).showPrivacyOptionsForm(),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Cüzdan Ayarları
            _buildSectionTitle(l.wallets, colorTheme),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color: colorTheme.primary,
                  ),
                  title: Text(
                    l.manageWallets,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  subtitle: accounts.when(
                    data: (list) => Text(
                      '${list.length} ${l.wallet.toLowerCase()}',
                      style: TextStyle(color: colorTheme.textSecondary),
                    ),
                    loading: () => Text(
                      l.loading,
                      style: TextStyle(color: colorTheme.textSecondary),
                    ),
                    error: (_, __) => Text(
                      l.error,
                      style: TextStyle(color: colorTheme.textSecondary),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: () =>
                      _showWalletsSheet(context, ref, l, isDark, colorTheme),
                ),
                Divider(height: 1, color: colorTheme.borderColor),
                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: colorTheme.success,
                  ),
                  title: Text(
                    l.addWallet,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: () =>
                      _showAddWalletDialog(context, ref, l, isDark, colorTheme),
                ),
                Divider(height: 1, color: colorTheme.borderColor),
                ListTile(
                  leading: Icon(Icons.repeat, color: colorTheme.tertiary),
                  title: Text(
                    l.recurringTransactions,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecurringTransactionsView(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: colorTheme.borderColor),
                ListTile(
                  leading: Icon(Icons.pie_chart, color: colorTheme.info),
                  title: Text(
                    l.budgets,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetsView(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Destek
            _buildSectionTitle(l.supportSection, colorTheme),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                ListTile(
                  leading: Icon(Icons.mail_outline, color: colorTheme.primary),
                  title: Text(
                    l.sendFeedback,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  subtitle: Text(
                    l.sendFeedbackDesc,
                    style: TextStyle(color: colorTheme.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: () => _sendFeedback(context, l),
                ),
                Divider(height: 1, color: colorTheme.borderColor),
                ListTile(
                  leading: Icon(
                    Icons.star_outline_rounded,
                    color: colorTheme.warning,
                  ),
                  title: Text(
                    l.rateApp,
                    style: TextStyle(color: colorTheme.textPrimary),
                  ),
                  subtitle: Text(
                    l.rateAppDesc,
                    style: TextStyle(color: colorTheme.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colorTheme.textMuted,
                  ),
                  onTap: SupportActions.openStoreListing,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hesap Ayarları
            _buildSectionTitle(l.account, colorTheme),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              colorTheme: colorTheme,
              children: [
                ListTile(
                  leading: Icon(Icons.logout, color: colorTheme.error),
                  title: Text(
                    l.signOut,
                    style: TextStyle(color: colorTheme.error),
                  ),
                  onTap: () => _showSignOutDialog(context, ref, l, colorTheme),
                ),
                Divider(height: 1, color: colorTheme.borderColor),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: colorTheme.error,
                  ),
                  title: Text(
                    l.deleteAccount,
                    style: TextStyle(color: colorTheme.error),
                  ),
                  onTap: () =>
                      _showDeleteAccountDialog(context, ref, l, colorTheme),
                ),
              ],
            ),

            const SizedBox(height: 32),
            // Uygulama Bilgisi
            Center(
              child: Text(
                ref
                    .watch(packageInfoProvider)
                    .maybeWhen(
                      data: (info) => '${info.appName} v${info.version}',
                      orElse: () => 'Wallet Elite',
                    ),
                style: TextStyle(color: colorTheme.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Geliştiriciye e-posta yazma ekranını açar; e-posta uygulaması yoksa
  /// adresi gösterir.
  Future<void> _sendFeedback(BuildContext context, AppLocalizations l) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await SupportActions.sendFeedbackEmail();
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.emailAppNotFound(AppInfo.developerEmail))),
      );
    }
  }

  Widget _buildProfileCard(
    BuildContext context,
    AsyncValue<ProfileModel?> userProfile,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return userProfile.when(
      data: (profile) {
        final user = Supabase.instance.client.auth.currentUser;
        final displayEmail = user?.email ?? '';

        return GestureDetector(
          onTap: () {
            if (profile != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ProfileEditSheet(profile: profile),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorTheme.primary.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorTheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildSettingsAvatar(profile, colorTheme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? l.user,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, size: 16, color: colorTheme.primary),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildSettingsAvatar(ProfileModel? profile, ColorTheme colorTheme) {
    final avatarUrl = profile?.avatarUrl;

    if (avatarUrl != null) {
      if (avatarUrl.startsWith('preset:')) {
        final presetData = avatarUrl.substring(7);
        final parts = presetData.split(':');
        if (parts.length >= 2) {
          final emoji = parts[0];
          final colorValue = int.tryParse(parts[1]) ?? 0xFF2196F3;
          return CircleAvatar(
            radius: 30,
            backgroundColor: Color(colorValue),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          );
        }
      } else {
        return CircleAvatar(
          radius: 30,
          backgroundColor: colorTheme.primary,
          backgroundImage: NetworkImage(avatarUrl),
        );
      }
    }

    return CircleAvatar(
      radius: 30,
      backgroundColor: colorTheme.primary,
      child: Text(
        _initialOf(profile?.fullName),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorTheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final isPremium = ref.watch(isPremiumProvider);
    return HeroSurface(
      colors: colorTheme,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      shadow: false,
      sheen: !isPremium,
      onTap: () => showPaywall(context),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.verified : Icons.workspace_premium,
            color: colorTheme.onHero,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? l.premiumActive : l.goPremium,
                  style: TextStyle(
                    color: colorTheme.onHero,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPremium ? l.premiumActiveDesc : l.goPremiumDesc,
                  style: TextStyle(
                    color: colorTheme.onHero.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium) Icon(Icons.chevron_right, color: colorTheme.onHero),
        ],
      ),
    );
  }

  Future<void> _exportData(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
  ) async {
    if (!ref.read(isPremiumProvider)) {
      showPaywall(context);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      final transactions = await ref.read(transactionsProvider.future);
      if (transactions.isEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(l.exportNoData)));
        return;
      }
      await ExportService.shareTransactionsCsv(
        transactions: transactions,
        accounts: await ref.read(accountsProvider.future),
        categories: await ref.read(categoriesProvider.future),
        l: l,
        localeCode: ref.read(localeProvider),
      );
    } catch (e) {
      debugPrint('Dışa aktarma hatası: $e');
      messenger.showSnackBar(SnackBar(content: Text(l.exportFailed)));
    }
  }

  Widget _buildSectionTitle(String title, ColorTheme colorTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
    required bool isDark,
    required ColorTheme colorTheme,
  }) {
    // Material zemin: ListTile'ların dokunma dalgası kartın üstünde çizilir
    // (renkli bir Container'da dalga zeminin altında kalıp görünmüyordu).
    return Material(
      color: colorTheme.cardColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
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
      leading: Icon(themeIcon, color: colorTheme.primary),
      title: Text(l.theme, style: TextStyle(color: colorTheme.textPrimary)),
      subtitle: Text(
        themeName,
        style: TextStyle(color: colorTheme.textSecondary),
      ),
      trailing: Icon(Icons.chevron_right, color: colorTheme.textMuted),
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
    // Etkin tema (kilitli bir tema seçiliyse ücretsiz tema gösterilir)
    final theme = context.colors;

    return ListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: theme.heroGradient,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.primary, width: 2),
        ),
      ),
      title: Text(
        _getColorSchemeLabel(l),
        style: TextStyle(color: colorTheme.textPrimary),
      ),
      subtitle: Text(
        theme.name,
        style: TextStyle(color: colorTheme.textSecondary),
      ),
      trailing: Icon(Icons.chevron_right, color: colorTheme.textMuted),
      onTap: () => showThemePickerSheet(context),
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

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    String locale,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return ListTile(
      leading: Icon(Icons.language, color: colorTheme.primary),
      title: Text(l.language, style: TextStyle(color: colorTheme.textPrimary)),
      subtitle: Text(
        appLanguageName(locale),
        style: TextStyle(color: colorTheme.textSecondary),
      ),
      trailing: Icon(Icons.chevron_right, color: colorTheme.textMuted),
      onTap: () =>
          _showLanguageDialog(context, ref, locale, l, isDark, colorTheme),
    );
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
      builder: (context) => SheetSurface(
        color: colorTheme.cardColor,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.45,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorTheme.outline,
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
                color: colorTheme.textPrimary,
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
                    color: colorTheme.warning,
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
                    color: colorTheme.tertiary,
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
              ? color.withValues(alpha: 0.1)
              : context.colors.subtleCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : context.colors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
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
                  color: context.colors.textPrimary,
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
    const languages = appLanguages;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SheetSurface(
        color: colorTheme.cardColor,
        height: MediaQuery.sizeOf(context).height * 0.7,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorTheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.selectLanguage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorTheme.textPrimary,
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
                    lang.name,
                    lang.flag,
                    lang.code,
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
        savePreferenceToProfile(ref, language: localeCode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorTheme.primary.withValues(alpha: 0.1)
              : colorTheme.subtleCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorTheme.primary : colorTheme.outline,
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
                  color: colorTheme.textPrimary,
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

  /// Uygulamada gösterilen para birimi simgesi. Tutarlar dönüştürülmez;
  /// yalnızca simge değişir (cüzdanların kendi para birimi ayrıdır).
  Widget _buildCurrencyTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    final currency = ref.watch(currencyProvider);
    return ListTile(
      leading: Icon(Icons.payments_outlined, color: colorTheme.primary),
      title: Text(
        l.currencyLabel,
        style: TextStyle(color: colorTheme.textPrimary),
      ),
      subtitle: Text(
        '$currency (${CurrencyUtils.getSymbol(currency).trim()})',
        style: TextStyle(color: colorTheme.textSecondary),
      ),
      trailing: Icon(Icons.chevron_right, color: colorTheme.textMuted),
      onTap: () => _showCurrencySheet(context, ref, currency, l, colorTheme),
    );
  }

  void _showCurrencySheet(
    BuildContext context,
    WidgetRef ref,
    String current,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    final currencies = [
      ('TRY', l.turkishLira),
      ('USD', l.usDollar),
      ('EUR', l.euro),
      ('GBP', l.britishPound),
      ('JPY', l.japaneseYen),
      ('RUB', l.russianRuble),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SheetSurface(
        color: colorTheme.cardColor,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.paddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorTheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.selectCurrency,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: currencies.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final (code, name) = currencies[index];
                  final isSelected = code == current;
                  return GestureDetector(
                    onTap: () {
                      ref.read(currencyProvider.notifier).setCurrency(code);
                      savePreferenceToProfile(ref, currency: code);
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorTheme.primary.withValues(alpha: 0.1)
                            : colorTheme.subtleCardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colorTheme.primary
                              : colorTheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              CurrencyUtils.getSymbol(code).trim(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorTheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: colorTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            code,
                            style: TextStyle(color: colorTheme.textSecondary),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: colorTheme.primary,
                              size: 22,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
    // Sheet kapandıktan sonra da geçerli olan bağlam ve mesajcı
    final rootContext = context;
    final messenger = ScaffoldMessenger.of(context);
    // Kaydırılarak silinen cüzdanlar: liste sunucudan yenilenene kadar
    // tekrar çizilmemeli (Dismissible ağaçta kalamaz).
    final removedIds = <String>{};

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // Consumer: cüzdan eklenince/silinince/adı değişince liste güncellenir
      builder: (sheetContext) => Consumer(
        builder: (context, sheetRef, _) {
          final accounts = sheetRef
              .watch(accountsProvider)
              .whenData(
                (list) =>
                    list.where((a) => !removedIds.contains(a.id)).toList(),
              );
          return SheetSurface(
            color: isDark ? colorTheme.backgroundDark : Colors.white,
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorTheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: colorTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l.wallets,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: colorTheme.success),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddWalletDialog(
                            rootContext,
                            ref,
                            l,
                            isDark,
                            colorTheme,
                          );
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
                                color: colorTheme.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l.noWallets,
                                style: TextStyle(
                                  color: colorTheme.textSecondary,
                                ),
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
                                color: colorTheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: colorTheme.cardColor,
                                      title: Text(
                                        l.deleteWallet,
                                        style: TextStyle(
                                          color: colorTheme.textPrimary,
                                        ),
                                      ),
                                      content: Text(
                                        l.deleteWalletConfirm,
                                        style: TextStyle(
                                          color: colorTheme.textSecondary,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: Text(l.cancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: Text(
                                            l.delete,
                                            style: TextStyle(
                                              color: colorTheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (direction) async {
                              removedIds.add(account.id);
                              final success = await ref
                                  .read(walletControllerProvider)
                                  .deleteAccount(account.id);
                              if (!success) {
                                // Silinemedi: cüzdan listeye geri gelsin
                                removedIds.remove(account.id);
                                ref.invalidate(accountsProvider);
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success ? l.walletDeleted : l.errorOccurred,
                                  ),
                                  backgroundColor: success
                                      ? null
                                      : colorTheme.error,
                                ),
                              );
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
                                  color: colorTheme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorTheme.borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: walletTypeColor(
                                          account.type,
                                          colorTheme,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        walletTypeIcon(account.type),
                                        color: walletTypeColor(
                                          account.type,
                                          colorTheme,
                                        ),
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
                                              color: colorTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            walletTypeName(account.type, l),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${account.currencySymbol}${NumberFormat('#,##0.00').format(account.balance)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: colorTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: colorTheme.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => LoadErrorView(
                      error: e,
                      onRetry: () => sheetRef.invalidate(accountsProvider),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
    // Ücretsiz sürüm cüzdan sınırı
    final walletCount = ref.read(accountsProvider).valueOrNull?.length ?? 0;
    if (!ref.read(isPremiumProvider) &&
        walletCount >= PremiumConstants.freeWalletLimit) {
      showPremiumRequiredDialog(
        context,
        l.walletLimitReached(PremiumConstants.freeWalletLimit),
      );
      return;
    }

    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String selectedType = 'cash';
    final currencies = ['TRY', 'USD', 'EUR', 'GBP', 'JPY', 'RUB'];
    final userCurrency = ref.read(currencyProvider);
    String selectedCurrency = currencies.contains(userCurrency)
        ? userCurrency
        : currencies.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: colorTheme.cardColor,
          title: Text(
            l.addWallet,
            style: TextStyle(color: colorTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: colorTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: l.walletName,
                    labelStyle: TextStyle(color: colorTheme.textSecondary),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.walletType,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorTheme.textPrimary,
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
                DropdownButtonFormField<String>(
                  initialValue: selectedCurrency,
                  decoration: InputDecoration(
                    labelText: l.currencyLabel,
                    labelStyle: TextStyle(color: colorTheme.textSecondary),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorTheme.textMuted),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  dropdownColor: colorTheme.cardColor,
                  style: TextStyle(color: colorTheme.textPrimary),
                  items: currencies.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCurrency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: colorTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: l.initialBalance,
                    hintText: '0',
                    labelStyle: TextStyle(color: colorTheme.textSecondary),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorTheme.textMuted),
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
                  currency: selectedCurrency,
                  initialBalance:
                      double.tryParse(
                        balanceController.text.trim().replaceAll(',', '.'),
                      ) ??
                      0,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? l.walletAdded : l.error),
                      backgroundColor: success
                          ? colorTheme.success
                          : colorTheme.error,
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
        backgroundColor: colorTheme.cardColor,
        title: Text(
          l.editWallet,
          style: TextStyle(color: colorTheme.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: TextStyle(color: colorTheme.textPrimary),
          decoration: InputDecoration(
            labelText: l.walletName,
            labelStyle: TextStyle(color: colorTheme.textSecondary),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorTheme.textMuted),
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
                    backgroundColor: success
                        ? colorTheme.success
                        : colorTheme.error,
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
          color: isSelected ? colorTheme.primary : colorTheme.subtleCardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorTheme.primary : colorTheme.textMuted,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? colorTheme.onPrimary
                  : colorTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorTheme.onPrimary
                    : colorTheme.textPrimary,
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
    WidgetRef ref,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    final router = GoRouter.of(context); // Capture router before dialog

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorTheme.cardColor,
        title: Text(l.signOut, style: TextStyle(color: colorTheme.textPrimary)),
        content: Text(
          l.signOutConfirm,
          style: TextStyle(color: colorTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Supabase + Google oturumunu kapatır; kullanıcıya bağlı
              // provider'lar currentUserIdProvider üzerinden sıfırlanır.
              await ref.read(authControllerProvider).signOut();
              router.go('/auth'); // Use captured router
            },
            child: Text(l.signOut, style: TextStyle(color: colorTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmWord = l.deleteAccountConfirmWord;
    final confirmController = TextEditingController();

    // Büyük/küçük harf ve Türkçe i/ı/İ farklarını yok say (ör. "sil" = "SİL")
    String normalize(String s) =>
        s.trim().toLowerCase().replaceAll('̇', '').replaceAll('ı', 'i');

    showDialog(
      context: context,
      builder: (dialogContext) {
        var isDeleting = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final isConfirmed =
                normalize(confirmController.text) == normalize(confirmWord);
            return AlertDialog(
              backgroundColor: colorTheme.cardColor,
              title: Text(
                l.deleteAccountConfirmTitle,
                style: TextStyle(color: colorTheme.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.deleteAccountConfirmMessage,
                    style: TextStyle(color: colorTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.deleteAccountTypeToConfirm(confirmWord),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    enabled: !isDeleting,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(color: colorTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: confirmWord,
                      hintStyle: TextStyle(color: colorTheme.textSecondary),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(l.cancel),
                ),
                TextButton(
                  // Onay kelimesi doğru yazılmadan buton pasif
                  onPressed: isDeleting || !isConfirmed
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final success = await ref
                              .read(authControllerProvider)
                              .deleteAccount();
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (success) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(l.deleteAccountSuccess)),
                            );
                            router.go('/auth');
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(l.errorOccurred),
                                backgroundColor: colorTheme.error,
                              ),
                            );
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l.deleteAccountConfirmButton,
                          style: TextStyle(
                            color: isConfirmed
                                ? colorTheme.error
                                : colorTheme.textMuted,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => confirmController.dispose());
  }
}

/// Adın baş harfi; ad boşsa 'U'.
String _initialOf(String? name) {
  final trimmed = name?.trim() ?? '';
  return trimmed.isEmpty ? 'U' : trimmed.characters.first.toUpperCase();
}
