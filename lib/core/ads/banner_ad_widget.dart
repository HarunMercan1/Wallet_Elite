// lib/core/ads/banner_ad_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';
import 'ads_providers.dart';

/// Ekran genişliğine uyarlanan (anchored adaptive) banner. Premium
/// kullanıcılarda, izin alınmadıysa veya reklam yüklenemezse yer kaplamaz.
class AdaptiveBannerAd extends ConsumerStatefulWidget {
  const AdaptiveBannerAd({super.key});

  @override
  ConsumerState<AdaptiveBannerAd> createState() => _AdaptiveBannerAdState();
}

class _AdaptiveBannerAdState extends ConsumerState<AdaptiveBannerAd> {
  BannerAd? _banner;
  bool _loaded = false;
  int? _loadedForWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    if (!ref.read(showAdsProvider)) return;
    final width = MediaQuery.of(context).size.width.truncate();
    if (_loadedForWidth == width && _banner != null) return;
    _loadedForWidth = width;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null) return;

    _disposeBanner();
    final banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner yüklenemedi: $error');
          ad.dispose();
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
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
