enum SortOption { dateDesc, dateAsc, amountDesc, amountAsc }

class TransactionFilterState {
  final String type; // 'all', 'income', 'expense'
  final List<String> selectedCategoryIds;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final SortOption sortOption;

  const TransactionFilterState({
    this.type = 'all',
    this.selectedCategoryIds = const [],
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.sortOption = SortOption.dateDesc,
  });

  static const _unset = Object();

  /// Tarih ve tutar sınırları açıkça `null` verilerek kaldırılabilir.
  TransactionFilterState copyWith({
    String? type,
    List<String>? selectedCategoryIds,
    Object? startDate = _unset,
    Object? endDate = _unset,
    Object? minAmount = _unset,
    Object? maxAmount = _unset,
    SortOption? sortOption,
  }) {
    return TransactionFilterState(
      type: type ?? this.type,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      startDate: identical(startDate, _unset)
          ? this.startDate
          : startDate as DateTime?,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      minAmount: identical(minAmount, _unset)
          ? this.minAmount
          : minAmount as double?,
      maxAmount: identical(maxAmount, _unset)
          ? this.maxAmount
          : maxAmount as double?,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get hasFilters =>
      type != 'all' ||
      selectedCategoryIds.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null;
}
