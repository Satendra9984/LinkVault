import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/data_backend_selection_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collections_providers.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/domain/usecases/create_item_usecase.dart';
import '../../../items/presentation/providers/items_providers.dart';
import 'mock_dataset_blueprint.dart';
import 'mock_dataset_profile.dart';

final mockDatasetServiceProvider = Provider<MockDatasetService>((ref) {
  return MockDatasetService(ref);
});

/// Debug-only mock dataset generator.
///
/// See [docs/09_SPRINT_ARCHITECTURE/DEBUG_MOCK_GENERATION.md].
class MockDatasetService {
  /// Marker substring on generated folder titles and URL titles for safe cleanup.
  static const mockTag = '[DEBUG_MOCK]';

  /// Distinct hues cycled by folder slot (deterministic, reproducible).
  static const List<String> _mockFolderColorHexes = [
    '#6366F1', // indigo
    '#EC4899', // pink
    '#F97316', // orange
    '#22C55E', // green
    '#0EA5E9', // sky
    '#A855F7', // purple
    '#E11D48', // rose
    '#14B8A6', // teal
    '#F59E0B', // amber
    '#8B5CF6', // violet
    '#06B6D4', // cyan
    '#EF4444', // red
    '#84CC16', // lime
    '#D946EF', // fuchsia
    '#64748B', // slate
    '#78716C', // stone
  ];

  final Ref _ref;
  final Uuid _uuid = const Uuid();

  MockDatasetService(this._ref);

  /// Ensures Library root, optionally removes prior mocks, then inserts data for [profile].
  ///
  /// [MockDatasetProfile.cleanupOnly] runs cleanup only (no inserts).
  Future<void> regenerateMockDataset(MockDatasetProfile profile) async {
    AppLogger.d('[debug] regenerateMockDataset profile=$profile');
    _throwIfReadOnlyCloud();

    final root = await _ensureLibraryRoot();
    await _deleteGeneratedMocksOnly(root.id);

    if (profile == MockDatasetProfile.cleanupOnly) {
      AppLogger.d('[debug] regenerateMockDataset cleanupOnly done');
      return;
    }

    await _insertDataset(root.id, profile);
    AppLogger.d('[debug] regenerateMockDataset done');
  }

  /// Deletes only rows whose titles contain [mockTag].
  Future<void> deleteGeneratedMocksOnly() async {
    _throwIfReadOnlyCloud();
    final root = await _ensureLibraryRoot();
    await _deleteGeneratedMocksOnly(root.id);
  }

  void _throwIfReadOnlyCloud() {
    final backend = _ref.read(dataBackendSelectionProvider);
    if (backend.isReadOnlyCloud) {
      throw StateError(
        'Cloud is read-only (subscription lapsed). Renew subscription to generate '
        'or remove debug mock data.',
      );
    }
  }

  Future<Collection> _ensureLibraryRoot() async {
    return _ref.read(libraryRootCollectionProvider.future);
  }

  Future<void> _deleteGeneratedMocksOnly(String libraryRootId) async {
    final getAllCollections = _ref.read(getAllCollectionsUseCaseProvider);
    final getAllItems = _ref.read(getAllItemsUseCaseProvider);
    final deleteCollection = _ref.read(deleteCollectionUseCaseProvider);
    final deleteItem = _ref.read(deleteItemUseCaseProvider);

    final allCollectionsEither = await getAllCollections();
    final allItemsEither = await getAllItems();

    final allCollections = allCollectionsEither.fold<List<Collection>>(
      (f) {
        AppLogger.w(
            '[debug] mock cleanup: failed to load collections: ${f.message}');
        return const [];
      },
      (list) => list,
    );
    final allItems = allItemsEither.fold<List<Item>>(
      (f) {
        AppLogger.w('[debug] mock cleanup: failed to load items: ${f.message}');
        return const [];
      },
      (list) => list,
    );

    final mockItems =
        allItems.where((i) => i.title.contains(mockTag)).toList();
    for (final item in mockItems) {
      final r = await deleteItem(item.id);
      r.fold(
        (f) => AppLogger.w('[debug] mock cleanup delete item failed: ${f.message}'),
        (_) {},
      );
    }

    final mockCollections = allCollections
        .where(
          (c) => c.id != libraryRootId && c.title.contains(mockTag),
        )
        .toList();

    final remainingIds = mockCollections.map((c) => c.id).toSet();
    var progress = true;
    while (remainingIds.isNotEmpty && progress) {
      progress = false;
      final snapshot = List<String>.from(remainingIds);
      for (final id in snapshot) {
        final hasChild = allCollections.any(
          (c) => c.parentId == id && remainingIds.contains(c.id),
        );
        if (hasChild) continue;
        final r = await deleteCollection(id);
        r.fold(
          (f) => AppLogger.w(
              '[debug] mock cleanup delete collection failed: ${f.message}'),
          (_) {},
        );
        remainingIds.remove(id);
        progress = true;
      }
    }
  }

