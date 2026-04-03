import 'package:link_vault/features/collections/presentation/providers/collections_providers.dart';
import 'package:link_vault/features/items/presentation/providers/items_providers.dart';
import 'package:link_vault/features/settings/application/use_cases/clear_local_library_use_case.dart';
import 'package:link_vault/features/settings/application/use_cases/clear_all_library_data_use_case.dart';
import 'package:link_vault/features/settings/application/use_cases/export_data_use_case.dart';
import 'package:link_vault/features/settings/application/use_cases/import_data_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/models/auth_settings_model.dart';
import '../../../../core/infrastructure/platform/file_service.dart';
import '../../../../core/infrastructure/providers.dart';
import '../../../../objectbox.g.dart';
import '../../data/models/app_settings_model.dart';

// Settings Status Providers
final appSettingsProvider = StreamProvider<AppSettingsModel?>((ref) {
  final store = ref.watch(appDatabaseProvider).store;
  return store.box<AppSettingsModel>().query().watch(triggerImmediately: true).map((q) => q.findFirst());
});

final hasMigratedToCloudProvider = Provider<bool>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  return settings?.hasMigratedToCloud ?? false;
});

// Service Provider
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

// Use Case Providers
final exportDataUseCaseProvider = Provider<ExportDataUseCase>((ref) {
  final collectionsRepo = ref.watch(collectionsRepositoryProvider);
  final itemsRepo = ref.watch(itemsRepositoryProvider);
  final fileService = ref.watch(fileServiceProvider);

  return ExportDataUseCase(
    collectionsRepo,
    itemsRepo,
    fileService,
  );
});

final importDataUseCaseProvider = Provider<ImportDataUseCase>((ref) {
  final collectionsRepo = ref.watch(collectionsRepositoryProvider);
  final itemsRepo = ref.watch(itemsRepositoryProvider);
  final fileService = ref.watch(fileServiceProvider);

  return ImportDataUseCase(
    collectionsRepo,
    itemsRepo,
    fileService,
  );
});

final clearLocalLibraryUseCaseProvider = Provider<ClearLocalLibraryUseCase>((ref) {
  return ClearLocalLibraryUseCase(ref.watch(appDatabaseProvider).store);
});

final clearAllLibraryDataUseCaseProvider = Provider<ClearAllLibraryDataUseCase>((ref) {
  return ClearAllLibraryDataUseCase(
    ref.watch(appDatabaseProvider).store,
    Supabase.instance.client,
  );
});

/// Emits the singleton [AuthSettingsModel] (id=1) whenever ObjectBox updates it.
final authSettingsRowStreamProvider = StreamProvider<AuthSettingsModel>((ref) {
  final store = ref.watch(appDatabaseProvider).store;
  final box = store.box<AuthSettingsModel>();
  return box
      .query(AuthSettingsModel_.id.equals(1))
      .watch(triggerImmediately: true)
      .map((q) => q.findFirst() ?? AuthSettingsModel());
});
