enum AppThemeEnums {
  light(value: 'light'),
  dark(value: 'dark');

  const AppThemeEnums({
    required this.value,
  });

  final String value;

  factory AppThemeEnums.fromString(String theme) {
    return AppThemeEnums.values.firstWhere(
      (thm) => thm.value == theme,
      orElse: () => AppThemeEnums.light,
    );
  }

  String? toStringValue(AppThemeEnums theme) {
    return value;
  }
}
