// lib/features/wallet/data/wallet_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wallet_repository.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

/// Wallet Repository Provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

/// Kullanıcının cüzdanlarını getir
final accountsProvider = FutureProvider<List<AccountModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final walletRepo = ref.watch(walletRepositoryProvider);
  return await walletRepo.getAccounts(user.id);
});

/// Kullanıcının kategorilerini getir (user_id ile)
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final walletRepo = ref.watch(walletRepositoryProvider);
  return await walletRepo.getCategories(user.id);
});

/// Gelir kategorileri (user_id ile)
final incomeCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final walletRepo = ref.watch(walletRepositoryProvider);
  return await walletRepo.getIncomeCategories(user.id);
});

/// Gider kategorileri (user_id ile)
final expenseCategoriesProvider = FutureProvider<List<CategoryModel>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final walletRepo = ref.watch(walletRepositoryProvider);
  return await walletRepo.getExpenseCategories(user.id);
});

/// Kullanıcının işlemlerini getir
final transactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final walletRepo = ref.watch(walletRepositoryProvider);
  return await walletRepo.getTransactions(user.id);
});

/// Wallet Controller (İşlemleri yöneten)
final walletControllerProvider = Provider<WalletController>((ref) {
  return WalletController(ref);
});

class WalletController {
  final Ref ref;

  WalletController(this.ref);

  /// Yeni cüzdan ekle
  Future<bool> createAccount({
    required String name,
    required String type,
    double initialBalance = 0,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('❌ WalletController.createAccount: Kullanıcı bulunamadı');
      return false;
    }

    final walletRepo = ref.read(walletRepositoryProvider);
    final account = await walletRepo.createAccount(
      userId: user.id,
      name: name,
      type: type,
      initialBalance: initialBalance,
    );

    if (account != null) {
      // Provider'ı yenile
      ref.invalidate(accountsProvider);
      return true;
    }

    return false;
  }

  /// Yeni işlem ekle
  Future<bool> createTransaction({
    required String accountId,
    String? categoryId,
    required double amount,
    required String type,
    String? description,
    DateTime? date,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('❌ WalletController.createTransaction: Kullanıcı bulunamadı');
      return false;
    }

    final walletRepo = ref.read(walletRepositoryProvider);
    final transaction = await walletRepo.createTransaction(
      userId: user.id,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      type: type,
      description: description,
      date: date,
    );

    if (transaction != null) {
      // Provider'ları yenile
      ref.invalidate(transactionsProvider);
      ref.invalidate(accountsProvider);
      return true;
    }

    return false;
  }

  /// Cüzdan sil
  Future<bool> deleteAccount(String accountId) async {
    final walletRepo = ref.read(walletRepositoryProvider);
    final success = await walletRepo.deleteAccount(accountId);

    if (success) {
      ref.invalidate(accountsProvider);
    }

    return success;
  }

  /// İşlem sil
  Future<bool> deleteTransaction(String transactionId) async {
    final walletRepo = ref.read(walletRepositoryProvider);
    final success = await walletRepo.deleteTransaction(transactionId);

    if (success) {
      ref.invalidate(transactionsProvider);
      ref.invalidate(accountsProvider);
    }

    return success;
  }
}
