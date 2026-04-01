import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../objectbox.g.dart';
import '../../collections/data/mappers/collection_mapper.dart';
import '../../collections/data/mappers/supabase_collection_mapper.dart';
import '../../collections/data/models/collection_model.dart';
import '../../collections/domain/entities/collection.dart';
import '../../monetization/application/cloud_migration_root_alignment.dart';
import '../../items/data/mappers/item_mapper.dart';
import '../../items/data/mappers/supabase_item_mapper.dart';
import '../../items/data/models/item_model.dart';
import '../../items/domain/entities/item.dart';
import '../data/sync_metadata_store.dart';
import '../domain/cloud_sync_trigger.dart';
import '../domain/conflict_policy.dart';
import '../domain/delta_sync_error_kind.dart';
import 'sync_transient_retry.dart';

class _DeltaSyncMetrics {
  const _DeltaSyncMetrics({
    required this.pulledCollections,
    required this.pulledUrls,
    required this.pushedCollections,
    required this.pushedUrls,
  });

  final int pulledCollections;
  final int pulledUrls;
  final int pushedCollections;
  final int pushedUrls;
}

/// Bidirectional delta sync: pull remote changes since anchor, merge LWW, then
/// push local rows newer than anchor. Anchor advances to [syncStarted] on success.
class CloudDeltaSyncService {
  CloudDeltaSyncService({
    required SupabaseClient supabase,
    required Store store,
    SyncMetadataStore? metadataStore,
    Logger? logger,
    int maxAttempts = 3,
    int pushBatchSize = 50,
  })  : _supabase = supabase,
        _store = store,
        _meta = metadataStore ?? SyncMetadataStore(),
        _log = logger ?? Logger(),
        _maxAttempts = maxAttempts,
        _pushBatchSize = pushBatchSize;

  final SupabaseClient _supabase;
  final Store _store;
  final SyncMetadataStore _meta;
  final Logger _log;
  final int _maxAttempts;
  final int _pushBatchSize;

  static bool _ownedByUser(String? ownerId, String userId) {
    if (ownerId == null) return true;
    return ownerId.trim().isEmpty || ownerId == userId;
  }

  /// Canonicalizes local collection entities so they align with the server root id
  /// before sync upsert. This prevents duplicate active `parent_id IS NULL` rows.
  static List<Collection> canonicalizeCollectionsForSync({
    required List<Collection> source,
    required String? localRootId,
    required String? serverRootId,
  }) {
    if (source.isEmpty ||
        localRootId == null ||
        localRootId.isEmpty ||
        serverRootId == null ||
        serverRootId.isEmpty ||
        localRootId == serverRootId) {
      return source;
    }
    return CloudMigrationRootAlignment.collectionsWithRemappedRootIds(
      source,
      localRootId: localRootId,
      serverRootId: serverRootId,
    );
  }

  /// Throws when payload would violate one-active-root expectation.
  static void assertValidRootRows(Iterable<Map<String, dynamic>> rows) {
    final roots = CloudMigrationRootAlignment.countActiveRootRowsInJson(rows);
    if (roots > 1) {
      throw StateError(
        'Invalid collections payload: $roots active root rows '
        '(expected <= 1)',
      );
    }
  }

  /// Rows on device that would still be pushed after [anchor] (approx. queue depth).
  static int countPendingForUser(Store store, String userId, DateTime? anchor) {
    final cut = anchor ?? DateTime.fromMillisecondsSinceEpoch(0);
    var n = 0;
    final collBox = store.box<CollectionModel>();
    for (final m in collBox.getAll()) {
      final c = CollectionMapper.toEntity(m);
      if (!_ownedByUser(c.ownerId, userId)) continue;
      if (c.updatedAt.toUtc().isAfter(cut)) n++;
    }
    final itemBox = store.box<ItemModel>();
    for (final m in itemBox.getAll()) {
      final i = ItemMapper.toEntity(m);
      if (!_ownedByUser(i.ownerId, userId)) continue;
      if (i.updatedAt.toUtc().isAfter(cut)) n++;
    }
    return n;
  }

