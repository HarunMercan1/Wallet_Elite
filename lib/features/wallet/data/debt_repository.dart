// lib/features/wallet/data/debt_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/debt_model.dart';

/// Borç/alacak işlemlerini yöneten repository
class DebtRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== DEBTS (Borçlar) ====================

  /// Kullanıcının tüm borç/alacaklarını getir
  Future<List<DebtModel>> getDebts(String userId) async {
    try {
      final response = await _supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Borçları getirme hatası: $e');
      return [];
    }
  }

  /// Sadece alacakları getir (lend)
  Future<List<DebtModel>> getLends(String userId) async {
    try {
      final response = await _supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .eq('type', 'lend')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Alacakları getirme hatası: $e');
      return [];
    }
  }

  /// Sadece borçları getir (borrow)
  Future<List<DebtModel>> getBorrows(String userId) async {
    try {
      final response = await _supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .eq('type', 'borrow')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Borçları getirme hatası: $e');
      return [];
    }
  }

  /// Tamamlanmamış borçları getir
  Future<List<DebtModel>> getActiveDebts(String userId) async {
    try {
      final response = await _supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Aktif borçları getirme hatası: $e');
      return [];
    }
  }

  /// Yaklaşan vadeli borçları getir (gelecek 7 gün)
  Future<List<DebtModel>> getUpcomingDebts(String userId) async {
    try {
      final now = DateTime.now();
      final weekLater = now.add(const Duration(days: 7));

      final response = await _supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .gte('due_date', now.toIso8601String())
          .lte('due_date', weekLater.toIso8601String())
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Yaklaşan borçları getirme hatası: $e');
      return [];
    }
  }

  /// Vadesi geçmiş borçları getir
  Future<List<DebtModel>> getOverdueDebts(String userId) async {
    try {
      final now = DateTime.now();

      final response = await _supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .lt('due_date', now.toIso8601String())
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => DebtModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Vadesi geçmiş borçları getirme hatası: $e');
      return [];
    }
  }

  /// Yeni borç/alacak ekle
  Future<DebtModel?> createDebt({
    required String userId,
    required String personName,
    required double amount,
    required String type, // 'lend' veya 'borrow'
    DateTime? dueDate,
    String? description,
  }) async {
    try {
      print('🔄 Borç/alacak oluşturuluyor...');
      print('   user_id: $userId');
      print('   personName: $personName');
      print('   amount: $amount');
      print('   type: $type');

      final response = await _supabase
          .from('debts')
          .insert({
            'user_id': userId,
            'person_name': personName,
            'amount': amount,
            'remaining_amount': amount,
            'type': type,
            'due_date': dueDate?.toIso8601String(),
            'description': description,
            'is_completed': false,
          })
          .select()
          .single();

      print('✅ Borç/alacak başarıyla oluşturuldu: ${response['id']}');
      return DebtModel.fromJson(response);
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Details: ${e.details}');
      print('   Hint: ${e.hint}');
      return null;
    } catch (e) {
      print('❌ Borç/alacak oluşturma hatası: $e');
      print('   Hata tipi: ${e.runtimeType}');
      return null;
    }
  }

  /// Borç/alacak güncelle
  Future<DebtModel?> updateDebt(DebtModel debt) async {
    try {
      final response = await _supabase
          .from('debts')
          .update(debt.toJson())
          .eq('id', debt.id)
          .select()
          .single();

      return DebtModel.fromJson(response);
    } catch (e) {
      print('Borç güncelleme hatası: $e');
      return null;
    }
  }

  /// Ödeme kaydet (kısmi veya tam)
  Future<DebtModel?> recordPayment({
    required String debtId,
    required double paymentAmount,
  }) async {
    try {
      // Mevcut borcu al
      final debtResponse = await _supabase
          .from('debts')
          .select()
          .eq('id', debtId)
          .single();

      final debt = DebtModel.fromJson(debtResponse);

      // Yeni kalan tutarı hesapla
      final newRemaining = debt.remainingAmount - paymentAmount;
      final isCompleted = newRemaining <= 0;

      // Güncelle
      final response = await _supabase
          .from('debts')
          .update({
            'remaining_amount': isCompleted ? 0 : newRemaining,
            'is_completed': isCompleted,
          })
          .eq('id', debtId)
          .select()
          .single();

      return DebtModel.fromJson(response);
    } catch (e) {
      print('Ödeme kaydetme hatası: $e');
      return null;
    }
  }

  /// Borcu tamamlandı olarak işaretle
  Future<bool> markAsCompleted(String debtId) async {
    try {
      await _supabase
          .from('debts')
          .update({'is_completed': true, 'remaining_amount': 0})
          .eq('id', debtId);

      return true;
    } catch (e) {
      print('Borç tamamlama hatası: $e');
      return false;
    }
  }

  /// Borç sil
  Future<bool> deleteDebt(String debtId) async {
    try {
      await _supabase.from('debts').delete().eq('id', debtId);
      return true;
    } catch (e) {
      print('Borç silme hatası: $e');
      return false;
    }
  }

  // ==================== STATISTICS ====================

  /// Toplam alacak miktarını getir
  Future<double> getTotalLentAmount(String userId) async {
    try {
      final response = await _supabase
          .from('debts')
          .select('remaining_amount')
          .eq('user_id', userId)
          .eq('type', 'lend')
          .eq('is_completed', false);

      double total = 0;
      for (final item in response as List) {
        total += (item['remaining_amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Toplam alacak hesaplama hatası: $e');
      return 0;
    }
  }

  /// Toplam borç miktarını getir
  Future<double> getTotalBorrowedAmount(String userId) async {
    try {
      final response = await _supabase
          .from('debts')
          .select('remaining_amount')
          .eq('user_id', userId)
          .eq('type', 'borrow')
          .eq('is_completed', false);

      double total = 0;
      for (final item in response as List) {
        total += (item['remaining_amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Toplam borç hesaplama hatası: $e');
      return 0;
    }
  }

  /// Kişi sayısını getir
  Future<int> getUniquePersonCount(String userId) async {
    try {
      final response = await _supabase
          .from('debts')
          .select('person_name')
          .eq('user_id', userId)
          .eq('is_completed', false);

      final uniqueNames = <String>{};
      for (final item in response as List) {
        uniqueNames.add(item['person_name'] as String);
      }
      return uniqueNames.length;
    } catch (e) {
      print('Kişi sayısı hesaplama hatası: $e');
      return 0;
    }
  }
}
