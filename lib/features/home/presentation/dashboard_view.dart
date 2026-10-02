// lib/features/home/presentation/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/ads/full_screen_ads.dart';
import '../../premium/data/premium_provider.dart';
import '../../premium/presentation/paywall_view.dart';
import 'main_shell.dart' show selectedTabProvider;
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

    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      // Background color comes from AppTheme (scaffoldBackgroundColor)
      // Tüm ekran kaydırılabilir: küçük ekran yüksekliğinde içerik taşmaz.
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        // Üstte renkli başlık yok; durum çubuğu simgeleri temaya uysun
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Kullanıcı satırı
                  _buildUserHeader(
                    context,
                    userProfile,
                    isPremium,
                    l,
                    colorTheme,
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 20),

                  // Hızlı Erişim Butonları
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionTile(
                            label: l.debtTracking,
                            icon: Icons.handshake_outlined,
                            accentColor: colorTheme.primary,
                            colorTheme: colorTheme,
                            onTap: () =>
                                _openSubScreen(context, ref, const DebtsView()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionTile(
                            label: l.budgets,
                            icon: Icons.pie_chart_outline_rounded,
                            accentColor: colorTheme.success,
                            colorTheme: colorTheme,
                            onTap: () => _openSubScreen(
                              context,
                              ref,
                              const BudgetsView(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionTile(
                            label: l.recurringTransactions,
                            icon: Icons.autorenew_rounded,
                            accentColor: colorTheme.tertiary,
                            colorTheme: colorTheme,
                            onTap: () => _openSubScreen(
                              context,
                              ref,
                              const RecurringTransactionsView(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Son İşlemler Başlığı
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 6, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.recentTransactions,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorTheme.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.read(selectedTabProvider.notifier).state = 1,
                          style: TextButton.styleFrom(
                            foregroundColor: colorTheme.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.all,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Son İşlemler Listesi
            _buildTransactionsList(
              context,
              ref,
              transactions,
              categories,
              l,
              colorTheme,
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  /// Alt ekranı açar; dönüşte (doğal geçiş anı) geçiş reklamı sayacını ilerletir.
  Future<void> _openSubScreen(
    BuildContext context,
    WidgetRef ref,
    Widget screen,
  ) async {
    final interstitial = ref.read(interstitialAdServiceProvider);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    interstitial.onUserAction();
  }

  Widget _buildUserHeader(
    BuildContext context,
    AsyncValue userProfile,
    bool isPremium,
    AppLocalizations l,
    ColorTheme colorTheme,
  ) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
        child: userProfile.when(
          data: (profile) {
            final showEliteBadge = isPremium || (profile?.isPremium ?? false);
            return Row(
              children: [
                // Avatar (Read-only)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorTheme.primary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: _buildDashboardAvatar(profile, colorTheme),
                ),
                const SizedBox(width: 12),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.welcome,
                        style: TextStyle(
                          color: colorTheme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        profile?.fullName ?? l.user,
                        style: TextStyle(
                          color: colorTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (showEliteBadge)
                  _buildEliteBadge(colorTheme)
                else
                  _buildGoPremiumButton(context, colorTheme, l),
              ],
            );
          },
          loading: () => const SizedBox(height: 47),
          error: (_, __) =>
              Text(l.error, style: TextStyle(color: colorTheme.textPrimary)),
        ),
      ),
    );
  }

  Widget _buildEliteBadge(ColorTheme colorTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colorTheme.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👑', style: TextStyle(fontSize: 13)),
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
    );
  }

  Widget _buildGoPremiumButton(
    BuildContext context,
    ColorTheme colorTheme,
    AppLocalizations l,
  ) {
    final borderRadius = BorderRadius.circular(20);
    return Material(
      color: colorTheme.tertiary.withValues(alpha: 0.14),
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => showPaywall(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 16,
                color: colorTheme.tertiary,
              ),
              const SizedBox(width: 5),
              Text(
                l.goPremium,
                style: TextStyle(
                  color: colorTheme.tertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardAvatar(dynamic profile, ColorTheme colorTheme) {
    const double radius = 20;
    final avatarUrl = profile?.avatarUrl;

    // Check for preset avatar
    if (avatarUrl != null && avatarUrl.startsWith('preset:')) {
      final presetData = avatarUrl.substring(7); // Remove 'preset:' prefix
      final parts = presetData.split(':');
      if (parts.length >= 2) {
        final emoji = parts[0];
        final colorValue = int.tryParse(parts[1]) ?? 0xFF2196F3;
        return CircleAvatar(
          radius: radius,
          backgroundColor: Color(colorValue),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        );
      }
    }

    // Regular image URL
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: colorTheme.primary,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    // Default: show initial letter
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorTheme.primary,
      child: Text(
        profile?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: colorTheme.onPrimary,
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

        final pillRadius = BorderRadius.circular(20);
        final onPrimary = colorTheme.onPrimary;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorTheme.primary, colorTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorTheme.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dekoratif halkalar
              Positioned(
                top: -56,
                right: -36,
                child: _buildDecorCircle(160, onPrimary),
              ),
              Positioned(
                bottom: -80,
                left: -48,
                child: _buildDecorCircle(180, onPrimary),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Selector
                    Material(
                      color: onPrimary.withValues(alpha: 0.18),
                      borderRadius: pillRadius,
                      child: InkWell(
                        borderRadius: pillRadius,
                        onTap: () => WalletSelectionSheet.show(context),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                color: onPrimary,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  walletLabel,
                                  style: TextStyle(
                                    color: onPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: onPrimary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatMoney(totalBalance, currencySymbol),
                        style: TextStyle(
                          color: onPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceStat(
                            l.income,
                            _formatMoney(totalIncome, currencySymbol),
                            Icons.arrow_upward_rounded,
                            colorTheme.success,
                            onPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildBalanceStat(
                            l.expense,
                            _formatMoney(totalExpense, currencySymbol),
                            Icons.arrow_downward_rounded,
                            colorTheme.error,
                            onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Text(l.error),
    );
  }

  /// Eksi işareti para biriminin önüne gelir: -₺200,00
  String _formatMoney(double value, String currencySymbol) {
    final formatted = NumberFormat('#,##0.00', 'tr_TR').format(value.abs());
    return '${value < 0 ? '-' : ''}$currencySymbol$formatted';
  }

  Widget _buildDecorCircle(double size, Color onPrimary) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPrimary.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _buildBalanceStat(
    String label,
    String value,
    IconData icon,
    Color color,
    Color onPrimary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: onPrimary.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: onPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
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
        if (transactionsList.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: colorTheme.textMuted,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.noTransactions,
                      style: TextStyle(
                        color: colorTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.addFirstTransaction,
                      style: TextStyle(
                        color: colorTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final categoryMap = <String, CategoryModel>{
          for (final cat in categories.valueOrNull ?? const <CategoryModel>[])
            cat.id: cat,
        };

        // Ana sayfada son işlemler; tamamı İşlemler sekmesinde
        const maxRecent = 10;
        final displayTransactions = transactionsList.take(maxRecent).toList();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
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
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (_, __) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text(l.error)),
        ),
      ),
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
                            color: colorTheme.textMuted,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            transaction.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorTheme.textSecondary,
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

  Widget _buildQuickActionTile({
    required String label,
    required IconData icon,
    required Color accentColor,
    required ColorTheme colorTheme,
    required VoidCallback onTap,
  }) {
    final borderRadius = BorderRadius.circular(18);

    return Material(
      color: colorTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: colorTheme.outline, width: 1),
      ),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(height: 10),
              // İki satırlık sabit alan: tüm kutular aynı yükseklikte kalır ve
              // uzun kelimeler bölünmek yerine küçülür.
              SizedBox(
                height: 32,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _splitIntoTwoLines(label),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: colorTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Uzun etiketi kelime ortasından bölmeden, iki dengeli satıra ayırır
  /// ("Tekrarlayan İşlemler" → "Tekrarlayan\nİşlemler"). Kısa etiketler tek
  /// satır kalır.
  String _splitIntoTwoLines(String label) {
    final words = label.trim().split(RegExp(r'\s+'));
    if (words.length < 2 || label.length <= 12) return label;

    var bestSplit = 1;
    var bestDiff = label.length;
    for (var i = 1; i < words.length; i++) {
      final first = words.sublist(0, i).join(' ').length;
      final second = words.sublist(i).join(' ').length;
      final diff = (first - second).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestSplit = i;
      }
    }
    return '${words.sublist(0, bestSplit).join(' ')}\n'
        '${words.sublist(bestSplit).join(' ')}';
  }
}
