// lib/core/theme/premium_theme_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/data/settings_provider.dart';
import 'app_colors.dart';

/// Key for storing unlocked themes in SharedPreferences
const String _unlockedThemesKey = 'unlocked_themes';

/// Provider that manages unlocked premium themes
final unlockedThemesProvider =
    StateNotifierProvider<UnlockedThemesNotifier, Set<String>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return UnlockedThemesNotifier(prefs);
    });

/// Notifier to manage unlocked themes state
class UnlockedThemesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;

  UnlockedThemesNotifier(this._prefs) : super({}) {
    _loadUnlockedThemes();
  }

  /// Load unlocked themes from SharedPreferences
  void _loadUnlockedThemes() {
    final unlockedList = _prefs.getStringList(_unlockedThemesKey) ?? [];
    state = unlockedList.toSet();
  }

  /// Unlock a theme after watching a rewarded ad
  Future<void> unlockTheme(String themeId) async {
    if (state.contains(themeId)) return;

    final newState = {...state, themeId};
    state = newState;
    await _prefs.setStringList(_unlockedThemesKey, newState.toList());
  }

  /// Check if a theme is unlocked
  bool isThemeUnlocked(String themeId) {
    // Elite theme is always free
    if (themeId == 'elite') return true;
    return state.contains(themeId);
  }

  /// Unlock all themes (for testing or purchase)
  Future<void> unlockAllThemes() async {
    final allThemeIds = ColorTheme.all.map((t) => t.id).toSet();
    state = allThemeIds;
    await _prefs.setStringList(_unlockedThemesKey, allThemeIds.toList());
  }
}

/// Provider that checks if a specific theme can be used
final canUseThemeProvider = Provider.family<bool, String>((ref, themeId) {
  final theme = ColorTheme.fromString(themeId);

  // Free themes are always available
  if (!theme.isPremium) return true;

  // Check if premium theme is unlocked
  final unlockedThemes = ref.watch(unlockedThemesProvider);
  return unlockedThemes.contains(themeId);
});
