// lib/features/settings/presentation/theme_picker_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ads_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/theme/premium_theme_provider.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../premium/presentation/paywall_view.dart';
import '../data/settings_provider.dart';

/// Renk şeması seçici: temalar uygulanmadan önce canlı önizlemeyle (koyu ve
/// açık) incelenir.
Future<void> showThemePickerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ThemePickerSheet(),
  );
}

class ThemePickerSheet extends ConsumerStatefulWidget {
  const ThemePickerSheet({super.key});

  @override
  ConsumerState<ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<ThemePickerSheet> {
  late String _previewId = ref.read(currentColorThemeProvider).id;
  Brightness? _previewBrightness;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = context.colors;
    final brightness = _previewBrightness ?? colors.brightness;
    final activeId = ref.watch(currentColorThemeProvider).id;
    final previewTheme = ColorTheme.fromString(
      _previewId,
    ).forBrightness(brightness);
    final currencySymbol = CurrencyUtils.getSymbol(ref.watch(currencyProvider));

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.colorScheme,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  _BrightnessToggle(
                    brightness: brightness,
                    lightLabel: l.light,
                    darkLabel: l.dark,
                    onChanged: (value) =>
                        setState(() => _previewBrightness = value),
                  ),
                ],
              ),
            ),

            // Canlı önizleme
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: ThemePreview(
                    key: ValueKey('$_previewId-$brightness'),
                    theme: previewTheme,
                    currencySymbol: currencySymbol,
                  ),
                ),
              ),
            ),

            // Tema listesi
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                itemCount: ColorTheme.all.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final theme = ColorTheme.all[index];
                  return _ThemeChip(
                    theme: theme.forBrightness(brightness),
                    isPreviewing: theme.id == _previewId,
                    isActive: theme.id == activeId,
                    isLocked: !ref.watch(canUseThemeProvider(theme.id)),
                    onTap: () => setState(() => _previewId = theme.id),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _buildActions(l, colors, previewTheme, activeId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(
    AppLocalizations l,
    ColorTheme colors,
    ColorTheme previewTheme,
    String activeId,
  ) {
    const height = 50.0;

    if (_previewId == activeId) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle, size: 20),
          label: Text(l.active),
          style: OutlinedButton.styleFrom(
            disabledForegroundColor: colors.textSecondary,
            side: BorderSide(color: colors.outline),
          ),
        ),
      );
    }

    if (ref.watch(canUseThemeProvider(_previewId))) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: () {
            ref.read(colorSchemeProvider.notifier).setColorScheme(_previewId);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: previewTheme.primary,
            foregroundColor: previewTheme.onPrimary,
          ),
          child: Text(l.apply),
        ),
      );
    }

    // Kilitli premium tema: reklamla süreli aç veya premium'a geç
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.rewardedThemeUnlockMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: height,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    showPaywall(navigator.context);
                  },
                  icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                  label: FittedBox(child: Text(l.goPremium)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: height,
                child: ElevatedButton.icon(
                  onPressed: () => _unlockWithAd(l),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: FittedBox(child: Text(l.watchAd)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: previewTheme.primary,
                    foregroundColor: previewTheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _unlockWithAd(AppLocalizations l) async {
    final themeId = _previewId;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final rewarded = ref.read(rewardedAdServiceProvider);
    if (!rewarded.isReady) {
      rewarded.load();
      messenger.showSnackBar(SnackBar(content: Text(l.adNotReady)));
      return;
    }
    final earned = await rewarded.show();
    if (!earned) return;

    await ref.read(unlockedThemesProvider.notifier).unlockTheme(themeId);
    ref.read(colorSchemeProvider.notifier).setColorScheme(themeId);
    if (navigator.canPop()) navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.themeUnlocked24h)));
  }
}

/// Önizleme için koyu/açık geçişi
class _BrightnessToggle extends StatelessWidget {
  final Brightness brightness;
  final String lightLabel;
  final String darkLabel;
  final ValueChanged<Brightness> onChanged;

