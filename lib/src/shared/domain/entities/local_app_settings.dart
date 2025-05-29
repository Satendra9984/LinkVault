import 'package:equatable/equatable.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';

class LocalAppSettings extends Equatable {
  const LocalAppSettings({
    required this.hasSeenOnboarding,
    required this.themeMode,
    required this.id,
  });

  final int id;
  final bool hasSeenOnboarding;
  final AppThemeEnums themeMode;

  // Copy with method for immutability
  LocalAppSettings copyWith({
    int? id,
    AppThemeEnums? themeMode,
    bool? hasSeenOnboarding,
    bool? isLoggedIn,
  }) {
    return LocalAppSettings(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  @override
  List<Object?> get props => [
        hasSeenOnboarding,
        themeMode,
        id,
      ];
}
