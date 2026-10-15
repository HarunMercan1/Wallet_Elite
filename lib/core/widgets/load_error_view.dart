import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Bir liste/ekran sunucudan yüklenemediğinde gösterilen durum: ham hata
/// metni yerine anlaşılır bir mesaj ve "Tekrar dene" butonu. Asıl hata
/// geliştirici için loglanır.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({super.key, required this.error, this.onRetry});

  final Object error;

  /// Genelde ilgili provider'ı `ref.invalidate` eder
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    debugPrint('Yükleme hatası: $error');
    final l = AppLocalizations.of(context)!;
    final c = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, color: c.error, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              l.loadErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
