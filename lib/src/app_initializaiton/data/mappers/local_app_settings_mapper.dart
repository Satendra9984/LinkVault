import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/app_initializaiton/data/models/settings_model.dart';

extension IsarAppSettingsMapper on IsarAppSettingsModel {
  LocalAppSettings toDomain() => LocalAppSettings(
        id: id,
        hasSeenOnboarding: seenOnboarding,
        themeMode: AppThemeEnums.fromString(theme ?? 'light'),
      );
}

extension DomainToIsarSettings on LocalAppSettings {
  IsarAppSettingsModel toIsar() {
    final m = IsarAppSettingsModel(
      seenOnboarding: hasSeenOnboarding,
      theme: themeMode.value,
    );
    return m;
  }
}
