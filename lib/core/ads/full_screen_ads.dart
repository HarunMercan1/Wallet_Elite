// lib/core/ads/full_screen_ads.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';
import 'ads_providers.dart';

/// Geçiş (interstitial) reklamı. Kullanıcıyı boğmamak için her
/// [_actionsPerAd] eylemde bir ve en az [_minInterval] arayla gösterilir.
class InterstitialAdService {
  static const _actionsPerAd = 3;
  static const _minInterval = Duration(minutes: 2);

  InterstitialAd? _ad;
  bool _loading = false;
  bool _enabled = false;
  int _actions = 0;

  set enabled(bool value) {
    _enabled = value;
    if (value) {
      _load();
    } else {
      dispose();
    }
  }

  void _load() {
    final unitId = AdHelper.interstitialAdUnitId;
    if (!_enabled || unitId.isEmpty || _ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          if (_enabled) {
            _ad = ad;
          } else {
            ad.dispose();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('Geçiş reklamı yüklenemedi: $error');
          _loading = false;
        },
      ),
    );
  }

  /// Doğal bir geçiş anında (işlem kaydı, alt ekrandan dönüş) çağrılır;
  /// sıklık sınırı uygunsa reklamı gösterir.
  void onUserAction() {
    if (!_enabled) return;
    _actions++;
    final ad = _ad;
    if (ad == null) {
      _load();
      return;
    }
    if (_actions < _actionsPerAd ||
        FullScreenAdGate.isShowing ||
        FullScreenAdGate.closedWithin(_minInterval)) {
      return;
    }

    _ad = null;
    _actions = 0;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        FullScreenAdGate.closed();
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Geçiş reklamı gösterilemedi: $error');
        ad.dispose();
        FullScreenAdGate.closed();
        _load();
      },
    );
    FullScreenAdGate.opened();
    ad.show();
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}

final interstitialAdServiceProvider = Provider<InterstitialAdService>((ref) {
  final service = InterstitialAdService();
  ref.listen<bool>(
    showAdsProvider,
    (_, show) => service.enabled = show,
    fireImmediately: true,
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Uygulama açılış (app open) reklamı: uygulama arka plandan öne geldiğinde
/// gösterilir. Kısa süreli çıkışlarda (izin penceresi, satın alma ekranı vb.)
/// ve başka bir tam ekran reklamın hemen ardından gösterilmez.
class AppOpenAdService {
  static const _maxCacheAge = Duration(hours: 4);
  static const _minBackgroundTime = Duration(seconds: 30);
  static const _minInterval = Duration(minutes: 4);

  AppOpenAd? _ad;
  DateTime? _loadedAt;
  DateTime? _backgroundedAt;
  bool _loading = false;
  bool _enabled = false;
  StreamSubscription<AppState>? _appStateSubscription;

  set enabled(bool value) {
    _enabled = value;
    if (value) {
      _appStateSubscription ??= _listenAppState();
      _load();
    } else {
      _disposeAd();
    }
  }

  StreamSubscription<AppState> _listenAppState() {
    AppStateEventNotifier.startListening();
    return AppStateEventNotifier.appStateStream.listen((state) {
      if (state == AppState.background) {
        _backgroundedAt = DateTime.now();
      } else if (state == AppState.foreground) {
        _showIfAppropriate();
      }
    });
  }

  void _load() {
    final unitId = AdHelper.appOpenAdUnitId;
    if (!_enabled || unitId.isEmpty || _ad != null || _loading) return;
    _loading = true;
    AppOpenAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          if (_enabled) {
            _ad = ad;
            _loadedAt = DateTime.now();
          } else {
            ad.dispose();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('Açılış reklamı yüklenemedi: $error');
          _loading = false;
        },
      ),
    );
  }

  void _showIfAppropriate() {
    if (!_enabled || FullScreenAdGate.isShowing) return;

    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null ||
        DateTime.now().difference(backgroundedAt) < _minBackgroundTime ||
        FullScreenAdGate.closedWithin(_minInterval)) {
      return;
    }

    final ad = _ad;
    final loadedAt = _loadedAt;
    if (ad == null || loadedAt == null) {
      _load();
      return;
    }
    // Süresi dolan reklam gösterilmez; yenisi istenir.
    if (DateTime.now().difference(loadedAt) > _maxCacheAge) {
      _disposeAd();
      _load();
      return;
    }

    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        FullScreenAdGate.closed();
        _load();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Açılış reklamı gösterilemedi: $error');
        ad.dispose();
        FullScreenAdGate.closed();
        _load();
      },
    );
    FullScreenAdGate.opened();
    ad.show();
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
    _loadedAt = null;
  }

  void dispose() {
    _appStateSubscription?.cancel();
    _appStateSubscription = null;
    _disposeAd();
  }
}

final appOpenAdServiceProvider = Provider<AppOpenAdService>((ref) {
  final service = AppOpenAdService();
  ref.listen<bool>(
    showAdsProvider,
    (_, show) => service.enabled = show,
    fireImmediately: true,
  );
  ref.onDispose(service.dispose);
  return service;
});
