// lib/features/wallet/presentation/edit_transaction_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/wallet_provider.dart';
import '../models/transaction_model.dart';

class EditTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late String _transactionType;
  late String? _selectedAccountId;
  late String? _selectedCategoryId;
  late DateTime _selectedDate;
  bool _isLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.transaction.description ?? '',
    );
    _transactionType = widget.transaction.type;
    _selectedAccountId = widget.transaction.accountId;
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accounts = ref.watch(accountsProvider);
    final categories = _transactionType == 'income'
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
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
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    l.editTransaction,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Delete button
                IconButton(
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.delete_outline, color: colorTheme.error),
                  onPressed: _isDeleting
                      ? null
                      : () => _confirmDelete(l, colorTheme),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type indicator (read-only)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (_transactionType == 'expense'
                                    ? colorTheme.error
                                    : AppColors.success)
                                .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _transactionType == 'expense'
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: _transactionType == 'expense'
                                ? colorTheme.error
                                : AppColors.success,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _transactionType == 'expense'
                                ? l.expense
                                : l.income,
                            style: TextStyle(
                              color: _transactionType == 'expense'
                                  ? colorTheme.error
                                  : AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Amount
                    _buildSectionTitle(
                      l.amount,
                      Icons.attach_money,
                      colorTheme,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        prefixText: '₺ ',
                        prefixStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _transactionType == 'expense'
                              ? colorTheme.error
                              : AppColors.success,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _transactionType == 'expense'
                            ? colorTheme.error
                            : AppColors.success,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l.enterAmount;
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 0) {
                          return l.enterAmount;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Category
                    _buildSectionTitle(
                      l.category,
                      Icons.category_outlined,
                      colorTheme,
                    ),
                    const SizedBox(height: 8),
                    categories.when(
                      data: (categoriesList) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categoriesList.map((cat) {
                            final isSelected = _selectedCategoryId == cat.id;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategoryId = cat.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorTheme.primary
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorTheme.primary
                                        : Colors.grey[200]!,
                                  ),
                                ),
                                child: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => Text(l.error),
                    ),

                    const SizedBox(height: 20),

                    // Note
                    _buildSectionTitle(l.note, Icons.note_outlined, colorTheme),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: l.addNote,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date
                    _buildSectionTitle(
                      l.date,
                      Icons.calendar_today,
                      colorTheme,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: colorTheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat(
                                'dd MMMM yyyy',
                                Localizations.localeOf(context).languageCode,
                              ).format(_selectedDate),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Wallet
                    _buildSectionTitle(
                      l.wallet,
                      Icons.account_balance_wallet_outlined,
                      colorTheme,
                    ),
                    const SizedBox(height: 8),
                    accounts.when(
                      data: (accountsList) {
                        return DropdownButtonFormField<String>(
                          value: _selectedAccountId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: accountsList.map((acc) {
                            return DropdownMenuItem(
                              value: acc.id,
                              child: Text(acc.name),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedAccountId = v),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => Text(l.error),
                    ),

                    const SizedBox(height: 28),

                    // Update button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _updateTransaction(l, colorTheme),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    l.save,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorTheme colorTheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _confirmDelete(AppLocalizations l, ColorTheme colorTheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteTransaction),
        content: Text(l.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTransaction(l, colorTheme);
            },
            style: TextButton.styleFrom(foregroundColor: colorTheme.error),
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(
    AppLocalizations l,
    ColorTheme colorTheme,
  ) async {
    setState(() => _isDeleting = true);

    final walletController = ref.read(walletControllerProvider);
    final success = await walletController.deleteTransaction(
      widget.transaction.id,
    );

    setState(() => _isDeleting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.transactionDeleted),
            backgroundColor: colorTheme.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.error), backgroundColor: colorTheme.error),
        );
      }
    }
  }

  Future<void> _updateTransaction(
    AppLocalizations l,
    ColorTheme colorTheme,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.selectWallet),
          backgroundColor: colorTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Get old transaction (for balance revert)
      final oldAmount = widget.transaction.amount;
      final oldType = widget.transaction.type;
      final oldAccountId = widget.transaction.accountId;

      // New values
      final newAmount = double.parse(_amountController.text);
      final newDescription = _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text;

      // Update transaction
      await supabase
          .from('transactions')
          .update({
            'amount': newAmount,
            'category_id': _selectedCategoryId,
            'description': newDescription,
            'date': _selectedDate.toIso8601String(),
            'account_id': _selectedAccountId,
          })
          .eq('id', widget.transaction.id);

      // Update balances
      // 1. Revert old amount from old account
      if (oldType == 'income') {
        await _updateAccountBalance(oldAccountId, -oldAmount);
      } else {
        await _updateAccountBalance(oldAccountId, oldAmount);
      }

      // 2. Add new amount to new account
      if (_transactionType == 'income') {
        await _updateAccountBalance(_selectedAccountId!, newAmount);
      } else {
        await _updateAccountBalance(_selectedAccountId!, -newAmount);
      }

      // Refresh providers
      ref.invalidate(transactionsProvider);
      ref.invalidate(accountsProvider);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.transactionUpdated),
            backgroundColor: colorTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.error}: $e'),
            backgroundColor: colorTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _updateAccountBalance(String accountId, double delta) async {
    final supabase = Supabase.instance.client;
    final account = await supabase
        .from('accounts')
        .select('balance')
        .eq('id', accountId)
        .single();
    final currentBalance = (account['balance'] as num).toDouble();
    await supabase
        .from('accounts')
        .update({'balance': currentBalance + delta})
        .eq('id', accountId);
  }
}
