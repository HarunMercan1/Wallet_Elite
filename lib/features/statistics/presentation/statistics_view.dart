// lib/features/statistics/presentation/statistics_view.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/utils/category_l10n.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../premium/data/premium_provider.dart';
import '../../premium/presentation/premium_gate.dart';
import '../../settings/data/settings_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/category_model.dart';
import '../../wallet/models/transaction_model.dart';
import 'category_analysis_view.dart';
import 'date_range_picker_view.dart';
import 'month_comparison_view.dart';
import 'trend_detail_view.dart';

/// Seçilebilir dönemler
enum _Period { last7Days, thisMonth, last30Days, thisYear, allTime, custom }

/// Harcama grafiğindeki bir çubuk (gün veya ay)
class _Bucket {
  final String label;
  final String tooltipLabel;
  double amount = 0;

  _Bucket(this.label, this.tooltipLabel);
}

/// İstatistik sekmesi. Dört soruyu yanıtlar: bu dönemde ne kadar kazandım /
/// harcadım, harcama zamana nasıl yayıldı, para nereye gitti, öne çıkan
/// işlemler neler. Ayrıntılar alt ekranlarda.
class StatisticsView extends ConsumerStatefulWidget {
  const StatisticsView({super.key});

  @override
  ConsumerState<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends ConsumerState<StatisticsView> {
  static const int _maxCategories = 5;
  // Bu kadar günden uzun dönemler gün yerine ay bazında çizilir
  static const int _maxDailyBars = 45;

  _Period _period = _Period.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;
  String? _customLabel;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final colorTheme = ref.watch(currentColorThemeProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorTheme.background,
      body: SafeArea(
        child: transactions.when(
          data: (all) => _buildContent(
            all,
            {
              for (final c in categories.valueOrNull ?? const <CategoryModel>[])
                c.id: c,
            },
            l,
            colorTheme,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${l.error}: $e')),
        ),
      ),
    );
  }

  // ========== Dönem ==========

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Dönemin ilk ve son günü (ikisi de dahil)
  ({DateTime start, DateTime end}) _range(List<TransactionModel> all) {
    final today = _today;
    switch (_period) {
      case _Period.last7Days:
        return (start: today.subtract(const Duration(days: 6)), end: today);
      case _Period.thisMonth:
        return (start: DateTime(today.year, today.month), end: today);
      case _Period.last30Days:
        return (start: today.subtract(const Duration(days: 29)), end: today);
      case _Period.thisYear:
        return (start: DateTime(today.year), end: today);
      case _Period.allTime:
        var first = today;
        for (final t in all) {
          if (t.date.isBefore(first)) first = t.date;
        }
        return (
          start: DateTime(first.year, first.month, first.day),
          end: today,
        );
      case _Period.custom:
        return (start: _customStart ?? today, end: _customEnd ?? today);
    }
  }

  String _periodLabel(_Period period, AppLocalizations l) {
    switch (period) {
      case _Period.last7Days:
        return l.last7Days;
      case _Period.thisMonth:
        return l.thisMonth;
      case _Period.last30Days:
        return l.last30Days;
      case _Period.thisYear:
        return l.thisYear;
      case _Period.allTime:
        return l.allTime;
      case _Period.custom:
        return _customLabel ?? l.customDateRange;
    }
  }

  Future<void> _pickCustomRange() async {
    final result = await Navigator.push<DateRangeResult>(
      context,
      MaterialPageRoute(
        builder: (context) => DateRangePickerView(
          initialStartDate: _customStart,
          initialEndDate: _customEnd,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _period = _Period.custom;
      _customStart = result.startDate;
      _customEnd = result.endDate;
      _customLabel = result.label;
    });
  }

  // ========== İçerik ==========

  String _money(double value, {int decimals = 2}) {
    final symbol = CurrencyUtils.getSymbol(ref.watch(currencyProvider));
    final pattern = decimals == 0 ? '#,##0' : '#,##0.00';
    final formatted = NumberFormat(pattern, 'tr_TR').format(value.abs());
    return '${value < 0 ? '-' : ''}$symbol$formatted';
  }

  Widget _buildContent(
    List<TransactionModel> all,
    Map<String, CategoryModel> categoryMap,
    AppLocalizations l,
    ColorTheme c,
  ) {
    final range = _range(all);
    final endExclusive = range.end.add(const Duration(days: 1));
    final inPeriod = all
        .where(
          (t) => !t.date.isBefore(range.start) && t.date.isBefore(endExclusive),
        )
        .toList();

    var income = 0.0;
    var expense = 0.0;
    var count = 0;
    TransactionModel? biggestIncome;
    TransactionModel? biggestExpense;
    final byCategory = <String?, double>{};
    for (final t in inPeriod) {
      if (t.isIncome) {
        income += t.amount;
        count++;
        if (biggestIncome == null || t.amount > biggestIncome.amount) {
          biggestIncome = t;
        }
      } else if (t.isExpense) {
        expense += t.amount;
        count++;
        if (biggestExpense == null || t.amount > biggestExpense.amount) {
          biggestExpense = t;
        }
        byCategory[t.categoryId] = (byCategory[t.categoryId] ?? 0) + t.amount;
      }
    }
    final days = range.end.difference(range.start).inDays + 1;
    final periodLabel = _periodLabel(_period, l);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            l.statistics,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildPeriodChips(l, c),
        const SizedBox(height: 16),
        if (count == 0)
          _buildEmptyState(l, c)
        else ...[
          _buildSummaryCard(all, income, expense, l, c),
          const SizedBox(height: 14),
          _buildTrendCard(inPeriod, range, expense, days, periodLabel, l, c),
          const SizedBox(height: 14),
          _buildCategoryCard(
            inPeriod,
            byCategory,
            categoryMap,
            expense,
            periodLabel,
            l,
            c,
          ),
          const SizedBox(height: 14),
          _buildHighlightsCard(
            biggestExpense,
            biggestIncome,
            categoryMap,
            count,
            income + expense,
            l,
            c,
          ),
        ],
        const SizedBox(height: 14),
        _buildComparisonLink(all, categoryMap, l, c),
      ],
    );
  }

