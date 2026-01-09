// lib/core/theme/color_theme_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/settings_provider.dart';
import 'app_colors.dart';

/// Provider that exposes the current ColorTheme based on user selection
final currentColorThemeProvider = Provider<ColorTheme>((ref) {
  final colorSchemeId = ref.watch(colorSchemeProvider);
  return ColorTheme.fromString(colorSchemeId);
});
