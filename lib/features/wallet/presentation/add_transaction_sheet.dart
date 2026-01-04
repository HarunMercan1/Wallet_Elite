import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../data/wallet_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  // Form verilerini tutan değişkenler
  bool isExpense = true; // Gider mi? (Kırmızı)
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool isLoading = false; // Kayıt sırasında döner tekerlek için

  @override
  Widget build(BuildContext context) {
    // Klavye açılınca ekranı yukarı itmesi için
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, keyboardSpace + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F38), // Koyu lacivert
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
        children: [
          // 1. ÜST ÇİZGİ (Tutma yeri)
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),

          // 2. GELİR / GİDER SEÇİMİ (Toggle)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeButton(title: 'Gider', isActive: isExpense, color: Colors.redAccent, onTap: () => setState(() => isExpense = true)),
              const SizedBox(width: 16),
              _buildTypeButton(title: 'Gelir', isActive: !isExpense, color: Colors.greenAccent, onTap: () => setState(() => isExpense = false)),
            ],
          ),

          const SizedBox(height: 30),

          // 3. TUTAR GİRİŞİ (Büyük Yazı)
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            decoration: InputDecoration(
              hintText: '₺0.00',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none, // Çizgisiz
            ),
          ),

          const SizedBox(height: 20),

          // 4. AÇIKLAMA GİRİŞİ
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: isExpense ? 'Nereye harcadın?' : 'Para nereden geldi?',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              prefixIcon: Icon(isExpense ? FontAwesomeIcons.burger : FontAwesomeIcons.moneyBill, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 30),

          // 5. KAYDET BUTONU
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isExpense ? Colors.redAccent : Colors.greenAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: isLoading ? null : _saveTransaction, // Tıklayınca kaydet
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('KAYDET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // BUTON TASARIMI İÇİN YARDIMCI
  Widget _buildTypeButton({required String title, required bool isActive, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? color : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          title,
          style: TextStyle(color: isActive ? color : Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- KAYDETME MANTIĞI ---
  Future<void> _saveTransaction() async {
    // 1. Basit kontrol: Boş mu?
    if (_amountController.text.isEmpty || _titleController.text.isEmpty) return;

    setState(() => isLoading = true); // Dönme dolabı başlat

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.')); // Virgülü noktaya çevir

      // 2. Repository'e Gönder (Mutfak siparişi)
      await ref.read(walletRepositoryProvider).addTransaction(
        title: _titleController.text,
        amount: amount,
        isExpense: isExpense,
      );

      // 3. Listeyi Yenile (Ekran güncellensin)
      ref.refresh(recentTransactionsProvider);

      // 4. Paneli Kapat
      if (mounted) context.pop();

    } catch (e) {
      print("Hata: $e"); // Hata olursa konsola yaz
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}