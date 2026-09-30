// lib/features/premium/data/premium_provider.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../auth/data/auth_provider.dart';
import 'premium_constants.dart';

/// Satın alma / geri yükleme sonucu
enum PurchaseOutcome {
  success,
  cancelled,
  pending,
  nothingToRestore,
  networkError,
  notAvailable,
  error,
}

class PremiumState {
  final bool isPremium;

  /// RevenueCat yapılandırıldı mı (API anahtarı var ve Android)
  final bool isAvailable;
  final Offering? offering;
  final bool isBusy;

  const PremiumState({
    this.isPremium = false,
    this.isAvailable = false,
    this.offering,
    this.isBusy = false,
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isAvailable,
    Offering? offering,
    bool? isBusy,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isAvailable: isAvailable ?? this.isAvailable,
      offering: offering ?? this.offering,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

/// RevenueCat üzerinden premium durumunu yönetir. Satın almaların doğrulanması
/// RevenueCat sunucularında yapılır; uygulama yalnızca entitlement'ı okur.
/// RevenueCat kullanıcısı Supabase kullanıcı ID'si ile eşlenir, böylece premium
/// hesaba bağlı kalır (aynı hesapla başka cihazda da geçerli).
class PremiumController extends StateNotifier<PremiumState> {
  PremiumController() : super(const PremiumState());

  Future<void>? _configureFuture;
  Future<void> _identityQueue = Future<void>.value();

  bool get _canConfigure =>
      PremiumConstants.revenueCatGoogleApiKey.isNotEmpty &&
      !kIsWeb &&
      Platform.isAndroid;

  Future<void> _ensureConfigured(String? userId) {
    return _configureFuture ??= () async {
      if (!_canConfigure) return;
      try {
        final configuration = PurchasesConfiguration(
          PremiumConstants.revenueCatGoogleApiKey,
        )..appUserID = userId;
        await Purchases.configure(configuration);
        Purchases.addCustomerInfoUpdateListener(_applyCustomerInfo);
        if (mounted) state = state.copyWith(isAvailable: true);
        _applyCustomerInfo(await Purchases.getCustomerInfo());
        await refreshOfferings();
      } catch (e) {
        debugPrint('RevenueCat yapılandırılamadı: $e');
      }
    }();
  }

  /// Oturum açan/kapanan Supabase kullanıcısıyla RevenueCat kimliğini eşle
  void onUserChanged(String? userId) {
    _identityQueue = _identityQueue.then((_) async {
      final firstConfigure = _configureFuture == null;
      await _ensureConfigured(userId);
      if (!_canConfigure || !state.isAvailable || firstConfigure) return;
      try {
        if (userId == null) {
          if (!await Purchases.isAnonymous) {
            _applyCustomerInfo(await Purchases.logOut());
          }
        } else {
          _applyCustomerInfo((await Purchases.logIn(userId)).customerInfo);
        }
      } catch (e) {
        debugPrint('RevenueCat kimlik eşleme hatası: $e');
      }
    });
  }

  Future<void> refreshOfferings() async {
    if (!state.isAvailable) return;
    try {
      final offerings = await Purchases.getOfferings();
      if (mounted && offerings.current != null) {
        state = state.copyWith(offering: offerings.current);
      }
    } catch (e) {
      debugPrint('RevenueCat teklifleri alınamadı: $e');
    }
  }

  Future<PurchaseOutcome> purchase(Package package) async {
    if (!state.isAvailable) return PurchaseOutcome.notAvailable;
    state = state.copyWith(isBusy: true);
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _applyCustomerInfo(result.customerInfo);
      return state.isPremium ? PurchaseOutcome.success : PurchaseOutcome.error;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      switch (code) {
        case PurchasesErrorCode.purchaseCancelledError:
          return PurchaseOutcome.cancelled;
        case PurchasesErrorCode.paymentPendingError:
          return PurchaseOutcome.pending;
        case PurchasesErrorCode.productAlreadyPurchasedError:
          // Play'de zaten sahip; yeniden eşitleyip geri yükle
          return _restore();
        case PurchasesErrorCode.networkError:
        case PurchasesErrorCode.offlineConnectionError:
        case PurchasesErrorCode.storeProblemError:
          return PurchaseOutcome.networkError;
        default:
          debugPrint('Satın alma hatası: $code $e');
          return PurchaseOutcome.error;
      }
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<PurchaseOutcome> restorePurchases() async {
    if (!state.isAvailable) return PurchaseOutcome.notAvailable;
    state = state.copyWith(isBusy: true);
    try {
      return await _restore();
    } finally {
      if (mounted) state = state.copyWith(isBusy: false);
    }
  }

  Future<PurchaseOutcome> _restore() async {
    try {
      _applyCustomerInfo(await Purchases.restorePurchases());
      return state.isPremium
          ? PurchaseOutcome.success
          : PurchaseOutcome.nothingToRestore;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.networkError ||
          code == PurchasesErrorCode.offlineConnectionError ||
          code == PurchasesErrorCode.storeProblemError) {
        return PurchaseOutcome.networkError;
      }
      debugPrint('Geri yükleme hatası: $code $e');
      return PurchaseOutcome.error;
    }
  }

  void _applyCustomerInfo(CustomerInfo info) {
    final isPremium =
        info.entitlements.all[PremiumConstants.entitlementId]?.isActive ??
        false;
    if (mounted && state.isPremium != isPremium) {
      state = state.copyWith(isPremium: isPremium);
    }
  }

  @override
  void dispose() {
    if (_configureFuture != null && state.isAvailable) {
      Purchases.removeCustomerInfoUpdateListener(_applyCustomerInfo);
    }
    super.dispose();
  }
}

final premiumControllerProvider =
    StateNotifierProvider<PremiumController, PremiumState>((ref) {
      final controller = PremiumController();
      ref.listen<String?>(
        currentUserIdProvider,
        (_, userId) => controller.onUserChanged(userId),
        fireImmediately: true,
      );
      return controller;
    });

/// Kullanıcı premium mu (reklamsız, tüm temalar, sınırsız cüzdan/bütçe, dışa aktarma)
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumControllerProvider.select((s) => s.isPremium));
});
