// lib/core/theme/color_theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/settings_provider.dart';
import 'app_colors.dart';
import 'premium_theme_provider.dart';

/// Cihazın (sistem) parlaklığını izler; sistem teması değişince güncellenir.
class PlatformBrightnessNotifier extends StateNotifier<Brightness>
    with WidgetsBindingObserver {
  PlatformBrightnessNotifier()
    : super(WidgetsBinding.instance.platformDispatcher.platformBrightness) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    state = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

final platformBrightnessProvider =
    StateNotifierProvider<PlatformBrightnessNotifier, Brightness>((ref) {
      return PlatformBrightnessNotifier();
    });

/// Uygulamanın o an kullandığı parlaklık (tema modu + sistem ayarı)
final activeBrightnessProvider = Provider<Brightness>((ref) {
  switch (ref.watch(themeModeProvider)) {
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.system:
      return ref.watch(platformBrightnessProvider);
  }
});

/// Ekranda kullanılan tema, etkin parlaklığın (koyu/açık) paletiyle. Seçili
/// tema premium ise ve kullanıcının hakkı yoksa (premium değil, ödüllü kilidin
/// süresi dolmuş, onboarding'de seçilmiş vb.) ücretsiz temaya düşer. Tema
/// kilidinin tek kontrol noktası burasıdır.
final currentColorThemeProvider = Provider<ColorTheme>((ref) {
  final colorSchemeId = ref.watch(colorSchemeProvider);
  final brightness = ref.watch(activeBrightnessProvider);
  final theme = ref.watch(canUseThemeProvider(colorSchemeId))
      ? ColorTheme.fromString(colorSchemeId)
      : ColorTheme.midnight;
  return theme.forBrightness(brightness);
});
