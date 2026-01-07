// lib/features/home/presentation/dashboard_view.dart
import '../../../core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../features/auth/data/auth_provider.dart';
import '../../../features/wallet/data/wallet_provider.dart';
import '../../../features/wallet/models/account_model.dart';
import '../../../features/wallet/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(transactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Kullanıcı Kartı
              _buildUserHeader(userProfile),

              const SizedBox(height: 24),

              // Toplam Bakiye Kartı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTotalBalanceCard(context, accounts),
              ),

              const SizedBox(height: 24),

              // Son İşlemler Başlığı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Son İşlemler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Tüm işlemlere git
                      },
                      child: const Text('Tümünü Gör'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Son İşlemler Listesi
              _buildTransactionsList(transactions),

              const SizedBox(height: 24), // Bottom nav için boşluk
            ],
          ),
        ),
      ),
    );
  }

  /// Kullanıcı başlık kartı
  Widget _buildUserHeader(AsyncValue userProfile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: userProfile.when(
        data: (profile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accent,
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Text(
                            profile?.fullName?.substring(0, 1).toUpperCase() ??
                                'U',
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
                        const Text(
                          'Hoş geldin,',
                          style: TextStyle(
                            color: AppColors.accentLight,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          profile?.fullName ?? 'Kullanıcı',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (profile?.isPremium ?? false)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '👑 ELITE',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(color: Colors.white),
        error: (_, __) => const Text(
          'Profil yüklenemedi',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Toplam bakiye kartı
  Widget _buildTotalBalanceCard(
    BuildContext context,
    AsyncValue<List<AccountModel>> accounts,
  ) {
    return accounts.when(
      data: (List<AccountModel> accountsList) {
        double totalBalance = 0.0;
        for (final account in accountsList) {
          totalBalance += account.balance;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Toplam Bakiye',
                style: TextStyle(color: AppColors.accentLight, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalBalance)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceStat(
                      context,
                      'Gelir',
                      '₺0.00', // TODO: Gerçek hesaplama
                      Icons.arrow_upward,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceStat(
                      context,
                      'Gider',
                      '₺0.00', // TODO: Gerçek hesaplama
                      Icons.arrow_downward,
                      AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Bakiye yüklenemedi'),
    );
  }

  Widget _buildBalanceStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final responsive = ResponsiveHelper(context);
    return Container(
      padding: EdgeInsets.all(responsive.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: responsive.isMobile ? 20 : 24),
          SizedBox(width: responsive.isMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.accentLight,
                  fontSize: responsive.subtitleFontSize,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.bodyFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Cüzdanlar listesi
  Widget _buildAccountsList(AsyncValue<List<AccountModel>> accounts) {
    return accounts.when(
      data: (List<AccountModel> accountsList) {
        if (accountsList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz cüzdan eklenmemiş',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: accountsList.length,
            itemBuilder: (context, index) {
              final account = accountsList[index];
              return _buildAccountCard(context, account);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Cüzdanlar yüklenemedi'),
    );
  }

  Widget _buildAccountCard(BuildContext context, AccountModel account) {
    final responsive = ResponsiveHelper(context);

    IconData iconData;
    Color iconColor;

    switch (account.type) {
      case 'bank':
        iconData = Icons.account_balance;
        iconColor = AppColors.info;
        break;
      case 'cash':
        iconData = Icons.payments;
        iconColor = AppColors.success;
        break;
      case 'gold':
        iconData = Icons.diamond;
        iconColor = AppColors.warning;
        break;
      case 'credit_card':
        iconData = Icons.credit_card;
        iconColor = AppColors.error;
        break;
      default:
        iconData = Icons.account_balance_wallet;
        iconColor = AppColors.primary;
    }

    return Container(
      width: responsive.isMobile ? 180 : 220, // ← Tablet'te daha geniş
      margin: const EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(
        responsive.isMobile ? 16 : 20,
      ), // ← Dinamik padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(responsive.isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: responsive.isMobile ? 24 : 28, // ← Dinamik icon size
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey[400]),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name,
                style: TextStyle(
                  fontSize: responsive.subtitleFontSize, // ← Dinamik font
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₺${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)}',
                style: TextStyle(
                  fontSize: responsive.isMobile ? 20 : 24, // ← Dinamik font
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// İşlemler listesi
  Widget _buildTransactionsList(
    AsyncValue<List<TransactionModel>> transactions,
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
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz işlem eklenmemiş',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // Son 5 işlemi göster
        final recentTransactions = transactionsList.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: recentTransactions.length,
          itemBuilder: (context, index) {
            final transaction = recentTransactions[index];
            return _buildTransactionItem(transaction);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('İşlemler yüklenemedi'),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isIncome = transaction.type == 'income';
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    final color = isIncome ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'İşlem',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy', 'tr_TR').format(transaction.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}₺${NumberFormat('#,##0.00', 'tr_TR').format(transaction.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
