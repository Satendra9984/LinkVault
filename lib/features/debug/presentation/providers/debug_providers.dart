import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../objectbox.g.dart';
import '../../../../core/infrastructure/providers.dart';
import '../../../../core/data/models/auth_settings_model.dart';
import '../../../collections/data/models/collection_model.dart';
import '../../../items/data/models/item_model.dart';
import '../../../monetization/presentation/providers/ad_gate_provider.dart';
import '../../domain/services/mock_dataset_profile.dart';
import '../../domain/services/mock_dataset_service.dart';

final debugToolsProvider = Provider<DebugTools>((ref) {
  return DebugTools(ref);
});

class DebugTools {
  final Ref _ref;

  DebugTools(this._ref);

  /// Replaces prior debug mocks, then inserts data for [profile].
  /// [MockDatasetProfile.cleanupOnly] deletes mocks only.
  Future<void> regenerateMockDataset(MockDatasetProfile profile) {
    return _ref.read(mockDatasetServiceProvider).regenerateMockDataset(profile);
  }

  /// Deletes rows whose titles contain [MockDatasetService.mockTag].
  Future<void> deleteGeneratedMocksOnly() {
    return _ref.read(mockDatasetServiceProvider).deleteGeneratedMocksOnly();
  }

  Future<void> resetAdTimer() async {
    final store = _ref.read(appDatabaseProvider).store;

    store.runInTransaction(TxMode.write, () {
      final box = store.box<AuthSettingsModel>();
      final settings = box.get(1);
      if (settings != null) {
        settings.installDate = DateTime.now().subtract(const Duration(days: 4));
        settings.dayPassExpiresAt =
            DateTime.now().subtract(const Duration(days: 1));
        settings.lastAdWatchedAt =
            DateTime.now().subtract(const Duration(days: 1));
        box.put(settings);
      }
    });

    await _ref.read(adGateProvider.notifier).refresh();
  }

  Future<void> clearLocalData() async {
    final store = _ref.read(appDatabaseProvider).store;

    store.runInTransaction(TxMode.write, () {
      store.box<CollectionModel>().removeAll();
      store.box<ItemModel>().removeAll();
    });
  }
}
