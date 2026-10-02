// lib/features/premium/presentation/paywall_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/premium_provider.dart';

/// Premium satın alma ekranını açar
Future<void> showPaywall(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const PaywallView(),
    ),
  );
}

enum _Plan { monthly, yearly, lifetime }

class PaywallView extends ConsumerStatefulWidget {
  const PaywallView({super.key});

  @override
  ConsumerState<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends ConsumerState<PaywallView> {
  _Plan _selected = _Plan.yearly;

  @override
  void initState() {
    super.initState();
    // Fiyatları güncel çek
    Future.microtask(
      () => ref.read(premiumControllerProvider.notifier).refreshOfferings(),
    );
  }

  Package? _packageFor(Offering? offering, _Plan plan) {
    if (offering == null) return null;
    switch (plan) {
      case _Plan.monthly:
        return offering.monthly;
      case _Plan.yearly:
        return offering.annual;
      case _Plan.lifetime:
        return offering.lifetime;
    }
  }

  Future<void> _purchase() async {
    final l = AppLocalizations.of(context)!;
    final controller = ref.read(premiumControllerProvider.notifier);
    final package = _packageFor(
      ref.read(premiumControllerProvider).offering,
      _selected,
    );
    if (package == null) {
      _showMessage(l.purchaseNotAvailable);
      return;
    }
    final outcome = await controller.purchase(package);
    if (!mounted) return;
    _handleOutcome(outcome, l);
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context)!;
    final outcome = await ref
        .read(premiumControllerProvider.notifier)
        .restorePurchases();
    if (!mounted) return;
    _handleOutcome(outcome, l, isRestore: true);
  }

  void _handleOutcome(
    PurchaseOutcome outcome,
    AppLocalizations l, {
    bool isRestore = false,
  }) {
    switch (outcome) {
      case PurchaseOutcome.success:
        _showMessage(isRestore ? l.restoreSuccess : l.purchaseSuccess);
        Navigator.of(context).pop();
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.pending:
        _showMessage(l.purchasePending);
      case PurchaseOutcome.nothingToRestore:
        _showMessage(l.restoreNothing);
      case PurchaseOutcome.networkError:
        _showMessage(l.networkError);
      case PurchaseOutcome.notAvailable:
        _showMessage(l.purchaseNotAvailable);
      case PurchaseOutcome.error:
        _showMessage(l.errorOccurred);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final premium = ref.watch(premiumControllerProvider);
    final offering = premium.offering;

    final features = [
      (Icons.block, l.premiumFeatureNoAds),
      (Icons.palette_outlined, l.premiumFeatureThemes),
      (Icons.all_inclusive, l.premiumFeatureUnlimited),
      (Icons.file_download_outlined, l.premiumFeatureExport),
    ];

    return Scaffold(
      backgroundColor: isDark ? colorTheme.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: premium.isPremium
            ? _buildAlreadyPremium(l, colorTheme, isDark)
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: colorTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.premiumTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.premiumSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  for (final (icon, text) in features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(icon, color: colorTheme.primary),
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
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildPlan(
                    _Plan.yearly,
                    l.planYearly,
                    _packageFor(offering, _Plan.yearly),
                    l.perYear,
                    colorTheme.primary,
                    isDark,
                    badge: l.bestValue,
                  ),
                  _buildPlan(
                    _Plan.monthly,
                    l.planMonthly,
                    _packageFor(offering, _Plan.monthly),
                    l.perMonth,
                    colorTheme.primary,
                    isDark,
                  ),
                  _buildPlan(
                    _Plan.lifetime,
                    l.planLifetime,
                    _packageFor(offering, _Plan.lifetime),
                    l.oneTimePayment,
                    colorTheme.primary,
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: premium.isBusy ? null : _purchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorTheme.primary,
                        foregroundColor: colorTheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: premium.isBusy
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorTheme.onPrimary,
                              ),
                            )
                          : Text(
                              l.continueButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: premium.isBusy ? null : _restore,
                    child: Text(l.restorePurchases),
                  ),
                  if (offering == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l.purchaseNotAvailable,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    l.subscriptionTerms,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlan(
    _Plan plan,
    String title,
    Package? package,
    String period,
    Color primary,
    bool isDark, {
    String? badge,
  }) {
    final isSelected = _selected == plan;
    final price = package?.storeProduct.priceString ?? '—';

    return GestureDetector(
      onTap: () => setState(() => _selected = plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? primary.withValues(alpha: 0.1)
              : context.colors.subtleCardColor,
          border: Border.all(
            color: isSelected ? primary : context.colors.textMuted,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primary : context.colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: context.colors.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyPremium(
    AppLocalizations l,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 72, color: colorTheme.primary),
            const SizedBox(height: 16),
            Text(
              l.premiumActive,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.premiumActiveDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
