import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/supabase_quota_messages.dart';
import '../mappers/supabase_item_mapper.dart';
import '../../domain/entities/item.dart';
import '../../domain/models/url_items_query.dart';
import '../../domain/repositories/i_items_repository.dart';
import '../../domain/url_sort_option.dart';

class SupabaseItemsRepository implements IItemsRepository {
  final SupabaseClient _supabase;
  final String? _userId;

  SupabaseItemsRepository(this._supabase, {String? userId})
      : _userId = userId ?? _supabase.auth.currentUser?.id;

  static String _escapeIlikePattern(String raw) {
    return raw
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_')
        .replaceAll(',', r'\,');
  }

  static String _lvStatusString(ItemStatus s) => switch (s) {
        ItemStatus.unread => 'unread',
        ItemStatus.read => 'read',
        ItemStatus.archived => 'archived',
      };

  @override
  Future<Either<Failure, UrlItemsPage>> queryUrlItems(UrlItemsQuery q) async {
    try {
      dynamic builder = _supabase.from('lv_urls').select();
      builder =
          builder.eq('collection_id', q.collectionId).eq('is_deleted', false);

      if (q.status != null) {
        builder = builder.eq('status', _lvStatusString(q.status!));
      }
      if (q.pinnedOnly) {
        builder = builder.eq('is_pinned', true);
      }
      if (q.withDescriptionOnly) {
        // Row has user-visible text if webpage summary or notes exist.
        builder = builder.or(
          'and(description.not.is.null,description.neq.),and(annotation.not.is.null,annotation.neq.)',
        );
      }
      if (q.withImageOnly) {
        builder = builder
            .not('thumbnail_url', 'is', null)
            .filter('thumbnail_url', 'neq', '');
      }
      final domain = q.domainContains.trim();
      if (domain.isNotEmpty) {
        final esc = _escapeIlikePattern(domain);
        builder = builder.ilike('url', '%$esc%');
      }
      if (q.savedAfter != null) {
        builder = builder.gte('created_at', q.savedAfter!.toIso8601String());
      }
      if (q.savedBefore != null) {
        builder = builder.lte('created_at', q.savedBefore!.toIso8601String());
      }
      final search = q.searchQuery.trim();
      if (search.isNotEmpty) {
        final esc = _escapeIlikePattern(search);
        final p = '%$esc%';
        builder = builder.or('title.ilike.$p,url.ilike.$p');
      }

      builder = _applyUrlSort(builder, q.sort);

      final limit = q.limit;
      final offset = q.offset;
      builder = builder.range(offset, offset + limit - 1);

      final response = await builder as List<dynamic>;
      final items =
          response
              .map((e) => SupabaseItemMapper.fromRow(e as Map<String, dynamic>))
              .toList();
      final hasMore = items.length == limit;
      return Right(UrlItemsPage(items: items, hasMore: hasMore));
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return Left(
        NetworkFailure(
          'Failed to query items',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  dynamic _applyUrlSort(dynamic builder, UrlSortOption sort) {
    switch (sort) {
      case UrlSortOption.position:
        return builder
            .order('position', ascending: true)
            .order('id', ascending: true);
      case UrlSortOption.dateAdded:
        return builder
            .order('created_at', ascending: false)
            .order('id', ascending: false);
      case UrlSortOption.dateEdited:
        return builder
            .order('updated_at', ascending: false)
            .order('id', ascending: false);
      case UrlSortOption.mostVisited:
        return builder
            .order('click_count', ascending: false)
            .order('id', ascending: false);
      case UrlSortOption.alphabeticalAsc:
        return builder
            .order('title', ascending: true)
            .order('id', ascending: true);
      case UrlSortOption.alphabeticalDesc:
        return builder
            .order('title', ascending: false)
            .order('id', ascending: false);
    }
  }

  @override
  Future<Either<Failure, void>> createItem(Item item) async {
    try {
      if (_userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }

      String? uploadedImageUrl = item.imageUrl;
      // If we have a local imagePath but no imageUrl, upload it
      if (item.imagePath != null &&
          item.imageUrl == null &&
          !item.imagePath!.startsWith('http')) {
        final file = File(item.imagePath!);
        if (await file.exists()) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${item.id}.jpg';
          final path = '$_userId/$fileName';
          await _supabase.storage.from('item-images').upload(path, file);
          uploadedImageUrl =
              _supabase.storage.from('item-images').getPublicUrl(path);
        }
      }

      final data = SupabaseItemMapper.toInsertJson(
        item,
        ownerId: _userId,
        uploadedImageUrl: uploadedImageUrl,
      );

      await _supabase.from('lv_urls').insert(data);
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return Left(
        NetworkFailure(
          'Failed to create item',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      // Soft delete to keep url_count triggers & reconciliation deterministic.
      await _supabase.from('lv_urls').update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return Left(
        NetworkFailure(
          'Failed to delete item',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> toggleItemPin(String id) async {
    try {
      final row = await _supabase
          .from('lv_urls')
          .select('is_pinned')
          .eq('id', id)
          .eq('is_deleted', false)
          .maybeSingle();

      if (row == null) return const Right(null);

      final currentPinned = (row['is_pinned'] as bool?) ?? false;
      final newPinned = !currentPinned;

      await _supabase
          .from('lv_urls')
          .update({'is_pinned': newPinned}).eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) return Left(authFailure);
      return Left(
        NetworkFailure(
          'Failed to toggle url pin',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> toggleItemArchive(String id) async {
    try {
      final row = await _supabase
          .from('lv_urls')
          .select('status,last_accessed_at')
          .eq('id', id)
          .eq('is_deleted', false)
          .maybeSingle();
      if (row == null) return const Right(null);

      final status = row['status'] as String?;
      final lastAccessed = row['last_accessed_at'] as String?;

      final isArchived = status == 'archived';
      final shouldRestore = isArchived;

      final newStatus = shouldRestore
          ? (lastAccessed != null ? 'read' : 'unread')
          : 'archived';

      await _supabase
          .from('lv_urls')
          .update({'status': newStatus}).eq('id', id);

      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) return Left(authFailure);
      return Left(
        NetworkFailure(
          'Failed to toggle url archive',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markItemReadAndTrack(String id) async {
    try {
      final row = await _supabase
          .from('lv_urls')
          .select('status,click_count')
          .eq('id', id)
          .eq('is_deleted', false)
          .maybeSingle();
      if (row == null) return const Right(null);

      final status = row['status'] as String?;
      final clickCount = (row['click_count'] as int?) ?? 0;

      // Best practice: only transition & track analytics when the URL
      // transitions `unread` -> `read` to reduce write load.
      if (status != 'unread') {
        return const Right(null);
      }

      // Omit last_accessed_at to reduce cloud write cost (status/click still update).
      await _supabase.from('lv_urls').update({
        'status': 'read',
        'click_count': clickCount + 1,
      }).eq('id', id);

      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) return Left(authFailure);
      return Left(
        NetworkFailure(
          'Failed to mark url as read/track',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> reorderItems(
    String collectionId,
    List<String> orderedIds,
  ) async {
    try {
      // Avoid reordering ids from other collections.
      final rows = await _supabase
          .from('lv_urls')
          .select('id')
          .eq('collection_id', collectionId)
          .eq('is_deleted', false);

      final allowedIds = (rows as List<dynamic>)
          .map((r) => (r as Map<String, dynamic>)['id'] as String)
          .toSet();

      const step = 1024.0;
      final updates = <Map<String, dynamic>>[];
      var i = 0;
      for (final urlId in orderedIds) {
        if (!allowedIds.contains(urlId)) continue;
        updates.add({
          'id': urlId,
          'position': (i + 1) * step,
        });
        i++;
      }

      if (updates.isEmpty) return const Right(null);

      await _supabase.from('lv_urls').upsert(updates, onConflict: 'id');
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) return Left(authFailure);
      return Left(
        NetworkFailure(
          'Failed to reorder urls',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Item?>> getItem(String id) async {
    try {
      final response = await _supabase
          .from('lv_urls')
          .select()
          .eq('id', id)
          .eq('is_deleted', false)
          .maybeSingle();
      if (response == null) return const Right(null);
      return Right(SupabaseItemMapper.fromRow(response));
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return Left(
        NetworkFailure(
          'Failed to get item',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getPaginatedItems(
    String collectionId,
    int limit,
    int offset,
  ) async {
    final page = await queryUrlItems(
      UrlItemsQuery(
        collectionId: collectionId,
        limit: limit,
        offset: offset,
      ),
    );
    return page.map((p) => p.items);
  }

  @override
  Future<Either<Failure, void>> updateItem(Item item) async {
    try {
      if (_userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }

      String? uploadedImageUrl = item.imageUrl;
      // Upload new image if local imagePath changed and not an http url
      if (item.imagePath != null && !item.imagePath!.startsWith('http')) {
        final file = File(item.imagePath!);
        if (await file.exists()) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${item.id}.jpg';
          final path = '$_userId/$fileName';
          await _supabase.storage.from('item-images').upload(path, file);
          uploadedImageUrl =
              _supabase.storage.from('item-images').getPublicUrl(path);
        }
      }

      final data = SupabaseItemMapper.toUpdateJson(
        item,
        uploadedImageUrl: uploadedImageUrl,
      );

      await _supabase.from('lv_urls').update(data).eq('id', item.id);
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return Left(
        NetworkFailure(
          'Failed to update item',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateItemPosition(
    String id,
    double newPosition,
  ) async {
    try {
      if (_userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }
      await _supabase.from('lv_urls').update({
        'position': newPosition,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return Left(
        NetworkFailure(
          'Failed to update item position',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getAllItems() async {
    try {
      final userId = _userId;
      if (userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }

      final response = await _supabase
          .from('lv_urls')
          .select()
          .eq('owner_id', userId)
          .eq('is_deleted', false);

      final items = (response as List<dynamic>)
          .map((data) => SupabaseItemMapper.fromRow(data as Map<String, dynamic>))
          .toList();

      return Right(items);
    } catch (e, stackTrace) {
      final authFailure = tryMapSupabaseAuthFailure(e, stackTrace);
      if (authFailure != null) {
        return Left(authFailure);
      }
      return Left(DatabaseFailure('Failed to get all items',
          error: e, stackTrace: stackTrace));
    }
  }

}
