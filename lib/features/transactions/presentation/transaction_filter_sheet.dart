import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/category_model.dart';
import 'transaction_filter_state.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  final TransactionFilterState initialState;

  const TransactionFilterSheet({super.key, required this.initialState});

  @override
  ConsumerState<TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState
    extends ConsumerState<TransactionFilterSheet> {
  late TransactionFilterState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrele', // TODO: Localize
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _state = const TransactionFilterState();
                    });
                  },
                  child: Text(
                    'Sıfırla', // TODO: Localize
                    style: TextStyle(color: colorTheme.error),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Sıralama
                _buildSectionTitle(l.sort ?? 'Sıralama', isDark),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortChip(SortOption.dateDesc, 'En Yeni', isDark),
                    _buildSortChip(SortOption.dateAsc, 'En Eski', isDark),
                    _buildSortChip(
                      SortOption.amountDesc,
                      'En Yüksek Tutar',
                      isDark,
                    ),
                    _buildSortChip(
                      SortOption.amountAsc,
                      'En Düşük Tutar',
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // İşlem Tipi
                _buildSectionTitle('İşlem Tipi', isDark),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildTypeChip('all', l.all, isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTypeChip('income', l.income, isDark)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeChip('expense', l.expense, isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tarih Aralığı
                _buildSectionTitle(l.date, isDark),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateButton(
                        context,
                        _state.startDate,
                        'Başlangıç',
                        (date) => setState(
                          () => _state = _state.copyWith(startDate: date),
                        ),
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateButton(
                        context,
                        _state.endDate,
                        'Bitiş',
                        (date) => setState(
                          () => _state = _state.copyWith(endDate: date),
                        ),
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Kategoriler
                _buildSectionTitle(l.categories, isDark),
                const SizedBox(height: 8),
                categoriesAsync.when(
                  data: (categories) {
                    final incomeCats = categories
                        .where((c) => c.type == 'income')
                        .toList();
                    final expenseCats = categories
                        .where((c) => c.type == 'expense')
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_state.type == 'all' ||
                            _state.type == 'income') ...[
                          Text(
                            l.income,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: incomeCats
                                .map((c) => _buildCategoryChip(c, isDark))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_state.type == 'all' ||
                            _state.type == 'expense') ...[
                          Text(
                            l.expense,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: expenseCats
                                .map((c) => _buildCategoryChip(c, isDark))
                                .toList(),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? colorTheme.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _state);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Uygula', // Localize
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildSortChip(SortOption option, String label, bool isDark) {
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isSelected = _state.sortOption == option;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (bool selected) {
        setState(() => _state = _state.copyWith(sortOption: option));
      },
      backgroundColor: isDark ? colorTheme.surfaceDark : Colors.grey[100],
      selectedColor: colorTheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? colorTheme.primary
            : (isDark ? Colors.white : Colors.black),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colorTheme.primary : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label, bool isDark) {
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isSelected = _state.type == value;
    return GestureDetector(
      onTap: () => setState(() => _state = _state.copyWith(type: value)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorTheme.primary
              : (isDark ? colorTheme.surfaceDark : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorTheme.primary : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    DateTime? date,
    String placeholder,
    Function(DateTime?) onChanged,
    bool isDark,
  ) {
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isSelected = date != null;
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorTheme.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: isSelected ? colorTheme.primary : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('dd MMM yyyy').format(date)
                    : placeholder,
                style: TextStyle(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close, size: 16, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(CategoryModel category, bool isDark) {
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isSelected = _state.selectedCategoryIds.contains(category.id);
    return FilterChip(
      selected: isSelected,
      label: Text(
        category.name,
      ), // Should use helper for localized name if possible
      onSelected: (bool selected) {
        final ids = List<String>.from(_state.selectedCategoryIds);
        if (selected) {
          ids.add(category.id);
        } else {
          ids.remove(category.id);
        }
        setState(() => _state = _state.copyWith(selectedCategoryIds: ids));
      },
      backgroundColor: isDark ? colorTheme.surfaceDark : Colors.grey[100],
      selectedColor: colorTheme.primary.withOpacity(0.2),
      checkmarkColor: colorTheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? colorTheme.primary
            : (isDark ? Colors.white : Colors.black),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colorTheme.primary : Colors.transparent,
        ),
      ),
    );
  }
}
