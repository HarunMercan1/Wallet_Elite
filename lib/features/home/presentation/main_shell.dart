// lib/features/home/presentation/main_shell.dart

import '../../settings/data/preferences_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../settings/data/settings_provider.dart';
import 'dashboard_view.dart';
import '../../wallet/presentation/add_transaction_sheet.dart';
import '../../settings/presentation/settings_view.dart';
import '../../transactions/presentation/transactions_view.dart';
import '../../statistics/presentation/statistics_view.dart';
import '../../recurring/data/recurring_provider.dart';
import '../../auth/data/auth_provider.dart';
import '../../../core/ads/ads_providers.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/ads/full_screen_ads.dart';
import '../../../core/services/app_update_service.dart';
import '../../premium/data/premium_provider.dart';

/// Bottom navigation için seçili sekme provider'ı
final selectedTabProvider = StateProvider<int>((ref) {
  ref.watch(currentUserIdProvider); // kullanıcı değişince ana sayfaya dön
  return 0;
});

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    // Açılışta vadesi gelen tekrarlayan işlemleri çalıştır (bir kez)
    ref.watch(recurringStartupRunProvider);
    // Açılışta reklam iznini (GDPR) topla ve premium durumunu yükle
    ref.watch(adConsentStartupProvider);
    ref.watch(isPremiumProvider);
    // Tam ekran reklamları (geçiş, uygulama açılış) hazırla
    ref.watch(interstitialAdServiceProvider);
    ref.watch(appOpenAdServiceProvider);
    // Play Store'da yeni sürüm varsa açılışta bir kez sor
    ref.listen(appUpdateInfoProvider, (_, next) {
      final info = next.valueOrNull;
      if (info != null) showUpdateAvailableDialog(context, info);
    });
    ref.watch(localeProvider); // dil değişince yeniden çiz
    // Yeni cihazda/yeniden kurulumda dil, tema ve para birimini profilden al
    ref.watch(preferencesRestoreProvider);
    final colorTheme = ref.watch(currentColorThemeProvider);
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = ResponsiveHelper.of(context);

    return Scaffold(
      // İşlem ekleme gibi alt pencerelerde klavye açılınca arkadaki tüm
      // sekmeler (grafikler dahil) her karede yeniden boyutlanmasın.
      // Sekmelerdeki metin alanları kendi Scaffold/scroll'ları ile kayar.
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: selectedTab,
        children: const [
          DashboardView(),
          TransactionsView(),
          SizedBox(), // Add butonu için placeholder
          StatisticsView(),
          SettingsView(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner yalnızca İstatistikler'de görünür (Ana Sayfa reklamsız);
          // tek örnek canlı tutulur, sekme değişince yeniden yüklenmez.
          Visibility(
            visible: selectedTab == 3,
            maintainState: true,
            child: const AdaptiveBannerAd(),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorTheme.cardColor,
              border: Border(
                top: BorderSide(color: colorTheme.borderColor, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.paddingS,
                  vertical: r.paddingS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home,
                      label: l.home,
                      isSelected: selectedTab == 0,
                      isDark: isDark,
                      primaryColor: colorTheme.primary,
                      onTap: () =>
                          ref.read(selectedTabProvider.notifier).state = 0,
                    ),
                    _NavItem(
                      icon: Icons.receipt_long_outlined,
                      selectedIcon: Icons.receipt_long,
                      label: l.transactions,
                      isSelected: selectedTab == 1,
                      isDark: isDark,
                      primaryColor: colorTheme.primary,
                      onTap: () =>
                          ref.read(selectedTabProvider.notifier).state = 1,
                    ),
                    // Ortadaki büyük + butonu
                    _AddButton(
                      primaryColor: colorTheme.primary,
                      primaryLightColor: colorTheme.primaryLight,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddTransactionSheet(),
                        );
                      },
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_outlined,
                      selectedIcon: Icons.bar_chart,
                      label: l.statistics,
                      isSelected: selectedTab == 3,
                      isDark: isDark,
                      primaryColor: colorTheme.primary,
                      onTap: () =>
                          ref.read(selectedTabProvider.notifier).state = 3,
                    ),
                    _NavItem(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      label: l.settings,
                      isSelected: selectedTab == 4,
                      isDark: isDark,
                      primaryColor: colorTheme.primary,
                      onTap: () =>
                          ref.read(selectedTabProvider.notifier).state = 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation bar item widget
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(r.radiusM),
      child: Container(
        constraints: BoxConstraints(maxWidth: r.wp(18)), // Dinamik max width
        padding: EdgeInsets.symmetric(
          horizontal: r.paddingXS,
          vertical: r.paddingS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? primaryColor : context.colors.textSecondary,
              size: r.navIconSize,
            ),
            SizedBox(height: r.spaceXS),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: r.navFontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? primaryColor
                      : context.colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ortadaki büyük + butonu
class _AddButton extends StatelessWidget {
  final Color primaryColor;
  final Color primaryLightColor;
  final VoidCallback onTap;

  const _AddButton({
    required this.primaryColor,
    required this.primaryLightColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final size = r.wp(14); // Dinamik boyut

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryLightColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: context.colors.onPrimary, size: r.iconXL),
      ),
    );
  }
}
