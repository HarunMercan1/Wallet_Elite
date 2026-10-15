import '../../../core/widgets/sheet_surface.dart';
import '../../../features/settings/data/settings_provider.dart';
import '../../../core/utils/currency_utils.dart';
// lib/features/recurring/presentation/add_recurring_sheet.dart

import '../../../core/utils/category_l10n.dart';
import '../../../core/utils/amount_input.dart';
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
  int _dayOfWeek = 1; // 1 = Pazartesi … 7 = Pazar (DateTime.weekday)
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _saveFailed = false;

  bool get isEditing => widget.recurring != null;

  @override
  void initState() {
    super.initState();
    if (widget.recurring != null) {
      final r = widget.recurring!;
      _amountController.text = amountToInputText(r.amount);
      _descriptionController.text = r.description ?? '';
      _isIncome = r.isIncome;
      _frequency = r.frequency;
      _dayOfMonth = r.dayOfMonth ?? 1;
      // Veritabanında 0 = Pazar … 6 = Cumartesi
      final storedDay = r.dayOfWeek ?? 1;
      _dayOfWeek = storedDay == 0 ? 7 : storedDay;
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

    return SheetSurface(
      color: colorTheme.cardColor,
      height: MediaQuery.sizeOf(context).height * 0.85,
      // Klavye açılınca kaydet butonu ve alanlar altında kalmasın
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing
                        ? l.editRecurringTransaction
                        : l.addRecurringTransaction,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorTheme.textPrimary,
                    ),
                  ),
                ),
                if (isEditing)
                  IconButton(
                    onPressed: _deleteRecurring,
                    icon: Icon(Icons.delete_outline, color: colorTheme.error),
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

          if (_saveFailed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l.errorOccurred,
                style: TextStyle(color: colorTheme.error, fontSize: 13),
              ),
            ),

          // Kaydet butonu
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorTheme.primary,
                  foregroundColor: colorTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: colorTheme.onPrimary,
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
            onTap: () => _setType(isIncome: false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isIncome
                    ? colorTheme.expense.withValues(alpha: 0.15)
                    : colorTheme.textSecondary.withValues(alpha: 0.1),
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
                    color: !_isIncome
                        ? colorTheme.expense
                        : colorTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l.expense,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !_isIncome
                            ? colorTheme.expense
                            : colorTheme.textSecondary,
                      ),
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
            onTap: () => _setType(isIncome: true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isIncome
                    ? colorTheme.income.withValues(alpha: 0.15)
                    : colorTheme.textSecondary.withValues(alpha: 0.1),
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
                    color: _isIncome
                        ? colorTheme.income
                        : colorTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l.income,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _isIncome
                            ? colorTheme.income
                            : colorTheme.textSecondary,
                      ),
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

  /// Gelir/gider değişince kategori listesi de değişir; eski seçim geçersizdir.
  void _setType({required bool isIncome}) {
    if (_isIncome == isIncome) return;
    setState(() {
      _isIncome = isIncome;
      _selectedCategoryId = null;
    });
  }

  Widget _buildAmountField(
    AppLocalizations l,
    bool isDark,
    ColorTheme colorTheme,
  ) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: const [AmountInputFormatter()],
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: l.amount,
        prefixText: '${CurrencyUtils.getSymbol(ref.watch(currencyProvider))} ',
        prefixStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _isIncome ? colorTheme.income : colorTheme.expense,
        ),
        filled: true,
        fillColor: colorTheme.borderColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l.pleaseEnterAmount;
        }
        if (parseAmount(value) == null) return l.pleaseEnterValidAmount;
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
      style: TextStyle(color: colorTheme.textPrimary),
      decoration: InputDecoration(
        labelText: l.description,
        hintText: l.descriptionHint,
        filled: true,
        fillColor: colorTheme.borderColor,
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
    // İlk hesabı varsayılan olarak seç (seçili hesap silinmişse de)
    if (!accounts.any((a) => a.id == _selectedAccountId)) {
      _selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedAccountId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l.selectAccount,
        filled: true,
        fillColor: colorTheme.borderColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: colorTheme.cardColor,
      items: accounts.map((account) {
        return DropdownMenuItem(
          value: account.id,
          child: Text(
            account.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorTheme.textPrimary),
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
    final hasSelected = categories.any((c) => c.id == _selectedCategoryId);

    return DropdownButtonFormField<String>(
      // Tür değişince alanın iç durumu da sıfırlansın
      key: ValueKey(_isIncome),
      initialValue: hasSelected ? _selectedCategoryId : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l.selectCategory,
        filled: true,
        fillColor: colorTheme.borderColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: colorTheme.cardColor,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(
            localizedCategoryName(category, l) ?? category.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorTheme.textPrimary),
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
            color: colorTheme.textSecondary,
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
              selectedColor: colorTheme.primary.withValues(alpha: 0.2),
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
      initialValue: _dayOfMonth,
      decoration: InputDecoration(
        labelText: l.dayOfMonth,
        filled: true,
        fillColor: colorTheme.borderColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: colorTheme.cardColor,
      items: List.generate(31, (i) => i + 1).map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text(
            day.toString(),
            style: TextStyle(color: colorTheme.textPrimary),
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
      initialValue: _dayOfWeek,
      decoration: InputDecoration(
        labelText: l.dayOfWeek,
        filled: true,
        fillColor: colorTheme.borderColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: colorTheme.cardColor,
      items: List.generate(7, (i) {
        return DropdownMenuItem(
          value: i + 1,
          child: Text(days[i], style: TextStyle(color: colorTheme.textPrimary)),
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
                color: colorTheme.borderColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.startDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(_startDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorTheme.textPrimary,
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
                color: colorTheme.borderColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l.endDate,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorTheme.textSecondary,
                          ),
                        ),
                      ),
                      if (_endDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _endDate = null),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: colorTheme.textSecondary,
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
                          ? colorTheme.textPrimary
                          : colorTheme.textSecondary,
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
    // Başlangıç tarihi kayıt oluşturulduktan sonra değiştirilemez
    if (!isEndDate && isEditing) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Bitiş tarihi başlangıçtan (ve bugünden) önce olamaz
    final endFloor = _startDate.isAfter(today) ? _startDate : today;
    final endInitial = (_endDate != null && !_endDate!.isBefore(endFloor))
        ? _endDate!
        : endFloor;

    final picked = await showDatePicker(
      context: context,
      initialDate: isEndDate ? endInitial : _startDate,
      firstDate: isEndDate ? endFloor : DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isEndDate) {
          _endDate = picked;
        } else {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    setState(() {
      _isLoading = true;
      _saveFailed = false;
    });

    final amount = parseAmount(_amountController.text)!;
    final description = _descriptionController.text.trim();
    final dayOfMonth = _frequency == RecurringFrequency.monthly
        ? _dayOfMonth
        : null;
    // Veritabanı 0 = Pazar … 6 = Cumartesi bekler
    final dayOfWeek = _frequency == RecurringFrequency.weekly
        ? _dayOfWeek % 7
        : null;

    final controller = ref.read(recurringControllerProvider.notifier);

    bool success;
    if (isEditing) {
      final original = widget.recurring!;
      var updated = original.copyWith(
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        description: description.isEmpty ? null : description,
        frequency: _frequency,
        dayOfMonth: dayOfMonth,
        dayOfWeek: dayOfWeek,
        endDate: _endDate,
      );
      // Takvim değiştiyse sıradaki çalışma tarihi de yeniden hesaplanır
      final scheduleChanged =
          original.frequency != updated.frequency ||
          original.dayOfMonth != updated.dayOfMonth ||
          original.dayOfWeek != updated.dayOfWeek;
      if (scheduleChanged) {
        updated = updated.copyWith(
          nextExecutionDate: updated.nextDateFrom(DateTime.now()),
        );
      }
      success = await controller.update(updated);
    } else {
      success = await controller.create(
        accountId: _selectedAccountId!,
        categoryId: _selectedCategoryId,
        amount: amount,
        type: _isIncome ? 'income' : 'expense',
        description: description.isEmpty ? null : description,
        frequency: _frequency,
        dayOfMonth: dayOfMonth,
        dayOfWeek: dayOfWeek,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _saveFailed = !success;
    });

    if (success) Navigator.of(context).pop();
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
            child: Text(
              l.delete,
              style: TextStyle(color: context.colors.error),
            ),
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
