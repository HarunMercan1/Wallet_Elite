// lib/features/recurring/data/recurring_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recurring_transaction_model.dart';
import 'recurring_repository.dart';
import '../../auth/data/auth_provider.dart';

/// Repository provider
final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository();
});

/// Tüm tekrarlayan işlemler provider'ı
final recurringTransactionsProvider =
    FutureProvider<List<RecurringTransactionModel>>((ref) async {
      final user = ref.watch(currentUserProvider).value;

      if (user == null) return [];

      final repo = ref.read(recurringRepositoryProvider);
      return repo.getRecurringTransactions(user.id);
    });

/// Aktif tekrarlayan işlemler provider'ı
final activeRecurringTransactionsProvider =
    FutureProvider<List<RecurringTransactionModel>>((ref) async {
      final user = ref.watch(currentUserProvider).value;

      if (user == null) return [];

      final repo = ref.read(recurringRepositoryProvider);
      return repo.getActiveRecurringTransactions(user.id);
    });

/// Bugün vadesi gelen işlemler provider'ı
final dueTransactionsProvider = FutureProvider<List<RecurringTransactionModel>>(
  (ref) async {
    final user = ref.watch(currentUserProvider).value;

    if (user == null) return [];

    final repo = ref.read(recurringRepositoryProvider);
    return repo.getDueTransactions(user.id);
  },
);

/// Tekrarlayan işlem filtresi
enum RecurringFilter { all, active, inactive }

/// Filtre provider'ı
final recurringFilterProvider = StateProvider<RecurringFilter>((ref) {
  return RecurringFilter.all;
});

/// Filtrelenmiş tekrarlayan işlemler
final filteredRecurringTransactionsProvider =
    Provider<AsyncValue<List<RecurringTransactionModel>>>((ref) {
      final filter = ref.watch(recurringFilterProvider);
      final allTransactions = ref.watch(recurringTransactionsProvider);

      return allTransactions.whenData((transactions) {
        switch (filter) {
          case RecurringFilter.active:
            return transactions.where((t) => t.isActive).toList();
          case RecurringFilter.inactive:
            return transactions.where((t) => !t.isActive).toList();
          case RecurringFilter.all:
            return transactions;
        }
      });
    });

/// Tekrarlayan işlem controller'ı
class RecurringController extends StateNotifier<AsyncValue<void>> {
  final RecurringRepository _repository;
  final Ref _ref;

  RecurringController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  /// Yeni tekrarlayan işlem oluştur
  Future<bool> create({
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
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return false;

    state = const AsyncValue.loading();

    try {
      await _repository.createRecurringTransaction(
        userId: user.id,
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        frequency: frequency,
        dayOfMonth: dayOfMonth,
        dayOfWeek: dayOfWeek,
        startDate: startDate,
        endDate: endDate,
      );

      // Provider'ları yenile
      _ref.invalidate(recurringTransactionsProvider);
      _ref.invalidate(activeRecurringTransactionsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Tekrarlayan işlemi güncelle
  Future<bool> update(RecurringTransactionModel recurring) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateRecurringTransaction(recurring);

      _ref.invalidate(recurringTransactionsProvider);
      _ref.invalidate(activeRecurringTransactionsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Tekrarlayan işlemi sil
  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteRecurringTransaction(id);

      _ref.invalidate(recurringTransactionsProvider);
      _ref.invalidate(activeRecurringTransactionsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Aktif/Pasif durumunu değiştir
  Future<bool> toggleActive(String id, bool isActive) async {
    try {
      await _repository.toggleActive(id, isActive);

      _ref.invalidate(recurringTransactionsProvider);
      _ref.invalidate(activeRecurringTransactionsProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vadesi gelen işlemleri çalıştır
  Future<int> executeDueTransactions() async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return 0;

    try {
      final count = await _repository.executeDueTransactions(user.id);

      // İşlemler oluşturulduğu için wallet provider'ını da yenile
      _ref.invalidate(recurringTransactionsProvider);

      return count;
    } catch (e) {
      return 0;
    }
  }
}

/// Controller provider
final recurringControllerProvider =
    StateNotifierProvider<RecurringController, AsyncValue<void>>((ref) {
      final repository = ref.read(recurringRepositoryProvider);
      return RecurringController(repository, ref);
    });
