import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_vault/core/theme/app_theme_enums.dart';
import 'package:link_vault/src/shared/domain/entities/local_app_settings.dart';
import 'package:link_vault/src/shared/domain/repositories/local_app_repo.dart';

part 'local_app_settings_state.dart';

class LocalAppSettingsCubit extends Cubit<LocalAppSettings> {
  // final LocalAppSettingsRepository _localAppSettingsRepository;

  LocalAppSettingsCubit()
      : super(
          const LocalAppSettings(
            hasSeenOnboarding: false,
            themeMode: AppThemeEnums.light,
          ),
        ) {
    // _load();
  }

  // Future<void> _load() async {
  //   final localAppSettings = await _localAppSettingsRepository.getSettings();
  //   emit(localAppSettings);
  // }

  void updateLocalAppSettings(LocalAppSettings localAppSettings) {
    emit(localAppSettings);
  }
}
