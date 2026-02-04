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
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/settings/data/settings_provider.dart';
import '../../wallet/presentation/edit_transaction_sheet.dart';
import '../../debts/presentation/debts_view.dart';

import '../../wallet/presentation/wallet_selection_sheet.dart';
import '../../budgets/presentation/budgets_view.dart';
import '../../recurring/presentation/recurring_transactions_view.dart';
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
    final locale = ref.watch(localeProvider);
    final colorTheme = ref.watch(currentColorThemeProvider);

    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(transactionsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
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

              // Hızlı Erişim Butonları (Borç Takibi, Bütçeler, Tekrarlayan İşlemler)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Borç Takibi
                    Expanded(
                      child: _buildQuickAccessCard(
                        context,
                        icon: Icons.people,
                        label: l.debtTracking,
                        colorTheme: colorTheme,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DebtsView()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Bütçeler
                    Expanded(
                      child: _buildQuickAccessCard(
                        context,
                        icon: Icons.pie_chart,
                        label: l.budgets,
                        colorTheme: colorTheme,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BudgetsView(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tekrarlayan İşlemler
                    Expanded(
                      child: _buildQuickAccessCard(
                        context,
                        icon: Icons.repeat,
                        label: l.recurringTransactions,
                        colorTheme: colorTheme,
                        isDark: isDark,
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
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Son İşlemler Listesi
              _buildTransactionsList(
                context,
                ref,
                transactions,
                categories,
                l,
                isDark,
                colorTheme,
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
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
            colorTheme.primary.withOpacity(0.9),
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
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
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
                            color: Colors.white.withOpacity(0.85),
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
                        color: colorTheme.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('👑', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 4),
                          Text(
                            'ELITE',
                            style: TextStyle(
                              color: Colors.black87,
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

        if (selectedWalletId == null) {
          // Sum all wallets
          for (final account in accountsList) {
            totalBalance += account.balance;
          }
        } else {
          // Find the selected wallet
          final selectedAccount = accountsList.firstWhere(
            (a) => a.id == selectedWalletId,
            orElse: () => accountsList.isNotEmpty
                ? accountsList.first
                : AccountModel(
                    id: '',
                    userId: '',
                    name: '',
                    type: '',
                    balance: 0,
                    createdAt: DateTime.now(),
                  ),
          );
          totalBalance = selectedAccount.balance;
          walletLabel = selectedAccount.name;
        }

        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorTheme.primary.withValues(alpha: 0.15),
              width: 1,
            ),
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
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalBalance)}',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
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
                      '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalIncome)}',
                      Icons.arrow_upward,
                      colorTheme.success,
                      isDark,
                      colorTheme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBalanceStat(
                      l.expense,
                      '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalExpense)}',
                      Icons.arrow_downward,
                      colorTheme.error,
                      isDark,
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
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : colorTheme.primary.withValues(alpha: 0.05),
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
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
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
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return transactions.when(
      data: (List<TransactionModel> transactionsList) {
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

        final recentTransactions = transactionsList.take(5).toList();

        Map<String, CategoryModel> categoryMap = {};
        if (categories.hasValue) {
          for (var cat in categories.value!) {
            categoryMap[cat.id] = cat;
          }
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: recentTransactions.length,
          itemBuilder: (context, index) {
            final transaction = recentTransactions[index];
            final category = transaction.categoryId != null
                ? categoryMap[transaction.categoryId]
                : null;
            return _buildTransactionItem(
              context,
              ref,
              transaction,
              category,
              l,
              isDark,
              colorTheme,
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
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? colorTheme.success : colorTheme.error;

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
          color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMM', 'tr_TR').format(transaction.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
              '${isIncome ? '+' : '-'}₺${NumberFormat('#,##0.00', 'tr_TR').format(transaction.amount)}',
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

  String? _getCategoryName(CategoryModel? category, AppLocalizations l) {
    if (category == null) return null;

    if (category.translationKey != null) {
      switch (category.translationKey) {
        case 'cat_food':
          return l.cat_food;
        case 'cat_transport':
          return l.cat_transport;
        case 'cat_shopping':
          return l.cat_shopping;
        case 'cat_entertainment':
          return l.cat_entertainment;
        case 'cat_bills':
          return l.cat_bills;
        case 'cat_health':
          return l.cat_health;
        case 'cat_education':
          return l.cat_education;
        case 'cat_rent':
          return l.cat_rent;
        case 'cat_taxes':
          return l.cat_taxes;
        case 'cat_salary':
          return l.cat_salary;
        case 'cat_freelance':
          return l.cat_freelance;
        case 'cat_investment':
          return l.cat_investment;
        case 'cat_gift':
          return l.cat_gift;
        case 'cat_pets':
          return l.cat_pets;
        case 'cat_groceries':
          return l.cat_groceries;
        case 'cat_electronics':
          return l.cat_electronics;
        case 'cat_charity':
          return l.cat_charity;
        case 'cat_insurance':
          return l.cat_insurance;
        case 'cat_gym':
          return l.cat_gym;
        case 'cat_other':
        case 'cat_others':
          return l.cat_other;
        case 'cat_travel':
          return l.cat_travel;
      }
    }

    // Fallback Check
    final name = category.name.toLowerCase();
    if (name.contains('food') || name.contains('yemek')) return l.cat_food;
    if (name.contains('pet') || name.contains('evcil')) return l.cat_pets;
    if (name.contains('grocer') || name.contains('market')) {
      return l.cat_groceries;
    }
    if (name.contains('electronic')) return l.cat_electronics;
    if (name.contains('charity') || name.contains('bağış')) {
      return l.cat_charity;
    }
    if (name.contains('insuranc') || name.contains('sigorta')) {
      return l.cat_insurance;
    }
    if (name.contains('gym') || name.contains('spor')) return l.cat_gym;
    if (name.contains('health')) return l.cat_health;
    if (name.contains('gift')) return l.cat_gift;
    if (name.contains('bill')) return l.cat_bills;
    if (name.contains('educat')) return l.cat_education;
    if (name.contains('entert')) return l.cat_entertainment;
    if (name.contains('shop')) return l.cat_shopping;
    if (name.contains('transport')) return l.cat_transport;
    if (name.contains('travel') || name.contains('seyahat')) {
      return l.cat_travel;
    }

    return category.name;
  }

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

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ColorTheme colorTheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final r = ResponsiveHelper.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: r.hp(11), // Dinamik yükseklik (~90px on 800px screen)
        padding: EdgeInsets.symmetric(
          vertical: r.paddingXS,
          horizontal: r.paddingXS,
        ),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
          borderRadius: r.borderRadiusM,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.paddingS),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: r.borderRadiusS,
              ),
              child: Icon(icon, color: colorTheme.accent, size: r.iconM),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: r.fontXS,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
