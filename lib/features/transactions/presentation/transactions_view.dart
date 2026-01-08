// lib/features/transactions/presentation/transactions_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/transaction_model.dart';
import '../../wallet/models/category_model.dart';
import '../../wallet/presentation/edit_transaction_sheet.dart';
import '../../settings/data/settings_provider.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  String _filterType = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final locale = ref.watch(localeProvider);

    final l = AppLocalizations(locale);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                l.transactions,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
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
                  fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Filtre Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _buildFilterChip(l.all, 'all', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(l.income, 'income', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(l.expense, 'expense', isDark),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // İşlemler listesi
            Expanded(
              child: transactions.when(
                data: (List<TransactionModel> txList) {
                  Map<String, CategoryModel> categoryMap = {};
                  if (categories.hasValue) {
                    for (var cat in categories.value!) {
                      categoryMap[cat.id] = cat;
                    }
                  }

                  var filteredList = txList.where((tx) {
                    if (_filterType != 'all' && tx.type != _filterType)
                      return false;
                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase();
                      final desc = tx.description?.toLowerCase() ?? '';
                      final catName =
                          categoryMap[tx.categoryId]?.name.toLowerCase() ?? '';
                      return desc.contains(query) || catName.contains(query);
                    }
                    return true;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return _buildEmptyState(l, isDark);
                  }

                  final groupedTx = _groupByDate(filteredList);

                  double totalFiltered = 0;
                  for (var tx in filteredList) {
                    totalFiltered += tx.type == 'income'
                        ? tx.amount
                        : -tx.amount;
                  }

                  return Column(
                    children: [
                      // Toplam
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
                          color: isDark ? AppColors.surfaceDark : Colors.white,
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
                                    ? AppColors.success
                                    : AppColors.error,
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

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _filterType == value;
    Color chipColor = AppColors.primary;
    if (value == 'income') chipColor = AppColors.success;
    if (value == 'expense') chipColor = AppColors.error;

    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : (isDark ? Colors.white10 : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l, bool isDark) {
    String message = l.noTransactions;
    if (_filterType == 'income') message = l.noIncomeFound;
    if (_filterType == 'expense') message = l.noExpenseFound;
    if (_searchQuery.isNotEmpty)
      message = '"$_searchQuery" ${l.isTr ? 'bulunamadı' : 'not found'}';

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
      return DateFormat('d MMMM yyyy', l.isTr ? 'tr_TR' : 'en_US').format(date);
    }
  }

  Widget _buildTransactionCard(
    TransactionModel tx,
    CategoryModel? category,
    AppLocalizations l,
    bool isDark,
  ) {
    final isIncome = tx.type == 'income';
    final color = isIncome ? AppColors.success : AppColors.error;

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
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                    category?.name ??
                        (tx.description ?? (isIncome ? l.income : l.expense)),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
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
