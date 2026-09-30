import 'package:flutter/foundation.dart';
// lib/features/wallet/data/wallet_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

/// Cüzdan işlemlerini yöneten repository
class WalletRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== ACCOUNTS (Cüzdanlar) ====================

  /// Kullanıcının tüm cüzdanlarını getir
  Future<List<AccountModel>> getAccounts(String userId) async {
    try {
      final response = await _supabase
          .from('accounts')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      return (response as List)
          .map((json) => AccountModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Cüzdanları getirme hatası: $e');
      return [];
    }
  }

  /// Yeni cüzdan oluştur
  Future<AccountModel?> createAccount({
    required String userId,
    required String name,
    required String type,
    required String currency,
    double initialBalance = 0,
  }) async {
    try {
      debugPrint('🔄 Cüzdan oluşturuluyor...');
      debugPrint('   user_id: $userId');
      debugPrint('   name: $name');
      debugPrint('   type: $type');
      debugPrint('   currency: $currency');
      debugPrint('   balance: $initialBalance');

      final response = await _supabase
          .from('accounts')
          .insert({
            'user_id': userId,
            'name': name,
            'type': type,
            'currency': currency,
            'balance': initialBalance,
          })
          .select()
          .single();

      debugPrint('✅ Cüzdan başarıyla oluşturuldu: ${response['id']}');
      return AccountModel.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('❌ Supabase PostgrestException:');
      debugPrint('   Code: ${e.code}');
      debugPrint('   Message: ${e.message}');
      debugPrint('   Details: ${e.details}');
      debugPrint('   Hint: ${e.hint}');
      return null;
    } catch (e) {
      debugPrint('❌ Cüzdan oluşturma hatası: $e');
      debugPrint('   Hata tipi: ${e.runtimeType}');
      return null;
    }
  }

  /// Cüzdan sil (ilişkili işlemleri de siler)
  Future<bool> deleteAccount(String accountId) async {
    try {
      // Önce bu cüzdana ait tüm işlemleri sil
      await _supabase.from('transactions').delete().eq('account_id', accountId);

      // Sonra cüzdanı sil
      await _supabase.from('accounts').delete().eq('id', accountId);
      return true;
    } catch (e) {
      debugPrint('Cüzdan silme hatası: $e');
      return false;
    }
  }

  /// Cüzdan adını güncelle
  Future<bool> updateAccountName(String accountId, String newName) async {
    try {
      await _supabase
          .from('accounts')
          .update({'name': newName})
          .eq('id', accountId);
      return true;
    } catch (e) {
      debugPrint('Cüzdan güncelleme hatası: $e');
      return false;
    }
  }

  // ==================== CATEGORIES (Kategoriler) ====================

  /// Varsayılan kategorileri oluştur (ilk kayıtta)
  Future<void> createDefaultCategories(String userId) async {
    try {
      debugPrint('🔄 Varsayılan kategoriler oluşturuluyor...');

      // Gelir kategorileri
      // translation_key, kategori adının kullanıcının dilinde gösterilmesini sağlar
      final incomeCategories = [
        {
          'name': 'Maaş',
          'translation_key': 'cat_salary',
          'type': 'income',
          'icon': 'wallet',
        },
        {
          'name': 'Freelance',
          'translation_key': 'cat_freelance',
          'type': 'income',
          'icon': 'laptop',
        },
        {
          'name': 'Yatırım',
          'translation_key': 'cat_investment',
          'type': 'income',
          'icon': 'trending_up',
        },
        {
          'name': 'Hediye',
          'translation_key': 'cat_gift',
          'type': 'income',
          'icon': 'card_giftcard',
        },
        {
          'name': 'Diğer Gelir',
          'translation_key': 'cat_other',
          'type': 'income',
          'icon': 'attach_money',
        },
      ];

      // Gider kategorileri
      final expenseCategories = [
        {
          'name': 'Market',
          'translation_key': 'cat_groceries',
          'type': 'expense',
          'icon': 'shopping_cart',
        },
        {
          'name': 'Ulaşım',
          'translation_key': 'cat_transport',
          'type': 'expense',
          'icon': 'directions_car',
        },
        {
          'name': 'Faturalar',
          'translation_key': 'cat_bills',
          'type': 'expense',
          'icon': 'receipt',
        },
        {
          'name': 'Eğlence',
          'translation_key': 'cat_entertainment',
          'type': 'expense',
          'icon': 'movie',
        },
        {
          'name': 'Yemek',
          'translation_key': 'cat_food',
          'type': 'expense',
          'icon': 'restaurant',
        },
        {
          'name': 'Sağlık',
          'translation_key': 'cat_health',
          'type': 'expense',
          'icon': 'local_hospital',
        },
        {
          'name': 'Giyim',
          'translation_key': 'cat_shopping',
          'type': 'expense',
          'icon': 'checkroom',
        },
        {
          'name': 'Eğitim',
          'translation_key': 'cat_education',
          'type': 'expense',
          'icon': 'school',
        },
        {
          'name': 'Diğer Gider',
          'translation_key': 'cat_other',
          'type': 'expense',
          'icon': 'more_horiz',
        },
      ];

      // Tüm kategorileri birleştir ve user_id ekle
      final allCategories = [
        ...incomeCategories,
        ...expenseCategories,
      ].map((cat) => {...cat, 'user_id': userId}).toList();

      await _supabase.from('categories').insert(allCategories);

      debugPrint('✅ ${allCategories.length} varsayılan kategori oluşturuldu');
    } catch (e) {
      debugPrint('❌ Varsayılan kategori oluşturma hatası: $e');
    }
  }

  // ==================== GLOBAL CATEGORIES (User-independent) ====================

  /// Tüm kategorileri getir (global - user_id yok)
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Global kategorileri getirme hatası: $e');
      return [];
    }
  }

  /// Tüm gelir kategorilerini getir (global)
  Future<List<CategoryModel>> getAllIncomeCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('type', 'income')
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Global gelir kategorileri hatası: $e');
      return [];
    }
  }

  /// Tüm gider kategorilerini getir (global)
  Future<List<CategoryModel>> getAllExpenseCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('type', 'expense')
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Global gider kategorileri hatası: $e');
      return [];
    }
  }

  // ==================== USER-SPECIFIC CATEGORIES ====================

  /// Kullanıcının tüm kategorilerini getir
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Kategorileri getirme hatası: $e');
      return [];
    }
  }

  /// Gelir kategorilerini getir
  Future<List<CategoryModel>> getIncomeCategories(String userId) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .eq('type', 'income')
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Gelir kategorileri hatası: $e');
      return [];
    }
  }

  /// Gider kategorilerini getir
  Future<List<CategoryModel>> getExpenseCategories(String userId) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .eq('type', 'expense')
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Gider kategorileri hatası: $e');
      return [];
    }
  }

  // ==================== TRANSACTIONS (İşlemler) ====================

  /// Kullanıcının tüm işlemlerini getir
  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('İşlemleri getirme hatası: $e');
      return [];
    }
  }

  /// Belirli bir cüzdanın işlemlerini getir
  Future<List<TransactionModel>> getAccountTransactions(
    String userId,
    String accountId,
  ) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .eq('account_id', accountId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Cüzdan işlemleri hatası: $e');
      return [];
    }
  }

  /// Yeni işlem ekle
  Future<TransactionModel?> createTransaction({
    required String userId,
    required String accountId,
    String? categoryId,
    required double amount,
    required String type,
    String? description,
    DateTime? date,
  }) async {
    try {
      final response = await _supabase
          .from('transactions')
          .insert({
            'user_id': userId,
            'account_id': accountId,
            'category_id': categoryId,
            'amount': amount,
            'type': type,
            'description': description,
            'date': (date ?? DateTime.now()).toIso8601String(),
          })
          .select()
          .single();

      // Cüzdan bakiyesi veritabanındaki trigger_apply_transaction_to_balance
      // trigger'ı tarafından aynı işlem içinde güncellenir.
      return TransactionModel.fromJson(response);
    } catch (e) {
      debugPrint('İşlem ekleme hatası: $e');
      return null;
    }
  }

  /// İşlem sil (bakiye DB trigger'ı ile geri alınır)
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      await _supabase.from('transactions').delete().eq('id', transactionId);
      return true;
    } catch (e) {
      debugPrint('İşlem silme hatası: $e');
      return false;
    }
  }
}
