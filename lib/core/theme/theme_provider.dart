import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';

// Enum for theme modes to be more explicit than ThemeMode
enum AppThemeMode { light, dark, system }

// State class for Theme
class ThemeState {
  final AppThemeMode mode;

  ThemeState({this.mode = AppThemeMode.system});

  ThemeMode get flutterThemeMode {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

// Notifier
class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    _loadTheme();
    return ThemeState();
  }

  Future<void> _loadTheme() async {
    final repo = ref.read(appSettingsRepositoryProvider);
    final modeStr = await repo.getThemeMode();
    final mode = AppThemeMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => AppThemeMode.system,
    );
    state = ThemeState(mode: mode);
  }

  void setMode(AppThemeMode mode) {
    state = ThemeState(mode: mode);
    final repo = ref.read(appSettingsRepositoryProvider);
    repo.setThemeMode(mode.name);
  }

  void toggleTheme() {
    if (state.mode == AppThemeMode.light) {
      setMode(AppThemeMode.dark);
    } else {
      setMode(AppThemeMode.light);
    }
  }
}

// Provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});
