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

  TransactionFilterState copyWith({
    String? type,
    List<String>? selectedCategoryIds,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    SortOption? sortOption,
  }) {
    return TransactionFilterState(
      type: type ?? this.type,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
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
