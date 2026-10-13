// lib/features/budgets/models/budget_model.dart
import '../../../core/utils/date_utils.dart';

/// Bütçe periyodu enum'u
enum BudgetPeriod {
  weekly,
  monthly,
  yearly;

  String get name {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'weekly';
      case BudgetPeriod.monthly:
        return 'monthly';
      case BudgetPeriod.yearly:
        return 'yearly';
    }
  }

  static BudgetPeriod fromString(String value) {
    switch (value) {
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'yearly':
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.monthly;
    }
  }
}

/// Bütçe modeli
class BudgetModel {
  final String id;
  final String userId;
  final String name;
  final String? categoryId;
  final double amount;
  final BudgetPeriod period;
  final int startDay;
  final bool isActive;
  final int notifyAtPercent;
  final bool notifyWhenExceeded;
  final DateTime createdAt;
  final DateTime updatedAt;

  // İlişkili veriler (join ile alınabilir)
  final String? categoryName;
  final String? categoryIcon;

  // Hesaplanan değerler (client-side)
  final double? spent;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.name,
    this.categoryId,
    required this.amount,
    required this.period,
    this.startDay = 1,
    this.isActive = true,
    this.notifyAtPercent = 80,
    this.notifyWhenExceeded = true,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryIcon,
    this.spent,
  });

  /// Bütçe kullanım yüzdesi
  double get usagePercent {
    if (amount <= 0) return 0;
    final spentAmount = spent ?? 0;
    return (spentAmount / amount * 100).clamp(0, 999);
  }

  /// Kalan miktar
  double get remaining {
    final spentAmount = spent ?? 0;
    return amount - spentAmount;
  }

  /// Bütçe aşıldı mı?
  bool get isExceeded => remaining < 0;

  /// Uyarı seviyesinde mi?
  bool get isWarning => usagePercent >= notifyAtPercent && !isExceeded;

  /// Güvenli bölgede mi?
  bool get isSafe => usagePercent < notifyAtPercent;

  /// Dönem başlangıç tarihini hesapla. [now] testler içindir.
  DateTime getPeriodStartDate({DateTime? now}) {
    final today = now ?? DateTime.now();

    switch (period) {
      case BudgetPeriod.weekly:
        // Haftanın başlangıcı (Pazartesi)
        return DateTime(
          today.year,
          today.month,
          today.day - (today.weekday - 1),
        );

      case BudgetPeriod.monthly:
        // Bu ayın başlangıç günü (kısa aylarda ayın son günü) geldiyse bu ay,
        // gelmediyse önceki ay
        final thisMonthStart = _monthDay(today.year, today.month, startDay);
        if (!today.isBefore(thisMonthStart)) return thisMonthStart;
        return _monthDay(today.year, today.month - 1, startDay);

      case BudgetPeriod.yearly:
        final thisYearStart = _monthDay(today.year, 1, startDay);
        if (!today.isBefore(thisYearStart)) return thisYearStart;
        return _monthDay(today.year - 1, 1, startDay);
    }
  }

  /// Dönem bitiş tarihini (hariç) hesapla = bir sonraki dönemin başlangıcı
  DateTime getPeriodEndDate({DateTime? now}) {
    final start = getPeriodStartDate(now: now);

    switch (period) {
      case BudgetPeriod.weekly:
        return DateTime(start.year, start.month, start.day + 7);
      case BudgetPeriod.monthly:
        return _monthDay(start.year, start.month + 1, startDay);
      case BudgetPeriod.yearly:
        return _monthDay(start.year + 1, 1, startDay);
    }
  }

  /// [year]/[month] için [day]. gün; ay daha kısaysa ayın son günü
  /// (ör. başlangıç günü 31 → Şubat'ta 28/29). Ay taşmalarını normalize eder.
  static DateTime _monthDay(int year, int month, int day) {
    final firstOfMonth = DateTime(year, month, 1);
    final lastDay = DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0).day;
    return DateTime(
      firstOfMonth.year,
      firstOfMonth.month,
      day > lastDay ? lastDay : day,
    );
  }

  /// JSON'dan model oluştur
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      period: BudgetPeriod.fromString(json['period'] as String),
      startDay: json['start_day'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      notifyAtPercent: json['notify_at_percent'] as int? ?? 80,
      notifyWhenExceeded: json['notify_when_exceeded'] as bool? ?? true,
      createdAt: parseServerTimestamp(json['created_at'] as String),
      updatedAt: parseServerTimestamp(json['updated_at'] as String),
      categoryName: json['categories']?['name'] as String?,
      categoryIcon: json['categories']?['icon'] as String?,
    );
  }

  /// Modeli JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category_id': categoryId,
      'amount': amount,
      'period': period.name,
      'start_day': startDay,
      'is_active': isActive,
      'notify_at_percent': notifyAtPercent,
      'notify_when_exceeded': notifyWhenExceeded,
    };
  }

  static const _unset = Object();

  /// Güncellenmiş kopya oluştur. [categoryId] açıkça `null` verilirse
  /// kategori kaldırılır (tüm harcamalar bütçesi).
  BudgetModel copyWith({
    String? id,
    String? userId,
    String? name,
    Object? categoryId = _unset,
    double? amount,
    BudgetPeriod? period,
    int? startDay,
    bool? isActive,
    int? notifyAtPercent,
    bool? notifyWhenExceeded,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryIcon,
    double? spent,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDay: startDay ?? this.startDay,
      isActive: isActive ?? this.isActive,
      notifyAtPercent: notifyAtPercent ?? this.notifyAtPercent,
      notifyWhenExceeded: notifyWhenExceeded ?? this.notifyWhenExceeded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      spent: spent ?? this.spent,
    );
  }
}
