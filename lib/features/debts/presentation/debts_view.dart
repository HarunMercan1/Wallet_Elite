// lib/features/debts/presentation/debts_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../wallet/data/debt_provider.dart';
import '../../wallet/models/debt_model.dart';
import 'add_debt_sheet.dart';
import 'debt_detail_sheet.dart';

class DebtsView extends ConsumerWidget {
  const DebtsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final filteredDebts = ref.watch(filteredDebtsProvider);
    final filterType = ref.watch(debtFilterTypeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(l.debtTracking),
        backgroundColor: colorTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Yeni kayıt ekle butonu
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: l.addDebt,
            onPressed: () => _showAddDebtSheet(context),
          ),
          // Geçmiş (tamamlananlar) butonu
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l.history,
            onPressed: () =>
                _showHistorySheet(context, ref, l, isDark, colorTheme),
          ),
        ],
      ),
      body: Column(
        children: [
          // Özet kartı
          _buildSummaryCard(context, ref, colorTheme, l, isDark),

          // Filtre butonları
          _buildFilterButtons(context, ref, filterType, colorTheme, l, isDark),

          // Borç listesi
          Expanded(
            child: filteredDebts.when(
              data: (debts) => debts.isEmpty
                  ? _buildEmptyState(context, l, isDark, colorTheme)
                  : _buildDebtsList(context, ref, debts, l, isDark, colorTheme),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l.error}: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    WidgetRef ref,
    ColorTheme colorTheme,
    AppLocalizations l,
    bool isDark,
  ) {
    final totalLent = ref.watch(totalLentProvider);
    final totalBorrowed = ref.watch(totalBorrowedProvider);
    final peopleCount = ref.watch(debtPeopleCountProvider);
    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: '₺',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorTheme.primary, colorTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorTheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Toplam Alacak
              Expanded(
                child: _buildSummaryItem(
                  title: l.totalLent,
                  value: totalLent.when(
                    data: (v) => currencyFormat.format(v),
                    loading: () => '...',
                    error: (_, __) => '₺0.00',
                  ),
                  icon: Icons.arrow_upward,
                  color: Colors.green.shade300,
                ),
              ),
              Container(height: 50, width: 1, color: Colors.white24),
              // Toplam Borç
              Expanded(
                child: _buildSummaryItem(
                  title: l.totalBorrowed,
                  value: totalBorrowed.when(
                    data: (v) => currencyFormat.format(v),
                    loading: () => '...',
                    error: (_, __) => '₺0.00',
                  ),
                  icon: Icons.arrow_downward,
                  color: Colors.red.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Net durum ve kişi sayısı
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Net durum
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Builder(
                      builder: (context) {
                        final lent = totalLent.valueOrNull ?? 0;
                        final borrowed = totalBorrowed.valueOrNull ?? 0;
                        final net = lent - borrowed;
                        final isPositive = net >= 0;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: isPositive
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${isPositive ? '+' : ''}${currencyFormat.format(net)}',
                              style: TextStyle(
                                color: isPositive
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Kişi sayısı
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      peopleCount.when(
                        data: (count) => l.people(count),
                        loading: () => '...',
                        error: (_, __) => l.people(0),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButtons(
    BuildContext context,
    WidgetRef ref,
    String filterType,
    ColorTheme colorTheme,
    AppLocalizations l,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            label: l.all,
            isSelected: filterType == 'all',
            onTap: () =>
                ref.read(debtFilterTypeProvider.notifier).state = 'all',
            colorTheme: colorTheme,
          ),
          _buildFilterChip(
            label: l.myLends,
            isSelected: filterType == 'lend',
            onTap: () =>
                ref.read(debtFilterTypeProvider.notifier).state = 'lend',
            colorTheme: colorTheme,
          ),
          _buildFilterChip(
            label: l.myDebts,
            isSelected: filterType == 'borrow',
            onTap: () =>
                ref.read(debtFilterTypeProvider.notifier).state = 'borrow',
            colorTheme: colorTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorTheme colorTheme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : colorTheme.primary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
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
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            l.noDebts,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddDebtSheet(context),
            icon: const Icon(Icons.add),
            label: Text(l.addDebt),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList(
    BuildContext context,
    WidgetRef ref,
    List<DebtModel> debts,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        return _buildDebtCard(context, ref, debt, l, isDark, colorTheme);
      },
    );
  }

  Widget _buildDebtCard(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: '₺',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat(
      'dd MMM yyyy',
      Localizations.localeOf(context).toString(),
    );

    final isLend = debt.type == 'lend';
    final isOverdue =
        debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now()) &&
        !debt.isCompleted;
    final daysRemaining = debt.dueDate != null
        ? debt.dueDate!.difference(DateTime.now()).inDays
        : null;

    // İlerleme yüzdesi
    final progress = debt.amount > 0
        ? (debt.amount - debt.remainingAmount) / debt.amount
        : 0.0;

    return GestureDetector(
      onTap: () => _showDebtDetail(context, debt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isOverdue
              ? Border.all(color: Colors.red.shade300, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tip ikonu
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isLend ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLend ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isLend ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Kişi adı ve tip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.personName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          decoration: debt.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        isLend ? l.lend : l.borrow,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLend ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tutar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(debt.remainingAmount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLend ? Colors.green : Colors.red,
                        decoration: debt.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (debt.remainingAmount != debt.amount)
                      Text(
                        '/ ${currencyFormat.format(debt.amount)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // İlerleme çubuğu
            if (!debt.isCompleted && progress > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? Colors.white12
                      : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLend ? Colors.green : Colors.red,
                  ),
                  minHeight: 6,
                ),
              ),
            ],

            // Vade bilgisi
            if (debt.dueDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 14,
                    color: isOverdue
                        ? Colors.red
                        : (isDark ? Colors.white54 : Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(debt.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue
                          ? Colors.red
                          : (isDark ? Colors.white54 : Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!debt.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? Colors.red.withValues(alpha: 0.1)
                            : (daysRemaining != null && daysRemaining <= 7
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOverdue
                            ? l.overdue
                            : l.daysRemaining(daysRemaining ?? 0),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isOverdue
                              ? Colors.red
                              : (daysRemaining != null && daysRemaining <= 7
                                    ? Colors.orange
                                    : Colors.green),
                        ),
                      ),
                    ),
                ],
              ),
            ],

            // Tamamlandı badge
            if (debt.isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l.markAsCompleted,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddDebtSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddDebtSheet(),
    );
  }

  void _showDebtDetail(BuildContext context, DebtModel debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DebtDetailSheet(debt: debt),
    );
  }

  void _showHistorySheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final completedDebts =
        ref
            .read(debtsProvider)
            .valueOrNull
            ?.where((d) => d.isCompleted)
            .toList() ??
        [];
    final currencyFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: '₺',
      decimalDigits: 2,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.history, color: colorTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l.completedDebts,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${completedDebts.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.grey[200],
            ),
            // List
            Expanded(
              child: completedDebts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: isDark ? Colors.white24 : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.noCompletedDebts,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white54 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: completedDebts.length,
                      itemBuilder: (context, index) {
                        final debt = completedDebts[index];
                        final isLend = debt.type == 'lend';
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showDebtDetail(context, debt);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isLend ? Colors.green : Colors.red)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: isLend ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debt.personName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isLend ? l.lent : l.borrowed,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isLend
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(debt.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isLend ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
