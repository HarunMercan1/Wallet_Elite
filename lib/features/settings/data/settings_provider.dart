// lib/features/settings/data/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences instance provider (initialized in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized in main.dart',
  );
});

/// Tema modu provider'ı (kalıcı)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;
  static const String _key = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(_loadInitial(_prefs));

  static ThemeMode _loadInitial(SharedPreferences? prefs) {
    if (prefs == null) return ThemeMode.system;
    final value = prefs.getString(_key);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _saveTheme(mode);
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await prefs.setString(_key, value);
  }
}

/// Dil provider'ı (kalıcı)
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<String> {
  final SharedPreferences? _prefs;
  static const String _key = 'locale';

  LocaleNotifier(this._prefs) : super(_loadInitial(_prefs));

  static String _loadInitial(SharedPreferences? prefs) {
    if (prefs == null) return 'tr';
    return prefs.getString(_key) ?? 'tr';
  }

  void setLocale(String locale) {
    state = locale;
    _saveLocale(locale);
  }

  Future<void> _saveLocale(String locale) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_key, locale);
  }
}

/// Color Scheme provider (persistent)
final colorSchemeProvider = StateNotifierProvider<ColorSchemeNotifier, String>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ColorSchemeNotifier(prefs);
});

class ColorSchemeNotifier extends StateNotifier<String> {
  final SharedPreferences? _prefs;
  static const String _key = 'color_scheme';

  ColorSchemeNotifier(this._prefs) : super(_loadInitial(_prefs));

  static String _loadInitial(SharedPreferences? prefs) {
    if (prefs == null) return 'elite';
    return prefs.getString(_key) ?? 'elite';
  }

  void setColorScheme(String scheme) {
    state = scheme;
    _saveColorScheme(scheme);
  }

  Future<void> _saveColorScheme(String scheme) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_key, scheme);
  }
}
