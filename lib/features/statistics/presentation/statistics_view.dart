// lib/features/statistics/presentation/statistics_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/transaction_model.dart';
import '../../wallet/models/category_model.dart';
import '../../../core/theme/color_theme_provider.dart';
import 'category_analysis_view.dart';
import 'trend_detail_view.dart';
import 'date_range_picker_view.dart';
import 'month_comparison_view.dart';

class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  String _selectedPeriod = 'thisMonth';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String? _customPeriodLabel;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      body: SafeArea(
        child: transactions.when(
          data: (List<TransactionModel> txList) {
            Map<String, CategoryModel> categoryMap = {};
            if (categories.hasValue) {
              for (var cat in categories.value!) {
                categoryMap[cat.id] = cat;
              }
            }

            // Filter by period
            final filteredTx = _filterByPeriod(txList, _selectedPeriod);

            // Calculate statistics
            double totalIncome = 0;
            double totalExpense = 0;
            int incomeCount = 0;
            int expenseCount = 0;
            TransactionModel? biggestIncome;
            TransactionModel? biggestExpense;
            Map<String, double> categoryExpenses = {};

            for (final tx in filteredTx) {
              if (tx.type == 'income') {
                totalIncome += tx.amount;
                incomeCount++;
                if (biggestIncome == null || tx.amount > biggestIncome.amount) {
                  biggestIncome = tx;
                }
              } else {
                totalExpense += tx.amount;
                expenseCount++;
                if (biggestExpense == null ||
                    tx.amount > biggestExpense.amount) {
                  biggestExpense = tx;
                }
                // Accumulate category expenses
                if (tx.categoryId != null) {
                  categoryExpenses[tx.categoryId!] =
                      (categoryExpenses[tx.categoryId!] ?? 0) + tx.amount;
                }
              }
            }

            final balance = totalIncome - totalExpense;
            final savingsRate = totalIncome > 0
                ? ((totalIncome - totalExpense) / totalIncome * 100)
                : 0.0;
            final daysInPeriod = _getDaysInPeriod(_selectedPeriod);
            final avgDailySpending = daysInPeriod > 0
                ? totalExpense / daysInPeriod
                : 0.0;

            // Sort categories by expense amount
            final sortedCategories = categoryExpenses.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.statistics,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      _buildPeriodSelector(l, isDark, colorTheme),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Main Balance Card
                  _buildMainBalanceCard(
                    context,
                    totalIncome,
                    totalExpense,
                    balance,
                    savingsRate,
                    l,
                    isDark,
                    colorTheme,
                  ),

                  const SizedBox(height: 20),

                  // Quick Stats Row 1: Daily spending & Transaction Summary
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildQuickStatCard(
                            l.averageDailySpending,
                            '₺${NumberFormat('#,##0.00', 'tr_TR').format(avgDailySpending)}',
                            Icons.calendar_today,
                            colorTheme.primary,
                            isDark,
                            colorTheme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTransactionSummaryCard(
                            incomeCount + expenseCount,
                            incomeCount,
                            expenseCount,
                            l,
                            isDark,
                            colorTheme,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quick Stats Row 2: Top Category & Financial Score
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildTopCategoryCard(
                            sortedCategories.isNotEmpty
                                ? categoryMap[sortedCategories.first.key]
                                : null,
                            sortedCategories.isNotEmpty
                                ? sortedCategories.first.value
                                : 0,
                            totalExpense,
                            l,
                            isDark,
                            colorTheme,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryAnalysisView(
                                    transactions: filteredTx,
                                    periodLabel: _getPeriodLabel(
                                      _selectedPeriod,
                                      l,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFinancialScoreCard(
                            savingsRate,
                            l,
                            isDark,
                            colorTheme,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // YENİ: Kategori Pasta Grafiği
                  _buildCategoryPieChart(
                    categoryExpenses,
                    categoryMap,
                    totalExpense,
                    l,
                    isDark,
                    colorTheme,
                    filteredTx,
                  ),

                  const SizedBox(height: 16),

                  // YENİ: Haftalık Trend Çizgi Grafiği
                  _buildWeeklyLineChart(filteredTx, l, isDark, colorTheme),

                  const SizedBox(height: 16),

                  // YENİ: Geçen Ay Karşılaştırma Kartı
                  Builder(
                    builder: (context) {
                      final lastMonthStats = _calculateLastMonthStats(txList);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonthComparisonView(
                                allTransactions: txList,
                                categoryMap: categoryMap,
                              ),
                            ),
                          );
                        },
                        child: _buildComparisonCard(
                          totalExpense,
                          lastMonthStats['expense']!,
                          totalIncome,
                          lastMonthStats['income']!,
                          l,
                          isDark,
                          colorTheme,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Gelir vs Gider Basit Bar
                  _buildIncomeVsExpenseChart(
                    totalIncome,
                    totalExpense,
                    l,
                    isDark,
                    colorTheme,
                  ),

                  const SizedBox(height: 24),

                  // Top Categories Section
                  if (sortedCategories.isNotEmpty) ...[
                    Text(
                      l.topCategories,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTopCategories(
                      sortedCategories.take(5).toList(),
                      categoryMap,
                      totalExpense,
                      l,
                      isDark,
                      colorTheme,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Biggest Transactions
                  if (biggestIncome != null || biggestExpense != null) ...[
                    Row(
                      children: [
                        if (biggestIncome != null)
                          Expanded(
                            child: _buildBiggestTransaction(
                              l.biggestIncome,
                              biggestIncome,
                              categoryMap[biggestIncome.categoryId],
                              colorTheme.success,
                              l,
                              isDark,
                              colorTheme,
                            ),
                          ),
                        if (biggestIncome != null && biggestExpense != null)
                          const SizedBox(width: 12),
                        if (biggestExpense != null)
                          Expanded(
                            child: _buildBiggestTransaction(
                              l.biggestExpense,
                              biggestExpense,
                              categoryMap[biggestExpense.categoryId],
                              colorTheme.error,
                              l,
                              isDark,
                              colorTheme,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Weekly Spending Trend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.spendingTrend,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrendDetailView(
                                transactions: filteredTx,
                                periodLabel: _getPeriodLabel(
                                  _selectedPeriod,
                                  l,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              l.viewDetails,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: colorTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrendDetailView(
                            transactions: filteredTx,
                            periodLabel: _getPeriodLabel(_selectedPeriod, l),
                          ),
                        ),
                      );
                    },
                    child: _buildWeeklyTrend(filteredTx, l, isDark, colorTheme),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l.error}: $e')),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'customRange') {
          final result = await Navigator.push<DateRangeResult>(
            context,
            MaterialPageRoute(
              builder: (context) => DateRangePickerView(
                initialStartDate: _customStartDate,
                initialEndDate: _customEndDate,
              ),
            ),
          );
          if (result != null) {
            setState(() {
              _selectedPeriod = 'customRange';
              _customStartDate = result.startDate;
              _customEndDate = result.endDate;
              _customPeriodLabel = result.label;
            });
          }
        } else {
          setState(() {
            _selectedPeriod = value;
            _customStartDate = null;
            _customEndDate = null;
            _customPeriodLabel = null;
          });
        }
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month, size: 16, color: colorTheme.primary),
            const SizedBox(width: 6),
            Text(
              _selectedPeriod == 'customRange'
                  ? (_customPeriodLabel ?? l.customDateRange)
                  : _getPeriodLabel(_selectedPeriod, l),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem('last7Days', l.last7Days, isDark, colorTheme),
        _buildMenuItem('thisMonth', l.thisMonth, isDark, colorTheme),
        _buildMenuItem('last30Days', l.last30Days, isDark, colorTheme),
        _buildMenuItem('thisYear', l.thisYear, isDark, colorTheme),
        _buildMenuItem('allTime', l.allTime, isDark, colorTheme),
        const PopupMenuDivider(),
        _buildMenuItem('customRange', l.customDateRange, isDark, colorTheme),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    String label,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (_selectedPeriod == value)
            Icon(Icons.check, size: 16, color: colorTheme.primary)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: _selectedPeriod == value
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBalanceCard(
    BuildContext context,
    double income,
    double expense,
    double balance,
    double savingsRate,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final isPositive = balance >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorTheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.balance,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(balance)}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      savingsRate >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: colorTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${savingsRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: colorTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceStat(
                  l.totalIncome,
                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(income)}',
                  Icons.arrow_downward,
                  colorTheme.success,
                  isDark,
                  colorTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceStat(
                  l.totalExpense,
                  '₺${NumberFormat('#,##0.00', 'tr_TR').format(expense)}',
                  Icons.arrow_upward,
                  colorTheme.error,
                  isDark,
                  colorTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummaryCard(
    int total,
    int incomeCount,
    int expenseCount,
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long,
              color: colorTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.transactionSummary,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            '$total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.arrow_downward, color: colorTheme.success, size: 12),
              Text(
                '$incomeCount',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_upward, color: colorTheme.error, size: 12),
              Text(
                '$expenseCount',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoryCard(
    CategoryModel? category,
    double amount,
    double totalExpense,
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme, {
    VoidCallback? onTap,
  }) {
    final percent = totalExpense > 0 ? (amount / totalExpense * 100) : 0.0;
    final categoryName = _getCategoryName(category, l) ?? l.noExpenseData;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category?.icon),
                    color: colorTheme.error,
                    size: 18,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l.topSpendingCategory,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (amount > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  color: colorTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialScoreCard(
    double savingsRate,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    // Calculate score (0-100) based on savings rate
    final score = (savingsRate.clamp(-50, 100) + 50) / 1.5;
    String scoreLabel;
    Color scoreColor;

    if (score >= 80) {
      scoreLabel = l.excellent;
      scoreColor = colorTheme.success;
    } else if (score >= 60) {
      scoreLabel = l.good;
      scoreColor = Colors.teal;
    } else if (score >= 40) {
      scoreLabel = l.average;
      scoreColor = Colors.orange;
    } else if (score >= 20) {
      scoreLabel = l.needsImprovement;
      scoreColor = Colors.deepOrange;
    } else {
      scoreLabel = l.poor;
      scoreColor = colorTheme.error;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.speed, color: scoreColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            l.financialScore,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            '${score.toInt()}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              scoreLabel,
              style: TextStyle(
                fontSize: 10,
                color: scoreColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeVsExpenseChart(
    double income,
    double expense,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final total = income + expense;
    final incomePercent = total > 0 ? income / total : 0.5;
    final expensePercent = total > 0 ? expense / total : 0.5;

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
          const SizedBox(height: 16),
          // Horizontal Bar Chart
          Row(
            children: [
              Expanded(
                flex: (incomePercent * 100).toInt().clamp(1, 99),
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorTheme.success,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: (expensePercent * 100).toInt().clamp(1, 99),
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorTheme.error,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorTheme.success,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l.income,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    ' (${(incomePercent * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorTheme.error,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l.expense,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    ' (${(expensePercent * 100).toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(
    List<MapEntry<String, double>> categories,
    Map<String, CategoryModel> categoryMap,
    double totalExpense,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: categories.map((entry) {
          final category = categoryMap[entry.key];
          final percent = totalExpense > 0 ? entry.value / totalExpense : 0.0;
          final categoryName = _getCategoryName(category, l) ?? l.cat_other;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category?.icon),
                    color: colorTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '₺${NumberFormat('#,##0.00', 'tr_TR').format(entry.value)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: isDark
                              ? Colors.white12
                              : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorTheme.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBiggestTransaction(
    String title,
    TransactionModel tx,
    CategoryModel? category,
    Color color,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 8),
          Text(
            '₺${NumberFormat('#,##0.00', 'tr_TR').format(tx.amount)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getCategoryName(category, l) ?? tx.description ?? '',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend(
    List<TransactionModel> txList,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    // Group expenses by day of week for last 7 days
    final now = DateTime.now();
    final Map<int, double> dailyExpenses = {};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dailyExpenses[date.weekday] = 0;
    }

    for (final tx in txList) {
      if (tx.type == 'expense') {
        final daysDiff = now.difference(tx.date).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          final weekday = tx.date.weekday;
          dailyExpenses[weekday] = (dailyExpenses[weekday] ?? 0) + tx.amount;
        }
      }
    }

    final maxExpense = dailyExpenses.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    final dayNames = [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final weekday = (index + 1); // Monday = 1, Sunday = 7
          final expense = dailyExpenses[weekday] ?? 0;
          final heightPercent = maxExpense > 0 ? expense / maxExpense : 0.0;
          final barHeight = (heightPercent * 120).clamp(4.0, 120.0);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorTheme.primary.withOpacity(0.7),
                      colorTheme.primary,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayNames[index],
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<TransactionModel> _filterByPeriod(
    List<TransactionModel> txList,
    String period,
  ) {
    final now = DateTime.now();

    switch (period) {
      case 'last7Days':
        final startDate = now.subtract(const Duration(days: 7));
        return txList.where((tx) => tx.date.isAfter(startDate)).toList();
      case 'thisMonth':
        return txList
            .where(
              (tx) => tx.date.month == now.month && tx.date.year == now.year,
            )
            .toList();
      case 'last30Days':
        final startDate = now.subtract(const Duration(days: 30));
        return txList.where((tx) => tx.date.isAfter(startDate)).toList();
      case 'thisYear':
        return txList.where((tx) => tx.date.year == now.year).toList();
      case 'customRange':
        if (_customStartDate != null && _customEndDate != null) {
          return txList
              .where(
                (tx) =>
                    tx.date.isAfter(
                      _customStartDate!.subtract(const Duration(days: 1)),
                    ) &&
                    tx.date.isBefore(
                      _customEndDate!.add(const Duration(days: 1)),
                    ),
              )
              .toList();
        }
        return txList;
      case 'allTime':
      default:
        return txList;
    }
  }

  int _getDaysInPeriod(String period) {
    switch (period) {
      case 'last7Days':
        return 7;
      case 'thisMonth':
        return DateTime.now().day;
      case 'last30Days':
        return 30;
      case 'thisYear':
        final now = DateTime.now();
        return now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      case 'allTime':
      default:
        return 365; // Rough estimate
    }
  }

  String _getPeriodLabel(String period, AppLocalizations l) {
    switch (period) {
      case 'last7Days':
        return l.last7Days;
      case 'thisMonth':
        return l.thisMonth;
      case 'last30Days':
        return l.last30Days;
      case 'thisYear':
        return l.thisYear;
      case 'allTime':
        return l.allTime;
      default:
        return l.thisMonth;
    }
  }

  String? _getCategoryName(CategoryModel? category, AppLocalizations l) {
    if (category == null) return null;

    if (category.translationKey != null) {
      switch (category.translationKey) {
        case 'cat_food':
          return l.cat_food;
        case 'cat_transport':
          return l.cat_transport;
        case 'cat_shopping':
          return l.cat_shopping;
        case 'cat_entertainment':
          return l.cat_entertainment;
        case 'cat_bills':
          return l.cat_bills;
        case 'cat_health':
          return l.cat_health;
        case 'cat_education':
          return l.cat_education;
        case 'cat_rent':
          return l.cat_rent;
        case 'cat_taxes':
          return l.cat_taxes;
        case 'cat_salary':
          return l.cat_salary;
        case 'cat_freelance':
          return l.cat_freelance;
        case 'cat_investment':
          return l.cat_investment;
        case 'cat_gift':
          return l.cat_gift;
        case 'cat_pets':
          return l.cat_pets;
        case 'cat_groceries':
          return l.cat_groceries;
        case 'cat_electronics':
          return l.cat_electronics;
        case 'cat_charity':
          return l.cat_charity;
        case 'cat_insurance':
          return l.cat_insurance;
        case 'cat_gym':
          return l.cat_gym;
        case 'cat_travel':
          return l.cat_travel;
        case 'cat_other':
        case 'cat_others':
          return l.cat_other;
      }
    }

    // Fallback Check
    final name = category.name.toLowerCase();
    if (name.contains('food') || name.contains('yemek')) return l.cat_food;
    if (name.contains('pet') || name.contains('evcil')) return l.cat_pets;
    if (name.contains('grocer') || name.contains('market')) {
      return l.cat_groceries;
    }
    if (name.contains('electronic')) return l.cat_electronics;
    if (name.contains('charity') || name.contains('bağış')) {
      return l.cat_charity;
    }
    if (name.contains('insuranc') || name.contains('sigorta')) {
      return l.cat_insurance;
    }
    if (name.contains('gym') || name.contains('spor')) return l.cat_gym;
    if (name.contains('health')) return l.cat_health;
    if (name.contains('gift')) return l.cat_gift;
    if (name.contains('bill')) return l.cat_bills;
    if (name.contains('educat')) return l.cat_education;
    if (name.contains('entert')) return l.cat_entertainment;
    if (name.contains('shop')) return l.cat_shopping;
    if (name.contains('transport')) return l.cat_transport;
    if (name.contains('travel') || name.contains('seyahat')) {
      return l.cat_travel;
    }

    return category.name;
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.wallet;
      case 'laptop':
        return Icons.laptop;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'checkroom':
        return Icons.checkroom;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  // ============ YENİ: Pasta Grafik Widget ============
  Widget _buildCategoryPieChart(
    Map<String, double> categoryExpenses,
    Map<String, CategoryModel> categoryMap,
    double totalExpense,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
    List<TransactionModel> filteredTx,
  ) {
    if (categoryExpenses.isEmpty) {
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

    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).toList();

    final colors = [
      colorTheme.primary,
      colorTheme.success,
      AppColors.warning,
      colorTheme.error,
      Colors.purple,
    ];

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
            l.categoryDistribution,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: topCategories.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cat = entry.value;
                        final percent = (cat.value / totalExpense * 100);
                        return PieChartSectionData(
                          color: colors[idx % colors.length],
                          value: cat.value,
                          title: '${percent.toStringAsFixed(0)}%',
                          radius: 35,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: topCategories.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cat = entry.value;
                    final categoryModel = categoryMap[cat.key];
                    final name = _getCategoryName(categoryModel, l) ?? l.other;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[idx % colors.length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 80,
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ YENİ: Geçen Ay Karşılaştırma Hesaplama ============
  Map<String, double> _calculateLastMonthStats(List<TransactionModel> allTx) {
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    double lastMonthIncome = 0;
    double lastMonthExpense = 0;

    for (final tx in allTx) {
      if (tx.date.isAfter(lastMonthStart.subtract(const Duration(days: 1))) &&
          tx.date.isBefore(lastMonthEnd.add(const Duration(days: 1)))) {
        if (tx.type == 'income') {
          lastMonthIncome += tx.amount;
        } else {
          lastMonthExpense += tx.amount;
        }
      }
    }

    return {'income': lastMonthIncome, 'expense': lastMonthExpense};
  }

  // ============ YENİ: Karşılaştırma Kartı ============
  Widget _buildComparisonCard(
    double thisMonthExpense,
    double lastMonthExpense,
    double thisMonthIncome,
    double lastMonthIncome,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final expenseChange = lastMonthExpense > 0
        ? ((thisMonthExpense - lastMonthExpense) / lastMonthExpense * 100)
        : 0.0;
    final incomeChange = lastMonthIncome > 0
        ? ((thisMonthIncome - lastMonthIncome) / lastMonthIncome * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.comparedToLastMonth,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildComparisonItem(
                  l.expense,
                  expenseChange,
                  expenseChange > 0, // artış kötü
                  isDark,
                  colorTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildComparisonItem(
                  l.income,
                  incomeChange,
                  incomeChange < 0, // azalış kötü
                  isDark,
                  colorTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(
    String label,
    double changePercent,
    bool isNegative,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final color = isNegative ? colorTheme.error : colorTheme.success;
    final icon = changePercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ YENİ: Haftalık Trend Line Chart ============
  Widget _buildWeeklyLineChart(
    List<TransactionModel> txList,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      double dayExpense = 0;
      for (final tx in txList) {
        if (tx.type == 'expense' &&
            tx.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
            tx.date.isBefore(dayEnd)) {
          dayExpense += tx.amount;
        }
      }

      spots.add(FlSpot((6 - i).toDouble(), dayExpense));
      labels.add(DateFormat('E', 'tr').format(day).substring(0, 2));
    }

    final maxY = spots.map((s) => s.y).reduce(math.max);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrendDetailView(
              transactions: txList,
              periodLabel: _getPeriodLabel(_selectedPeriod, l),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.last7DaysSpending,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
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
                          final idx = value.toInt();
                          if (idx >= 0 && idx < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[idx],
                                style: TextStyle(
                                  fontSize: 10,
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
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: maxY > 0 ? maxY * 1.2 : 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: colorTheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: colorTheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorTheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
