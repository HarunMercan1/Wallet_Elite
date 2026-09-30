// lib/core/ads/ad_helper.dart

import 'package:flutter/foundation.dart';

/// AdMob reklam birimi kimlikleri. Debug derlemeleri daima Google'ın resmi
/// test kimliklerini kullanır; böylece geliştirme sırasında gerçek reklama
/// tıklanıp hesap riske atılmaz. Uygulama kimliği
/// android/app/src/main/res/values/admob.xml içinde.
class AdHelper {
  static const String _testAdaptiveBannerId =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String _productionAdaptiveBannerId =
      'ca-app-pub-3820038977003119/3641957956';
  static const String _productionRewardedId =
      'ca-app-pub-3820038977003119/3376207957';

  static bool get isTestMode => kDebugMode;

  static String get bannerAdUnitId =>
      isTestMode ? _testAdaptiveBannerId : _productionAdaptiveBannerId;

  static String get rewardedAdUnitId =>
      isTestMode ? _testRewardedId : _productionRewardedId;
}
