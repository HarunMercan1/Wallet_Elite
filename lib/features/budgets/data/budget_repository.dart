// lib/features/budgets/data/budget_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget_model.dart';

/// Bütçe repository - Supabase CRUD işlemleri
class BudgetRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Kullanıcının tüm bütçelerini getir (harcama bilgisiyle)
  Future<List<BudgetModel>> getBudgets(String userId) async {
    final response = await _supabase
        .from('budgets')
        .select('''
          *,
          categories(name, icon)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final budgets = (response as List)
        .map((json) => BudgetModel.fromJson(json))
        .toList();

    // Her bütçe için harcama miktarını hesapla
    return Future.wait(
      budgets.map((budget) async {
        final spent = await _calculateSpent(budget);
        return budget.copyWith(spent: spent);
      }),
    );
  }

  /// Aktif bütçeleri getir
  Future<List<BudgetModel>> getActiveBudgets(String userId) async {
    final response = await _supabase
        .from('budgets')
        .select('''
          *,
          categories(name, icon)
        ''')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    final budgets = (response as List)
        .map((json) => BudgetModel.fromJson(json))
        .toList();

    return Future.wait(
      budgets.map((budget) async {
        final spent = await _calculateSpent(budget);
        return budget.copyWith(spent: spent);
      }),
    );
  }

  /// Tek bir bütçeyi getir
  Future<BudgetModel?> getBudget(String id) async {
    final response = await _supabase
        .from('budgets')
        .select('''
          *,
          categories(name, icon)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    final budget = BudgetModel.fromJson(response);
    final spent = await _calculateSpent(budget);
    return budget.copyWith(spent: spent);
  }

  /// Belirli dönem için harcanan miktarı hesapla
  Future<double> _calculateSpent(BudgetModel budget) async {
    final startDate = budget.getPeriodStartDate();
    final endDate = budget.getPeriodEndDate();

    var query = _supabase
        .from('transactions')
        .select('amount')
        .eq('user_id', budget.userId)
        .eq('type', 'expense')
        .gte('date', startDate.toIso8601String())
        .lt('date', endDate.toIso8601String());

    // Kategori filtresi varsa uygula
    if (budget.categoryId != null) {
      query = query.eq('category_id', budget.categoryId!);
    }

    final response = await query;

    double total = 0;
    for (final row in response as List) {
      total += (row['amount'] as num).toDouble();
    }

    return total;
  }

  /// Yeni bütçe oluştur
  Future<BudgetModel> createBudget({
    required String userId,
    required String name,
    String? categoryId,
    required double amount,
    required BudgetPeriod period,
    int startDay = 1,
    int notifyAtPercent = 80,
    bool notifyWhenExceeded = true,
  }) async {
    final data = {
      'user_id': userId,
      'name': name,
      'category_id': categoryId,
      'amount': amount,
      'period': period.name,
      'start_day': startDay,
      'notify_at_percent': notifyAtPercent,
      'notify_when_exceeded': notifyWhenExceeded,
    };

    final response = await _supabase
        .from('budgets')
        .insert(data)
        .select()
        .single();

    return BudgetModel.fromJson(response);
  }

  /// Bütçeyi güncelle
  Future<void> updateBudget(BudgetModel budget) async {
    await _supabase
        .from('budgets')
        .update({
          'name': budget.name,
          'category_id': budget.categoryId,
          'amount': budget.amount,
          'period': budget.period.name,
          'start_day': budget.startDay,
          'is_active': budget.isActive,
          'notify_at_percent': budget.notifyAtPercent,
          'notify_when_exceeded': budget.notifyWhenExceeded,
        })
        .eq('id', budget.id);
  }

  /// Bütçeyi sil
  Future<void> deleteBudget(String id) async {
    await _supabase.from('budgets').delete().eq('id', id);
  }

  /// Bütçe aktif/pasif durumunu değiştir
  Future<void> toggleActive(String id, bool isActive) async {
    await _supabase
        .from('budgets')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  /// Aşılmış veya uyarı seviyesindeki bütçeleri getir
  Future<List<BudgetModel>> getWarningBudgets(String userId) async {
    final budgets = await getActiveBudgets(userId);
    return budgets.where((b) => b.isWarning || b.isExceeded).toList();
  }

  /// Belirli kategoriye ait bütçeyi getir
  Future<BudgetModel?> getBudgetByCategory(
    String userId,
    String categoryId,
  ) async {
    final response = await _supabase
        .from('budgets')
        .select('''
          *,
          categories(name, icon)
        ''')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;

    final budget = BudgetModel.fromJson(response);
    final spent = await _calculateSpent(budget);
    return budget.copyWith(spent: spent);
  }
}
