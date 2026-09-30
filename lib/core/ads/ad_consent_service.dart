// lib/core/ads/ad_consent_service.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google UMP (GDPR) iznini toplar ve Mobile Ads SDK'sını yalnızca izin durumu
/// kesinleşince başlatır; böylece izinsiz/erken reklam isteği gönderilmez.
class AdConsentService extends ChangeNotifier {
  static const _umpTestDeviceId = String.fromEnvironment('UMP_TEST_DEVICE_ID');

  Future<void>? _gatheringFuture;
  Future<void>? _mobileAdsInitialization;
  bool _adsReady = false;
  bool _privacyOptionsRequired = false;
  bool _disposed = false;

  /// Reklam istenebilir mi (izin alındı ve SDK başlatıldı)
  bool get adsReady => _adsReady;

  /// Ayarlarda "Reklam gizlilik ayarları" seçeneği gösterilmeli mi (AB/UK)
  bool get isPrivacyOptionsRequired => _privacyOptionsRequired;

  Future<void> gatherConsent() {
    return _gatheringFuture ??= _gatherConsent().whenComplete(() {
      _gatheringFuture = null;
    });
  }

  Future<void> _gatherConsent() async {
    try {
      await _requestConsentInfoUpdate().timeout(const Duration(seconds: 12));
      await _loadAndShowConsentFormIfRequired().timeout(
        const Duration(seconds: 30),
      );
    } catch (error) {
      // Ağ/form hatasında UMP'nin önceki oturumdan sakladığı durum kullanılır;
      // canRequestAds kontrolü yine yapılır.
      debugPrint('UMP izin akışı tamamlanamadı: $error');
    }

    await _refreshPrivacyOptionsRequirement();
    await _refreshAdReadiness();
  }

  Future<void> showPrivacyOptionsForm() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error == null) {
        completer.complete();
      } else {
        completer.completeError(error);
      }
    });
    try {
      await completer.future;
    } catch (error) {
      debugPrint('Gizlilik seçenekleri formu açılamadı: $error');
    }
    await _refreshPrivacyOptionsRequirement();
    await _refreshAdReadiness();
  }

  Future<void> _requestConsentInfoUpdate() {
    final completer = Completer<void>();
    final debugSettings = kDebugMode && _umpTestDeviceId.isNotEmpty
        ? ConsentDebugSettings(
            debugGeography: DebugGeography.debugGeographyEea,
            testIdentifiers: const [_umpTestDeviceId],
          )
        : null;

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(consentDebugSettings: debugSettings),
      () => completer.complete(),
      (error) => completer.completeError(error),
    );
    return completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error == null) {
        completer.complete();
      } else {
        completer.completeError(error);
      }
    });
    return completer.future;
  }

  Future<void> _refreshPrivacyOptionsRequirement() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      final required = status == PrivacyOptionsRequirementStatus.required;
      if (_privacyOptionsRequired != required) {
        _privacyOptionsRequired = required;
        _safeNotify();
      }
    } catch (error) {
      debugPrint('UMP gizlilik seçenekleri durumu okunamadı: $error');
    }
  }

  Future<void> _refreshAdReadiness() async {
    var canRequestAds = false;
    try {
      canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (error) {
      debugPrint('UMP reklam izni durumu okunamadı: $error');
    }

    if (canRequestAds) {
      _mobileAdsInitialization ??= MobileAds.instance.initialize();
      try {
        await _mobileAdsInitialization;
      } catch (error) {
        _mobileAdsInitialization = null;
        debugPrint('Mobile Ads başlatılamadı: $error');
        canRequestAds = false;
      }
    }

    if (_adsReady != canRequestAds) {
      _adsReady = canRequestAds;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
