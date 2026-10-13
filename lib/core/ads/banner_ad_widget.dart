// lib/core/ads/banner_ad_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';
import 'ads_providers.dart';

/// Ekran genişliğine uyarlanan (anchored adaptive) banner. Premium
/// kullanıcılarda, izin alınmadıysa veya reklam yüklenemezse yer kaplamaz.
class AdaptiveBannerAd extends ConsumerStatefulWidget {
  /// Banner ekranın en altındaysa (altında gezinme çubuğu yoksa) sistem
  /// çubuğunun üstünde kalması için true verilir.
  final bool bottomSafeArea;

  const AdaptiveBannerAd({super.key, this.bottomSafeArea = false});

  @override
  ConsumerState<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends ConsumerState<AdaptiveBannerAd> {
  // Yüklenemeyen reklam için yeniden deneme aralığı (klavye açılıp kapanması
  // gibi her ekran değişikliğinde yeni istek gönderilmesin)
  static const _retryAfter = Duration(seconds: 60);

  BannerAd? _banner;
  bool _loaded = false;
  bool _requesting = false;
  int? _loadedForWidth;
  DateTime? _lastFailureAt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    if (!ref.read(showAdsProvider) || _requesting) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    if (_loadedForWidth == width && _banner != null) return;
    final lastFailureAt = _lastFailureAt;
    if (_loadedForWidth == width &&
        lastFailureAt != null &&
        DateTime.now().difference(lastFailureAt) < _retryAfter) {
      return;
    }
    _loadedForWidth = width;

    // Boyut beklenirken ikinci bir çağrı aynı reklamı tekrar istemesin
    _requesting = true;
    final AdSize? size;
    try {
      size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        width,
      );
    } finally {
      _requesting = false;
    }
    if (!mounted || size == null || !ref.read(showAdsProvider)) return;

    _disposeBanner();
    final banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _lastFailureAt = null;
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner yüklenemedi: $error');
          ad.dispose();
          _lastFailureAt = DateTime.now();
          if (mounted) {
            setState(() {
              _banner = null;
              _loaded = false;
            });
          }
        },
      ),
    );
    setState(() => _banner = banner);
    await banner.load();
  }

  void _disposeBanner() {
    _banner?.dispose();
    _banner = null;
    _loaded = false;
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium'a geçilince veya izin durumu değişince banner'ı kaldır/yükle
    ref.listen<bool>(showAdsProvider, (_, show) {
      if (show) {
        _maybeLoad();
      } else if (_banner != null) {
        setState(_disposeBanner);
      }
    });

    final banner = _banner;
    if (!ref.watch(showAdsProvider) || banner == null || !_loaded) {
      return const SizedBox.shrink();
    }
    final adBox = SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
    return widget.bottomSafeArea ? SafeArea(top: false, child: adBox) : adBox;
  }
}
