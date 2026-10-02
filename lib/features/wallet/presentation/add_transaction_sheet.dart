import '../../../features/settings/data/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/ads/full_screen_ads.dart';
import '../data/wallet_provider.dart';
import '../models/category_model.dart';
import '../../../core/utils/category_l10n.dart';

/// Klavye yüksekliği kadar alttan boşluk bırakır. viewInsets'e yalnızca bu
/// küçük widget bağımlıdır; klavye animasyonunun her karesinde form yeniden
/// kurulmaz, yalnızca yerleşim güncellenir.
class _KeyboardInset extends StatelessWidget {
  final Widget child;

  const _KeyboardInset({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}

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
  final _amountFocusNode = FocusNode();

  late TabController _tabController;
  String _transactionType = 'expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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
    _amountFocusNode.dispose();
    super.dispose();
  }

  String _getCategoryName(CategoryModel category, AppLocalizations l) =>
      localizedCategoryName(category, l) ?? category.name;

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
      // Tutar kartı ve kaydet butonu altta sabit durur, klavye açılınca onun
      // hemen üstüne çıkar; geri kalan alanlar aralarında kayar.
      child: _KeyboardInset(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorTheme.outline,
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Favorite Categories (6 adet + Daha Fazla)
                      _buildSectionTitle(l.category, Icons.category_outlined),
                      const SizedBox(height: 12),
                      _buildFavoriteCategoryGrid(categories),

                      const SizedBox(height: 20),

                      // 2. Description
                      _buildSectionTitle(l.note, Icons.note_outlined),
                      const SizedBox(height: 10),
                      _buildDescriptionInput(),

                      const SizedBox(height: 20),

                      // 3. Date Selection
                      _buildDateSelector(),

                      const SizedBox(height: 20),

                      // 4. Wallet Selection
                      _buildSectionTitle(
                        l.wallet,
                        Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(height: 10),
                      _buildWalletSelector(accounts),
                    ],
                  ),
                ),
              ),

              // 5. Amount Input + Save Button (altta sabit)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAmountInput(),
                      const SizedBox(height: 12),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded, color: context.colors.textPrimary),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: context.colors.subtleCardColor,
            ),
          ),
          Expanded(
            child: Text(
              l.addTransaction,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
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
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      decoration: BoxDecoration(
        color: colorTheme.subtleCardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _transactionType == 'expense'
              ? colorTheme.error.withValues(alpha: 0.9)
              : colorTheme.success.withValues(alpha: 0.9),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: colorTheme.textSecondary,
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

    return GestureDetector(
      // Kartın herhangi bir yerine dokununca tutar alanı odaklanır
      behavior: HitTestBehavior.opaque,
      onTap: _amountFocusNode.requestFocus,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.10),
              color.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.amount,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  CurrencyUtils.getSymbol(ref.watch(currencyProvider)),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: IntrinsicWidth(
                    child: TextFormField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      showCursor: false,
                      style: TextStyle(
                        fontSize: 40,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 40,
                          height: 1.15,
                          fontWeight: FontWeight.bold,
                          color: color.withValues(alpha: 0.3),
                        ),
                        // Çerçevesiz: kartın kendisi alanı çevreliyor
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
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
            color: colorTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCategoryGrid(
    AsyncValue<List<CategoryModel>> categories,
  ) {
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
    final colorTheme = ref.watch(currentColorThemeProvider);

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = category.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorTheme.primary : colorTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colorTheme.primary : colorTheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category.icon ?? 'category'),
              size: 16,
              color: isSelected
                  ? colorTheme.onPrimary
                  : colorTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              _getCategoryName(category, l), // Use translated name
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? colorTheme.onPrimary
                    : colorTheme.textPrimary,
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
    return GestureDetector(
      onTap: () => _showAllCategoriesSheet(allCategories),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorTheme.subtleCardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorTheme.outline, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.more_horiz, size: 16, color: colorTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              l.more,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorTheme.textSecondary,
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
            height: MediaQuery.sizeOf(context).height * 0.7,
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
                    color: colorTheme.outline,
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
                            color: colorTheme.textPrimary,
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
                Divider(height: 1, color: colorTheme.borderColor),
                // İpucu
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: colorTheme.subtleCardColor,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: colorTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l.longPressToFavorite,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorTheme.textSecondary,
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
                                    : colorTheme.subtleCardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? colorTheme.primary
                                      : (isFavorite
                                            ? colorTheme.warning
                                            : colorTheme.outline),
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
                                            ? colorTheme.onPrimary
                                            : colorTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          _getCategoryName(category, l),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? colorTheme.onPrimary
                                                : colorTheme.textPrimary,
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
                                  color: colorTheme.warning,
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
                            : colorTheme.subtleCardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? colorTheme.primary
                              : colorTheme.outline,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(iconName),
                        size: 20,
                        color: isSelected
                            ? colorTheme.onPrimary
                            : colorTheme.textSecondary,
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

                // Async işlemden önce al; sheet kapanınca context geçersizleşebilir
                final messenger = ScaffoldMessenger.of(context);
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
                      'is_custom': true,
                    });

                    // Provider'ları yenile
                    ref.invalidate(categoriesProvider);
                    ref.invalidate(incomeCategoriesProvider);
                    ref.invalidate(expenseCategoriesProvider);

                    if (!parentContext.mounted) return;
                    Navigator.pop(parentContext); // Sheet kapat
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l.categoryAdded),
                        backgroundColor: colorTheme.success,
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
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
        color: context.colors.subtleCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 28,
            color: context.colors.textMuted,
          ),
          const SizedBox(height: 8),
          Text(
            l.categoryNotFound,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
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
              _isLoading ? l.loading : l.createCategories,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);
    return TextFormField(
      controller: _descriptionController,
      maxLines: 1,
      style: TextStyle(color: colorTheme.textPrimary),
      decoration: InputDecoration(
        hintText: l.addNote,
        hintStyle: TextStyle(color: colorTheme.textSecondary, fontSize: 14),
        filled: true,
        fillColor: colorTheme.subtleCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorTheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorTheme.outline),
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
    final colorTheme = ref.watch(currentColorThemeProvider);
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(data: Theme.of(context), child: child!);
          },
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorTheme.subtleCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorTheme.outline),
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
                color: colorTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: colorTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSelector(AsyncValue<List<dynamic>> accounts) {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);
    return accounts.when(
      data: (accountsList) {
        if (accountsList.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorTheme.subtleCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorTheme.outline),
            ),
            child: Text(
              l.walletNotFound,
              style: TextStyle(color: colorTheme.textSecondary),
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
                        : colorTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? colorTheme.primary
                          : colorTheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getAccountIcon(account.type),
                        color: isSelected
                            ? colorTheme.onPrimary
                            : colorTheme.primary,
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
                                  ? colorTheme.onPrimary
                                  : colorTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${CurrencyUtils.getSymbol(ref.watch(currencyProvider))}${NumberFormat('#,##0.00', 'tr_TR').format(account.balance)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? colorTheme.onPrimary.withValues(alpha: 0.7)
                                  : colorTheme.textSecondary,
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
        final interstitial = ref.read(interstitialAdServiceProvider);
        Navigator.pop(context);
        interstitial.onUserAction();
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
