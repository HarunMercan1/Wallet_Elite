// lib/features/debts/presentation/debt_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../wallet/data/debt_provider.dart';
import '../../wallet/models/debt_model.dart';

class DebtDetailSheet extends ConsumerStatefulWidget {
  final DebtModel debt;

  const DebtDetailSheet({super.key, required this.debt});

  @override
  ConsumerState<DebtDetailSheet> createState() => _DebtDetailSheetState();
}

class _DebtDetailSheetState extends ConsumerState<DebtDetailSheet> {
  final _paymentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: '₺',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat(
      'dd MMMM yyyy',
      Localizations.localeOf(context).toString(),
    );

    final debt = widget.debt;
    final isLend = debt.type == 'lend';
    final isOverdue =
        debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now()) &&
        !debt.isCompleted;
    final progress = debt.amount > 0
        ? (debt.amount - debt.remainingAmount) / debt.amount
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorTheme.backgroundDark : colorTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Tip ikonu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isLend ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isLend ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isLend ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        isLend ? l.lend : l.borrow,
                        style: TextStyle(
                          color: isLend ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteDebt(context, ref, debt, l),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tutar kartı
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLend
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l.remaining,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(debt.remainingAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (debt.remainingAmount != debt.amount) ...[
                          const SizedBox(height: 4),
                          Text(
                            '/ ${currencyFormat.format(debt.amount)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                        if (!debt.isCompleted && progress > 0) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% ${l.remaining.toLowerCase()}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vade bilgisi (düzenlenebilir)
                  if (debt.dueDate != null)
                    GestureDetector(
                      onTap: () => _editDueDate(context, ref, debt, l),
                      child: _buildInfoRow(
                        icon: Icons.event,
                        label: l.dueDate,
                        value: dateFormat.format(debt.dueDate!),
                        isDark: isDark,
                        isWarning: isOverdue,
                        warningText: isOverdue ? l.overdue : null,
                        showEditIcon: true,
                      ),
                    ),

                  // Oluşturma tarihi
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: l.date,
                    value: dateFormat.format(debt.createdAt),
                    isDark: isDark,
                  ),

                  // Açıklama (düzenlenebilir)
                  GestureDetector(
                    onTap: () => _editDescription(
                      context,
                      ref,
                      debt,
                      l,
                      isDark,
                      colorTheme,
                    ),
                    child: _buildInfoRow(
                      icon: Icons.notes,
                      label: l.note,
                      value: debt.description?.isNotEmpty == true
                          ? debt.description!
                          : '-',
                      isDark: isDark,
                      showEditIcon: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Aksiyonlar
                  if (!debt.isCompleted) ...[
                    // Ödeme kaydet
                    Text(
                      l.recordPayment,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _paymentController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: currencyFormat.format(
                                debt.remainingAmount,
                              ),
                              prefixText: '₺ ',
                              prefixIcon: Icon(
                                Icons.payment,
                                color: colorTheme.primary,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? colorTheme.surfaceDark
                                  : colorTheme.surfaceLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorTheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _recordPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tamamlandı olarak işaretle
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _markAsCompleted,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(l.markAsCompleted),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  const SizedBox(height: 32),

                  // Ödeme Geçmişi
                  Text(
                    l.paymentHistory,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, child) {
                      final paymentsAsync = ref.watch(
                        debtPaymentsProvider(widget.debt.id),
                      );

                      return paymentsAsync.when(
                        data: (payments) {
                          if (payments.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Text(
                                  l.noPaymentsYet,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: payments.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final payment = payments[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l.payment,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dateFormat.format(
                                            payment.paymentDate,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      currencyFormat.format(payment.amount),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Text('Hata: $error'),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isWarning = false,
    String? warningText,
    bool showEditIcon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isWarning
                  ? Colors.red
                  : (isDark ? Colors.white10 : Colors.grey.shade100)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isWarning
                  ? Colors.red
                  : (isDark ? Colors.white54 : Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 15,
                          color: isWarning
                              ? Colors.red
                              : (isDark ? Colors.white : Colors.black87),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (warningText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          warningText,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (showEditIcon) ...[
                      const Spacer(),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editDueDate(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    AppLocalizations l,
  ) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: debt.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (newDate != null && newDate != debt.dueDate) {
      final controller = ref.read(debtControllerProvider);
      final updatedDebt = debt.copyWith(dueDate: newDate);
      await controller.updateDebt(updatedDebt);
    }
  }

  Future<void> _editDescription(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) async {
    final textController = TextEditingController(text: debt.description ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
        title: Text(l.note),
        content: TextField(
          controller: textController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l.addNote,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, textController.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (result != null && result != debt.description) {
      final controller = ref.read(debtControllerProvider);
      final updatedDebt = debt.copyWith(
        description: result.isEmpty ? null : result,
      );
      await controller.updateDebt(updatedDebt);
    }
  }

  Future<void> _deleteDebt(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    AppLocalizations l,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.read(currentColorThemeProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? colorTheme.surfaceDark : Colors.white,
        title: Text(
          l.deleteDebt,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          l.deleteDebtConfirm,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l.deleteDebt,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.pop(context);
      final controller = ref.read(debtControllerProvider);
      await controller.deleteDebt(debt.id);
    }
  }

  Future<void> _recordPayment() async {
    final amountText = _paymentController.text.trim();
    if (amountText.isEmpty) {
      // Tüm kalan tutarı öde
      _paymentController.text = widget.debt.remainingAmount.toString();
    }

    final amount = double.tryParse(_paymentController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    final controller = ref.read(debtControllerProvider);
    final success = await controller.recordPayment(
      debtId: widget.debt.id,
      amount: amount,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.paymentRecorded),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _markAsCompleted() async {
    setState(() => _isLoading = true);

    final controller = ref.read(debtControllerProvider);
    final success = await controller.markAsCompleted(widget.debt.id);

    setState(() => _isLoading = false);

    if (success && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.debtUpdated), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}
