import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/utils/responsive_helper.dart';
import '../data/wallet_provider.dart';
import '../models/category_model.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late TabController _tabController;
  String _transactionType = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Favori kategoriler (varsayılan popüler olanlar)
  final List<String> _defaultFavoriteExpenseCategories = [
    'Market',
    'Yemek',
    'Ulaşım',
    'Faturalar',
    'Eğlence',
    'Sağlık',
  ];
  final List<String> _defaultFavoriteIncomeCategories = [
    'Maaş',
    'Freelance',
    'Yatırım',
    'Hediye',
    'Diğer Gelir',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _transactionType = _tabController.index == 0 ? 'expense' : 'income';
          _selectedCategoryId = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final accounts = ref.read(accountsProvider);
    accounts.whenData((list) {
      if (list.isNotEmpty && _selectedAccountId == null) {
        setState(() => _selectedAccountId = list.first.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getCategoryName(CategoryModel category, AppLocalizations l) {
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
        case 'cat_others':
        case 'cat_other':
          return l.cat_other;
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
        case 'cat_sport':
          return l.cat_gym;
        case 'cat_travel':
          return l.cat_travel;
      }
    }

    // Fallback: Check English name
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

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final categories = _transactionType == 'income'
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = ResponsiveHelper.of(context);
    final colorTheme = ref.watch(currentColorThemeProvider);

    return Container(
      height: r.hp(92),
      decoration: BoxDecoration(
        color: isDark ? colorTheme.backgroundDark : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(r.radiusXL),
          topRight: Radius.circular(r.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(),

          // Tab Bar
          _buildTabBar(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Amount Input
                    _buildAmountInput(),

                    const SizedBox(height: 24),

                    // 2. Favorite Categories (6 adet + Daha Fazla)
                    _buildSectionTitle(l.category, Icons.category_outlined),
                    const SizedBox(height: 12),
                    _buildFavoriteCategoryGrid(categories),

                    const SizedBox(height: 20),

                    // 3. Description
                    _buildSectionTitle(l.note, Icons.note_outlined),
                    const SizedBox(height: 10),
                    _buildDescriptionInput(),

                    const SizedBox(height: 20),

                    // 4. Date Selection
                    _buildDateSelector(),

                    const SizedBox(height: 20),

                    // 5. Wallet Selection (En altta)
                    _buildSectionTitle(
                      l.wallet,
                      Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildWalletSelector(accounts),

                    const SizedBox(height: 28),

                    // Save Button
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
            ),
          ),
          Expanded(
            child: Text(
              l.addTransaction,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _transactionType == 'expense'
              ? colorTheme.error.withOpacity(0.9)
              : colorTheme.success.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color:
                  (_transactionType == 'expense'
                          ? colorTheme.error
                          : colorTheme.success)
                      .withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward_rounded, size: 16),
                const SizedBox(width: 4),
                Text(l.expense),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_downward_rounded, size: 16),
                const SizedBox(width: 4),
                Text(l.income),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildAmountInput remains mostly the same, just checking if l10n is used there (it's not, just numbers)

  Widget _buildAmountInput() {
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isExpense = _transactionType == 'expense';
    final color = isExpense ? colorTheme.error : colorTheme.success;
    final l = AppLocalizations.of(
      context,
    )!; // Added mostly for completeness if needed later

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '₺',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: IntrinsicWidth(
              child: TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                showCursor: false,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.3),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l.enterAmount; // Translated
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return l.enterAmount;
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    return Row(
      children: [
        Icon(icon, size: 18, color: colorTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCategoryGrid(
    AsyncValue<List<CategoryModel>> categories,
  ) {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);

    return categories.when(
      data: (categoriesList) {
        if (categoriesList.isEmpty) {
          return _buildEmptyCategories();
        }

        // Önce veritabanındaki favorileri al
        final dbFavorites = categoriesList.where((c) => c.isFavorite).toList();

        // Eğer veritabanında favori yoksa, varsayılan isimlere göre filtrele
        List<CategoryModel> favoriteCategories;
        List<CategoryModel> otherCategories;

        if (dbFavorites.isNotEmpty) {
          // Veritabanındaki favorileri kullan
          favoriteCategories = dbFavorites;
          otherCategories = categoriesList.where((c) => !c.isFavorite).toList();
        } else {
          // Varsayılan isimlere göre filtrele (fallback)
          // Not: İdealde kullanıcı favorileri DB'de tutulmalı
          favoriteCategories = categoriesList.take(6).toList();
          otherCategories = categoriesList.skip(6).toList();
        }

        // Maksimum 6 favori göster
        final displayCategories = favoriteCategories.take(6).toList();
        final hasMore =
            otherCategories.isNotEmpty || favoriteCategories.length > 6;

        return Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...displayCategories.map(
                  (category) => _buildCategoryChip(category),
                ),
                if (hasMore) _buildMoreButton(categoriesList, colorTheme),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _buildEmptyCategories(),
    );
  }

  Widget _buildCategoryChip(CategoryModel category) {
    final isSelected = _selectedCategoryId == category.id;
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = category.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorTheme.primary
              : (isDark ? colorTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorTheme.primary
                : (isDark ? Colors.white24 : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorTheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category.icon ?? 'category'),
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
            const SizedBox(width: 6),
            Text(
              _getCategoryName(category, l), // Use translated name
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton(
    List<CategoryModel> allCategories,
    ColorTheme colorTheme,
  ) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showAllCategoriesSheet(allCategories),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.more_horiz,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              l.more,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllCategoriesSheet(List<CategoryModel> allCategories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? colorTheme.backgroundDark : Colors.white,
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
                // Title
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        color: AppColors
                            .info, // Changed from primary to avoid confusion, or keep primary
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _transactionType == 'expense'
                              ? l.expenseCategories
                              : l.incomeCategories,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      // Yeni Kategori Ekle butonu
                      TextButton.icon(
                        onPressed: () => _showAddCategoryDialog(ctx),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l.newCategory),
                        style: TextButton.styleFrom(
                          foregroundColor: colorTheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: isDark ? Colors.white12 : null),
                // İpucu
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: isDark ? colorTheme.surfaceDark : Colors.grey[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l.longPressToFavorite,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Categories List
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: allCategories.length,
                    itemBuilder: (context, index) {
                      final category = allCategories[index];
                      final isSelected = _selectedCategoryId == category.id;
                      final isFavorite = category.isFavorite;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategoryId = category.id);
                          Navigator.pop(ctx);
                        },
                        onLongPress: () => _toggleFavorite(category),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorTheme.primary
                                    : (isDark
                                          ? colorTheme.surfaceDark
                                          : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? colorTheme.primary
                                      : (isFavorite
                                            ? colorTheme.accent
                                            : (isDark
                                                  ? Colors.white24
                                                  : Colors.grey[200]!)),
                                  width: isFavorite ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(category.icon),
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                  ? Colors.grey[300]
                                                  : Colors.grey[700]),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          _getCategoryName(category, l),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark
                                                      ? Colors.white
                                                      : Colors.black87),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Yıldız ikonu
                            if (isFavorite)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Icon(
                                  Icons.star,
                                  size: 12,
                                  color: colorTheme.accent,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(CategoryModel category) async {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);
    try {
      final newValue = !category.isFavorite;
      await Supabase.instance.client
          .from('categories')
          .update({'is_favorite': newValue})
          .eq('id', category.id);

      // Provider'ları yenile
      ref.invalidate(categoriesProvider);
      ref.invalidate(incomeCategoriesProvider);
      ref.invalidate(expenseCategoriesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue
                  ? l.addedToFavorites(category.name)
                  : l.removedFromFavorites(category.name),
            ),
            backgroundColor: colorTheme.success,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (e.toString().contains('SocketException') ||
                      e.toString().contains('host lookup') ||
                      e.toString().contains('Network is unreachable'))
                  ? l.networkError
                  : l.errorWithDetails(e.toString()),
            ),
            backgroundColor: colorTheme.error,
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog(BuildContext parentContext) {
    final l = AppLocalizations.of(parentContext)!;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final nameController = TextEditingController();
    String? selectedIcon = 'category';

    final icons = [
      'shopping_cart',
      'restaurant',
      'directions_car',
      'receipt',
      'movie',
      'local_hospital',
      'checkroom',
      'school',
      'wallet',
      'laptop',
      'trending_up',
      'card_giftcard',
      'attach_money',
      'more_horiz',
    ];

    showDialog(
      context: parentContext,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            _transactionType == 'expense'
                ? l.newExpenseCategory
                : l.newIncomeCategory,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l.categoryName,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Text(
                l.selectIcon,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: icons.map((iconName) {
                  final isSelected = selectedIcon == iconName;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedIcon = iconName),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorTheme.primary
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? colorTheme.primary
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(iconName),
                        size: 20,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                Navigator.pop(ctx); // Dialog kapat

                // Kategori oluştur
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId != null) {
                  try {
                    await Supabase.instance.client.from('categories').insert({
                      'user_id': userId,
                      'name': nameController.text.trim(),
                      'type': _transactionType,
                      'icon': selectedIcon,
                    });

                    // Provider'ları yenile
                    ref.invalidate(categoriesProvider);
                    ref.invalidate(incomeCategoriesProvider);
                    ref.invalidate(expenseCategoriesProvider);

                    if (mounted) {
                      Navigator.pop(parentContext); // Sheet kapat
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.categoryAdded),
                          backgroundColor: colorTheme.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            (e.toString().contains('SocketException') ||
                                    e.toString().contains('host lookup') ||
                                    e.toString().contains(
                                      'Network is unreachable',
                                    ))
                                ? l.networkError
                                : l.errorWithDetails(e.toString()),
                          ),
                          backgroundColor: colorTheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTheme.primary,
              ),
              child: Text(l.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategories() {
    final l = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 28, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            l.categoryNotFound,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () async {
              setState(() => _isLoading = true);
              final walletRepo = ref.read(walletRepositoryProvider);
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null) {
                await walletRepo.createDefaultCategories(userId);
                ref.invalidate(categoriesProvider);
                ref.invalidate(incomeCategoriesProvider);
                ref.invalidate(expenseCategoriesProvider);
              }
              setState(() => _isLoading = false);
            },
            icon: _isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_circle_outline, size: 16),
            label: Text(
              _isLoading ? 'Oluşturuluyor...' : 'Kategorileri Oluştur',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    return TextFormField(
      controller: _descriptionController,
      maxLines: 1,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: l.addNote,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        filled: true,
        fillColor: isDark ? colorTheme.surfaceDark : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey[200]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey[200]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }

  Widget _buildDateSelector() {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? ColorScheme.dark(primary: colorTheme.primary)
                    : ColorScheme.light(primary: colorTheme.primary),
              ),
              child: child!,
            );
          },
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: colorTheme.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              _isToday(_selectedDate)
                  ? l.today
                  : DateFormat(
                      'dd MMM yyyy',
                      Localizations.localeOf(context).languageCode,
                    ).format(_selectedDate),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSelector(AsyncValue<List<dynamic>> accounts) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    return accounts.when(
      data: (accountsList) {
        if (accountsList.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? colorTheme.surfaceDark : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey[200]!,
              ),
            ),
            child: Text(
              l.walletNotFound,
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }

        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: accountsList.length,
            itemBuilder: (context, index) {
              final account = accountsList[index];
              final isSelected = _selectedAccountId == account.id;

              return GestureDetector(
                onTap: () => setState(() => _selectedAccountId = account.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(
                    right: index < accountsList.length - 1 ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorTheme.primary
                        : (isDark ? colorTheme.surfaceDark : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? colorTheme.primary
                          : (isDark ? Colors.white24 : Colors.grey[200]!),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorTheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getAccountIcon(account.type),
                        color: isSelected ? Colors.white : colorTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            account.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          Text(
                            '₺${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Text(l.error),
    );
  }

  Widget _buildSaveButton() {
    final l = AppLocalizations.of(context)!;
    final isExpense = _transactionType == 'expense';
    final colorTheme = ref.watch(currentColorThemeProvider);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: isExpense ? colorTheme.error : colorTheme.success,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isExpense
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isExpense ? l.addExpense : l.addIncome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'gold':
        return Icons.diamond_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
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

  void _saveTransaction() async {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.selectWallet),
          backgroundColor: colorTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.isEmpty
        ? null
        : _descriptionController.text;
    final walletController = ref.read(walletControllerProvider);

    final success = await walletController.createTransaction(
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId,
      amount: amount,
      type: _transactionType,
      description: description,
      date: _selectedDate,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  _transactionType == 'expense'
                      ? l.expenseAdded
                      : l.incomeAdded,
                ),
              ],
            ),
            backgroundColor: colorTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.error),
            backgroundColor: colorTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
