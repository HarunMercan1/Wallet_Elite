// lib/features/recurring/presentation/recurring_transactions_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../data/recurring_provider.dart';
import '../models/recurring_transaction_model.dart';
import 'add_recurring_sheet.dart';

class RecurringTransactionsView extends ConsumerWidget {
  const RecurringTransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final filter = ref.watch(recurringFilterProvider);
    final transactionsAsync = ref.watch(filteredRecurringTransactionsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l.recurringTransactions),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Filtre butonu
          PopupMenuButton<RecurringFilter>(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onSelected: (value) {
              ref.read(recurringFilterProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: RecurringFilter.all,
                child: Row(
                  children: [
                    if (filter == RecurringFilter.all)
                      Icon(Icons.check, color: colorTheme.primary, size: 18),
                    if (filter != RecurringFilter.all)
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(l.all),
                  ],
                ),
              ),
              PopupMenuItem(
                value: RecurringFilter.active,
                child: Row(
                  children: [
                    if (filter == RecurringFilter.active)
                      Icon(Icons.check, color: colorTheme.primary, size: 18),
                    if (filter != RecurringFilter.active)
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(l.active),
                  ],
                ),
              ),
              PopupMenuItem(
                value: RecurringFilter.inactive,
                child: Row(
                  children: [
                    if (filter == RecurringFilter.inactive)
                      Icon(Icons.check, color: colorTheme.primary, size: 18),
                    if (filter != RecurringFilter.inactive)
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(l.inactive),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return _buildEmptyState(context, l, isDark, colorTheme);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final recurring = transactions[index];
              return _buildRecurringCard(
                context,
                ref,
                recurring,
                l,
                isDark,
                colorTheme,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('${l.error}: $error')),
      ),
      floatingActionButton: transactionsAsync.maybeWhen(
        data: (transactions) => transactions.isEmpty
            ? null
            : FloatingActionButton(
                onPressed: () => _showAddSheet(context),
                backgroundColor: colorTheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l.noRecurringTransactions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.addRecurringTransactionHint,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSheet(context),
            icon: const Icon(Icons.add),
            label: Text(l.addRecurringTransaction),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    WidgetRef ref,
    RecurringTransactionModel recurring,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).languageCode,
      symbol: '₺',
      decimalDigits: 2,
    );

    final isIncome = recurring.isIncome;
    final amountColor = isIncome ? colorTheme.income : colorTheme.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.cardDark : colorTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: !recurring.isActive
            ? Border.all(color: Colors.grey.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditSheet(context, recurring),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // İkon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: amountColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Başlık ve açıklama
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  recurring.description ??
                                      (isIncome ? l.income : l.expense),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: recurring.isActive
                                        ? (isDark
                                              ? Colors.white
                                              : Colors.black87)
                                        : Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!recurring.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l.inactive,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFrequencyText(recurring.frequency, l),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tutar
                    Text(
                      '${isIncome ? '+' : '-'}${currencyFormat.format(recurring.amount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: recurring.isActive ? amountColor : Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Alt bilgi
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l.nextExecution}: ${DateFormat('dd MMM yyyy').format(recurring.nextExecutionDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),

                    // Aktif/Pasif toggle
                    Switch(
                      value: recurring.isActive,
                      onChanged: (value) {
                        ref
                            .read(recurringControllerProvider.notifier)
                            .toggleActive(recurring.id, value);
                      },
                      activeColor: colorTheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFrequencyText(RecurringFrequency frequency, AppLocalizations l) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return l.daily;
      case RecurringFrequency.weekly:
        return l.weekly;
      case RecurringFrequency.monthly:
        return l.monthly;
      case RecurringFrequency.yearly:
        return l.yearly;
    }
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddRecurringSheet(),
    );
  }

  void _showEditSheet(
    BuildContext context,
    RecurringTransactionModel recurring,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddRecurringSheet(recurring: recurring),
    );
  }
}
