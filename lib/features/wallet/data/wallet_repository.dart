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
      print('Cüzdanları getirme hatası: $e');
      return [];
    }
  }

  /// Yeni cüzdan oluştur
  Future<AccountModel?> createAccount({
    required String userId,
    required String name,
    required String type,
    double initialBalance = 0,
  }) async {
    try {
      print('🔄 Cüzdan oluşturuluyor...');
      print('   user_id: $userId');
      print('   name: $name');
      print('   type: $type');
      print('   balance: $initialBalance');

      final response = await _supabase
          .from('accounts')
          .insert({
            'user_id': userId,
            'name': name,
            'type': type,
            'balance': initialBalance,
          })
          .select()
          .single();

      print('✅ Cüzdan başarıyla oluşturuldu: ${response['id']}');
      return AccountModel.fromJson(response);
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');
      print('   Details: ${e.details}');
      print('   Hint: ${e.hint}');
      return null;
    } catch (e) {
      print('❌ Cüzdan oluşturma hatası: $e');
      print('   Hata tipi: ${e.runtimeType}');
      return null;
    }
  }

  /// Cüzdan sil
  Future<bool> deleteAccount(String accountId) async {
    try {
      await _supabase.from('accounts').delete().eq('id', accountId);
      return true;
    } catch (e) {
      print('Cüzdan silme hatası: $e');
      return false;
    }
  }

  // ==================== CATEGORIES (Kategoriler) ====================

  /// Varsayılan kategorileri oluştur (ilk kayıtta)
  Future<void> createDefaultCategories(String userId) async {
    try {
      print('🔄 Varsayılan kategoriler oluşturuluyor...');

      // Gelir kategorileri
      final incomeCategories = [
        {
          'name': 'Maaş',
          'type': 'income',
          'icon': 'wallet',
          'color': '#4CAF50',
        },
        {
          'name': 'Freelance',
          'type': 'income',
          'icon': 'laptop',
          'color': '#2196F3',
        },
        {
          'name': 'Yatırım',
          'type': 'income',
          'icon': 'trending_up',
          'color': '#9C27B0',
        },
        {
          'name': 'Hediye',
          'type': 'income',
          'icon': 'card_giftcard',
          'color': '#E91E63',
        },
        {
          'name': 'Diğer Gelir',
          'type': 'income',
          'icon': 'attach_money',
          'color': '#00BCD4',
        },
      ];

      // Gider kategorileri
      final expenseCategories = [
        {
          'name': 'Market',
          'type': 'expense',
          'icon': 'shopping_cart',
          'color': '#FF5722',
        },
        {
          'name': 'Ulaşım',
          'type': 'expense',
          'icon': 'directions_car',
          'color': '#795548',
        },
        {
          'name': 'Faturalar',
          'type': 'expense',
          'icon': 'receipt',
          'color': '#607D8B',
        },
        {
          'name': 'Eğlence',
          'type': 'expense',
          'icon': 'movie',
          'color': '#F44336',
        },
        {
          'name': 'Yemek',
          'type': 'expense',
          'icon': 'restaurant',
          'color': '#FF9800',
        },
        {
          'name': 'Sağlık',
          'type': 'expense',
          'icon': 'local_hospital',
          'color': '#E91E63',
        },
        {
          'name': 'Giyim',
          'type': 'expense',
          'icon': 'checkroom',
          'color': '#3F51B5',
        },
        {
          'name': 'Eğitim',
          'type': 'expense',
          'icon': 'school',
          'color': '#009688',
        },
        {
          'name': 'Diğer Gider',
          'type': 'expense',
          'icon': 'more_horiz',
          'color': '#9E9E9E',
        },
      ];

      // Tüm kategorileri birleştir ve user_id ekle
      final allCategories = [
        ...incomeCategories,
        ...expenseCategories,
      ].map((cat) => {...cat, 'user_id': userId}).toList();

      await _supabase.from('categories').insert(allCategories);

      print('✅ ${allCategories.length} varsayılan kategori oluşturuldu');
    } catch (e) {
      print('❌ Varsayılan kategori oluşturma hatası: $e');
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
      print('Global kategorileri getirme hatası: $e');
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
      print('Global gelir kategorileri hatası: $e');
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
      print('Global gider kategorileri hatası: $e');
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
      print('Kategorileri getirme hatası: $e');
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
      print('Gelir kategorileri hatası: $e');
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
      print('Gider kategorileri hatası: $e');
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
      print('İşlemleri getirme hatası: $e');
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
      print('Cüzdan işlemleri hatası: $e');
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

      // ⚠️ ÖNEMLİ: İşlem eklendikten sonra cüzdan bakiyesini güncelle
      await _updateAccountBalance(accountId, amount, type);

      return TransactionModel.fromJson(response);
    } catch (e) {
      print('İşlem ekleme hatası: $e');
      return null;
    }
  }

  /// Cüzdan bakiyesini güncelle (private method)
  Future<void> _updateAccountBalance(
    String accountId,
    double amount,
    String type,
  ) async {
    try {
      // Mevcut bakiyeyi al
      final account = await _supabase
          .from('accounts')
          .select('balance')
          .eq('id', accountId)
          .single();

      final currentBalance = (account['balance'] as num).toDouble();

      // Yeni bakiyeyi hesapla
      double newBalance;
      if (type == 'income') {
        newBalance = currentBalance + amount;
      } else if (type == 'expense') {
        newBalance = currentBalance - amount;
      } else {
        return; // Transfer için ayrı mantık gerekecek
      }

      // Güncelle
      await _supabase
          .from('accounts')
          .update({'balance': newBalance})
          .eq('id', accountId);
    } catch (e) {
      print('Bakiye güncelleme hatası: $e');
    }
  }

  /// İşlem sil
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      // ⚠️ Silmeden önce işlem bilgilerini al (bakiye geri döndürme için)
      final transaction = await _supabase
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .single();

      final txn = TransactionModel.fromJson(transaction);

      // İşlemi sil
      await _supabase.from('transactions').delete().eq('id', transactionId);

      // Bakiyeyi geri döndür
      await _reverseAccountBalance(txn.accountId, txn.amount, txn.type);

      return true;
    } catch (e) {
      print('İşlem silme hatası: $e');
      return false;
    }
  }

  /// Bakiyeyi geri döndür (private method)
  Future<void> _reverseAccountBalance(
    String accountId,
    double amount,
    String type,
  ) async {
    try {
      final account = await _supabase
          .from('accounts')
          .select('balance')
          .eq('id', accountId)
          .single();

      final currentBalance = (account['balance'] as num).toDouble();

      // Ters işlem yap
      double newBalance;
      if (type == 'income') {
        newBalance = currentBalance - amount; // Geliri geri al
      } else if (type == 'expense') {
        newBalance = currentBalance + amount; // Gideri geri ekle
      } else {
        return;
      }

      await _supabase
          .from('accounts')
          .update({'balance': newBalance})
          .eq('id', accountId);
    } catch (e) {
      print('Bakiye geri döndürme hatası: $e');
    }
  }
}
