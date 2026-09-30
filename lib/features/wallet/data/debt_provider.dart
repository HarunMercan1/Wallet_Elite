// lib/features/wallet/data/debt_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_provider.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';
import 'debt_repository.dart';

/// DebtRepository provider
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository();
});

/// Kullanıcının tüm borç/alacaklarını getir
final debtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getDebts(userId);
});

/// Sadece alacakları getir (lend)
final lendsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getLends(userId);
});

/// Sadece borçları getir (borrow)
final borrowsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getBorrows(userId);
});

/// Aktif (tamamlanmamış) borçları getir
final activeDebtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getActiveDebts(userId);
});

/// Yaklaşan vadeli borçları getir (gelecek 7 gün)
final upcomingDebtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getUpcomingDebts(userId);
});

/// Vadesi geçmiş borçları getir
final overdueDebtsProvider = FutureProvider<List<DebtModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getOverdueDebts(userId);
});

/// Toplam alacak miktarı
final totalLentProvider = FutureProvider<double>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getTotalLentAmount(userId);
});

/// Toplam borç miktarı
final totalBorrowedProvider = FutureProvider<double>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getTotalBorrowedAmount(userId);
});

/// Benzersiz kişi sayısı
final debtPeopleCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  final debtRepo = ref.watch(debtRepositoryProvider);
  return await debtRepo.getUniquePersonCount(userId);
});

/// Tamamlananları göster/gizle durumu
final showCompletedDebtsProvider = StateProvider<bool>((ref) {
  ref.watch(currentUserIdProvider); // kullanıcı değişince sıfırla
  return false;
});

/// Filtre tipi (all, lend, borrow)
final debtFilterTypeProvider = StateProvider<String>((ref) {
  ref.watch(currentUserIdProvider); // kullanıcı değişince sıfırla
  return 'all';
});

/// Filtrelenmiş borç listesi
final filteredDebtsProvider = Provider<AsyncValue<List<DebtModel>>>((ref) {
  final debts = ref.watch(debtsProvider);
  final filterType = ref.watch(debtFilterTypeProvider);
  final showCompleted = ref.watch(showCompletedDebtsProvider);

  return debts.whenData((list) {
    var filtered = list;

    // Tip filtrelemesi
    if (filterType == 'lend') {
      filtered = filtered.where((d) => d.type == 'lend').toList();
    } else if (filterType == 'borrow') {
      filtered = filtered.where((d) => d.type == 'borrow').toList();
    }

    // Tamamlananları filtrele
    if (!showCompleted) {
      filtered = filtered.where((d) => !d.isCompleted).toList();
    }

    return filtered;
  });
});

/// Borç Controller Provider
final debtControllerProvider = Provider<DebtController>((ref) {
  return DebtController(ref);
});

/// Belirli bir borcun ödeme geçmişini getir
final debtPaymentsProvider =
    FutureProvider.family<List<DebtPaymentModel>, String>((ref, debtId) async {
      final debtRepo = ref.watch(debtRepositoryProvider);
      return await debtRepo.getDebtPayments(debtId);
    });

/// Borç işlemlerini yöneten controller
class DebtController {
  final Ref ref;

  DebtController(this.ref);

  /// Yeni borç/alacak ekle
  Future<bool> createDebt({
    required String personName,
    required double amount,
    required String type,
    DateTime? dueDate,
    String? description,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final debtRepo = ref.read(debtRepositoryProvider);
    final result = await debtRepo.createDebt(
      userId: user.id,
      personName: personName,
      amount: amount,
      type: type,
      dueDate: dueDate,
      description: description,
    );

    if (result != null) {
      // Tüm ilgili provider'ları yenile
      _invalidateAllProviders();
      return true;
    }
    return false;
  }

  /// Borç güncelle
  Future<bool> updateDebt(DebtModel debt) async {
    final debtRepo = ref.read(debtRepositoryProvider);
    final result = await debtRepo.updateDebt(debt);

    if (result != null) {
      _invalidateAllProviders();
      return true;
    }
    return false;
  }

  /// Ödeme kaydet
  Future<bool> recordPayment({
    required String debtId,
    required double amount,
  }) async {
    final debtRepo = ref.read(debtRepositoryProvider);
    try {
      final result = await debtRepo.recordPayment(
        debtId: debtId,
        paymentAmount: amount,
      );

      if (result != null) {
        _invalidateAllProviders();
        ref.invalidate(debtPaymentsProvider(debtId));
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Borcu tamamlandı olarak işaretle
  Future<bool> markAsCompleted(String debtId) async {
    final debtRepo = ref.read(debtRepositoryProvider);
    final result = await debtRepo.markAsCompleted(debtId);

    if (result) {
      _invalidateAllProviders();
      return true;
    }
    return false;
  }

  /// Borç sil
  Future<bool> deleteDebt(String debtId) async {
    final debtRepo = ref.read(debtRepositoryProvider);
    final result = await debtRepo.deleteDebt(debtId);

    if (result) {
      _invalidateAllProviders();
      return true;
    }
    return false;
  }

  /// Tüm provider'ları yenile
  void _invalidateAllProviders() {
    ref.invalidate(debtsProvider);
    ref.invalidate(lendsProvider);
    ref.invalidate(borrowsProvider);
    ref.invalidate(activeDebtsProvider);
    ref.invalidate(upcomingDebtsProvider);
    ref.invalidate(overdueDebtsProvider);
    ref.invalidate(totalLentProvider);
    ref.invalidate(totalBorrowedProvider);
    ref.invalidate(debtPeopleCountProvider);
  }
}
