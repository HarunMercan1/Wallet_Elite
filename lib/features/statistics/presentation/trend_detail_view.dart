import '../../../features/settings/data/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
// lib/features/statistics/presentation/trend_detail_view.dart

import '../../../core/utils/number_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../wallet/models/transaction_model.dart';

class TrendDetailView extends ConsumerStatefulWidget {
  final List<TransactionModel> transactions;
  final String periodLabel;

  /// Seçili dönemden bağımsız tüm işlemler. Grafik (son 7 gün / 4 hafta /
  /// 3 ay) ve ay karşılaştırması kendi zaman aralığını kullandığı için
  /// bunlardan hesaplanır; verilmezse dönem işlemleri kullanılır.
  final List<TransactionModel>? allTransactions;

  /// Verilmezse ayarlardaki para birimi kullanılır
  final String? currencySymbol;

  const TrendDetailView({
    super.key,
    required this.transactions,
    required this.periodLabel,
    this.allTransactions,
    this.currencySymbol,
  });

  @override
  ConsumerState<TrendDetailView> createState() => _TrendDetailViewState();
}

class _TrendDetailViewState extends ConsumerState<TrendDetailView>
    with SingleTickerProviderStateMixin {
  String _selectedTimeframe = 'weekly';
  bool _showExpenses = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _symbol =>
      widget.currencySymbol ??
      CurrencyUtils.getSymbol(ref.watch(currencyProvider));

  List<TransactionModel> get _allTransactions =>
      widget.allTransactions ?? widget.transactions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);

    return Scaffold(
      backgroundColor: colorTheme.background,
      appBar: AppBar(
        title: Text(l.trendDetails),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period indicator
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.periodLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Spacer(),
                // Toggle expenses/income
                _buildToggleButton(l, isDark, colorTheme),
              ],
            ),

            const SizedBox(height: 24),

            // Timeframe selector
            _buildTimeframeSelector(l, isDark, colorTheme),

            const SizedBox(height: 24),

            // Main chart
            _buildMainChart(l, isDark, colorTheme),

            const SizedBox(height: 32),

            // Statistics summary
            _buildStatisticsSummary(l, isDark, colorTheme),

            const SizedBox(height: 32),

            // Spending patterns
            _buildSpendingPatterns(l, isDark, colorTheme),

            const SizedBox(height: 32),

            // Period comparison
            _buildPeriodComparison(l, isDark, colorTheme),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorTheme.subtleCardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _showExpenses = true);
              _animationController.reset();
              _animationController.forward();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _showExpenses ? colorTheme.error : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l.expense,
                style: TextStyle(
                  color: _showExpenses
                      ? Colors.white
                      : colorTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _showExpenses = false);
              _animationController.reset();
              _animationController.forward();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !_showExpenses ? colorTheme.success : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l.income,
                style: TextStyle(
                  color: !_showExpenses
                      ? Colors.white
                      : colorTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector(
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    final timeframes = [
      {'key': 'weekly', 'label': l.weekly},
      {'key': 'monthly', 'label': l.monthly},
      {'key': 'last3Months', 'label': l.last3Months},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorTheme.subtleCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: timeframes.map((tf) {
          final isSelected = _selectedTimeframe == tf['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTimeframe = tf['key']!);
                _animationController.reset();
                _animationController.forward();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tf['label']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? colorTheme.onPrimary
                        : colorTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainChart(AppLocalizations l, bool isDark, dynamic colorTheme) {
    final chartData = _getChartData();
    final maxValue = chartData.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _showExpenses ? l.totalExpense : l.totalIncome,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_symbol${NumberFormat('#,##0.00').format(chartData.values.fold<double>(0, (sum, v) => sum + v))}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _showExpenses ? colorTheme.error : colorTheme.success,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: chartData.entries.map((entry) {
                    final heightPercent = maxValue > 0
                        ? entry.value / maxValue
                        : 0.0;
                    final barHeight = (heightPercent * 140 * _animation.value)
                        .clamp(4.0, 140.0);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (entry.value > 0 && _animation.value > 0.5)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _formatShortAmount(entry.value),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: colorTheme.textSecondary,
                                  ),
                                ),
                              ),
                            // Büyük yazı boyutunda etiketlere yer açmak için
                            // çubuk gerekirse kısalır
                            Flexible(
                              child: Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _showExpenses
                                        ? [
                                            colorTheme.error.withValues(
                                              alpha: 0.6,
                                            ),
                                            colorTheme.error,
                                          ]
                                        : [
                                            colorTheme.success.withValues(
                                              alpha: 0.6,
                                            ),
                                            colorTheme.success,
                                          ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSummary(
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    final transactions = widget.transactions
        .where((tx) => tx.type == (_showExpenses ? 'expense' : 'income'))
        .toList();

    final total = transactions.fold<double>(0, (sum, tx) => sum + tx.amount);
    final avg = transactions.isNotEmpty ? total / transactions.length : 0.0;
    final maxTx = transactions.isNotEmpty
        ? transactions.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;
    final minTx = transactions.isNotEmpty
        ? transactions.reduce((a, b) => a.amount < b.amount ? a : b)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.transactionSummary,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: l.totalTransactions,
                value: '${transactions.length}',
                icon: Icons.receipt_long,
                color: colorTheme.primary,
                isDark: isDark,
                colorTheme: colorTheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: l.averageTransaction,
                value: '$_symbol${NumberFormat('#,##0').format(avg)}',
                icon: Icons.calculate,
                color: colorTheme.warning,
                isDark: isDark,
                colorTheme: colorTheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: _showExpenses ? l.biggestExpense : l.biggestIncome,
                value: maxTx != null
                    ? '$_symbol${NumberFormat('#,##0').format(maxTx.amount)}'
                    : '-',
                icon: Icons.arrow_upward,
                color: _showExpenses ? colorTheme.error : colorTheme.success,
                isDark: isDark,
                colorTheme: colorTheme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: l.lowestAmount,
                value: minTx != null
                    ? '$_symbol${NumberFormat('#,##0').format(minTx.amount)}'
                    : '-',
                icon: Icons.arrow_downward,
                color: colorTheme.info,
                isDark: isDark,
                colorTheme: colorTheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required ColorTheme colorTheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: colorTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingPatterns(
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    final transactions = widget.transactions
        .where((tx) => tx.type == (_showExpenses ? 'expense' : 'income'))
        .toList();

    double weekdayTotal = 0;
    double weekendTotal = 0;
    int weekdayCount = 0;
    int weekendCount = 0;

    for (final tx in transactions) {
      if (tx.date.weekday >= 6) {
        weekendTotal += tx.amount;
        weekendCount++;
      } else {
        weekdayTotal += tx.amount;
        weekdayCount++;
      }
    }

    final weekdayAvg = weekdayCount > 0 ? weekdayTotal / weekdayCount : 0.0;
    final weekendAvg = weekendCount > 0 ? weekendTotal / weekendCount : 0.0;
    final maxAvg = math.max(weekdayAvg, weekendAvg);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: colorTheme.primary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l.spendingPatterns,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPatternBar(
            label: l.weekdaySpending,
            value: weekdayAvg,
            maxValue: maxAvg,
            color: colorTheme.primary,
            isDark: isDark,
            colorTheme: colorTheme,
          ),
          const SizedBox(height: 16),
          _buildPatternBar(
            label: l.weekendSpending,
            value: weekendAvg,
            maxValue: maxAvg,
            color: colorTheme.tertiary,
            isDark: isDark,
            colorTheme: colorTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
    required bool isDark,
    required ColorTheme colorTheme,
  }) {
    final percent = maxValue > 0 ? value / maxValue : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colorTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_symbol${NumberFormat('#,##0').format(value)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: colorTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodComparison(
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    // Calculate this period vs last period
    final now = DateTime.now();
    final thisMonth = _allTransactions
        .where(
          (tx) =>
              tx.type == (_showExpenses ? 'expense' : 'income') &&
              tx.date.month == now.month &&
              tx.date.year == now.year,
        )
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final lastMonth = _allTransactions
        .where((tx) {
          final lastMonthDate = DateTime(now.year, now.month - 1, 1);
          return tx.type == (_showExpenses ? 'expense' : 'income') &&
              tx.date.month == lastMonthDate.month &&
              tx.date.year == lastMonthDate.year;
        })
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final diff = thisMonth - lastMonth;
    final percentChange = lastMonth > 0 ? (diff / lastMonth * 100) : 0.0;
    final isPositive = diff >= 0;
    final changeText = diff == 0
        ? l.noChange
        : _showExpenses
        ? '${formatPercent(percentChange.abs(), decimals: 1)} ${isPositive ? l.youSpentMore : l.youSpentLess}'
        : '${isPositive ? '+' : '-'}${formatPercent(percentChange.abs(), decimals: 1)}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: colorTheme.primary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l.monthlyComparison,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.thisMonth,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_symbol${NumberFormat('#,##0').format(thisMonth)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.lastMonth,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_symbol${NumberFormat('#,##0').format(lastMonth)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Geçen ay veri yoksa yüzde anlamsızdır
          if (lastMonth > 0) const SizedBox(height: 16),
          if (lastMonth > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    (isPositive
                            ? (_showExpenses
                                  ? colorTheme.error
                                  : colorTheme.success)
                            : (_showExpenses
                                  ? colorTheme.success
                                  : colorTheme.error))
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive
                        ? (_showExpenses
                              ? colorTheme.error
                              : colorTheme.success)
                        : (_showExpenses
                              ? colorTheme.success
                              : colorTheme.error),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      changeText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? (_showExpenses
                                  ? colorTheme.error
                                  : colorTheme.success)
                            : (_showExpenses
                                  ? colorTheme.success
                                  : colorTheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, double> _getChartData() {
    final l = AppLocalizations.of(context)!;
    final type = _showExpenses ? 'expense' : 'income';
    final transactions = _allTransactions.where((tx) => tx.type == type);

    final data = <String, double>{};
    final today = dateOnly(DateTime.now());

    // Takvim günü farkı (saat farkı kullanılırsa 7 gün önceki bir işlem
    // bugünün çubuğuna karışabilir)
    int daysAgo(DateTime date) =>
        (today.difference(dateOnly(date)).inHours / 24).round();

    switch (_selectedTimeframe) {
      case 'weekly':
        final dayNames = [l.mon, l.tue, l.wed, l.thu, l.fri, l.sat, l.sun];
        for (int i = 6; i >= 0; i--) {
          final date = DateTime(today.year, today.month, today.day - i);
          data[dayNames[date.weekday - 1]] = 0;
        }
        for (final tx in transactions) {
          final diff = daysAgo(tx.date);
          if (diff >= 0 && diff < 7) {
            final dayName = dayNames[tx.date.weekday - 1];
            data[dayName] = (data[dayName] ?? 0) + tx.amount;
          }
        }
        break;

      case 'monthly':
        // Son 4 hafta; her çubuk haftanın ilk gününün tarihiyle etiketlenir
        final labels = <int, String>{};
        for (int i = 3; i >= 0; i--) {
          final weekStart = DateTime(
            today.year,
            today.month,
            today.day - (i * 7 + 6),
          );
          labels[i] = DateFormat('d MMM').format(weekStart);
          data[labels[i]!] = 0;
        }
        for (final tx in transactions) {
          final diff = daysAgo(tx.date);
          if (diff < 0) continue;
          final label = labels[diff ~/ 7];
          if (label != null) data[label] = (data[label] ?? 0) + tx.amount;
        }
        break;

      case 'last3Months':
        for (int i = 2; i >= 0; i--) {
          final month = DateTime(today.year, today.month - i, 1);
          final monthLabel = DateFormat('MMM').format(month);
          data[monthLabel] = 0;
          for (final tx in transactions) {
            if (tx.date.month == month.month && tx.date.year == month.year) {
              data[monthLabel] = (data[monthLabel] ?? 0) + tx.amount;
            }
          }
        }
        break;
    }

    return data;
  }

  String _formatShortAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
