// lib/features/budgets/data/budget_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_model.dart';
import 'budget_repository.dart';
import '../../auth/data/auth_provider.dart';

/// Repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// Tüm bütçeler provider'ı
final budgetsProvider = FutureProvider<List<BudgetModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return [];

  final repo = ref.read(budgetRepositoryProvider);
  return repo.getBudgets(user.id);
});

/// Aktif bütçeler provider'ı
final activeBudgetsProvider = FutureProvider<List<BudgetModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return [];

  final repo = ref.read(budgetRepositoryProvider);
  return repo.getActiveBudgets(user.id);
});

/// Uyarı/aşılmış bütçeler provider'ı
final warningBudgetsProvider = FutureProvider<List<BudgetModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return [];

  final repo = ref.read(budgetRepositoryProvider);
  return repo.getWarningBudgets(user.id);
});

/// Bütçe detayı provider'ı
final budgetDetailProvider = FutureProvider.family<BudgetModel?, String>((
  ref,
  id,
) async {
  final repo = ref.read(budgetRepositoryProvider);
  return repo.getBudget(id);
});

/// Bütçe controller'ı
class BudgetController extends StateNotifier<AsyncValue<void>> {
  final BudgetRepository _repository;
  final Ref _ref;

  BudgetController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  /// Yeni bütçe oluştur
  Future<bool> create({
    required String name,
    String? categoryId,
    required double amount,
    required BudgetPeriod period,
    int startDay = 1,
    int notifyAtPercent = 80,
    bool notifyWhenExceeded = true,
  }) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return false;

    state = const AsyncValue.loading();

    try {
      await _repository.createBudget(
        userId: user.id,
        name: name,
        categoryId: categoryId,
        amount: amount,
        period: period,
        startDay: startDay,
        notifyAtPercent: notifyAtPercent,
        notifyWhenExceeded: notifyWhenExceeded,
      );

      // Provider'ları yenile
      _ref.invalidate(budgetsProvider);
      _ref.invalidate(activeBudgetsProvider);
      _ref.invalidate(warningBudgetsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Bütçeyi güncelle
  Future<bool> update(BudgetModel budget) async {
    state = const AsyncValue.loading();

    try {
      await _repository.updateBudget(budget);

      _ref.invalidate(budgetsProvider);
      _ref.invalidate(activeBudgetsProvider);
      _ref.invalidate(warningBudgetsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Bütçeyi sil
  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteBudget(id);

      _ref.invalidate(budgetsProvider);
      _ref.invalidate(activeBudgetsProvider);
      _ref.invalidate(warningBudgetsProvider);

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

      _ref.invalidate(budgetsProvider);
      _ref.invalidate(activeBudgetsProvider);
      _ref.invalidate(warningBudgetsProvider);

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Controller provider
final budgetControllerProvider =
    StateNotifierProvider<BudgetController, AsyncValue<void>>((ref) {
      final repository = ref.read(budgetRepositoryProvider);
      return BudgetController(repository, ref);
    });
