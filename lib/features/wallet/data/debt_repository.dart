import 'package:flutter/foundation.dart';
// lib/features/wallet/data/debt_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';

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
      debugPrint('Borçları getirme hatası: $e');
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
      debugPrint('Alacakları getirme hatası: $e');
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
      debugPrint('Borçları getirme hatası: $e');
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
      debugPrint('Aktif borçları getirme hatası: $e');
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
      debugPrint('Yaklaşan borçları getirme hatası: $e');
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
      debugPrint('Vadesi geçmiş borçları getirme hatası: $e');
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
      debugPrint('🔄 Borç/alacak oluşturuluyor...');
      debugPrint('   user_id: $userId');
      debugPrint('   personName: $personName');
      debugPrint('   amount: $amount');
      debugPrint('   type: $type');

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

      debugPrint('✅ Borç/alacak başarıyla oluşturuldu: ${response['id']}');
      return DebtModel.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('❌ Supabase PostgrestException:');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.details}');
      debugPrint('   Hint: ${e.hint}');
      throw 'Veritabanı hatası: ${e.message} (Kod: ${e.code})';
    } catch (e) {
      debugPrint('❌ Borç/alacak oluşturma hatası: $e');
      throw 'Beklenmeyen bir hata oluştu: $e';
    }
  }

  /// Borç/alacak güncelle
  Future<DebtModel?> updateDebt(DebtModel debt) async {
    try {
      // Yalnızca kullanıcının düzenleyebildiği alanlar gönderilir; tutar ve
      // kalan tutar ödemelerle (DB trigger) yönetilir, ekrandaki eski kopyayla
      // üzerine yazılmamalı.
      final response = await _supabase
          .from('debts')
          .update({
            'person_name': debt.personName,
            'due_date': debt.dueDate?.toIso8601String(),
            'description': debt.description,
          })
          .eq('id', debt.id)
          .select()
          .single();

      return DebtModel.fromJson(response);
    } catch (e) {
      debugPrint('Borç güncelleme hatası: $e');
      return null;
    }
  }

  /// Ödeme kaydet (kısmi veya tam)
  Future<DebtModel?> recordPayment({
    required String debtId,
    required double paymentAmount,
  }) async {
    try {
      // Ödemeyi kaydet; kalan tutar ve tamamlanma durumu DB'deki
      // trigger_apply_debt_payment ile aynı işlem içinde güncellenir.
      await _supabase.from('debt_payments').insert({
        'debt_id': debtId,
        'amount': paymentAmount,
        'payment_date': DateTime.now().toIso8601String(),
      });

      final response = await _supabase
          .from('debts')
          .select()
          .eq('id', debtId)
          .single();

      return DebtModel.fromJson(response);
    } catch (e) {
      debugPrint('Ödeme kaydetme hatası: $e');
      throw 'Ödeme kaydedilirken hata oluştu: $e';
    }
  }

  /// Ödeme geçmişini getir
  Future<List<DebtPaymentModel>> getDebtPayments(String debtId) async {
    try {
      final response = await _supabase
          .from('debt_payments')
          .select()
          .eq('debt_id', debtId)
          .order('payment_date', ascending: false);

      return (response as List)
          .map((json) => DebtPaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Ödeme geçmişi getirme hatası: $e');
      return [];
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
      debugPrint('Borç tamamlama hatası: $e');
      return false;
    }
  }

  /// Borç sil
  Future<bool> deleteDebt(String debtId) async {
    try {
      await _supabase.from('debts').delete().eq('id', debtId);
      return true;
    } catch (e) {
      debugPrint('Borç silme hatası: $e');
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
      debugPrint('Toplam alacak hesaplama hatası: $e');
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
      debugPrint('Toplam borç hesaplama hatası: $e');
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
      debugPrint('Kişi sayısı hesaplama hatası: $e');
      return 0;
    }
  }
}
