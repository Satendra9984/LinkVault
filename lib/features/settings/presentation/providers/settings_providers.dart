import 'package:link_vault/features/collections/presentation/providers/collections_providers.dart';
import 'package:link_vault/features/items/presentation/providers/items_providers.dart';
import 'package:link_vault/features/settings/application/use_cases/export_data_use_case.dart';
import 'package:link_vault/features/settings/application/use_cases/import_data_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/infrastructure/platform/file_service.dart';
import '../../../../core/infrastructure/providers.dart';
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
