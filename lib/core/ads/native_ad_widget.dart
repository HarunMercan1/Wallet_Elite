// lib/core/ads/native_ad_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../theme/app_colors.dart';
import 'ad_helper.dart';
import 'ads_providers.dart';

/// Liste içine yerleşen, uygulama temasına uyan küçük native reklam kartı.
/// Premium kullanıcılarda, izin alınmadıysa veya reklam yüklenemezse yer
/// kaplamaz.
class NativeAdCard extends ConsumerStatefulWidget {
  final EdgeInsetsGeometry margin;

  const NativeAdCard({super.key, this.margin = EdgeInsets.zero});

  @override
  ConsumerState<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends ConsumerState<NativeAdCard>
    with AutomaticKeepAliveClientMixin {
  // Küçük şablonun (TemplateType.small) yüksekliği
  static const double _height = 104;

  static const _retryAfter = Duration(seconds: 60);

  NativeAd? _ad;
  bool _loaded = false;
  // Şablon renkleri yüklenirken sabitlenir: hangi palet için yüklendi
  // ("tema kimliği/parlaklık"). Tema geçiş animasyonundaki ara renkler yeni
  // istek tetiklemesin diye renklerin kendisi değil kimlik karşılaştırılır.
  String? _loadedForPalette;
  DateTime? _lastFailureAt;

  // Liste kaydırılınca reklam atılıp yeniden istenmesin
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoad();
  }

  void _maybeLoad() {
    if (!ref.read(showAdsProvider) || AdHelper.nativeAdUnitId.isEmpty) return;
    final theme = Theme.of(context);
    final colorTheme = theme.extension<ColorTheme>()!;
    // Açık/koyu ya da renk teması değişince yeniden yükle
    final palette = '${colorTheme.id}/${theme.brightness.name}';
    final samePalette = _loadedForPalette == palette;
    if (_ad != null && samePalette) return;
    final lastFailureAt = _lastFailureAt;
    if (samePalette &&
        lastFailureAt != null &&
        DateTime.now().difference(lastFailureAt) < _retryAfter) {
      return;
    }
    _loadedForPalette = palette;

    _disposeAd();
    final ad = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          _lastFailureAt = null;
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native reklam yüklenemedi: $error');
          ad.dispose();
          _lastFailureAt = DateTime.now();
          if (mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: colorTheme.cardColor,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: colorTheme.onPrimary,
          backgroundColor: colorTheme.primary,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: colorTheme.textPrimary,
          backgroundColor: colorTheme.cardColor,
          style: NativeTemplateFontStyle.bold,
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: colorTheme.textSecondary,
          backgroundColor: colorTheme.cardColor,
          style: NativeTemplateFontStyle.normal,
          size: 13,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: colorTheme.textSecondary,
          backgroundColor: colorTheme.cardColor,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
      ),
    );
    _ad = ad;
    ad.load();
  }

  void _disposeAd() {
    _ad?.dispose();
    _ad = null;
    _loaded = false;
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Premium'a geçilince veya izin durumu değişince reklamı kaldır/yükle
    ref.listen<bool>(showAdsProvider, (_, show) {
      if (show) {
        _maybeLoad();
      } else if (_ad != null) {
        setState(_disposeAd);
      }
    });

    final ad = _ad;
    if (!ref.watch(showAdsProvider) || ad == null || !_loaded) {
      return const SizedBox.shrink();
    }
    final colorTheme = Theme.of(context).extension<ColorTheme>()!;

    return Container(
      margin: widget.margin,
      height: _height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorTheme.outline, width: 1),
      ),
      child: AdWidget(ad: ad),
    );
  }
}
