// lib/features/statistics/presentation/category_analysis_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/transaction_model.dart';
import '../../wallet/models/category_model.dart';

class CategoryAnalysisView extends ConsumerStatefulWidget {
  final List<TransactionModel> transactions;
  final String periodLabel;

  const CategoryAnalysisView({
    super.key,
    required this.transactions,
    required this.periodLabel,
  });

  @override
  ConsumerState<CategoryAnalysisView> createState() =>
      _CategoryAnalysisViewState();
}

class _CategoryAnalysisViewState extends ConsumerState<CategoryAnalysisView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final categories = ref.watch(categoriesProvider);

    // Build category map
    Map<String, CategoryModel> categoryMap = {};
    if (categories.hasValue) {
      for (var cat in categories.value!) {
        categoryMap[cat.id] = cat;
      }
    }

    // Calculate category statistics
    final expenseTransactions = widget.transactions
        .where((tx) => tx.type == 'expense')
        .toList();

    Map<String, double> categoryExpenses = {};
    Map<String, int> categoryCounts = {};
    double totalExpense = 0;

    for (final tx in expenseTransactions) {
      if (tx.categoryId != null) {
        categoryExpenses[tx.categoryId!] =
            (categoryExpenses[tx.categoryId!] ?? 0) + tx.amount;
        categoryCounts[tx.categoryId!] =
            (categoryCounts[tx.categoryId!] ?? 0) + 1;
        totalExpense += tx.amount;
      }
    }

    // Sort categories by expense amount
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final avgTransaction = expenseTransactions.isNotEmpty
        ? totalExpense / expenseTransactions.length
        : 0.0;

    return Scaffold(
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l.categoryDetails),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: sortedCategories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.noExpenseData,
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period indicator
                  Container(
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
                      style: TextStyle(
                        color: colorTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: l.totalExpense,
                          value:
                              '₺${NumberFormat('#,##0.00', 'tr_TR').format(totalExpense)}',
                          icon: Icons.trending_down,
                          color: colorTheme.error,
                          isDark: isDark,
                          colorTheme: colorTheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          title: l.averageTransaction,
                          value:
                              '₺${NumberFormat('#,##0.00', 'tr_TR').format(avgTransaction)}',
                          icon: Icons.calculate,
                          color: colorTheme.primary,
                          isDark: isDark,
                          colorTheme: colorTheme,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Pie Chart
                  _buildPieChart(
                    sortedCategories,
                    categoryMap,
                    totalExpense,
                    l,
                    isDark,
                    colorTheme,
                  ),

                  const SizedBox(height: 32),

                  // Top & Least Categories
                  if (sortedCategories.isNotEmpty) ...[
                    _buildHighlightCard(
                      title: l.topSpendingCategory,
                      category: categoryMap[sortedCategories.first.key],
                      amount: sortedCategories.first.value,
                      percent: totalExpense > 0
                          ? sortedCategories.first.value / totalExpense * 100
                          : 0,
                      color: colorTheme.error,
                      l: l,
                      isDark: isDark,
                      colorTheme: colorTheme,
                    ),
                    const SizedBox(height: 12),
                    if (sortedCategories.length > 1)
                      _buildHighlightCard(
                        title: l.leastSpendingCategory,
                        category: categoryMap[sortedCategories.last.key],
                        amount: sortedCategories.last.value,
                        percent: totalExpense > 0
                            ? sortedCategories.last.value / totalExpense * 100
                            : 0,
                        color: colorTheme.success,
                        l: l,
                        isDark: isDark,
                        colorTheme: colorTheme,
                      ),
                  ],

                  const SizedBox(height: 32),

                  // All Categories List
                  Text(
                    l.allCategories,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Column(
                        children: sortedCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final categoryEntry = entry.value;
                          final category = categoryMap[categoryEntry.key];
                          final percent = totalExpense > 0
                              ? categoryEntry.value / totalExpense
                              : 0.0;
                          final count = categoryCounts[categoryEntry.key] ?? 0;

                          return _buildCategoryListItem(
                            category: category,
                            amount: categoryEntry.value,
                            percent: percent,
                            count: count,
                            index: index,
                            l: l,
                            isDark: isDark,
                            colorTheme: colorTheme,
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Budget Tips Section
                  if (sortedCategories.isNotEmpty)
                    _buildBudgetTips(
                      sortedCategories,
                      categoryMap,
                      totalExpense,
                      l,
                      isDark,
                      colorTheme,
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
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
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    List<MapEntry<String, double>> categories,
    Map<String, CategoryModel> categoryMap,
    double total,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final List<Color> colors = [
      colorTheme.primary,
      colorTheme.error,
      colorTheme.success,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),),
      child: Column(
        children: [
          // Main chart area with side stats
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pie Chart with center total
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(180, 180),
                            painter: PieChartPainter(
                              categories: categories,
                              total: total,
                              colors: colors,
                              progress: _animation.value,
                              isDark: isDark,
                              colorTheme: colorTheme,
                            ),
                          );
                        },
                      ),
                      // Center stats
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${categories.length}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            l.categories,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Side category list with percentages
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.take(5).toList().asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final cat = entry.value;
                    final category = categoryMap[cat.key];
                    final color = colors[index % colors.length];
                    final percent = total > 0 ? (cat.value / total * 100) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getCategoryName(category, l) ??
                                            l.cat_other,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${percent.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: percent / 100 * _animation.value,
                                    backgroundColor: isDark
                                        ? Colors.white12
                                        : Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      color,
                                    ),
                                    minHeight: 4,
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
              ),
            ],
          ),

          // Bottom summary row
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  icon: Icons.category,
                  value: '${categories.length}',
                  label: l.categories,
                  color: colorTheme.primary,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDark ? Colors.white24 : Colors.grey[300],
                ),
                _buildMiniStat(
                  icon: Icons.trending_down,
                  value: '₺${NumberFormat('#,##0', 'tr_TR').format(total)}',
                  label: l.totalExpense,
                  color: colorTheme.error,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDark ? Colors.white24 : Colors.grey[300],
                ),
                _buildMiniStat(
                  icon: Icons.pie_chart,
                  value: categories.isNotEmpty
                      ? '${(categories.first.value / total * 100).toStringAsFixed(0)}%'
                      : '0%',
                  label: l.topSpendingCategory,
                  color: colorTheme.success,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHighlightCard({
    required String title,
    required CategoryModel? category,
    required double amount,
    required double percent,
    required Color color,
    required AppLocalizations l,
    required bool isDark,
    required ColorTheme colorTheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(category?.icon),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  _getCategoryName(category, l) ?? l.cat_other,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₺${NumberFormat('#,##0.00', 'tr_TR').format(amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListItem({
    required CategoryModel? category,
    required double amount,
    required double percent,
    required int count,
    required int index,
    required AppLocalizations l,
    required bool isDark,
    required ColorTheme colorTheme,
  }) {
    final delay = index * 0.1;
    final itemProgress = ((_animation.value - delay) / (1 - delay)).clamp(
      0.0,
      1.0,
    );

    return Opacity(
      opacity: itemProgress,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - itemProgress)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(category?.icon),
                      color: colorTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryName(category, l) ?? l.cat_other,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '$count ${l.transactions.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${NumberFormat('#,##0.00', 'tr_TR').format(amount)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent * itemProgress,
                  backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(colorTheme.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetTips(
    List<MapEntry<String, double>> categories,
    Map<String, CategoryModel> categoryMap,
    double totalExpense,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    // Generate tips based on top spending categories
    final topCategory = categories.first;
    final category = categoryMap[topCategory.key];
    final categoryName = _getCategoryName(category, l) ?? l.cat_other;
    final potentialSavings = topCategory.value * 0.2; // 20% reduction

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorTheme.primary.withOpacity(0.1),
            colorTheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colorTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l.budgetTips,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.savings,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.potentialSavings,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.ifYouReduce(
                          categoryName,
                          20,
                          '₺${NumberFormat('#,##0', 'tr_TR').format(potentialSavings)}',
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}

// Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> categories;
  final double total;
  final List<Color> colors;
  final double progress;
  final bool isDark;
  final ColorTheme colorTheme;

  PieChartPainter({
    required this.categories,
    required this.total,
    required this.colors,
    required this.progress,
    required this.isDark,
    required this.colorTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < categories.length && i < colors.length; i++) {
      final sweepAngle = (categories[i].value / total) * 2 * math.pi * progress;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center hole with theme-aware color
    final holePaint = Paint()
      ..color = isDark ? colorTheme.surfaceDark : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.55, holePaint);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
