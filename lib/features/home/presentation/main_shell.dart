// lib/features/home/presentation/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../settings/data/settings_provider.dart';
import 'dashboard_view.dart';
import '../../wallet/presentation/add_transaction_sheet.dart';
import '../../settings/presentation/settings_view.dart';
import '../../transactions/presentation/transactions_view.dart';
import '../../statistics/presentation/statistics_view.dart';

/// Bottom navigation için seçili sekme provider'ı
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final locale = ref.watch(localeProvider);
    final colorTheme = ref.watch(currentColorThemeProvider);
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = ResponsiveHelper.of(context);

    return Scaffold(
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              width: 0.5,
            ),
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
                  onTap: () => ref.read(selectedTabProvider.notifier).state = 0,
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  selectedIcon: Icons.receipt_long,
                  label: l.transactions,
                  isSelected: selectedTab == 1,
                  isDark: isDark,
                  primaryColor: colorTheme.primary,
                  onTap: () => ref.read(selectedTabProvider.notifier).state = 1,
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
                  onTap: () => ref.read(selectedTabProvider.notifier).state = 3,
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: l.settings,
                  isSelected: selectedTab == 4,
                  isDark: isDark,
                  primaryColor: colorTheme.primary,
                  onTap: () => ref.read(selectedTabProvider.notifier).state = 4,
                ),
              ],
            ),
          ),
        ),
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
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.grey[500] : Colors.grey[500]),
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
                      : (isDark ? Colors.grey[500] : Colors.grey[500]),
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
        child: Icon(Icons.add, color: Colors.white, size: r.iconXL),
      ),
    );
  }
}
