// lib/core/ads/ads_providers.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../features/premium/data/premium_provider.dart';
import 'ad_consent_service.dart';
import 'ad_helper.dart';

/// GDPR/UMP izin durumu ve Mobile Ads SDK başlatma
final adConsentProvider = ChangeNotifierProvider<AdConsentService>((ref) {
  return AdConsentService();
});

/// Reklam gösterilsin mi: izin alındı, SDK hazır ve kullanıcı premium değil
final showAdsProvider = Provider<bool>((ref) {
  final adsReady = ref.watch(adConsentProvider.select((c) => c.adsReady));
  final isPremium = ref.watch(isPremiumProvider);
  return adsReady && !isPremium;
});

/// Tam ekran reklamlar (geçiş, uygulama açılış, ödüllü) arasında ortak durum:
/// aynı anda yalnızca biri gösterilir ve art arda gösterim engellenir.
class FullScreenAdGate {
  static bool isShowing = false;
  static DateTime? lastClosedAt;

  static bool closedWithin(Duration duration) {
    final last = lastClosedAt;
    return last != null && DateTime.now().difference(last) < duration;
  }

  static void opened() => isShowing = true;

  static void closed() {
    isShowing = false;
    lastClosedAt = DateTime.now();
  }
}

/// Ödüllü reklamı önceden yükler ve gösterir
class RewardedAdService {
  RewardedAd? _ad;
  bool _loading = false;

  bool get isReady => _ad != null;

  void load() {
    if (_ad != null || _loading) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
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
    final ad = _ad;
    if (ad == null) {
      load();
      return false;
    }
    _ad = null;

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
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    await closed.future;
    FullScreenAdGate.closed();
    load(); // bir sonrakini hazırla
    return earned;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
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

/// Uygulama açılışında GDPR iznini bir kez toplar (gerekirse formu gösterir)
final adConsentStartupProvider = FutureProvider<void>((ref) {
  return ref.read(adConsentProvider).gatherConsent();
});
