part of 'app_theme_cubit.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

final class AppThemeState extends ThemeState {
  final AppThemeEnums appThemeMode;

  AppThemeState(this.appThemeMode);
}
