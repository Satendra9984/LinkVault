// features/splash/data/datasources/splash_local_data_source.dart

import 'package:isar/isar.dart';
import 'package:link_vault/src/splash/data/models/settings_model.dart';

class LocalAppSettignsLocalDataSource {
  final Isar _isar;
  LocalAppSettignsLocalDataSource(this._isar);

  Future<bool> hasSeenOnboarding() async {
    final appSettingsCollection = _isar.collection<IsarAppSettingsModel>();
    final appSettings = await appSettingsCollection.get(1);
    return appSettings?.seenOnboarding ?? false;
  }

  /// Once onboarding completes, call this
  Future<void> setOnboardingStatus(bool hasSeenOnboarding) async {
    await _isar.writeTxn(() async {
      var appSettings = await _isar.isarAppSettingsModels.get(1);

      appSettings ??= IsarAppSettingsModel(seenOnboarding: hasSeenOnboarding);

      await _isar.isarAppSettingsModels.put(appSettings);
    });
  }

  Future<IsarAppSettingsModel?> getAppSettings() async {
    final model =
        await _isar.writeTxn(() => _isar.isarAppSettingsModels.get(1));
    return model;
  }

  Stream<IsarAppSettingsModel?> watchIsarAppSettings() {
   return _isar.isarAppSettingsModels.watchObject(1);
  }

  Future<void> saveAppSettings(IsarAppSettingsModel settings) {
    return _isar.writeTxn(
      () => _isar.isarAppSettingsModels.put(settings),
    );
  }
}
