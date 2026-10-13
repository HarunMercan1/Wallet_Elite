import '../../../features/settings/data/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
// lib/features/wallet/presentation/wallet_selection_sheet.dart

import '../../../core/utils/wallet_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/wallet_provider.dart';
import '../models/account_model.dart';

/// A reusable bottom sheet for selecting a wallet.
/// Updates the global `selectedWalletIdProvider` when a wallet is selected.
class WalletSelectionSheet extends ConsumerWidget {
  const WalletSelectionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const WalletSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final accounts = ref.watch(accountsProvider);
    final selectedWalletId = ref.watch(selectedWalletIdProvider);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.6,
      decoration: BoxDecoration(
        color: isDark ? colorTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorTheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: colorTheme.primary),
                const SizedBox(width: 8),
                Text(
                  l.wallets,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // "All Wallets" Option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: accounts.when(
              data: (list) {
                final totalBalance = list.fold<double>(
                  0,
                  (sum, a) => sum + a.balance,
                );
                return _buildWalletTile(
                  context: context,
                  ref: ref,
                  account: null, // null means "All Wallets"
                  isSelected: selectedWalletId == null,
                  l: l,
                  isDark: isDark,
                  colorTheme: colorTheme,
                  totalBalance: totalBalance,
                );
              },
              loading: () => _buildWalletTile(
                context: context,
                ref: ref,
                account: null,
                isSelected: selectedWalletId == null,
                l: l,
                isDark: isDark,
                colorTheme: colorTheme,
                totalBalance: 0,
              ),
              error: (_, __) => _buildWalletTile(
                context: context,
                ref: ref,
                account: null,
                isSelected: selectedWalletId == null,
                l: l,
                isDark: isDark,
                colorTheme: colorTheme,
                totalBalance: 0,
              ),
            ),
          ),
          // Wallet List
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
                          style: TextStyle(color: colorTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final account = list[index];
                    return _buildWalletTile(
                      context: context,
                      ref: ref,
                      account: account,
                      isSelected: selectedWalletId == account.id,
                      l: l,
                      isDark: isDark,
                      colorTheme: colorTheme,
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
    );
  }

  Widget _buildWalletTile({
    required BuildContext context,
    required WidgetRef ref,
    required AccountModel? account,
    required bool isSelected,
    required AppLocalizations l,
    required bool isDark,
    required ColorTheme colorTheme,
    double totalBalance = 0,
  }) {
    final isAllWallets = account == null;

    return GestureDetector(
      onTap: () {
        ref.read(selectedWalletIdProvider.notifier).state = isAllWallets
            ? null
            : account.id;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorTheme.primary.withValues(alpha: 0.1)
              : colorTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorTheme.primary : colorTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAllWallets
                    ? colorTheme.primary.withValues(alpha: 0.1)
                    : walletTypeColor(
                        account.type,
                        colorTheme,
                      ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAllWallets
                    ? Icons.all_inclusive
                    : walletTypeIcon(account.type),
                color: isAllWallets
                    ? colorTheme.primary
                    : walletTypeColor(account.type, colorTheme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAllWallets ? l.allWallets : account.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: colorTheme.textPrimary,
                    ),
                  ),
                  if (!isAllWallets) ...[
                    const SizedBox(height: 2),
                    Text(
                      walletTypeName(account.type, l),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorTheme.primary, size: 22)
            else
              Text(
                isAllWallets
                    ? '${CurrencyUtils.getSymbol(ref.watch(currencyProvider))}${NumberFormat('#,##0.00').format(totalBalance)}'
                    : '${account.currencySymbol}${NumberFormat('#,##0.00').format(account.balance)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorTheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
