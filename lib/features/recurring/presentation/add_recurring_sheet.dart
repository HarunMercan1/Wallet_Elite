// lib/features/recurring/presentation/add_recurring_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/account_model.dart';
import '../../wallet/models/category_model.dart';
import '../data/recurring_provider.dart';
import '../models/recurring_transaction_model.dart';

class AddRecurringSheet extends ConsumerStatefulWidget {
  final RecurringTransactionModel? recurring;

  const AddRecurringSheet({super.key, this.recurring});

  @override
  ConsumerState<AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends ConsumerState<AddRecurringSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isIncome = false;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  int _dayOfMonth = 1;
  int _dayOfWeek = 1; // Pazartesi
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get isEditing => widget.recurring != null;

  @override
  void initState() {
    super.initState();
    if (widget.recurring != null) {
      final r = widget.recurring!;
      _amountController.text = r.amount.toStringAsFixed(2);
      _descriptionController.text = r.description ?? '';
      _isIncome = r.isIncome;
      _frequency = r.frequency;
      _dayOfMonth = r.dayOfMonth ?? 1;
      _dayOfWeek = r.dayOfWeek ?? 1;
      _startDate = r.startDate;
      _endDate = r.endDate;
      _selectedAccountId = r.accountId;
      _selectedCategoryId = r.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);

    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? colorTheme.surfaceDark : colorTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  isEditing
                      ? l.editRecurringTransaction
                      : l.addRecurringTransaction,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isEditing)
                  IconButton(
                    onPressed: _deleteRecurring,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gelir/Gider seçimi
                    _buildTypeSelector(l, colorTheme),
                    const SizedBox(height: 20),

                    // Tutar
                    _buildAmountField(l, isDark, colorTheme),
                    const SizedBox(height: 16),

                    // Açıklama
                    _buildDescriptionField(l, isDark, colorTheme),
                    const SizedBox(height: 16),

                    // Hesap seçimi
                    accountsAsync.when(
                      data: (accounts) => _buildAccountSelector(
                        accounts,
                        l,
                        isDark,
                        colorTheme,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),

                    // Kategori seçimi
                    categoriesAsync.when(
                      data: (categories) {
                        final filtered = categories
                            .where(
                              (c) =>
                                  c.type == (_isIncome ? 'income' : 'expense'),
                            )
                            .toList();
                        return _buildCategorySelector(
                          filtered,
                          l,
                          isDark,
                          colorTheme,
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),

                    // Frekans seçimi
                    _buildFrequencySelector(l, isDark, colorTheme),
                    const SizedBox(height: 16),

                    // Gün seçimi (frekansa göre)
                    if (_frequency == RecurringFrequency.monthly)
                      _buildDayOfMonthSelector(l, isDark, colorTheme),
                    if (_frequency == RecurringFrequency.weekly)
                      _buildDayOfWeekSelector(l, isDark, colorTheme),
                    const SizedBox(height: 16),

                    // Tarihler
                    _buildDateSelectors(l, isDark, colorTheme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Kaydet butonu
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? l.save : l.add,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l, ColorTheme colorTheme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isIncome = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isIncome
                    ? colorTheme.expense.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: !_isIncome
                    ? Border.all(color: colorTheme.expense, width: 2)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: !_isIncome ? colorTheme.expense : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.expense,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: !_isIncome ? colorTheme.expense : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isIncome = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isIncome
                    ? colorTheme.income.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: _isIncome
                    ? Border.all(color: colorTheme.income, width: 2)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    color: _isIncome ? colorTheme.income : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.income,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _isIncome ? colorTheme.income : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: l.amount,
        prefixText: '₺ ',
        prefixStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _isIncome ? colorTheme.income : colorTheme.expense,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l.pleaseEnterAmount;
        }
        final amount = double.tryParse(value.replaceAll(',', '.'));
        if (amount == null || amount <= 0) {
          return l.pleaseEnterValidAmount;
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return TextFormField(
      controller: _descriptionController,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: l.description,
        hintText: l.descriptionHint,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAccountSelector(
    List<AccountModel> accounts,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    // İlk hesabı varsayılan olarak seç
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return DropdownButtonFormField<String>(
      value: _selectedAccountId,
      decoration: InputDecoration(
        labelText: l.selectAccount,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? colorTheme.cardDark : colorTheme.cardLight,
      items: accounts.map((account) {
        return DropdownMenuItem(
          value: account.id,
          child: Text(
            account.name,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedAccountId = value),
      validator: (value) {
        if (value == null) return l.pleaseSelectAccount;
        return null;
      },
    );
  }

  Widget _buildCategorySelector(
    List<CategoryModel> categories,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: l.selectCategory,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? colorTheme.cardDark : colorTheme.cardLight,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(
            category.name,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
    );
  }

  Widget _buildFrequencySelector(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.frequency,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: RecurringFrequency.values.map((freq) {
            final isSelected = _frequency == freq;
            return ChoiceChip(
              label: Text(_getFrequencyLabel(freq, l)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _frequency = freq);
              },
              selectedColor: colorTheme.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? colorTheme.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayOfMonthSelector(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return DropdownButtonFormField<int>(
      value: _dayOfMonth,
      decoration: InputDecoration(
        labelText: l.dayOfMonth,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? colorTheme.cardDark : colorTheme.cardLight,
      items: List.generate(31, (i) => i + 1).map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text(
            day.toString(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _dayOfMonth = value!),
    );
  }

  Widget _buildDayOfWeekSelector(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final days = [
      l.monday,
      l.tuesday,
      l.wednesday,
      l.thursday,
      l.friday,
      l.saturday,
      l.sunday,
    ];

    return DropdownButtonFormField<int>(
      value: _dayOfWeek,
      decoration: InputDecoration(
        labelText: l.dayOfWeek,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? colorTheme.cardDark : colorTheme.cardLight,
      items: List.generate(7, (i) {
        return DropdownMenuItem(
          value: i + 1,
          child: Text(
            days[i],
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _dayOfWeek = value!),
    );
  }

  Widget _buildDateSelectors(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(isEndDate: false),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.startDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(_startDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(isEndDate: true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.endDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      if (_endDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _endDate = null),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _endDate != null
                        ? dateFormat.format(_endDate!)
                        : l.optional,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _endDate != null
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getFrequencyLabel(RecurringFrequency freq, AppLocalizations l) {
    switch (freq) {
      case RecurringFrequency.daily:
        return l.daily;
      case RecurringFrequency.weekly:
        return l.weekly;
      case RecurringFrequency.monthly:
        return l.monthly;
      case RecurringFrequency.yearly:
        return l.yearly;
    }
  }

  Future<void> _selectDate({required bool isEndDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEndDate ? (_endDate ?? DateTime.now()) : _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isEndDate) {
          _endDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));

    final controller = ref.read(recurringControllerProvider.notifier);

    bool success;
    if (isEditing) {
      final updated = widget.recurring!.copyWith(
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        frequency: _frequency,
        dayOfMonth: _frequency == RecurringFrequency.monthly
            ? _dayOfMonth
            : null,
        dayOfWeek: _frequency == RecurringFrequency.weekly ? _dayOfWeek : null,
        endDate: _endDate,
      );
      success = await controller.update(updated);
    } else {
      success = await controller.create(
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId,
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        frequency: _frequency,
        dayOfMonth: _frequency == RecurringFrequency.monthly
            ? _dayOfMonth
            : null,
        dayOfWeek: _frequency == RecurringFrequency.weekly ? _dayOfWeek : null,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteRecurring() async {
    final l = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteRecurringTransaction),
        content: Text(l.deleteRecurringConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.recurring != null) {
      await ref
          .read(recurringControllerProvider.notifier)
          .delete(widget.recurring!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