  Widget _buildPeriodChips(AppLocalizations l, ColorTheme c) {
    Widget chip(_Period period, {IconData? icon}) {
      final selected = period == _period;
      final radius = BorderRadius.circular(20);
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Material(
          color: selected ? c.primary : c.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: selected ? c.primary : c.outline),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              if (period == _Period.custom) {
                _requirePremium(_pickCustomRange);
              } else {
                setState(() => _period = period);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 15,
                      color: selected ? c.onPrimary : c.textSecondary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    _periodLabel(period, l),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? c.onPrimary : c.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(_Period.last7Days),
          chip(_Period.thisMonth),
          chip(_Period.last30Days),
          chip(_Period.thisYear),
          chip(_Period.allTime),
          chip(_Period.custom, icon: Icons.calendar_month_rounded),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l, ColorTheme c) {
    return _card(
      c,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 52, color: c.textMuted),
            const SizedBox(height: 12),
            Text(
              l.noData,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(ColorTheme c, {required Widget child, VoidCallback? onTap}) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: c.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: c.outline),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(18), child: child),
      ),
    );
  }

  Widget _cardHeader(
    String title,
    ColorTheme c, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ),
        if (action != null)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            // Ayrıntı ekranları Premium'a özel
            onTap: onAction == null ? null : () => _requirePremium(onAction),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _isPremium
                        ? Icons.chevron_right_rounded
                        : Icons.lock_outline_rounded,
                    size: _isPremium ? 18 : 14,
                    color: c.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  bool get _isPremium => ref.watch(isPremiumProvider);

  /// Premium kullanıcıda [action]'ı çalıştırır; değilse Premium'u tanıtır.
  void _requirePremium(VoidCallback action) {
    if (ref.read(isPremiumProvider)) {
      action();
      return;
    }
    showPremiumRequiredDialog(
      context,
      AppLocalizations.of(context)!.premiumStatsMessage,
    );
  }

  // ========== 1. Özet ==========

  Widget _buildSummaryCard(
    List<TransactionModel> all,
    double income,
    double expense,
    AppLocalizations l,
    ColorTheme c,
  ) {
    final net = income - expense;
    final total = income + expense;

    return _card(
      c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.balance,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
              if (_period == _Period.thisMonth)
                _buildMonthChangeBadge(all, expense, l, c),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money(net),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: net < 0 ? c.error : c.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Gelir / gider oranı tek bakışta
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (income > 0)
                    Expanded(
                      flex: (income / total * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: c.success),
                    ),
                  if (income > 0 && expense > 0) const SizedBox(width: 3),
                  if (expense > 0)
                    Expanded(
                      flex: (expense / total * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: c.error),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryStat(l.income, _money(income), c.success, c),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryStat(l.expense, _money(expense), c.error, c),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value, Color color, ColorTheme c) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: c.textSecondary),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bu ayın harcaması, geçen ayın aynı gününe kadarki harcamaya göre
  Widget _buildMonthChangeBadge(
    List<TransactionModel> all,
    double expense,
    AppLocalizations l,
    ColorTheme c,
  ) {
    final today = _today;
    final lastMonthStart = DateTime(today.year, today.month - 1);
    final lastMonthLastDay = DateTime(today.year, today.month, 0).day;
    final lastMonthEnd = DateTime(
      lastMonthStart.year,
      lastMonthStart.month,
      today.day > lastMonthLastDay ? lastMonthLastDay : today.day,
    ).add(const Duration(days: 1));

    var lastExpense = 0.0;
    for (final t in all) {
      if (t.isExpense &&
          !t.date.isBefore(lastMonthStart) &&
          t.date.isBefore(lastMonthEnd)) {
        lastExpense += t.amount;
      }
    }
    if (lastExpense <= 0) return const SizedBox.shrink();

    final change = (expense - lastExpense) / lastExpense * 100;
    final spentLess = change <= 0;
    final color = spentLess ? c.success : c.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            spentLess ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '%${change.abs().toStringAsFixed(0)} · ${l.comparedToLastMonth}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ========== 2. Harcama trendi ==========

  List<_Bucket> _buildBuckets(
    List<TransactionModel> inPeriod,
    DateTime start,
    DateTime end,
  ) {
    final locale = ref.watch(localeProvider);
    final days = end.difference(start).inDays + 1;
    final buckets = <_Bucket>[];

    if (days <= _maxDailyBars) {
      final labelEvery = days <= 7 ? 1 : (days / 6).ceil();
      for (var i = 0; i < days; i++) {
        final day = start.add(Duration(days: i));
        final label = days <= 7
            ? DateFormat.E(locale).format(day)
            : (i % labelEvery == 0 ? '${day.day}' : '');
        buckets.add(_Bucket(label, DateFormat.MMMd(locale).format(day)));
      }
      for (final t in inPeriod) {
        if (!t.isExpense) continue;
        final index = DateTime(
          t.date.year,
          t.date.month,
          t.date.day,
        ).difference(start).inDays;
        if (index >= 0 && index < buckets.length) {
          buckets[index].amount += t.amount;
        }
      }
    } else {
      final months = (end.year - start.year) * 12 + end.month - start.month + 1;
      final labelEvery = (months / 6).ceil();
      for (var i = 0; i < months; i++) {
        final month = DateTime(start.year, start.month + i);
        buckets.add(
          _Bucket(
            i % labelEvery == 0 ? DateFormat.MMM(locale).format(month) : '',
            DateFormat.yMMM(locale).format(month),
          ),
        );
      }
      for (final t in inPeriod) {
        if (!t.isExpense) continue;
        final index =
            (t.date.year - start.year) * 12 + t.date.month - start.month;
        if (index >= 0 && index < buckets.length) {
          buckets[index].amount += t.amount;
        }
      }
    }
    return buckets;
  }

  Widget _buildTrendCard(
    List<TransactionModel> inPeriod,
    ({DateTime start, DateTime end}) range,
    double expense,
    int days,
    String periodLabel,
    AppLocalizations l,
    ColorTheme c,
  ) {
    final buckets = _buildBuckets(inPeriod, range.start, range.end);
    var maxAmount = 0.0;
    for (final b in buckets) {
      if (b.amount > maxAmount) maxAmount = b.amount;
    }

    return _card(
      c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            l.spendingTrend,
            c,
            action: l.viewDetails,
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrendDetailView(
                  transactions: inPeriod,
                  periodLabel: periodLabel,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l.averageDailySpending}: ${_money(expense / days)}',
            style: TextStyle(fontSize: 12.5, color: c.textSecondary),
          ),
          const SizedBox(height: 16),
          if (maxAmount <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  l.noExpenseData,
                  style: TextStyle(color: c.textSecondary),
                ),
              ),
            )
          else
            SizedBox(
              height: 170,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth =
                      (constraints.maxWidth / buckets.length * 0.62).clamp(
                        3.0,
                        22.0,
                      );
                  return BarChart(
                    BarChartData(
                      maxY: maxAmount * 1.12,
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: maxAmount / 3,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: c.borderColor, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= buckets.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  buckets[i].label,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: c.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: c.surfaceVariant,
                          tooltipRoundedRadius: 10,
                          getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                            '${buckets[group.x].tooltipLabel}\n',
                            TextStyle(
                              fontSize: 11,
                              color: c.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                            children: [
                              TextSpan(
                                text: _money(rod.toY),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: c.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < buckets.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: buckets[i].amount,
                                width: barWidth,
                                color: c.primary,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(barWidth / 2.5),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ========== 3. Kategoriler ==========

  /// Dilim renkleri: temanın ana rengi + ondan belirgin biçimde ayrışan sabit
  /// renkler. Ana renge yakın tondakiler atlanır ki iki dilim karışmasın.
  List<Color> _categoryPalette(ColorTheme c) {
    const candidates = [
      Color(0xFFF59E0B), // amber
      Color(0xFF8B5CF6), // mor
      Color(0xFFEC4899), // pembe
      Color(0xFF14B8A6), // turkuaz
      Color(0xFF3B82F6), // mavi
      Color(0xFFEF4444), // kırmızı
    ];
    final primaryHsl = HSLColor.fromColor(c.primary);
    final isNeutral = primaryHsl.saturation < 0.15;
    bool farFromPrimary(Color color) {
      if (isNeutral) return true;
      final diff = (HSLColor.fromColor(color).hue - primaryHsl.hue).abs();
      return (diff > 180 ? 360 - diff : diff) >= 40;
    }

    return [c.primary, ...candidates.where(farFromPrimary).take(4)];
  }

  Widget _buildCategoryCard(
    List<TransactionModel> inPeriod,
    Map<String?, double> byCategory,
    Map<String, CategoryModel> categoryMap,
    double expense,
    String periodLabel,
    AppLocalizations l,
    ColorTheme c,
  ) {
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final palette = _categoryPalette(c);

    // En büyük kategoriler ayrı, kalanı "Diğer" olarak tek dilimde
    final slices = <({String name, double amount, Color color})>[];
    var rest = 0.0;
    for (var i = 0; i < sorted.length; i++) {
      if (i < _maxCategories) {
        slices.add((
          name:
              localizedCategoryName(categoryMap[sorted[i].key], l) ??
              l.cat_other,
          amount: sorted[i].value,
          color: palette[i % palette.length],
        ));
      } else {
        rest += sorted[i].value;
      }
    }
    if (rest > 0) {
      slices.add((name: l.other, amount: rest, color: c.textMuted));
    }

    return _card(
      c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            l.categoryDistribution,
            c,
            action: slices.isEmpty ? null : l.viewDetails,
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryAnalysisView(
                  transactions: inPeriod,
                  periodLabel: periodLabel,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (slices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  l.noExpenseData,
                  style: TextStyle(color: c.textSecondary),
                ),
              ),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 58,
                        startDegreeOffset: -90,
                        sections: [
                          for (final s in slices)
                            PieChartSectionData(
                              value: s.amount,
                              color: s.color,
                              radius: 24,
                              showTitle: false,
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.expense,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: c.textSecondary,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _money(expense, decimals: 0),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final s in slices)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '%${(s.amount / expense * 100).toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 12.5, color: c.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 96,
                      child: Text(
                        _money(s.amount),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ========== 4. Öne çıkanlar ==========

  Widget _buildHighlightsCard(
    TransactionModel? biggestExpense,
    TransactionModel? biggestIncome,
    Map<String, CategoryModel> categoryMap,
    int count,
    double volume,
    AppLocalizations l,
    ColorTheme c,
  ) {
    String title(TransactionModel t) =>
        localizedCategoryName(categoryMap[t.categoryId], l) ??
        t.description ??
        (t.isIncome ? l.income : l.expense);

    final rows = <Widget>[
      if (biggestExpense != null)
        _highlightRow(
          Icons.arrow_downward_rounded,
          c.error,
          l.biggestExpense,
          title(biggestExpense),
          _money(biggestExpense.amount),
          c,
        ),
      if (biggestIncome != null)
        _highlightRow(
          Icons.arrow_upward_rounded,
          c.success,
          l.biggestIncome,
          title(biggestIncome),
          _money(biggestIncome.amount),
          c,
        ),
      _highlightRow(
        Icons.receipt_long_outlined,
        c.info,
        l.transactions,
        l.averageTransaction,
        '$count  ·  ${_money(volume / count)}',
        c,
      ),
    ];

    return _card(
      c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(l.transactionSummary, c),
          const SizedBox(height: 6),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.borderColor),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _highlightRow(
    IconData icon,
    Color color,
    String label,
    String detail,
    String value,
    ColorTheme c,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ========== 5. Aylık karşılaştırma ==========

  Widget _buildComparisonLink(
    List<TransactionModel> all,
    Map<String, CategoryModel> categoryMap,
    AppLocalizations l,
    ColorTheme c,
  ) {
    return _card(
      c,
      onTap: () => _requirePremium(
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthComparisonView(
              allTransactions: all,
              categoryMap: categoryMap,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.tertiary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.compare_arrows_rounded, color: c.tertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.monthlyComparison,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  l.monthlyComparisonDesc,
                  style: TextStyle(fontSize: 12.5, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            _isPremium
                ? Icons.chevron_right_rounded
                : Icons.lock_outline_rounded,
            size: _isPremium ? 24 : 18,
            color: c.textMuted,
          ),
        ],
      ),
    );
  }
}
