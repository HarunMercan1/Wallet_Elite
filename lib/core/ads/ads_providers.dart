// lib/core/ads/ads_providers.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../features/premium/data/premium_provider.dart';
import 'ad_consent_service.dart';
import 'ad_helper.dart';
import 'full_screen_ad_gate.dart';

export 'full_screen_ad_gate.dart';

/// GDPR/UMP izin durumu ve Mobile Ads SDK başlatma
final adConsentProvider = ChangeNotifierProvider<AdConsentService>((ref) {
  return AdConsentService();
});

/// Reklam gösterilsin mi: izin alındı, SDK hazır, premium durumu öğrenildi ve
/// kullanıcı premium değil
final showAdsProvider = Provider<bool>((ref) {
  final adsReady = ref.watch(adConsentProvider.select((c) => c.adsReady));
  final premiumResolved = ref.watch(
    premiumControllerProvider.select((s) => s.isResolved),
  );
  final isPremium = ref.watch(isPremiumProvider);
  return adsReady && premiumResolved && !isPremium;
});

/// Ödüllü reklamı önceden yükler ve gösterir
class RewardedAdService {
  // Yüklenen reklamlar bir saat sonra geçersiz olur
  static const _maxCacheAge = Duration(minutes: 55);

  RewardedAd? _ad;
  DateTime? _loadedAt;
  bool _loading = false;

  bool get _isExpired {
    final loadedAt = _loadedAt;
    return loadedAt != null &&
        DateTime.now().difference(loadedAt) > _maxCacheAge;
  }

  bool get isReady => _ad != null && !_isExpired;

  void load() {
    if (_ad != null && _isExpired) dispose();
    if (_ad != null || _loading) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadedAt = DateTime.now();
          _loading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Ödüllü reklam yüklenemedi: $error');
          _loading = false;
        },
      ),
    );
  }

  /// Reklamı gösterir; kullanıcı ödülü hak ederse true döner.
  Future<bool> show() async {
    if (!isReady) {
      load();
      return false;
    }
    final ad = _ad!;
    _ad = null;
    _loadedAt = null;

    var earned = false;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Ödüllü reklam gösterilemedi: $error');
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    FullScreenAdGate.opened();
    try {
      await ad.show(onUserEarnedReward: (_, _) => earned = true);
      await closed.future;
    } catch (e) {
      debugPrint('Ödüllü reklam gösterilemedi: $e');
    } finally {
      FullScreenAdGate.closed();
    }
    load(); // bir sonrakini hazırla
    return earned;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
    _loadedAt = null;
  }
}

final rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  final service = RewardedAdService();
  // Reklamlar hazır olunca bir tane önceden yükle
  ref.listen<bool>(showAdsProvider, (_, show) {
    if (show) service.load();
  }, fireImmediately: true);
  ref.onDispose(service.dispose);
  return service;
});

/// Uygulama açılışında GDPR iznini bir kez toplar (gerekirse formu gösterir).
/// Premium kullanıcı reklam görmediği için ona izin formu da gösterilmez;
/// bu yüzden önce premium durumunun öğrenilmesi beklenir.
final adConsentStartupProvider = FutureProvider<void>((ref) async {
  final premium = ref.watch(
    premiumControllerProvider.select((s) => (s.isResolved, s.isPremium)),
  );
  final (isResolved, isPremium) = premium;
  if (!isResolved || isPremium) return;
  await ref.read(adConsentProvider).gatherConsent();
});
