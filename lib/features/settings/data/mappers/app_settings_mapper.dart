
import '../../domain/entities/app_settings.dart' as domain;
import '../models/app_settings_model.dart' as data;

class AppSettingsMapper {
  static domain.AppSettings toEntity(data.AppSettingsModel model) {
    return domain.AppSettings(
      id: model.id,
      lastAdWatch: model.lastAdWatch,
      isPremium: model.isPremium,
      themeMode: domain.AppThemeMode.values
          .firstWhere((e) => e.name == model.themeMode.name),
    );
  }

  static data.AppSettingsModel toModel(domain.AppSettings entity) {
    return data.AppSettingsModel()
      ..id = entity.id == 0 ? 0 : entity.id
      ..lastAdWatch = entity.lastAdWatch
      ..isPremium = entity.isPremium
      ..themeMode = data.AppThemeMode.values
          .firstWhere((e) => e.name == entity.themeMode.name);
  }
}
