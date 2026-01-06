// lib/features/wallet/presentation/wallet_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../features/auth/data/auth_provider.dart';
import '../data/wallet_provider.dart';

class WalletView extends ConsumerWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. VERİYİ ÇEK (transactionsProvider kullan, recentTransactionsProvider yok)
    final transactionState = ref.watch(transactionsProvider);

    // 2. HESAP MAKİNESİ (Gelen veriyi topla/çıkar)
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

    // 3. EKRAN TASARIMI
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER (Profil Resmi ve Çıkış) ---
            _buildHeader(ref),

            const SizedBox(height: 24),

            // --- TOPLAM VARLIK KARTI (O sevdiğin Gradient Tasarım) ---
            _buildBalanceCard(totalBalance, totalIncome, totalExpense),

            const SizedBox(height: 30),

            // --- ARAÇLAR MENÜSÜ (Yeni Butonlar) ---
            const Text('Araçlar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionBox(icon: FontAwesomeIcons.layerGroup, label: 'Kategori', onTap: () {
                  print("Kategori");
                }),
                _ActionBox(icon: FontAwesomeIcons.handHoldingDollar, label: 'Borçlar', onTap: () {
                  print("Borçlar");
                }),
                _ActionBox(icon: FontAwesomeIcons.buildingColumns, label: 'Hesaplar', onTap: () {
                  print("Hesaplar");
                }),
                _ActionBox(icon: FontAwesomeIcons.moneyBillTransfer, label: 'Transfer', onTap: () {
                  print("Transfer");
                }),
              ],
            ),

            const SizedBox(height: 30),

            // --- SON HAREKETLER LİSTESİ ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Son Hareketler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () => ref.refresh(transactionsProvider),
                    child: const Text('Yenile', style: TextStyle(color: Colors.amber))),
              ],
            ),
            const SizedBox(height: 10),

            // Liste Durumu (Yükleniyor mu? Hata mı var? Veri mi geldi?)
            transactionState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.amber)),
              error: (err, stack) => Center(child: Text('Hata: $err', style: const TextStyle(color: Colors.red))),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("Henüz işlem yok.\n'+' butonuna basarak ekle!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                // Son 10 işlemi göster
                final recentTransactions = transactions.take(10).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    return _TransactionTile(transaction: recentTransactions[index]);
                  },
                );
              },
            ),

            const SizedBox(height: 80), // Alttaki menü kapatmasın diye boşluk
          ],
        ),
      ),
    );
  }

  // --- 1. Header Parçası ---
  Widget _buildHeader(WidgetRef ref) {
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
              children: const [
                Text('Hoş geldin,', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Harun Reşit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  // --- 2. Balance Kartı (GRADIENT GERİ GELDİ!) ---
  Widget _buildBalanceCard(double total, double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // İŞTE O SEVDİĞİN RENK GEÇİŞİ:
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
          const Text('Toplam Varlık', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '₺ ${total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _BalanceBadge(icon: Icons.arrow_downward, text: 'Gelir', amount: '₺ ${income.toStringAsFixed(0)}', color: Colors.greenAccent),
              const SizedBox(width: 20),
              _BalanceBadge(icon: Icons.arrow_upward, text: 'Gider', amount: '₺ ${expense.toStringAsFixed(0)}', color: Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }
}

// --- YARDIMCI WIDGET'LAR ---

class _BalanceBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final String amount;
  final Color color;
  const _BalanceBadge({required this.icon, required this.text, required this.amount, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  const _ActionBox({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(color: const Color(0xFF1A1F38), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
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
  const _TransactionTile({required this.transaction});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1F38), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transaction.isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.isExpense ? FontAwesomeIcons.burger : FontAwesomeIcons.sackDollar,
              color: transaction.isExpense ? Colors.redAccent : Colors.greenAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'İşlem',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
              color: transaction.isExpense ? Colors.redAccent : Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}