// lib/features/transactions/presentation/transactions_view.dart

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
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
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
                      color: isDark ? Colors.white : Colors.black87,
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
                            : (isDark
                                  ? colorTheme.surfaceDark
                                  : colorTheme.surfaceLight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _filterState.hasFilters
                              ? colorTheme.primary
                              : (isDark ? Colors.white10 : Colors.grey[300]!),
                        ),),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: _filterState.hasFilters
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey[700]),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filtrele', // Localize next step
                            style: TextStyle(
                              color: _filterState.hasFilters
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white70
                                        : Colors.grey[700]),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_filterState.hasFilters) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 10,
                                color: Colors.white,
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
                    // Kategori sayısı kadar chip veya "X Kategori" eklenebilir
                  ],
                ),
              ),

            // Arama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: l.searchTransactions,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
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
                  fillColor: isDark
                      ? colorTheme.surfaceDark
                      : colorTheme.surfaceLight,
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
                      final catName =
                          categoryMap[tx.categoryId]?.name.toLowerCase() ?? '';
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
                          color: isDark
                              ? colorTheme.surfaceDark
                              : colorTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${filteredList.length} ${l.transactions.toLowerCase()}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${totalFiltered >= 0 ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(totalFiltered)}',
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
                                      color: Colors.grey[500],
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
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white : colorTheme.primary,
          ),
        ),
        backgroundColor: isDark
            ? colorTheme.surfaceDark
            : colorTheme.primary.withOpacity(0.1),
        deleteIcon: Icon(
          Icons.close,
          size: 14,
          color: isDark ? Colors.white70 : colorTheme.primary,
        ),
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
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
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

    IconData categoryIcon = isIncome
        ? Icons.arrow_downward
        : Icons.arrow_upward;
    if (category != null) {
      categoryIcon = _getCategoryIcon(category.icon);
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
          color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoryIcon, color: color, size: 20),
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
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormat('HH:mm').format(tx.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      if (tx.description != null && category != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tx.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
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
              '${isIncome ? '+' : '-'}₺${NumberFormat('#,##0.00', 'tr_TR').format(tx.amount)}',
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
        case 'cat_other':
        case 'cat_others':
          return l.cat_other;
        case 'cat_travel':
          return l.cat_travel;
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
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }
}
