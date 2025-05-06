import 'package:equatable/equatable.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';

class LocalAppSettings extends Equatable {

  const LocalAppSettings({
    required this.hasSeenOnboarding,
    required this.theme,
  });
  
  final bool hasSeenOnboarding;
  final AppThemeEnums theme;

  @override
  List<Object?> get props => [
        hasSeenOnboarding,
        theme,
      ];
}
