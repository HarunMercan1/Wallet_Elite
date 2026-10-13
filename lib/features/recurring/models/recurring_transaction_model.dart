// lib/features/recurring/models/recurring_transaction_model.dart
import '../../../core/utils/date_utils.dart';

/// Tekrarlama sıklığı
enum RecurringFrequency {
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  final String value;
  const RecurringFrequency(this.value);

  static RecurringFrequency fromString(String value) {
    return RecurringFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecurringFrequency.monthly,
    );
  }
}

/// Bir tekrarlayan işlemin, [notBefore] gününde ya da sonrasında çalışacağı
/// ilk tarih. Başlangıç tarihi daha ilerideyse oradan başlar.
///
/// - Haftalık: [dayOfWeek] (0 = Pazar … 6 = Cumartesi) verilmişse o güne denk
///   gelen ilk tarih; sonraki tekrarlar sunucuda +7 gün ile ilerler.
/// - Aylık: [dayOfMonth] (yoksa başlangıç günü); kısa aylarda ayın son günü.
/// - Yıllık: başlangıç tarihinin ay/günü.
DateTime firstRecurringDate({
  required RecurringFrequency frequency,
  required DateTime startDate,
  required DateTime notBefore,
  int? dayOfMonth,
  int? dayOfWeek,
}) {
  final start = DateTime(startDate.year, startDate.month, startDate.day);
  final floor = DateTime(notBefore.year, notBefore.month, notBefore.day);
  final base = start.isAfter(floor) ? start : floor;

  DateTime clamped(int year, int month, int day) {
    final first = DateTime(year, month, 1);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(first.year, first.month, day > lastDay ? lastDay : day);
  }

  switch (frequency) {
    case RecurringFrequency.daily:
      return base;

    case RecurringFrequency.weekly:
      if (dayOfWeek == null) {
        // Başlangıç tarihinin haftalık ritmini koru
        final passed = base.difference(start).inDays;
        final remainder = passed % 7;
        return remainder == 0
            ? base
            : DateTime(base.year, base.month, base.day + (7 - remainder));
      }
      final delta = (dayOfWeek - base.weekday % 7 + 7) % 7;
      return DateTime(base.year, base.month, base.day + delta);

    case RecurringFrequency.monthly:
      final day = dayOfMonth ?? start.day;
      final thisMonth = clamped(base.year, base.month, day);
      if (!thisMonth.isBefore(base)) return thisMonth;
      return clamped(base.year, base.month + 1, day);

    case RecurringFrequency.yearly:
      final thisYear = clamped(base.year, start.month, start.day);
      if (!thisYear.isBefore(base)) return thisYear;
      return clamped(base.year + 1, start.month, start.day);
  }
}

