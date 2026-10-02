// lib/core/services/support_actions.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_info.dart';

/// Kurulu sürüm bilgisi (Ayarlar altbilgisi ve geri bildirim e-postası için)
final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// Geliştiriciye yazma ve mağaza sayfasını açma
class SupportActions {
  /// E-posta uygulamasını geliştirici adresi ve sürüm bilgisiyle açar.
  /// E-posta uygulaması yoksa false döner.
  static Future<bool> sendFeedbackEmail() async {
    var versionLine = 'Wallet Elite';
    try {
      final info = await PackageInfo.fromPlatform();
      versionLine = 'Wallet Elite ${info.version} (${info.buildNumber})';
    } catch (e) {
      debugPrint('Sürüm bilgisi okunamadı: $e');
    }
    final device = kIsWeb
        ? 'web'
        : '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

    final uri = Uri(
      scheme: 'mailto',
      path: AppInfo.developerEmail,
      // Uri(queryParameters:) boşlukları "+" yapar; e-posta uygulamaları
      // bunu olduğu gibi gösterdiği için elle kodlanır.
      query: _encodeQuery({
        'subject': 'Wallet Elite - Feedback',
        'body': '\n\n\n---\n$versionLine\n$device',
      }),
    );
    try {
      return await launchUrl(uri);
    } catch (e) {
      debugPrint('E-posta uygulaması açılamadı: $e');
      return false;
    }
  }

  /// Play Store'daki uygulama sayfasını açar (puan verme / güncelleme).
  static Future<bool> openStoreListing() async {
    try {
      if (await launchUrl(
        AppInfo.playStoreAppUri,
        mode: LaunchMode.externalApplication,
      )) {
        return true;
      }
    } catch (e) {
      debugPrint('Play Store uygulaması açılamadı: $e');
    }
    try {
      return await launchUrl(
        AppInfo.playStoreWebUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Play Store sayfası açılamadı: $e');
      return false;
    }
  }

  static String _encodeQuery(Map<String, String> params) => params.entries
      .map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}
