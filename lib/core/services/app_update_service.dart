// lib/core/services/app_update_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../l10n/app_localizations.dart';
import 'support_actions.dart';

/// Play Store'da daha yeni bir sürüm varsa onun bilgisi, yoksa null.
/// Uygulama Play'den kurulmadıysa (debug, elle kurulum) kontrol hata verir;
/// bu durumda sessizce null dönülür.
final appUpdateInfoProvider = FutureProvider<AppUpdateInfo?>((ref) async {
  if (kIsWeb || !Platform.isAndroid) return null;
  try {
    final info = await InAppUpdate.checkForUpdate();
    return info.updateAvailability == UpdateAvailability.updateAvailable
        ? info
        : null;
  } catch (e) {
    debugPrint('Güncelleme kontrolü yapılamadı: $e');
    return null;
  }
});

/// "Güncelleme var" penceresini gösterir; kullanıcı kabul ederse Play'in
/// uygulama içi güncelleme akışını başlatır.
Future<void> showUpdateAvailableDialog(
  BuildContext context,
  AppUpdateInfo info,
) async {
  final l = AppLocalizations.of(context)!;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.system_update_rounded, size: 32),
      title: Text(l.updateAvailableTitle),
      content: Text(l.updateAvailableMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l.later),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l.updateNow),
        ),
      ],
    ),
  );
  if (accepted != true) return;

  try {
    if (info.immediateUpdateAllowed) {
      await InAppUpdate.performImmediateUpdate();
    } else if (info.flexibleUpdateAllowed) {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } else {
      await SupportActions.openStoreListing();
    }
  } catch (e) {
    // Kullanıcı Play ekranında vazgeçtiyse veya akış başlatılamadıysa
    debugPrint('Güncelleme başlatılamadı: $e');
  }
}