/// Tekrarlayan işlem modeli
class RecurringTransactionModel {
  final String id;
  final String userId;
  final String accountId;
  final String? categoryId;
  final double amount;
  final String type; // income veya expense
  final String? description;
  final RecurringFrequency frequency;
  final int? dayOfMonth; // Aylık için (1-31)
  final int? dayOfWeek; // Haftalık için (0-6, 0=Pazar)
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextExecutionDate;
  final DateTime? lastExecutionDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecurringTransactionModel({
    required this.id,
    required this.userId,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.frequency,
    this.dayOfMonth,
    this.dayOfWeek,
    required this.startDate,
    this.endDate,
    required this.nextExecutionDate,
    this.lastExecutionDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan model oluştur
  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      accountId: json['account_id'] as String,
      categoryId: json['category_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String?,
      frequency: RecurringFrequency.fromString(json['frequency'] as String),
      dayOfMonth: json['day_of_month'] as int?,
      dayOfWeek: json['day_of_week'] as int?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      nextExecutionDate: DateTime.parse(json['next_execution_date'] as String),
      lastExecutionDate: json['last_execution_date'] != null
          ? DateTime.parse(json['last_execution_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: parseServerTimestamp(json['created_at'] as String),
      updatedAt: parseServerTimestamp(json['updated_at'] as String),
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'frequency': frequency.value,
      'day_of_month': dayOfMonth,
      'day_of_week': dayOfWeek,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'next_execution_date': nextExecutionDate.toIso8601String().split('T')[0],
      'last_execution_date': lastExecutionDate?.toIso8601String().split('T')[0],
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Ekleme için JSON (id ve timestamp'ler hariç)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'account_id': accountId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'frequency': frequency.value,
      'day_of_month': dayOfMonth,
      'day_of_week': dayOfWeek,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'next_execution_date': nextExecutionDate.toIso8601String().split('T')[0],
      'is_active': isActive,
    };
  }

  /// Gelir işlemi mi?
  bool get isIncome => type == 'income';

  /// Gider işlemi mi?
  bool get isExpense => type == 'expense';

  /// Sona erdi mi?
  bool get isEnded => endDate != null && DateTime.now().isAfter(endDate!);

  /// Bugün çalışacak mı?
  bool get shouldExecuteToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextExec = DateTime(
      nextExecutionDate.year,
      nextExecutionDate.month,
      nextExecutionDate.day,
    );
    return isActive && !isEnded && !nextExec.isAfter(today);
  }

  /// [from] gününden itibaren takvime uyan ilk çalışma tarihi. Zaten
  /// çalıştırılmış bir gün (son çalışma tarihi) tekrar seçilmez.
  DateTime nextDateFrom(DateTime from) {
    var floor = DateTime(from.year, from.month, from.day);
    final last = lastExecutionDate;
    if (last != null) {
      final afterLast = DateTime(last.year, last.month, last.day + 1);
      if (afterLast.isAfter(floor)) floor = afterLast;
    }
    return firstRecurringDate(
      frequency: frequency,
      startDate: startDate,
      notBefore: floor,
      dayOfMonth: dayOfMonth,
      dayOfWeek: dayOfWeek,
    );
  }

  /// Sonraki çalışma tarihini hesapla
  DateTime calculateNextExecutionDate() {
    final now = DateTime.now();
    DateTime next;

    switch (frequency) {
      case RecurringFrequency.daily:
        next =
            lastExecutionDate?.add(const Duration(days: 1)) ??
            DateTime(now.year, now.month, now.day + 1);
        break;

      case RecurringFrequency.weekly:
        final daysUntilNext = dayOfWeek != null
            ? ((dayOfWeek! - now.weekday) % 7)
            : 7;
        next = DateTime(now.year, now.month, now.day + daysUntilNext);
        break;

      case RecurringFrequency.monthly:
        final targetDay = dayOfMonth ?? now.day;
        int nextMonth = now.month + 1;
        int nextYear = now.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        // Ayın son gününü aşmamak için
        final daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final safeDay = targetDay > daysInMonth ? daysInMonth : targetDay;
        next = DateTime(nextYear, nextMonth, safeDay);
        break;

      case RecurringFrequency.yearly:
        next = DateTime(now.year + 1, startDate.month, startDate.day);
        break;
    }

    return next;
  }

  static const _unset = Object();

  /// Kopyala ve güncelle. Boş bırakılabilen alanlar (kategori, açıklama,
  /// gün seçimleri, bitiş tarihi) açıkça `null` verilerek temizlenebilir.
  RecurringTransactionModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    Object? categoryId = _unset,
    double? amount,
    String? type,
    Object? description = _unset,
    RecurringFrequency? frequency,
    Object? dayOfMonth = _unset,
    Object? dayOfWeek = _unset,
    DateTime? startDate,
    Object? endDate = _unset,
    DateTime? nextExecutionDate,
    DateTime? lastExecutionDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      frequency: frequency ?? this.frequency,
      dayOfMonth: identical(dayOfMonth, _unset)
          ? this.dayOfMonth
          : dayOfMonth as int?,
      dayOfWeek: identical(dayOfWeek, _unset)
          ? this.dayOfWeek
          : dayOfWeek as int?,
      startDate: startDate ?? this.startDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate as DateTime?,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      lastExecutionDate: lastExecutionDate ?? this.lastExecutionDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
