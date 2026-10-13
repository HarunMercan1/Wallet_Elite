import '../../../features/settings/data/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
// lib/features/debts/presentation/debt_detail_sheet.dart

import '../../../core/utils/amount_input.dart';
import 'package:flutter/material.dart';
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
      symbol: CurrencyUtils.getSymbol(ref.watch(currencyProvider)),
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
        color: colorTheme.background,
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
              color: colorTheme.outline,
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
                    color: (isLend ? colorTheme.success : colorTheme.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isLend ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isLend ? colorTheme.success : colorTheme.error,
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
                          color: colorTheme.textPrimary,
                        ),
                      ),
                      Text(
                        isLend ? l.lend : l.borrow,
                        style: TextStyle(
                          color: isLend ? colorTheme.success : colorTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorTheme.error),
                  onPressed: () => _deleteDebt(context, ref, debt, l),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: colorTheme.textSecondary,
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
                            ? [colorTheme.success, colorTheme.success]
                            : [colorTheme.error, colorTheme.error],
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
                        color: colorTheme.textPrimary,
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
                            inputFormatters: [const AmountInputFormatter()],
                            decoration: InputDecoration(
                              hintText: currencyFormat.format(
                                debt.remainingAmount,
                              ),
                              prefixText:
                                  '${CurrencyUtils.getSymbol(ref.watch(currencyProvider))} ',
                              prefixIcon: Icon(
                                Icons.payment,
                                color: colorTheme.primary,
                              ),
                              filled: true,
                              fillColor: colorTheme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorTheme.borderColor,
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
                            foregroundColor: colorTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: colorTheme.onPrimary,
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
                          foregroundColor: colorTheme.success,
                          side: BorderSide(color: colorTheme.success),
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
                      color: colorTheme.textPrimary,
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
                                    color: colorTheme.textSecondary,
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
                                  color: colorTheme.subtleCardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorTheme.success.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: colorTheme.success,
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
                                            color: colorTheme.textPrimary,
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
                                            color: colorTheme.textSecondary,
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
                                        color: colorTheme.textPrimary,
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
                        error: (error, stack) => Text('${l.error}: $error'),
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
                  ? context.colors.error
                  : context.colors.subtleCardColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isWarning
                  ? context.colors.error
                  : context.colors.textSecondary,
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
                    color: context.colors.textSecondary,
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
                              ? context.colors.error
                              : context.colors.textPrimary,
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
                          color: context.colors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          warningText,
                          style: TextStyle(
                            color: context.colors.error,
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
                        color: context.colors.textMuted,
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
        backgroundColor: colorTheme.cardColor,
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
        clearDescription: result.isEmpty,
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
    final colorTheme = ref.read(currentColorThemeProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorTheme.cardColor,
        title: Text(
          l.deleteDebt,
          style: TextStyle(color: colorTheme.textPrimary),
        ),
        content: Text(
          l.deleteDebtConfirm,
          style: TextStyle(color: colorTheme.textSecondary),
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
              style: TextStyle(color: colorTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      Navigator.pop(context);
      final controller = ref.read(debtControllerProvider);
      await controller.deleteDebt(debt.id);
    }
  }

  Future<void> _recordPayment() async {
    final amountText = _paymentController.text.trim();
    if (amountText.isEmpty) {
      // Tüm kalan tutarı öde
      _paymentController.text = amountToInputText(widget.debt.remainingAmount);
    }

    final amount = parseAmount(_paymentController.text);
    if (amount == null) return;

    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final colors = context.colors;

    // Kalan tutardan fazlası ödenemez
    if (amount > widget.debt.remainingAmount + 0.001) {
      _paymentController.text = amountToInputText(widget.debt.remainingAmount);
      return;
    }

    setState(() => _isLoading = true);

    var success = false;
    try {
      success = await ref
          .read(debtControllerProvider)
          .recordPayment(debtId: widget.debt.id, amount: amount);
    } catch (e) {
      debugPrint('Ödeme kaydetme hatası: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? l.paymentRecorded : l.errorOccurred),
        backgroundColor: success ? colors.success : colors.error,
      ),
    );
    if (success) Navigator.pop(context);
  }

  Future<void> _markAsCompleted() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final colors = context.colors;

    setState(() => _isLoading = true);

    var success = false;
    try {
      success = await ref
          .read(debtControllerProvider)
          .markAsCompleted(widget.debt.id);
    } catch (e) {
      debugPrint('Borç tamamlama hatası: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? l.debtUpdated : l.errorOccurred),
        backgroundColor: success ? colors.success : colors.error,
      ),
    );
    if (success) Navigator.pop(context);
  }
}
