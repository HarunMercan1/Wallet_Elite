// lib/features/wallet/presentation/wallet_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../features/auth/data/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/wallet_provider.dart';

class WalletView extends ConsumerWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final transactionState = ref.watch(transactionsProvider);

    double totalBalance = 0;
    double totalIncome = 0;
    double totalExpense = 0;

    if (transactionState.hasValue) {
      final transactions = transactionState.value!;
      for (var t in transactions) {
        if (t.isExpense) {
          totalBalance -= t.amount;
          totalExpense += t.amount;
        } else if (t.isIncome) {
          totalBalance += t.amount;
          totalIncome += t.amount;
        }
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(ref, l),

            const SizedBox(height: 24),

            _buildBalanceCard(totalBalance, totalIncome, totalExpense, l),

            const SizedBox(height: 30),

            Text(
              l.categories,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionBox(
                  icon: FontAwesomeIcons.layerGroup,
                  label: l.category,
                  onTap: () {},
                ),
                _ActionBox(
                  icon: FontAwesomeIcons.handHoldingDollar,
                  label: l.debtBook,
                  onTap: () {},
                ),
                _ActionBox(
                  icon: FontAwesomeIcons.buildingColumns,
                  label: l.wallets,
                  onTap: () {},
                ),
                _ActionBox(
                  icon: FontAwesomeIcons.moneyBillTransfer,
                  label: l.more,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.recentTransactions,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.refresh(transactionsProvider),
                  child: Text(
                    l.loading.replaceAll('...', ''),
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            transactionState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
              error: (err, stack) => Center(
                child: Text(
                  '${l.error}: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        '${l.noTransactions}\n${l.addFirstTransaction}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final recentTransactions = transactions.take(10).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    return _TransactionTile(
                      transaction: recentTransactions[index],
                      l: l,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, AppLocalizations l) {
    final authController = ref.read(authControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              radius: 22,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.welcome,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  l.user,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () => authController.signOut(),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    double total,
    double income,
    double expense,
    AppLocalizations l,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF2D3760)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.totalBalance,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '₺ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _BalanceBadge(
                icon: Icons.arrow_downward,
                text: l.income,
                amount: '₺ ${income.toStringAsFixed(0)}',
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 20),
              _BalanceBadge(
                icon: Icons.arrow_upward,
                text: l.expense,
                amount: '₺ ${expense.toStringAsFixed(0)}',
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final String amount;
  final Color color;
  const _BalanceBadge({
    required this.icon,
    required this.text,
    required this.amount,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBox({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F38),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final dynamic transaction;
  final AppLocalizations l;
  const _TransactionTile({required this.transaction, required this.l});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isExpense
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.isExpense
                  ? FontAwesomeIcons.burger
                  : FontAwesomeIcons.sackDollar,
              color: transaction.isExpense
                  ? Colors.redAccent
                  : Colors.greenAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ??
                      (transaction.isExpense ? l.expense : l.income),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.date.toString().substring(0, 10),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isExpense ? '-' : '+'} ₺${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: transaction.isExpense
                  ? Colors.redAccent
                  : Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
