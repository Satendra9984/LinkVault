import 'package:objectbox/objectbox.dart';

enum AppThemeMode { light, dark, system }

@Entity()
class AppSettingsModel {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime? lastAdWatch;

  bool isPremium = false;

  bool hasMigratedToCloud = false;

  int dbThemeMode = AppThemeMode.system.index;

  @Transient()
  AppThemeMode get themeMode => AppThemeMode.values[dbThemeMode];

  set themeMode(AppThemeMode mode) => dbThemeMode = mode.index;
}
