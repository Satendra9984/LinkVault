import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../objectbox.g.dart';
import '../../../../core/infrastructure/providers.dart';
import '../../../../core/data/models/auth_settings_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/data/models/collection_model.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/data/models/item_model.dart';
import '../../../items/presentation/providers/items_providers.dart';
import '../../../monetization/presentation/providers/ad_gate_provider.dart';

final debugToolsProvider = Provider<DebugTools>((ref) {
  return DebugTools(ref);
});

class DebugTools {
  final Ref _ref;
  final Uuid _uuid = const Uuid();

  DebugTools(this._ref);

  Future<void> generateMockCollections(int count) async {
    final useCase = _ref.read(createCollectionUseCaseProvider);
    final user = _ref.read(currentUserProvider);

    final categories = ['Travel', 'Food', 'Books', 'Movies', 'Music'];
    final colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEEAD'];
    // The app expects emojis for iconName based on the standard `CategoryManager`
    final icons = ['✈️', '🍔', '📚', '🎬', '🎵'];

    for (var i = 0; i < count; i++) {
      final index = i % categories.length;
      final collection = Collection(
        id: _uuid.v4(),
        ownerId: user?.supabaseId,
        title: 'Mock Collection ${i + 1}',
        category: categories[index],
        colorHex: colors[index],
        iconName: icons[index],
        position: DateTime.now().millisecondsSinceEpoch.toDouble() + i,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await useCase(collection);
    }
  }

  Future<void> generateMockItems(int count) async {
    final collectionsRepo = _ref.read(collectionsRepositoryProvider);
    final itemsUseCase = _ref.read(createItemUseCaseProvider);
    final user = _ref.read(currentUserProvider);

    final collectionsResult = await collectionsRepo.getAllCollections();
    final collections = collectionsResult.fold((l) => <Collection>[], (r) => r);

    if (collections.isEmpty) return; // Need collections to generate items

    for (var i = 0; i < count; i++) {
      final collectionId = collections[i % collections.length].id;
      final item = Item(
        id: _uuid.v4(),
        ownerId: user?.supabaseId,
        title: 'Mock Item ${i + 1}',
        description: 'This is a mock description generated for testing purposes.',
        status: i % 3 == 0 ? ItemStatus.visited : ItemStatus.pending,
        position: DateTime.now().millisecondsSinceEpoch.toDouble() + i,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        collectionId: collectionId,
      );
      await itemsUseCase(item);
    }
  }

  Future<void> resetAdTimer() async {
    final store = _ref.read(appDatabaseProvider).store;

    store.runInTransaction(TxMode.write, () {
      final box = store.box<AuthSettingsModel>();
      final settings = box.get(1);
      if (settings != null) {
        // Manipulate ObjectBox record directly to simulate an expired state past the 3-day trial
        settings.installDate = DateTime.now().subtract(const Duration(days: 4));
        settings.dayPassExpiresAt = DateTime.now().subtract(const Duration(days: 1));
        settings.lastAdWatchedAt = DateTime.now().subtract(const Duration(days: 1));
        box.put(settings);
      }
    });

    // Refresh ad gate state so UI updates
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
