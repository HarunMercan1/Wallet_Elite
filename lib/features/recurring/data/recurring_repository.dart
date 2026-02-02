// lib/features/recurring/data/recurring_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recurring_transaction_model.dart';
import '../../wallet/data/wallet_repository.dart';

/// Tekrarlayan işlemler repository
class RecurringRepository {
  final _supabase = Supabase.instance.client;

  /// Kullanıcının tüm tekrarlayan işlemlerini getir
  Future<List<RecurringTransactionModel>> getRecurringTransactions(
    String userId,
  ) async {
    final response = await _supabase
        .from('recurring_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RecurringTransactionModel.fromJson(json))
        .toList();
  }

  /// Aktif tekrarlayan işlemleri getir
  Future<List<RecurringTransactionModel>> getActiveRecurringTransactions(
    String userId,
  ) async {
    final response = await _supabase
        .from('recurring_transactions')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('next_execution_date', ascending: true);

    return (response as List)
        .map((json) => RecurringTransactionModel.fromJson(json))
        .toList();
  }

  /// Bugün çalışması gereken işlemleri getir
  Future<List<RecurringTransactionModel>> getDueTransactions(
    String userId,
  ) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _supabase
        .from('recurring_transactions')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .lte('next_execution_date', today);

    return (response as List)
        .map((json) => RecurringTransactionModel.fromJson(json))
        .toList();
  }

  /// Yeni tekrarlayan işlem oluştur
  Future<RecurringTransactionModel> createRecurringTransaction({
    required String userId,
    required String accountId,
    String? categoryId,
    required double amount,
    required String type,
    String? description,
    required RecurringFrequency frequency,
    int? dayOfMonth,
    int? dayOfWeek,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    // İlk çalışma tarihini hesapla
    DateTime nextExecutionDate = startDate;
    final now = DateTime.now();

    if (startDate.isBefore(now)) {
      // Başlangıç tarihi geçmişteyse, sonraki uygun tarihi bul
      nextExecutionDate = _calculateNextDate(
        frequency: frequency,
        dayOfMonth: dayOfMonth,
        dayOfWeek: dayOfWeek,
        startDate: startDate,
      );
    }

    final data = {
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
      'is_active': true,
    };

    final response = await _supabase
        .from('recurring_transactions')
        .insert(data)
        .select()
        .single();

    return RecurringTransactionModel.fromJson(response);
  }

  /// Tekrarlayan işlemi güncelle
  Future<RecurringTransactionModel> updateRecurringTransaction(
    RecurringTransactionModel recurring,
  ) async {
    final response = await _supabase
        .from('recurring_transactions')
        .update({
          'account_id': recurring.accountId,
          'category_id': recurring.categoryId,
          'amount': recurring.amount,
          'type': recurring.type,
          'description': recurring.description,
          'frequency': recurring.frequency.value,
          'day_of_month': recurring.dayOfMonth,
          'day_of_week': recurring.dayOfWeek,
          'end_date': recurring.endDate?.toIso8601String().split('T')[0],
          'is_active': recurring.isActive,
        })
        .eq('id', recurring.id)
        .select()
        .single();

    return RecurringTransactionModel.fromJson(response);
  }

  /// Tekrarlayan işlemi sil
  Future<void> deleteRecurringTransaction(String id) async {
    await _supabase.from('recurring_transactions').delete().eq('id', id);
  }

  /// Tekrarlayan işlemi pasife al / aktifleştir
  Future<void> toggleActive(String id, bool isActive) async {
    await _supabase
        .from('recurring_transactions')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  /// Tekrarlayan işlemi çalıştır (gerçek işlem oluştur)
  Future<void> executeRecurringTransaction(
    RecurringTransactionModel recurring,
  ) async {
    final walletRepo = WalletRepository();

    // Gerçek işlemi oluştur
    await walletRepo.createTransaction(
      userId: recurring.userId,
      accountId: recurring.accountId,
      categoryId: recurring.categoryId,
      amount: recurring.amount,
      type: recurring.type,
      description: recurring.description,
      date: DateTime.now(),
    );

    // Sonraki çalışma tarihini hesapla ve güncelle
    final nextDate = _calculateNextDate(
      frequency: recurring.frequency,
      dayOfMonth: recurring.dayOfMonth,
      dayOfWeek: recurring.dayOfWeek,
      startDate: recurring.startDate,
      lastExecutionDate: DateTime.now(),
    );

    // Bitiş tarihi kontrolü
    final shouldDeactivate =
        recurring.endDate != null && nextDate.isAfter(recurring.endDate!);

    await _supabase
        .from('recurring_transactions')
        .update({
          'next_execution_date': nextDate.toIso8601String().split('T')[0],
          'last_execution_date': DateTime.now().toIso8601String().split('T')[0],
          'is_active': !shouldDeactivate,
        })
        .eq('id', recurring.id);
  }

  /// Tüm vadesi gelen işlemleri çalıştır
  Future<int> executeDueTransactions(String userId) async {
    final dueTransactions = await getDueTransactions(userId);
    int executedCount = 0;

    for (final recurring in dueTransactions) {
      await executeRecurringTransaction(recurring);
      executedCount++;
    }

    return executedCount;
  }

  /// Sonraki çalışma tarihini hesapla
  DateTime _calculateNextDate({
    required RecurringFrequency frequency,
    int? dayOfMonth,
    int? dayOfWeek,
    required DateTime startDate,
    DateTime? lastExecutionDate,
  }) {
    final now = DateTime.now();
    final baseDate = lastExecutionDate ?? now;

    switch (frequency) {
      case RecurringFrequency.daily:
        return DateTime(baseDate.year, baseDate.month, baseDate.day + 1);

      case RecurringFrequency.weekly:
        final daysToAdd = dayOfWeek != null
            ? ((dayOfWeek - baseDate.weekday + 7) % 7)
            : 7;
        final nextWeek = daysToAdd == 0 ? 7 : daysToAdd;
        return DateTime(baseDate.year, baseDate.month, baseDate.day + nextWeek);

      case RecurringFrequency.monthly:
        int nextMonth = baseDate.month + 1;
        int nextYear = baseDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        final targetDay = dayOfMonth ?? startDate.day;
        final daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final safeDay = targetDay > daysInMonth ? daysInMonth : targetDay;
        return DateTime(nextYear, nextMonth, safeDay);

      case RecurringFrequency.yearly:
        return DateTime(baseDate.year + 1, startDate.month, startDate.day);
    }
  }
}
