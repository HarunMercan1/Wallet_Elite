// lib/features/premium/presentation/premium_gate.dart

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'paywall_view.dart';

/// Ücretsiz sürüm sınırına ulaşıldığında gösterilir; Premium'a yönlendirir.
Future<void> showPremiumRequiredDialog(BuildContext context, String message) {
  final l = AppLocalizations.of(context)!;
  final navigator = Navigator.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.workspace_premium, size: 40),
      title: Text(l.premiumTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            showPaywall(navigator.context);
          },
          child: Text(l.goPremium),
        ),
      ],
    ),
  );
}