  Future<DeltaSyncResult> run({
    required String userId,
    CloudSyncTrigger syncTrigger = CloudSyncTrigger.bootstrap,
  }) async {
    final syncStarted = DateTime.now().toUtc();
    final anchor = await _meta.getLastSyncedAt(userId);
    final anchorIso = anchor?.toUtc().toIso8601String();
    final wallStart = DateTime.now();

    try {
      final metrics = await withTransientRetry(
        maxAttempts: _maxAttempts,
        operation: () => _runDeltaBody(
          userId: userId,
          syncStarted: syncStarted,
          anchor: anchor,
          anchorIso: anchorIso,
        ),
      );

      final pending = countPendingForUser(_store, userId, syncStarted);
      final durationMs = DateTime.now().difference(wallStart).inMilliseconds;
      _log.i(
        '[DeltaSync] ok reason=${syncTrigger.name} user=$userId durationMs=$durationMs '
        'pulled=${metrics.pulledCollections}/${metrics.pulledUrls} '
        'pushed=${metrics.pushedCollections}/${metrics.pushedUrls} pending~=$pending',
      );

      return DeltaSyncResult(
        ok: true,
        pulledCollections: metrics.pulledCollections,
        pulledUrls: metrics.pulledUrls,
        pushedCollections: metrics.pushedCollections,
        pushedUrls: metrics.pushedUrls,
        pendingLocalApprox: pending,
      );
    } catch (e, st) {
      final durationMs = DateTime.now().difference(wallStart).inMilliseconds;
      _log.e(
        '[DeltaSync] failed reason=${syncTrigger.name} user=$userId durationMs=$durationMs',
        error: e,
        stackTrace: st,
      );
      final kind = classifyDeltaSyncFailure(e);
      final pending = countPendingForUser(_store, userId, anchor);
      return DeltaSyncResult(
        ok: false,
        errorMessage: e.toString(),
        failureKind: kind,
        pulledCollections: 0,
        pulledUrls: 0,
        pushedCollections: 0,
        pushedUrls: 0,
        pendingLocalApprox: pending,
      );
    }
  }

