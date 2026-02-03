// lib/features/budgets/presentation/budgets_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../data/budget_provider.dart';
import '../models/budget_model.dart';
import 'add_budget_sheet.dart';

class BudgetsView extends ConsumerWidget {
  const BudgetsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final budgetsAsync = ref.watch(budgetsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l.budgets),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) {
            return _buildEmptyState(context, l, isDark, colorTheme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(budgetsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildBudgetCard(
                    context,
                    ref,
                    budget,
                    l,
                    isDark,
                    colorTheme,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(l.error, style: TextStyle(color: Colors.red[300])),
            ],
          ),
        ),
      ),
      floatingActionButton: budgetsAsync.maybeWhen(
        data: (budgets) => budgets.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _showAddSheet(context),
                backgroundColor: colorTheme.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: Text(l.addBudget),
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
            Icons.pie_chart_outline,
            size: 80,
            color: colorTheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            l.noBudgets,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.addBudgetHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSheet(context),
            icon: const Icon(Icons.add),
            label: Text(l.addBudget),
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

  Widget _buildBudgetCard(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₺', decimalDigits: 2);
    final progressColor = budget.isExceeded
        ? Colors.red
        : budget.isWarning
        ? Colors.orange
        : colorTheme.success;

    return GestureDetector(
      onTap: () => _showAddSheet(context, budget: budget),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: budget.isExceeded
              ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
              : null,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Kategori/Genel ikon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    budget.categoryId != null
                        ? Icons.category
                        : Icons.account_balance_wallet,
                    color: progressColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (budget.categoryName != null)
                        Text(
                          budget.categoryName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                // Aktif/Pasif Switch
                Switch(
                  value: budget.isActive,
                  onChanged: (value) {
                    ref
                        .read(budgetControllerProvider.notifier)
                        .toggleActive(budget.id, value);
                  },
                  activeColor: colorTheme.primary,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(budget.spent ?? 0),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      currencyFormat.format(budget.amount),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (budget.usagePercent / 100).clamp(0.0, 1.0),
                    backgroundColor: progressColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(progressColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${budget.usagePercent.toStringAsFixed(0)}% ${l.used}',
                      style: TextStyle(
                        fontSize: 12,
                        color: progressColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${l.remaining}: ${currencyFormat.format(budget.remaining.abs())}${budget.isExceeded ? ' (${l.exceeded})' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Footer - Periyod bilgisi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getPeriodLabel(budget.period, l),
                style: TextStyle(
                  fontSize: 12,
                  color: colorTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel(BudgetPeriod period, AppLocalizations l) {
    switch (period) {
      case BudgetPeriod.weekly:
        return l.weekly;
      case BudgetPeriod.monthly:
        return l.monthly;
      case BudgetPeriod.yearly:
        return l.yearly;
    }
  }

  void _showAddSheet(BuildContext context, {BudgetModel? budget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddBudgetSheet(budget: budget),
    );
  }
}
