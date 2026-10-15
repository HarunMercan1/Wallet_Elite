// lib/features/premium/presentation/premium_gate.dart

import '../../../core/widgets/sheet_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'paywall_view.dart';

/// Ücretsiz sürüm sınırına ulaşıldığında gösterilir; Premium'a yönlendirir.
Future<void> showPremiumRequiredDialog(BuildContext context, String message) {
  final navigator = Navigator.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PremiumRequiredSheet(
      message: message,
      onUpgrade: () {
        Navigator.pop(navigator.context);
        showPaywall(navigator.context);
      },
    ),
  );
}

class _PremiumRequiredSheet extends ConsumerWidget {
  const _PremiumRequiredSheet({required this.message, required this.onUpgrade});

  final String message;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);

    final features = [
      (Icons.block, l.premiumFeatureNoAds),
      (Icons.insights_outlined, l.premiumFeatureStats),
      (Icons.palette_outlined, l.premiumFeatureThemes),
      (Icons.all_inclusive, l.premiumFeatureUnlimited),
      (Icons.file_download_outlined, l.premiumFeatureExport),
    ];

    return SheetSurface(
      color: colorTheme.cardColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Degrade başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                gradient: colorTheme.heroGradient,
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorTheme.onHero.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorTheme.onHero.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: colorTheme.onHero,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.premiumTitle,
                    style: TextStyle(
                      color: colorTheme.onHero,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorTheme.onHero.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            // Premium ile gelenler
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Column(
                children: [
                  for (final (icon, text) in features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              icon,
                              color: colorTheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 15,
                                color: colorTheme.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: colorTheme.success,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Butonlar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onUpgrade,
                      icon: const Icon(Icons.workspace_premium),
                      label: Text(
                        l.goPremium,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorTheme.primary,
                        foregroundColor: colorTheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l.cancel,
                      style: TextStyle(color: colorTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