  Future<void> _insertDataset(String libraryRootId, MockDatasetProfile profile) async {
    final user = _ref.read(currentUserProvider);
    final ownerId = user?.supabaseId;
    final now = DateTime.now();

    final createCollection = _ref.read(createCollectionUseCaseProvider);
    final createItem = _ref.read(createItemUseCaseProvider);

    final n = profile.nonRootCollectionCount;
    final parentSlots = mockFolderParentIndices(n);
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) {
        final da = mockFolderDepth(a, parentSlots);
        final db = mockFolderDepth(b, parentSlots);
        if (da != db) return da.compareTo(db);
        return a.compareTo(b);
      });

    final slotToId = <int, String>{};
    var positionCursor = 0.0;
    const step = 1024.0;

    for (final slot in order) {
      positionCursor += step;
      final parentSlot = parentSlots[slot];
      final parentId =
          parentSlot < 0 ? libraryRootId : slotToId[parentSlot]!;
      final gen = MockFolderGenSpec.forIndex(slot);
      final depth = mockFolderDepth(slot, parentSlots);
      final id = _uuid.v4();
      final title = '$mockTag Folder $slot (L$depth)';
      final c = Collection(
        id: id,
        ownerId: ownerId,
        parentId: parentId,
        isShared: false,
        title: title,
        description: 'Debug mock folder slot=$slot depth=$depth',
        category: 'general',
        colorHex: _mockFolderColorHexes[slot % _mockFolderColorHexes.length],
        iconName: '📁',
        iconJson: null,
        position: positionCursor,
        isPinned: gen.isPinned,
        isArchived: gen.isArchived,
        isDeleted: false,
        childCount: 0,
        createdAt: now,
        updatedAt: now,
        lastAccessedAt: now,
        itemsLayout: gen.itemsLayout,
        childCollectionsLayout: gen.childCollectionsLayout,
        itemsSortDefault: gen.itemsSortDefault,
        openLinksIn: gen.openLinksIn,
        showLinkPreviews: true,
        itemCount: 0,
      );
      final result = await createCollection(c);
      result.fold(
        (f) => throw StateError('createCollection failed: ${f.message}'),
        (_) {},
      );
      slotToId[slot] = id;
    }

    final folderIdsOrdered = List.generate(n, (i) => slotToId[i]!);
    final roundRobinIds = <String>[libraryRootId, ...folderIdsOrdered];

    await _insertUrls(
      createItem: createItem,
      ownerId: ownerId,
      now: now,
      collectionIds: roundRobinIds,
      total: profile.urlCount,
    );
  }

  Future<void> _insertUrls({
    required CreateItemUseCase createItem,
    required String? ownerId,
    required DateTime now,
    required List<String> collectionIds,
    required int total,
  }) async {
    if (total <= 0 || collectionIds.isEmpty) return;

    final templates = _urlTemplates(now);
    var urlPosition = 0.0;
    const urlStep = 512.0;

    for (var k = 0; k < total; k++) {
      urlPosition += urlStep;
      final t = templates[k % templates.length];
      final collectionId = collectionIds[k % collectionIds.length];
      final id = _uuid.v4();

      // Rotate a few fields so archived / pin mix appears across the dataset.
      final ItemStatus rotatedStatus;
      switch (k % 9) {
        case 0:
        case 3:
          rotatedStatus = ItemStatus.unread;
          break;
        case 1:
        case 4:
        case 7:
          rotatedStatus = ItemStatus.read;
          break;
        default:
          rotatedStatus = ItemStatus.archived;
      }
      final isPinned = k % 4 == 0 || k % 11 == 5;
      final resolvedStatus = t.forceStatus ?? rotatedStatus;

      final item = Item(
        id: id,
        ownerId: ownerId,
        collectionId: collectionId,
        link: t.url,
        title: '$mockTag ${t.titleSuffix} #$k',
        description: t.description,
        imageUrl: t.thumbnailUrl,
        imagePath: null,
        faviconUrl: t.faviconUrl,
        dominantColor: t.dominantColor,
        tags: t.tags,
        annotation: t.annotation,
        siteName: t.siteName,
        canonicalUrl: t.canonicalUrl,
        contentType: t.contentType,
        publishedAt: t.publishedAt,
        status: resolvedStatus,
        isPinned: t.forcePinned ?? isPinned,
        position: urlPosition,
        clickCount: t.clickCount ??
            (resolvedStatus == ItemStatus.read ? (k % 7) + 1 : 0),
        lastAccessedAt: t.lastAccessedAt ??
            (resolvedStatus == ItemStatus.read
                ? now.subtract(Duration(days: k % 5))
                : null),
        isDeleted: false,
        deletedAt: null,
        createdAt: now,
        updatedAt: now,
      );
      final result = await createItem(item);
      result.fold(
        (f) => throw StateError('createItem failed: ${f.message}'),
        (_) {},
      );
    }
  }

  /// Canonical URL rows covering minimal, preview-rich, notes, article meta, statuses.
  List<_UrlTemplate> _urlTemplates(DateTime now) {
    DateTime daysAgo(int d) => now.subtract(Duration(days: d));
    return [
      // 0 — minimal valid (still use https example; title carries tag)
      _UrlTemplate(
        url: 'https://example.com/',
        titleSuffix: 'Minimal',
        description: null,
        siteName: 'example.com',
        thumbnailUrl: null,
        faviconUrl: null,
        dominantColor: null,
        tags: null,
        annotation: null,
        contentType: 'text/html',
        canonicalUrl: null,
        publishedAt: null,
        clickCount: 0,
        lastAccessedAt: null,
        forceStatus: ItemStatus.unread,
        forcePinned: false,
      ),
      // 1 — full preview
      _UrlTemplate(
        url: 'https://martinfowler.com/articles/microservices.html',
        titleSuffix: 'Microservices',
        description: 'Martin Fowler on microservices architecture.',
        siteName: 'martinfowler.com',
        thumbnailUrl:
            'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg',
        faviconUrl:
            'https://www.google.com/s2/favicons?sz=64&domain_url=https://martinfowler.com',
        dominantColor: '#0F172A',
        tags: 'architecture,backend',
        annotation: null,
        contentType: 'text/html',
        canonicalUrl: 'https://martinfowler.com/articles/microservices.html',
        publishedAt: daysAgo(120),
        clickCount: 2,
        lastAccessedAt: daysAgo(2),
        forceStatus: null,
        forcePinned: null,
      ),
      // 2 — notes + tags emphasis
      _UrlTemplate(
        url: 'https://kentcdodds.com/blog/testing-node-apps',
        titleSuffix: 'Testing Node',
        description: 'Testing guidance.',
        siteName: 'kentcdodds.com',
        thumbnailUrl:
            'https://images.pexels.com/photos/3861964/pexels-photo-3861964.jpeg',
        faviconUrl:
            'https://www.google.com/s2/favicons?sz=64&domain_url=https://kentcdodds.com',
        dominantColor: '#1E293B',
        tags: 'testing,quality',
        annotation: 'Personal notes: revisit chapter on integration tests.',
        contentType: 'text/html',
        canonicalUrl: null,
        publishedAt: daysAgo(60),
        clickCount: 0,
        lastAccessedAt: null,
        forceStatus: null,
        forcePinned: null,
      ),
      // 3 — article metadata
      _UrlTemplate(
        url: 'https://arxiv.org/abs/1706.03762',
        titleSuffix: 'Attention Paper',
        description: 'Transformer architecture paper.',
        siteName: 'arXiv',
        thumbnailUrl:
            'https://images.pexels.com/photos/256417/pexels-photo-256417.jpeg',
        faviconUrl:
            'https://www.google.com/s2/favicons?sz=64&domain_url=https://arxiv.org',
        dominantColor: '#0EA5E9',
        tags: 'ml,paper',
        annotation: null,
        contentType: 'application/pdf',
        canonicalUrl: 'https://arxiv.org/abs/1706.03762',
        publishedAt: DateTime(2017, 6, 12),
        clickCount: 10,
        lastAccessedAt: daysAgo(7),
        forceStatus: ItemStatus.read,
        forcePinned: true,
      ),
      // 4 — video
      _UrlTemplate(
        url: 'https://www.youtube.com/watch?v=3duGLapZ0a0',
        titleSuffix: 'Flutter Video',
        description: 'Flutter layout video.',
        siteName: 'YouTube',
        thumbnailUrl: 'https://i.ytimg.com/vi/3duGLapZ0a0/maxresdefault.jpg',
        faviconUrl:
            'https://www.google.com/s2/favicons?sz=64&domain_url=https://youtube.com',
        dominantColor: '#DC2626',
        tags: 'flutter,video',
        annotation: null,
        contentType: 'video/mp4',
        canonicalUrl: null,
        publishedAt: daysAgo(30),
        clickCount: 0,
        lastAccessedAt: null,
        forceStatus: ItemStatus.unread,
        forcePinned: true,
      ),
      // 5 — read + analytics
      _UrlTemplate(
        url: 'https://www.seriouseats.com/best-chocolate-chip-cookies-recipe',
        titleSuffix: 'Cookies',
        description: 'Cookie recipe reference.',
        siteName: 'Serious Eats',
        thumbnailUrl:
            'https://images.pexels.com/photos/230325/pexels-photo-230325.jpeg',
        faviconUrl:
            'https://www.google.com/s2/favicons?sz=64&domain_url=https://seriouseats.com',
        dominantColor: '#FBBF24',
        tags: 'food',
        annotation: null,
        contentType: 'text/html',
        canonicalUrl: null,
        publishedAt: daysAgo(200),
        clickCount: 5,
        lastAccessedAt: daysAgo(1),
        forceStatus: ItemStatus.read,
        forcePinned: false,
      ),
      // 6 — archived + pinned
      _UrlTemplate(
        url: 'https://developer.mozilla.org/en-US/docs/Web/HTML',
        titleSuffix: 'MDN HTML',
        description: 'HTML documentation.',
        siteName: 'MDN',
        thumbnailUrl: null,
        faviconUrl:
            'https://www.google.com/s2/favicons?sz=64&domain_url=https://developer.mozilla.org',
        dominantColor: '#047857',
        tags: 'docs,web',
        annotation: 'Archived reference',
        contentType: 'text/html',
        canonicalUrl: null,
        publishedAt: daysAgo(400),
        clickCount: 1,
        lastAccessedAt: daysAgo(100),
        forceStatus: ItemStatus.archived,
        forcePinned: true,
      ),
      // 7 — archived unpinned
      _UrlTemplate(
        url: 'https://html.spec.whatwg.org/multipage/',
        titleSuffix: 'WHATWG HTML',
        description: 'Living HTML standard.',
        siteName: 'WHATWG',
        thumbnailUrl: null,
        faviconUrl:
            'https://www.google.com/s2/favicons?sz=64&domain_url=https://html.spec.whatwg.org',
        dominantColor: '#4338CA',
        tags: 'spec',
        annotation: null,
        contentType: 'text/html',
        canonicalUrl: 'https://html.spec.whatwg.org/multipage/',
        publishedAt: daysAgo(500),
        clickCount: 0,
        lastAccessedAt: null,
        forceStatus: ItemStatus.archived,
        forcePinned: false,
      ),
    ];
  }
}

class _UrlTemplate {
  final String url;
  final String titleSuffix;
  final String? description;
  final String? siteName;
  final String? thumbnailUrl;
  final String? faviconUrl;
  final String? dominantColor;
  final String? tags;
  final String? annotation;
  final String? contentType;
  final String? canonicalUrl;
  final DateTime? publishedAt;
  final int? clickCount;
  final DateTime? lastAccessedAt;
  final ItemStatus? forceStatus;
  final bool? forcePinned;

  const _UrlTemplate({
    required this.url,
    required this.titleSuffix,
    this.description,
    this.siteName,
    this.thumbnailUrl,
    this.faviconUrl,
    this.dominantColor,
    this.tags,
    this.annotation,
    this.contentType,
    this.canonicalUrl,
    this.publishedAt,
    this.clickCount,
    this.lastAccessedAt,
    this.forceStatus,
    this.forcePinned,
  });
}
