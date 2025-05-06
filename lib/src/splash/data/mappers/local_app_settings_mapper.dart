import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/splash/data/models/settings_model.dart';

extension IsarAppSettingsMapper on IsarAppSettingsModel {
  LocalAppSettings toDomain() => LocalAppSettings(
        hasSeenOnboarding: seenOnboarding,
        theme: AppThemeEnums.fromString(theme ?? 'light'),
      );
}

extension DomainToIsarSettings on LocalAppSettings {
  IsarAppSettingsModel toIsar() {
    final m = IsarAppSettingsModel(
      seenOnboarding: hasSeenOnboarding,
      theme: theme.value,
    );
    return m;
  }
}
