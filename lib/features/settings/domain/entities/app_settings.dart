enum AppThemeMode { light, dark, system }

class AppSettings {
  final int id;
  final DateTime? lastAdWatch;
  final bool isPremium;
  final AppThemeMode themeMode;

  const AppSettings({
    required this.id,
    this.lastAdWatch,
    this.isPremium = false,
    this.themeMode = AppThemeMode.system,
  });
}
