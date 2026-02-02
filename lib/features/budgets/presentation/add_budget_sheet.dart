// lib/features/budgets/presentation/add_budget_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/category_model.dart';
import '../data/budget_provider.dart';
import '../models/budget_model.dart';

class AddBudgetSheet extends ConsumerStatefulWidget {
  final BudgetModel? budget;

  const AddBudgetSheet({super.key, this.budget});

  @override
  ConsumerState<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends ConsumerState<AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetPeriod _period = BudgetPeriod.monthly;
  int _startDay = 1;
  int _notifyAtPercent = 80;
  bool _notifyWhenExceeded = true;
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      final b = widget.budget!;
      _nameController.text = b.name;
      _amountController.text = b.amount.toStringAsFixed(2);
      _period = b.period;
      _startDay = b.startDay;
      _notifyAtPercent = b.notifyAtPercent;
      _notifyWhenExceeded = b.notifyWhenExceeded;
      _selectedCategoryId = b.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
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
                  isEditing ? l.editBudget : l.addBudget,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (isEditing)
                  IconButton(
                    onPressed: _deleteBudget,
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
                    // Bütçe adı
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: l.budgetName,
                        hintText: l.budgetNameHint,
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
                          return l.pleaseEnterBudgetName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tutar
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: l.budgetAmount,
                        prefixText: '₺ ',
                        prefixStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorTheme.primary,
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
                        final amount = double.tryParse(
                          value.replaceAll(',', '.'),
                        );
                        if (amount == null || amount <= 0) {
                          return l.pleaseEnterValidAmount;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kategori seçimi (opsiyonel)
                    categoriesAsync.when(
                      data: (categories) {
                        final expenseCategories = categories
                            .where((c) => c.type == 'expense')
                            .toList();
                        return _buildCategorySelector(
                          expenseCategories,
                          l,
                          isDark,
                          colorTheme,
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    ),
                    const SizedBox(height: 16),

                    // Periyot seçimi
                    _buildPeriodSelector(l, isDark, colorTheme),
                    const SizedBox(height: 16),

                    // Başlangıç günü (aylık bütçe için)
                    if (_period == BudgetPeriod.monthly)
                      _buildStartDaySelector(l, isDark, colorTheme),
                    const SizedBox(height: 16),

                    // Uyarı yüzdesi
                    _buildNotifySlider(l, isDark, colorTheme),
                    const SizedBox(height: 16),

                    // Aşıldığında bildir
                    SwitchListTile(
                      value: _notifyWhenExceeded,
                      onChanged: (value) =>
                          setState(() => _notifyWhenExceeded = value),
                      title: Text(
                        l.notifyWhenExceeded,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      activeColor: colorTheme.primary,
                      contentPadding: EdgeInsets.zero,
                    ),

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

  Widget _buildCategorySelector(
    List<CategoryModel> categories,
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l.category} (${l.optional})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Tüm harcamalar seçeneği
            ChoiceChip(
              label: Text(l.allExpenses),
              selected: _selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategoryId = null);
              },
              selectedColor: colorTheme.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedCategoryId == null ? colorTheme.primary : null,
                fontWeight: _selectedCategoryId == null
                    ? FontWeight.w600
                    : null,
              ),
            ),
            ...categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              return ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryId = selected ? category.id : null;
                  });
                },
                selectedColor: colorTheme.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? colorTheme.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.budgetPeriod,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: BudgetPeriod.values.map((period) {
            final isSelected = _period == period;
            return ChoiceChip(
              label: Text(_getPeriodLabel(period, l)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _period = period);
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

  Widget _buildStartDaySelector(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return DropdownButtonFormField<int>(
      value: _startDay,
      decoration: InputDecoration(
        labelText: l.budgetStartDay,
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
      items: List.generate(28, (i) => i + 1).map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text(
            '$day',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _startDay = value!),
    );
  }

  Widget _buildNotifySlider(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.notifyAtPercent,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '%$_notifyAtPercent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorTheme.primary,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _notifyAtPercent.toDouble(),
          min: 50,
          max: 100,
          divisions: 10,
          activeColor: colorTheme.primary,
          onChanged: (value) =>
              setState(() => _notifyAtPercent = value.round()),
        ),
      ],
    );
  }

  String _getPeriodLabel(BudgetPeriod period, AppLocalizations l) {
    switch (period) {
      case BudgetPeriod.weekly:
        return l.weekly;
      case BudgetPeriod.monthly:
        return l.monthly;
      case BudgetPeriod.yearly:
        return l.yearly;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final controller = ref.read(budgetControllerProvider.notifier);

    bool success;
    if (isEditing) {
      final updated = widget.budget!.copyWith(
        name: _nameController.text,
        categoryId: _selectedCategoryId,
        amount: amount,
        period: _period,
        startDay: _startDay,
        notifyAtPercent: _notifyAtPercent,
        notifyWhenExceeded: _notifyWhenExceeded,
      );
      success = await controller.update(updated);
    } else {
      success = await controller.create(
        name: _nameController.text,
        categoryId: _selectedCategoryId,
        amount: amount,
        period: _period,
        startDay: _startDay,
        notifyAtPercent: _notifyAtPercent,
        notifyWhenExceeded: _notifyWhenExceeded,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteBudget() async {
    final l = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteBudget),
        content: Text(l.deleteBudgetConfirmation),
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

    if (confirm == true && widget.budget != null) {
      await ref
          .read(budgetControllerProvider.notifier)
          .delete(widget.budget!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
