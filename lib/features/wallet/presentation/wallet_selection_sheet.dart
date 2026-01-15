// lib/features/wallet/presentation/wallet_selection_sheet.dart

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
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
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
              ? colorTheme.primary.withOpacity(0.1)
              : (isDark ? colorTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorTheme.primary
                : (isDark ? Colors.white10 : Colors.grey[200]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAllWallets
                    ? colorTheme.primary.withOpacity(0.1)
                    : _getWalletColor(
                        account.type,
                        colorTheme,
                      ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isAllWallets
                    ? Icons.all_inclusive
                    : _getWalletIcon(account.type),
                color: isAllWallets
                    ? colorTheme.primary
                    : _getWalletColor(account.type, colorTheme),
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
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (!isAllWallets) ...[
                    const SizedBox(height: 2),
                    Text(
                      _getWalletTypeName(account.type, l),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                    ? '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalBalance)}'
                    : '₺${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? colorTheme.accent : colorTheme.primary,
                ),
              ),
          ],
        ),
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

  Color _getWalletColor(String type, ColorTheme colorTheme) {
    switch (type) {
      case 'bank':
        return Colors.blue;
      case 'cash':
        return colorTheme.success;
      case 'credit_card':
        return colorTheme.error;
      case 'savings':
        return Colors.orange;
      default:
        return colorTheme.primary;
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
