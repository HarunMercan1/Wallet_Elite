// lib/core/theme/premium_theme_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/premium/data/premium_constants.dart';
import '../../features/premium/data/premium_provider.dart';
import '../../features/settings/data/settings_provider.dart';
import 'app_colors.dart';

/// Ödüllü reklamla geçici açılan temalar: `temaId|bitişZamanıISO`
const String _unlockedThemesKey = 'rewarded_theme_unlocks';

/// Ödüllü reklamla açılan premium temaları ve bitiş zamanlarını yönetir
final unlockedThemesProvider =
    StateNotifierProvider<UnlockedThemesNotifier, Map<String, DateTime>>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return UnlockedThemesNotifier(prefs);
    });

class UnlockedThemesNotifier extends StateNotifier<Map<String, DateTime>> {
  final SharedPreferences _prefs;
  Timer? _expiryTimer;

  UnlockedThemesNotifier(this._prefs) : super({}) {
    _load();
  }

  void _load() {
    final now = DateTime.now();
    final entries = <String, DateTime>{};
    for (final raw in _prefs.getStringList(_unlockedThemesKey) ?? const []) {
      final parts = raw.split('|');
      if (parts.length != 2) continue;
      final expiry = DateTime.tryParse(parts[1]);
      if (expiry != null && expiry.isAfter(now)) entries[parts[0]] = expiry;
    }
    _setState(entries);
  }

  /// Ödüllü reklam izlendikten sonra temayı süreli olarak aç
  Future<void> unlockTheme(String themeId) async {
    final expiry = DateTime.now().add(PremiumConstants.rewardedThemeDuration);
    _setState({...state, themeId: expiry});
    await _prefs.setStringList(
      _unlockedThemesKey,
      state.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList(),
    );
  }

  /// Temanın geçici kilidi açık mı
  bool isUnlocked(String themeId) =>
      state[themeId]?.isAfter(DateTime.now()) ?? false;

  /// Süresi dolan kilitleri düşür ve bir sonraki bitişe zamanlayıcı kur;
  /// böylece uygulama açıkken süre dolunca tema otomatik ücretsize döner.
  void _setState(Map<String, DateTime> entries) {
    final now = DateTime.now();
    final active = {
      for (final e in entries.entries)
        if (e.value.isAfter(now)) e.key: e.value,
    };
    state = active;

    _expiryTimer?.cancel();
    if (active.isNotEmpty) {
      final next = active.values.reduce((a, b) => a.isBefore(b) ? a : b);
      _expiryTimer = Timer(
        next.difference(now) + const Duration(seconds: 1),
        () => _setState(state),
      );
    }
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}

/// Tema kullanılabilir mi: ücretsiz tema, premium kullanıcı veya süresi
/// dolmamış ödüllü kilit açma
final canUseThemeProvider = Provider.family<bool, String>((ref, themeId) {
  final theme = ColorTheme.fromString(themeId);
  if (!theme.isPremium) return true;
  if (ref.watch(isPremiumProvider)) return true;
  final expiry = ref.watch(unlockedThemesProvider)[themeId];
  return expiry != null && expiry.isAfter(DateTime.now());
});

/// Ödüllü kilidin bitiş zamanı (varsa)
final themeUnlockExpiryProvider = Provider.family<DateTime?, String>((
  ref,
  themeId,
) {
  return ref.watch(unlockedThemesProvider)[themeId];
});
