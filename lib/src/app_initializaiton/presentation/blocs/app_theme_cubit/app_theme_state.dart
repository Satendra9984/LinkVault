part of 'app_theme_cubit.dart';

sealed class ThemeState extends Equatable {
  const ThemeState(this.appThemeMode);

  final AppThemeEnums appThemeMode;

  @override
  List<Object> get props => [appThemeMode];
}

final class AppThemeState extends ThemeState {

  AppThemeState(super.appThemeMode);
}
