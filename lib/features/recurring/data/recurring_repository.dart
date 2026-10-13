// lib/features/recurring/data/recurring_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recurring_transaction_model.dart';

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
    final today = _dateOnly(DateTime.now());

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
    // İlk çalışma tarihi: başlangıç gününden (geçmişteyse bugünden) itibaren
    // takvime uyan ilk gün. Bugüne denk gelirse işlem bugün oluşturulur.
    final nextExecutionDate = firstRecurringDate(
      frequency: frequency,
      startDate: startDate,
      notBefore: DateTime.now(),
      dayOfMonth: dayOfMonth,
      dayOfWeek: dayOfWeek,
    );

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
      'start_date': _dateOnly(startDate),
      'end_date': endDate == null ? null : _dateOnly(endDate),
      'next_execution_date': _dateOnly(nextExecutionDate),
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
          'end_date': recurring.endDate == null
              ? null
              : _dateOnly(recurring.endDate!),
          'next_execution_date': _dateOnly(recurring.nextExecutionDate),
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

  /// Tekrarlayan işlemi pasife al / aktifleştir.
  /// Yeniden aktifleştirirken sıradaki tarih bugüne/ileriye alınır; aksi halde
  /// duraklatılan süre boyunca kaçan tüm dönemler toplu olarak oluşturulurdu.
  Future<void> toggleActive(String id, bool isActive) async {
    final update = <String, dynamic>{'is_active': isActive};

    if (isActive) {
      final row = await _supabase
          .from('recurring_transactions')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row != null) {
        final r = RecurringTransactionModel.fromJson(row);
        update['next_execution_date'] = _dateOnly(
          r.nextDateFrom(DateTime.now()),
        );
      }
    }

    await _supabase.from('recurring_transactions').update(update).eq('id', id);
  }

  /// Vadesi gelen tüm işlemleri çalıştır (kullanıcının kendi kayıtları).
  /// İşlemler DB'deki process_due_recurring_transactions() ile atomik olarak
  /// oluşturulur; kaçırılan her dönem için ayrı işlem yazılır ve aynı kayıt iki
  /// kez işlenmez. Aynı fonksiyon pg_cron ile saat başı da çalışır.
  Future<int> executeDueTransactions() async {
    final result = await _supabase.rpc('process_due_recurring_transactions');
    return (result as num?)?.toInt() ?? 0;
  }

  /// Yerel tarihin `yyyy-MM-dd` karşılığı (DATE sütunları için)
  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
