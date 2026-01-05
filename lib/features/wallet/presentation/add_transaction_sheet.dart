import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_helper.dart'; // İkon yardımcısı
import '../../../core/widgets/custom_button.dart'; // Özel butonumuz
import '../data/wallet_provider.dart';
import '../models/category_model.dart';
import 'package:go_router/go_router.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  bool isExpense = true;
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  bool isLoading = false;
  String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final categoriesState = ref.watch(categoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.fromLTRB(24, 16, 24, keyboardSpace + 24),
      decoration: const BoxDecoration(
        color: AppColors.container,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Tutma Çizgisi
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // 1. GELİR / GİDER SEÇİMİ
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTab('Gider', true),
                _buildTab('Gelir', false),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. KATEGORİ IZGARASI (GRID)
          Expanded(
            child: categoriesState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text("Hata: $err")),
              data: (categories) {
                final filtered = categories.where((c) => c.type == (isExpense ? 'expense' : 'income')).toList();
                if (filtered.isEmpty) return const Center(child: Text("Kategori yok", style: TextStyle(color: Colors.grey)));

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cat = filtered[index];
                    final isSelected = selectedCategoryId == cat.id;
                    return GestureDetector(
                      onTap: () => setState(() {
                        selectedCategoryId = cat.id;
                        if (_titleController.text.isEmpty) _titleController.text = cat.name;
                      }),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(IconHelper.getIcon(cat.iconCode), color: isSelected ? Colors.black : Colors.grey, size: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(cat.name, style: TextStyle(color: isSelected ? AppColors.primary : Colors.grey, fontSize: 11), maxLines: 1),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 3. ALT KISIM (INPUTLAR)
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: '0', hintStyle: TextStyle(color: Colors.grey[700], fontSize: 32),
              suffixText: '₺', suffixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              border: InputBorder.none,
            ),
          ),

          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Açıklama ekle...', hintStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
              border: InputBorder.none,
            ),
          ),

          const SizedBox(height: 20),

          // MODÜLER BUTON KULLANIMI
          CustomButton(
            text: 'KAYDET',
            isLoading: isLoading,
            onPressed: _saveTransaction,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isExpenseTab) {
    final isSelected = isExpense == isExpenseTab;
    return GestureDetector(
      onTap: () => setState(() => isExpense = isExpenseTab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (isExpenseTab ? AppColors.expense : AppColors.income) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_amountController.text.isEmpty) return;
    setState(() => isLoading = true);
    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      await ref.read(walletRepositoryProvider).addTransaction(
        title: _titleController.text.isEmpty ? 'Harcama' : _titleController.text,
        amount: amount,
        isExpense: isExpense,
      );
      ref.refresh(recentTransactionsProvider);
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}