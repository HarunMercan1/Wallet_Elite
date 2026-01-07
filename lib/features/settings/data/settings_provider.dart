// lib/features/settings/data/settings_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tema modu provider'ı
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setTheme(ThemeMode mode) {
    state = mode;
    // TODO: SharedPreferences ile kalıcı kaydet
  }
}

/// Dil provider'ı
final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('tr'); // Varsayılan Türkçe

  void setLocale(String locale) {
    state = locale;
    // TODO: SharedPreferences ile kalıcı kaydet
  }
}