  Future<_DeltaSyncMetrics> _runDeltaBody({
    required String userId,
    required DateTime syncStarted,
    required DateTime? anchor,
    required String? anchorIso,
  }) async {
    // ── Pull collections ───────────────────────────────────────────────
    dynamic collQuery =
        _supabase.from('lv_collections').select().eq('owner_id', userId);
    if (anchorIso != null) {
      collQuery = collQuery.gt('updated_at', anchorIso);
    }
    final collRows = await collQuery as List<dynamic>;
    var pulledColl = 0;
    for (final raw in collRows) {
      final map = Map<String, dynamic>.from(raw as Map);
      final remote = SupabaseCollectionMapper.fromRow(map);
      _mergeCollection(remote);
      pulledColl++;
    }

    // ── Pull URLs ─────────────────────────────────────────────────────
    dynamic urlQuery =
        _supabase.from('lv_urls').select().eq('owner_id', userId);
    if (anchorIso != null) {
      urlQuery = urlQuery.gt('updated_at', anchorIso);
    }
    final urlRows = await urlQuery as List<dynamic>;
    var pulledUrl = 0;
    for (final raw in urlRows) {
      final map = Map<String, dynamic>.from(raw as Map);
      final remote = SupabaseItemMapper.fromRow(map);
      _mergeItem(remote);
      pulledUrl++;
    }

    // ── Push local → cloud (batched upserts) ─────────────────────────
    final pushCutoff = anchor ?? DateTime.fromMillisecondsSinceEpoch(0);

    final allOwnedCollections = <Collection>[];
    final collectionsToPush = <Collection>[];
    final collBox = _store.box<CollectionModel>();
    for (final m in collBox.getAll()) {
      final c = CollectionMapper.toEntity(m);
      if (!_ownedByUser(c.ownerId, userId)) continue;
      allOwnedCollections.add(c);
      if (!c.updatedAt.toUtc().isAfter(pushCutoff)) continue;
      if (c.id.isEmpty) continue;
      collectionsToPush.add(c);
    }

    final localRootId =
        CloudMigrationRootAlignment.canonicalTopLevelRootId(allOwnedCollections);
    String? serverRootId;
    if (collectionsToPush.isNotEmpty) {
      final raw = await _supabase.rpc(
        'ensure_library_root',
        params: {'p_owner_id': userId},
      );
      serverRootId = raw?.toString();
    }

    final canonicalCollections = canonicalizeCollectionsForSync(
      source: collectionsToPush,
      localRootId: localRootId,
      serverRootId: serverRootId,
    );

    final collectionPayloads = canonicalCollections
        .map((c) => SupabaseCollectionMapper.toJson(c, userId))
        .toList();
    assertValidRootRows(collectionPayloads);
    final payloadRootCount =
        CloudMigrationRootAlignment.countActiveRootRowsInJson(collectionPayloads);
    _log.i(
      '[DeltaSync] root-canonicalization localRoot=$localRootId '
      'serverRoot=$serverRootId payloadRoots=$payloadRootCount '
      'payloadCollections=${collectionPayloads.length}',
    );
    await _upsertBatches('lv_collections', collectionPayloads);
    final pushedColl = collectionPayloads.length;

    final urlPayloads = <Map<String, dynamic>>[];
    final itemBox = _store.box<ItemModel>();
    for (final m in itemBox.getAll()) {
      final i = ItemMapper.toEntity(m);
      if (!_ownedByUser(i.ownerId, userId)) continue;
      if (!i.updatedAt.toUtc().isAfter(pushCutoff)) continue;
      if (i.id.isEmpty) continue;
      urlPayloads.add(SupabaseItemMapper.toInsertJson(i, ownerId: userId));
    }
    await _upsertBatches('lv_urls', urlPayloads);
    final pushedUrl = urlPayloads.length;

    await _meta.setLastSyncedAt(userId, syncStarted);

    return _DeltaSyncMetrics(
      pulledCollections: pulledColl,
      pulledUrls: pulledUrl,
      pushedCollections: pushedColl,
      pushedUrls: pushedUrl,
    );
  }

  Future<void> _upsertBatches(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    final size = _pushBatchSize.clamp(1, 500);
    for (var i = 0; i < rows.length; i += size) {
      final end = i + size > rows.length ? rows.length : i + size;
      final batch = rows.sublist(i, end);
      await _supabase.from(table).upsert(batch);
    }
  }

  void _mergeCollection(Collection remote) {
    final box = _store.box<CollectionModel>();
    final existing =
        box.query(CollectionModel_.uid.equals(remote.id)).build().findFirst();
    if (existing == null) {
      box.put(CollectionMapper.toModel(remote));
      return;
    }
    final local = CollectionMapper.toEntity(existing);
    if (ConflictPolicy.remoteIsNewer(local.updatedAt, remote.updatedAt)) {
      final model = CollectionMapper.toModel(remote)..id = existing.id;
      box.put(model);
    }
  }

  void _mergeItem(Item remote) {
    final box = _store.box<ItemModel>();
    final existing =
        box.query(ItemModel_.uid.equals(remote.id)).build().findFirst();
    if (existing == null) {
      box.put(ItemMapper.toModel(remote));
      return;
    }
    final local = ItemMapper.toEntity(existing);
    if (ConflictPolicy.remoteIsNewer(local.updatedAt, remote.updatedAt)) {
      final model = ItemMapper.toModel(remote)..id = existing.id;
      box.put(model);
    }
  }
}

class DeltaSyncResult {
  final bool ok;
  final String? errorMessage;
  final DeltaSyncErrorKind? failureKind;
  final int pulledCollections;
  final int pulledUrls;
  final int pushedCollections;
  final int pushedUrls;
  final int pendingLocalApprox;

  const DeltaSyncResult({
    required this.ok,
    this.errorMessage,
    this.failureKind,
    this.pulledCollections = 0,
    this.pulledUrls = 0,
    this.pushedCollections = 0,
    this.pushedUrls = 0,
    this.pendingLocalApprox = 0,
  });
}
