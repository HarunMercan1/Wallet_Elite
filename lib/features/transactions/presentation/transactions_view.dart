// lib/features/transactions/presentation/transactions_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/transaction_model.dart';
import '../../settings/data/settings_provider.dart';

class TransactionsView extends ConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                locale == 'tr' ? 'İşlemler' : 'Transactions',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // İşlemler listesi
            Expanded(
              child: transactions.when(
                data: (List<TransactionModel> txList) {
                  if (txList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            locale == 'tr'
                                ? 'Henüz işlem yok'
                                : 'No transactions yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Tarihe göre grupla
                  final groupedTx = _groupByDate(txList);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupedTx.length,
                    itemBuilder: (context, index) {
                      final date = groupedTx.keys.elementAt(index);
                      final dayTx = groupedTx[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tarih başlığı
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _formatDate(date, locale),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          // O güne ait işlemler
                          ...dayTx.map(
                            (tx) => _buildTransactionCard(tx, locale),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Hata: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupByDate(
    List<TransactionModel> txList,
  ) {
    final Map<String, List<TransactionModel>> grouped = {};

    for (final tx in txList) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(tx);
    }

    // Tarihe göre sırala (en yeni önce)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  String _formatDate(String dateKey, String locale) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (DateFormat('yyyy-MM-dd').format(now) == dateKey) {
      return locale == 'tr' ? 'Bugün' : 'Today';
    } else if (DateFormat('yyyy-MM-dd').format(yesterday) == dateKey) {
      return locale == 'tr' ? 'Dün' : 'Yesterday';
    } else {
      return DateFormat(
        'd MMMM yyyy',
        locale == 'tr' ? 'tr_TR' : 'en_US',
      ).format(date);
    }
  }

  Widget _buildTransactionCard(TransactionModel tx, String locale) {
    final isIncome = tx.type == 'income';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          // İkon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),

          // Açıklama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ??
                      (isIncome
                          ? (locale == 'tr' ? 'Gelir' : 'Income')
                          : (locale == 'tr' ? 'Gider' : 'Expense')),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(tx.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // Tutar
          Text(
            '${isIncome ? '+' : '-'}₺${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