  const _BrightnessToggle({
    required this.brightness,
    required this.lightLabel,
    required this.darkLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget segment(Brightness value, IconData icon, String label) {
      final selected = value == brightness;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? colors.onPrimary : colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? colors.onPrimary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.subtleCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(Brightness.light, Icons.light_mode_rounded, lightLabel),
          segment(Brightness.dark, Icons.dark_mode_rounded, darkLabel),
        ],
      ),
    );
  }
}

/// Liste öğesi: temanın renk örneği, adı ve durumu (aktif / kilitli / PRO)
class _ThemeChip extends StatelessWidget {
  final ColorTheme theme;
  final bool isPreviewing;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.theme,
    required this.isPreviewing,
    required this.isActive,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isPreviewing ? colors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: colors.outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Üst yarı: ana renk gradyanı, alt yarı: tema zemini
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 30,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.primary, theme.primaryLight],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 7,
                      bottom: 6,
                      child: Row(
                        children: [
                          _dot(theme.tertiary),
                          const SizedBox(width: 3),
                          _dot(theme.success),
                          const SizedBox(width: 3),
                          _dot(theme.error),
                        ],
                      ),
                    ),
                    if (isActive || isLocked)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          isActive ? Icons.check_circle : Icons.lock_rounded,
                          size: 16,
                          color: theme.onPrimary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              theme.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.15,
                fontWeight: isPreviewing ? FontWeight.w700 : FontWeight.w500,
                color: isPreviewing ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Bir temanın küçük ölçekli canlı önizlemesi: ana sayfanın başlığı, bakiye
/// kartı, hızlı erişim, işlem satırları ve temel butonlar o temanın gerçek
/// renkleriyle çizilir.
class ThemePreview extends StatelessWidget {
  final ColorTheme theme;
  final String currencySymbol;

  const ThemePreview({
    super.key,
    required this.theme,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.create(colorTheme: theme, brightness: theme.brightness),
      // Önizleme dokunulmaz; yalnızca görünüm içindir
      child: IgnorePointer(
        child: Builder(
          builder: (context) => _PreviewBody(currencySymbol: currencySymbol),
        ),
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  final String currencySymbol;

  const _PreviewBody({required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: c.primary,
                child: Text(
                  'W',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: c.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.welcome,
                      style: TextStyle(fontSize: 10.5, color: c.textSecondary),
                    ),
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: c.tertiary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'ELITE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: c.onTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bakiye kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.primary, c.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.totalBalance,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${currencySymbol}12.450,00',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: c.onPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _balanceStat(
                        c,
                        l.income,
                        '${currencySymbol}18.000',
                        Icons.arrow_upward_rounded,
                        c.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _balanceStat(
                        c,
                        l.expense,
                        '${currencySymbol}5.550',
                        Icons.arrow_downward_rounded,
                        c.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Hızlı erişim
          Row(
            children: [
              Expanded(
                child: _quickTile(c, Icons.handshake_outlined, c.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _quickTile(
                  c,
                  Icons.pie_chart_outline_rounded,
                  c.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _quickTile(c, Icons.autorenew_rounded, c.tertiary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _quickTile(
                  c,
                  Icons.notifications_none_rounded,
                  c.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _quickTile(c, Icons.info_outline_rounded, c.info),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // İşlem satırları
          _transactionRow(
            c,
            Icons.restaurant,
            l.cat_food,
            '-${currencySymbol}240,00',
            c.error,
          ),
          const SizedBox(height: 8),
          _transactionRow(
            c,
            Icons.wallet,
            l.cat_salary,
            '+${currencySymbol}18.000,00',
            c.success,
          ),
          const SizedBox(height: 12),

          // Butonlar ve seçim öğeleri
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l.save),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l.cancel),
                ),
              ),
              const SizedBox(width: 4),
              Switch(value: true, onChanged: (_) {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceStat(
    ColorTheme c,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: c.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: c.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: c.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickTile(ColorTheme c, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: c.cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: c.outline),
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }

  Widget _transactionRow(
    ColorTheme c,
    IconData icon,
    String title,
    String amount,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: c.cardColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: c.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  '01.10',
                  style: TextStyle(fontSize: 10.5, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
