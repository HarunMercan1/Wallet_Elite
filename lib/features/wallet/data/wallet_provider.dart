import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wallet_repository.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
// 1. REPOSITORY PROVIDER (Aşçının kendisi)
// Uygulamanın her yerinden Repository'e ulaşmak için bunu kullanacağız.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(Supabase.instance.client);
});

// 2. TRANSACTIONS PROVIDER (Yemek Servisi)
// Bu provider, Repository'i tetikler ve listeyi getirir.
// "FutureProvider" kullandık çünkü işlem internetten gelecek (zaman alır).
final recentTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getRecentTransactions();
});

// KATEGORİ LİSTESİNİ VEREN PROVIDER
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getCategories();
});