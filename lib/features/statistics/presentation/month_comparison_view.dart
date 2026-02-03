// lib/features/statistics/presentation/month_comparison_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../wallet/models/transaction_model.dart';
import '../../wallet/models/category_model.dart';

/// Ay karşılaştırma detay sayfası
class MonthComparisonView extends ConsumerWidget {
  final List<TransactionModel> allTransactions;
  final Map<String, CategoryModel> categoryMap;

  const MonthComparisonView({
    super.key,
    required this.allTransactions,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);

    // Bu ay ve geçen ay verilerini hesapla
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    // Bu ay işlemleri
    final thisMonthTx = allTransactions
        .where(
          (tx) =>
              tx.date.isAfter(thisMonthStart.subtract(const Duration(days: 1))),
        )
        .toList();

    // Geçen ay işlemleri
    final lastMonthTx = allTransactions
        .where(
          (tx) =>
              tx.date.isAfter(
                lastMonthStart.subtract(const Duration(days: 1)),
              ) &&
              tx.date.isBefore(lastMonthEnd.add(const Duration(days: 1))),
        )
        .toList();

    // İstatistikleri hesapla
    final thisMonthStats = _calculateStats(thisMonthTx);
    final lastMonthStats = _calculateStats(lastMonthTx);

    return Scaffold(
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l.comparedToLastMonth,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Özet Kart
            _buildSummaryCard(
              thisMonthStats,
              lastMonthStats,
              l,
              isDark,
              colorTheme,
            ),

            const SizedBox(height: 24),

            // Bar Chart Karşılaştırma
            _buildComparisonBarChart(
              thisMonthStats,
              lastMonthStats,
              l,
              isDark,
              colorTheme,
            ),

            const SizedBox(height: 24),

            // Kategori Bazlı Karşılaştırma
            Text(
              l.categoryAnalysis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryComparison(
              thisMonthTx,
              lastMonthTx,
              l,
              isDark,
              colorTheme,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateStats(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;
    int incomeCount = 0;
    int expenseCount = 0;

    for (final tx in transactions) {
      if (tx.type == 'income') {
        income += tx.amount;
        incomeCount++;
      } else {
        expense += tx.amount;
        expenseCount++;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
      'incomeCount': incomeCount.toDouble(),
      'expenseCount': expenseCount.toDouble(),
    };
  }

  Widget _buildSummaryCard(
    Map<String, double> thisMonth,
    Map<String, double> lastMonth,
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    final incomeChange = lastMonth['income']! > 0
        ? ((thisMonth['income']! - lastMonth['income']!) /
              lastMonth['income']! *
              100)
        : 0.0;
    final expenseChange = lastMonth['expense']! > 0
        ? ((thisMonth['expense']! - lastMonth['expense']!) /
              lastMonth['expense']! *
              100)
        : 0.0;
    final savingsChange = thisMonth['balance']! - lastMonth['balance']!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Gelir Karşılaştırma
          _buildComparisonRow(
            l.income,
            thisMonth['income']!,
            lastMonth['income']!,
            incomeChange,
            incomeChange >= 0, // Gelir artışı iyi
            colorTheme,
            isDark,
          ),
          const Divider(height: 24),
          // Gider Karşılaştırma
          _buildComparisonRow(
            l.expense,
            thisMonth['expense']!,
            lastMonth['expense']!,
            expenseChange,
            expenseChange <= 0, // Gider azalışı iyi
            colorTheme,
            isDark,
          ),
          const Divider(height: 24),
          // Tasarruf Karşılaştırma
          _buildComparisonRow(
            l.balance,
            thisMonth['balance']!,
            lastMonth['balance']!,
            savingsChange,
            savingsChange >= 0,
            colorTheme,
            isDark,
            isAmount: true,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    double thisMonth,
    double lastMonth,
    double change,
    bool isPositive,
    dynamic colorTheme,
    bool isDark, {
    bool isAmount = false,
  }) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    final color = isPositive ? colorTheme.success : colorTheme.error;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${formatter.format(thisMonth)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${isAmount ? "" : ""}${isAmount ? (change >= 0 ? "+" : "") : (change >= 0 ? "↑" : "↓")}${isAmount ? formatter.format(change) : "${change.abs().toStringAsFixed(1)}%"}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonBarChart(
    Map<String, double> thisMonth,
    Map<String, double> lastMonth,
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    final maxValue = [
      thisMonth['income']!,
      thisMonth['expense']!,
      lastMonth['income']!,
      lastMonth['expense']!,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.incomeVsExpense,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = [l.income, l.expense];
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  // Gelir
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: lastMonth['income']!,
                        color: colorTheme.success.withOpacity(0.5),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: thisMonth['income']!,
                        color: colorTheme.success,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  // Gider
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: lastMonth['expense']!,
                        color: colorTheme.error.withOpacity(0.5),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: thisMonth['expense']!,
                        color: colorTheme.error,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                l.lastMonth,
                colorTheme.primary.withOpacity(0.5),
                isDark,
              ),
              const SizedBox(width: 24),
              _buildLegendItem(l.thisMonth, colorTheme.primary, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryComparison(
    List<TransactionModel> thisMonthTx,
    List<TransactionModel> lastMonthTx,
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    // Kategori bazlı harcamaları hesapla
    final thisMonthCategories = <String, double>{};
    final lastMonthCategories = <String, double>{};

    for (final tx in thisMonthTx.where((t) => t.type == 'expense')) {
      if (tx.categoryId != null) {
        thisMonthCategories[tx.categoryId!] =
            (thisMonthCategories[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    for (final tx in lastMonthTx.where((t) => t.type == 'expense')) {
      if (tx.categoryId != null) {
        lastMonthCategories[tx.categoryId!] =
            (lastMonthCategories[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    // Tüm kategorileri birleştir
    final allCategories = {
      ...thisMonthCategories.keys,
      ...lastMonthCategories.keys,
    };

    if (allCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            l.noExpenseData,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    // Değişime göre sırala
    final sortedCategories = allCategories.toList()
      ..sort((a, b) {
        final changeA =
            (thisMonthCategories[a] ?? 0) - (lastMonthCategories[a] ?? 0);
        final changeB =
            (thisMonthCategories[b] ?? 0) - (lastMonthCategories[b] ?? 0);
        return changeB.abs().compareTo(changeA.abs());
      });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: sortedCategories.take(5).map((categoryId) {
          final category = categoryMap[categoryId];
          final thisMonthAmount = thisMonthCategories[categoryId] ?? 0;
          final lastMonthAmount = lastMonthCategories[categoryId] ?? 0;
          final change = lastMonthAmount > 0
              ? ((thisMonthAmount - lastMonthAmount) / lastMonthAmount * 100)
              : (thisMonthAmount > 0 ? 100 : 0);
          final isIncrease = change > 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.category,
                    color: colorTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? l.other,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(thisMonthAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isIncrease ? colorTheme.error : colorTheme.success)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isIncrease
                            ? colorTheme.error
                            : colorTheme.success,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${change.abs().toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isIncrease
                              ? colorTheme.error
                              : colorTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
