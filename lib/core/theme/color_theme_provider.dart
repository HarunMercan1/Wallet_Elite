// lib/core/theme/color_theme_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/settings_provider.dart';
import 'app_colors.dart';
import 'premium_theme_provider.dart';

/// Ekranda kullanılan tema. Seçili tema premium ise ve kullanıcının hakkı
/// yoksa (premium değil, ödüllü kilidin süresi dolmuş, onboarding'de seçilmiş
/// vb.) ücretsiz temaya düşer. Tema kilidinin tek kontrol noktası burasıdır.
final currentColorThemeProvider = Provider<ColorTheme>((ref) {
  final colorSchemeId = ref.watch(colorSchemeProvider);
  if (!ref.watch(canUseThemeProvider(colorSchemeId))) {
    return ColorTheme.midnight;
  }
  return ColorTheme.fromString(colorSchemeId);
});
