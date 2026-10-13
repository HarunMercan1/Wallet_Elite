// lib/features/transactions/presentation/transactions_view.dart

import '../../../core/utils/icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/transaction_model.dart';
import '../../wallet/models/category_model.dart';
import '../../wallet/presentation/edit_transaction_sheet.dart';
import 'transaction_filter_state.dart';
import 'transaction_filter_sheet.dart';
import '../../../core/utils/currency_utils.dart';
import '../../settings/data/settings_provider.dart';
import '../../../core/utils/category_l10n.dart';
import '../../../core/ads/native_ad_widget.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  TransactionFilterState _filterState = const TransactionFilterState();
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context) async {
    final result = await showModalBottomSheet<TransactionFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterSheet(initialState: _filterState),
    );

    if (result != null) {
      setState(() {
        _filterState = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider);
    final categories = ref.watch(categoriesProvider);

    final colorTheme = ref.watch(currentColorThemeProvider);
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve Filtre Butonu Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.transactions,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openFilterSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _filterState.hasFilters
                            ? colorTheme.primary
                            : colorTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _filterState.hasFilters
                              ? colorTheme.primary
                              : colorTheme.borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: _filterState.hasFilters
                                ? colorTheme.onPrimary
                                : colorTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l.periodFilter,
                            style: TextStyle(
                              color: _filterState.hasFilters
                                  ? colorTheme.onPrimary
                                  : colorTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_filterState.hasFilters) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colorTheme.onPrimary.withValues(
                                  alpha: 0.24,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 10,
                                color: colorTheme.onPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Seçili Filtreleri Gösteren Yatay Liste (Aktifse)
            if (_filterState.hasFilters)
              Container(
                height: 44,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (_filterState.type != 'all')
                      _buildActiveFilterChip(
                        _filterState.type == 'income' ? l.income : l.expense,
                        () => setState(
                          () =>
                              _filterState = _filterState.copyWith(type: 'all'),
                        ),
                        isDark,
                        colorTheme,
                      ),
                    if (_filterState.startDate != null ||
                        _filterState.endDate != null)
                      _buildActiveFilterChip(
                        l.date, // Geliştirilebilir: Tarih aralığını yaz
                        () => setState(
                          () => _filterState = _filterState.copyWith(
                            startDate: null,
                            endDate: null,
                          ),
                        ), // Sıfırlama mantığı daha detaylı olabilir
                        isDark,
                        colorTheme,
                      ),
                    if (_filterState.selectedCategoryIds.isNotEmpty)
                      _buildActiveFilterChip(
                        '${l.categories} (${_filterState.selectedCategoryIds.length})',
                        () => setState(
                          () => _filterState = _filterState.copyWith(
                            selectedCategoryIds: const [],
                          ),
                        ),
                        isDark,
                        colorTheme,
                      ),
                  ],
                ),
              ),

            // Arama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(color: colorTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: l.searchTransactions,
                  hintStyle: TextStyle(color: colorTheme.textSecondary),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorTheme.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // İşlemler listesi
            Expanded(
              child: transactionsAsync.when(
                data: (List<TransactionModel> txList) {
                  Map<String, CategoryModel> categoryMap = {};
                  if (categories.hasValue) {
                    for (var cat in categories.value!) {
                      categoryMap[cat.id] = cat;
                    }
                  }

                  // === FILTRELEME MANTIĞI ===
                  var filteredList = txList.where((tx) {
                    // Tip Filtresi ('all', 'income', 'expense')
                    if (_filterState.type != 'all' &&
                        tx.type != _filterState.type) {
                      return false;
                    }

                    // Kategori Filtresi
                    if (_filterState.selectedCategoryIds.isNotEmpty) {
                      if (!_filterState.selectedCategoryIds.contains(
                        tx.categoryId,
                      )) {
                        return false;
                      }
                    }

                    // Tarih Aralığı Filtresi
                    if (_filterState.startDate != null) {
                      if (tx.date.isBefore(_filterState.startDate!)) {
                        return false;
                      }
                    }
                    if (_filterState.endDate != null) {
                      // Bitiş tarihinin gün sonunu al (23:59:59)
                      final endOfDay = DateTime(
                        _filterState.endDate!.year,
                        _filterState.endDate!.month,
                        _filterState.endDate!.day,
                        23,
                        59,
                        59,
                      );
                      if (tx.date.isAfter(endOfDay)) return false;
                    }

                    // Arama Sorgusu
                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      final desc = tx.description?.toLowerCase() ?? '';
                      final category = categoryMap[tx.categoryId];
                      // Hem ekranda görünen (çevrilmiş) hem de kayıtlı ad
                      final catName =
                          '${localizedCategoryName(category, l) ?? ''} '
                                  '${category?.name ?? ''}'
                              .toLowerCase();
                      return desc.contains(query) || catName.contains(query);
                    }
                    return true;
                  }).toList();

                  // === SIRALAMA MANTIĞI ===
                  filteredList.sort((a, b) {
                    switch (_filterState.sortOption) {
                      case SortOption.dateDesc:
                        return b.date.compareTo(a.date);
                      case SortOption.dateAsc:
                        return a.date.compareTo(b.date);
                      case SortOption.amountDesc:
                        return b.amount.compareTo(a.amount);
                      case SortOption.amountAsc:
                        return a.amount.compareTo(b.amount);
                    }
                  });

                  if (filteredList.isEmpty) {
                    return _buildEmptyState(l, isDark);
                  }

                  // Gruplama sadece Tarih sıralaması seçiliyse anlamlıdır
                  // Ancak kullanıcı "Tutar"a göre sıralasa bile, yine de tarih başlıkları altında göstermek
                  // kafa karıştırıcı olabilir veya olmayabilir.
                  // Genelde "Tutar" sıralamasında Tarih gruplaması kaldırılır ve düz liste gösterilir.
                  // Biz şimdilik her durumda gruplu gösterelim veya Sorting seçeneğine göre değiştirelim.

                  // Eğer Tarihe göre sıralama DEĞİLSE, düz liste gösterelim
                  if (_filterState.sortOption == SortOption.amountAsc ||
                      _filterState.sortOption == SortOption.amountDesc) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final tx = filteredList[index];
                        return _buildTransactionCard(
                          tx,
                          categoryMap[tx.categoryId],
                          l,
                          isDark,
                          colorTheme,
                        );
                      },
                    );
                  }

                  // Tarihe Göre Gruplama (Varsayılan)
                  final groupedTx = _groupByDate(filteredList);

                  // Toplam Hesaplama
                  double totalFiltered = 0;
                  for (var tx in filteredList) {
                    totalFiltered += tx.type == 'income'
                        ? tx.amount
                        : -tx.amount;
                  }

                  return Column(
                    children: [
                      // Filtrelenmiş Özeti
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorTheme.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filteredList.length} ${l.transactions.toLowerCase()}',
                              style: TextStyle(
                                color: colorTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${totalFiltered >= 0 ? '+' : '-'}${CurrencyUtils.getSymbol(ref.watch(currencyProvider))}${NumberFormat('#,##0.00').format(totalFiltered.abs())}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: totalFiltered >= 0
                                    ? colorTheme.success
                                    : colorTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: groupedTx.length,
                          itemBuilder: (context, index) {
                            final date = groupedTx.keys.elementAt(index);
                            final dayTx = groupedTx[date]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    _formatDate(date, l),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                ...dayTx.map(
                                  (tx) => _buildTransactionCard(
                                    tx,
                                    categoryMap[tx.categoryId],
                                    l,
                                    isDark,
                                    colorTheme,
                                  ),
                                ),
                                // İlk günün altında liste içi native reklam
                                if (index == 0)
                                  const NativeAdCard(
                                    margin: EdgeInsets.only(top: 4, bottom: 4),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${l.error}: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(
    String label,
    VoidCallback onRemove,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(fontSize: 12, color: colorTheme.primary),
        ),
        backgroundColor: isDark
            ? colorTheme.surfaceDark
            : colorTheme.primary.withValues(alpha: 0.1),
        deleteIcon: Icon(Icons.close, size: 14, color: colorTheme.primary),
        onDeleted: onRemove,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // _buildTransactionCard, _getCategoryName, _getCategoryIcon, _groupByDate, _formatDate, _buildEmptyState... same as before...

  Widget _buildEmptyState(AppLocalizations l, bool isDark) {
    String message = l.noTransactions;
    if (_filterState.type == 'income') message = l.noIncomeFound;
    if (_filterState.type == 'expense') message = l.noExpenseFound;
    if (_searchQuery.isNotEmpty) message = '"$_searchQuery" ${l.notFound}';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: context.colors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Map<String, List<TransactionModel>> _groupByDate(
    List<TransactionModel> txList,
  ) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in txList) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(tx);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  String _formatDate(String dateKey, AppLocalizations l) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (DateFormat('yyyy-MM-dd').format(now) == dateKey) {
      return l.today;
    } else if (DateFormat('yyyy-MM-dd').format(yesterday) == dateKey) {
      return l.yesterday;
    } else {
      return DateFormat(
        'd MMMM yyyy',
        Localizations.localeOf(context).toString(),
      ).format(date);
    }
  }

  Widget _buildTransactionCard(
    TransactionModel tx,
    CategoryModel? category,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final isIncome = tx.type == 'income';
    final color = isIncome ? colorTheme.success : colorTheme.error;

    // İşlemin cüzdanının para birimi (ana sayfadaki ile aynı)
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;
    final currencySymbol =
        account?.currencySymbol ??
        CurrencyUtils.getSymbol(ref.watch(currencyProvider));

    IconData icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    if (category != null) {
      icon = categoryIcon(category.icon);
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => EditTransactionSheet(transaction: tx),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCategoryName(category, l) ??
                        (tx.description ?? (isIncome ? l.income : l.expense)),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormat('HH:mm').format(tx.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorTheme.textSecondary,
                        ),
                      ),
                      if (tx.description != null && category != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorTheme.textMuted,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tx.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}$currencySymbol${NumberFormat('#,##0.00').format(tx.amount)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getCategoryName(CategoryModel? category, AppLocalizations l) =>
      localizedCategoryName(category, l);
}
