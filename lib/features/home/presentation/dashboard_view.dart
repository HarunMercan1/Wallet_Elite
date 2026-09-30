// lib/features/home/presentation/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../features/auth/data/auth_provider.dart';
import '../../../features/wallet/data/wallet_provider.dart';
import '../../../features/wallet/models/account_model.dart';
import '../../../features/wallet/models/transaction_model.dart';
import '../../../features/wallet/models/category_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/settings/data/settings_provider.dart';
import '../../wallet/presentation/edit_transaction_sheet.dart';
import '../../debts/presentation/debts_view.dart';

import '../../wallet/presentation/wallet_selection_sheet.dart';
import '../../budgets/presentation/budgets_view.dart';
import '../../recurring/presentation/recurring_transactions_view.dart';
import '../../../core/utils/category_l10n.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/responsive_helper.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final selectedWalletId = ref.watch(selectedWalletIdProvider);
    final categories = ref.watch(categoriesProvider);
    ref.watch(localeProvider); // dil değişince yeniden çiz

    // Theme setup
    final themeData = Theme.of(context);
    final colorTheme = themeData.extension<ColorTheme>()!;
    final isDark = themeData.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    // Gelir/Gider hesapla
    double totalIncome = 0;
    double totalExpense = 0;
    if (transactions.hasValue) {
      for (var t in transactions.value!) {
        if (t.type == 'income') {
          totalIncome += t.amount;
        } else if (t.type == 'expense') {
          totalExpense += t.amount;
        }
      }
    }

    return Scaffold(
      // Background color comes from AppTheme (scaffoldBackgroundColor)
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Kullanıcı Kartı
          _buildUserHeader(context, userProfile, l, colorTheme, isDark),

          const SizedBox(height: 24),

          // Toplam Bakiye Kartı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTotalBalanceCard(
              context,
              ref,
              accounts,
              selectedWalletId,
              totalIncome,
              totalExpense,
              l,
              isDark,
              colorTheme,
            ),
          ),

          const SizedBox(height: 16),

          // Hızlı Erişim Butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionTile(
                    context,
                    label: l.debtTracking,
                    accentColor: colorTheme.primary,
                    colorTheme: colorTheme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DebtsView()),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionTile(
                    context,
                    label: l.budgets,
                    accentColor: colorTheme.success,
                    colorTheme: colorTheme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BudgetsView()),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionTile(
                    context,
                    label: l.recurringTransactions,
                    accentColor: colorTheme.tertiary,
                    colorTheme: colorTheme,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecurringTransactionsView(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Son İşlemler Başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.recentTransactions,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorTheme.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Son İşlemler Listesi
          Expanded(
            child: _buildTransactionsList(
              context,
              ref,
              transactions,
              categories,
              l,
              colorTheme,
            ),
          ),

          const SizedBox(height: 16), // Alt boşluk
        ],
      ),
    );
  }

  Widget _buildUserHeader(
    BuildContext context,
    AsyncValue userProfile,
    AppLocalizations l,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorTheme.primary,
            colorTheme.primaryLight,
            colorTheme.primary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: userProfile.when(
            data: (profile) {
              return Row(
                children: [
                  // Avatar (Read-only)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: _buildDashboardAvatar(profile, colorTheme),
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l.welcome,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile?.fullName ?? l.user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Premium badge (if applicable)
                  if (profile?.isPremium ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorTheme.tertiary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            'ELITE',
                            style: TextStyle(
                              color: colorTheme.onTertiary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) =>
                Text(l.error, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardAvatar(dynamic profile, ColorTheme colorTheme) {
    final avatarUrl = profile?.avatarUrl;

    // Check for preset avatar
    if (avatarUrl != null && avatarUrl.startsWith('preset:')) {
      final presetData = avatarUrl.substring(7); // Remove 'preset:' prefix
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
    }

    // Regular image URL
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: colorTheme.accent,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    // Default: show initial letter
    return CircleAvatar(
      radius: 30,
      backgroundColor: colorTheme.accent,
      child: Text(
        profile?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AccountModel>> accounts,
    String? selectedWalletId,
    double totalIncome,
    double totalExpense,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return accounts.when(
      data: (List<AccountModel> accountsList) {
        double totalBalance = 0.0;
        String walletLabel = l.allWallets;
        String currencySymbol = CurrencyUtils.getSymbol(
          ref.watch(currencyProvider),
        );

        if (selectedWalletId == null) {
          // Sum all wallets
          for (final account in accountsList) {
            totalBalance += account.balance;
          }
        } else {
          // Find the selected wallet
          final selectedAccount = accountsList.firstWhere(
            (a) => a.id == selectedWalletId,
            orElse: () => AccountModel(
              id: '',
              userId: '',
              name: '',
              type: '',
              balance: 0,
              currency: 'TRY',
              createdAt: DateTime.now(),
            ),
          );
          totalBalance = selectedAccount.balance;
          walletLabel = selectedAccount.name;
          currencySymbol = selectedAccount.currencySymbol;
        }

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colorTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorTheme.outline, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Selector Row
              GestureDetector(
                onTap: () => WalletSelectionSheet.show(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      walletLabel,
                      style: TextStyle(
                        color: colorTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: colorTheme.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$currencySymbol${NumberFormat('#,##0.00', 'tr_TR').format(totalBalance)}',
                style: TextStyle(
                  color: colorTheme.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceStat(
                      l.income,
                      '$currencySymbol${NumberFormat('#,##0.00', 'tr_TR').format(totalIncome)}',
                      Icons.arrow_upward,
                      colorTheme.success,
                      colorTheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBalanceStat(
                      l.expense,
                      '$currencySymbol${NumberFormat('#,##0.00', 'tr_TR').format(totalExpense)}',
                      Icons.arrow_downward,
                      colorTheme.error,
                      colorTheme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Text(l.error),
    );
  }

  Widget _buildBalanceStat(
    String label,
    String value,
    IconData icon,
    Color color,
    ColorTheme colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorTheme.subtleCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: colorTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<TransactionModel>> transactions,
    AsyncValue<List<CategoryModel>> categories,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    return transactions.when(
      data: (List<TransactionModel> transactionsList) {
        return LayoutBuilder(
          builder: (context, constraints) {
            if (transactionsList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 56,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l.noTransactions,
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.addFirstTransaction,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }

            Map<String, CategoryModel> categoryMap = {};
            if (categories.hasValue) {
              for (var cat in categories.value!) {
                categoryMap[cat.id] = cat;
              }
            }

            // Estimate item height (68px card + 10px margin = ~78px). Using 80 to be safe.
            const double itemHeight = 80;
            final int maxItems = (constraints.maxHeight / itemHeight).floor();
            // Ensure we show at least 1 if there's space, but clamp to list length
            final int count = maxItems.clamp(0, transactionsList.length);
            final displayTransactions = transactionsList.take(count).toList();

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayTransactions.length,
              itemBuilder: (context, index) {
                final transaction = displayTransactions[index];
                final category = transaction.categoryId != null
                    ? categoryMap[transaction.categoryId]
                    : null;
                return _buildTransactionItem(
                  context,
                  ref,
                  transaction,
                  category,
                  l,
                  colorTheme,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Text(l.error),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
    CategoryModel? category,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? colorTheme.success : colorTheme.error;

    final accountsList = ref.read(accountsProvider).value ?? [];
    final txAccount = accountsList.firstWhere(
      (a) => a.id == transaction.accountId,
      orElse: () => AccountModel(
        id: '',
        userId: '',
        name: '',
        type: '',
        balance: 0,
        currency: 'TRY',
        createdAt: DateTime.now(),
      ),
    );
    final String currencySymbol = txAccount.currencySymbol;

    IconData categoryIcon = isIncome
        ? Icons.arrow_downward
        : Icons.arrow_upward;
    if (category != null) {
      categoryIcon = _getCategoryIcon(category.icon);
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => EditTransactionSheet(transaction: transaction),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorTheme.outline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(categoryIcon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCategoryName(category, l) ??
                        (transaction.description ??
                            (isIncome ? l.income : l.expense)),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMM', 'tr_TR').format(transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorTheme.textSecondary,
                        ),
                      ),
                      if (transaction.description != null &&
                          category != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            transaction.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}$currencySymbol${NumberFormat('#,##0.00', 'tr_TR').format(transaction.amount)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getCategoryName(CategoryModel? category, AppLocalizations l) =>
      localizedCategoryName(category, l);

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.wallet;
      case 'laptop':
        return Icons.laptop;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'checkroom':
        return Icons.checkroom;
      case 'school':
        return Icons.school;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required String label,
    required Color accentColor,
    required ColorTheme colorTheme,
    required VoidCallback onTap,
  }) {
    final r = ResponsiveHelper.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: r.hp(9), // slightly shorter
        decoration: BoxDecoration(
          color: colorTheme.cardColor,
          borderRadius: r.borderRadiusM,
          border: Border.all(color: colorTheme.outline, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top Accent Strip
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(
                      16,
                    ), // Match r.borderRadiusM roughly
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                r.paddingM,
                r.paddingM,
                r.paddingS,
                r.paddingM,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: r.fontS,
                        fontWeight: FontWeight.w600,
                        color: colorTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colorTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
