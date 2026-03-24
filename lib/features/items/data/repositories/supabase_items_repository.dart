import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../mappers/supabase_item_mapper.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/i_items_repository.dart';

class SupabaseItemsRepository implements IItemsRepository {
  final SupabaseClient _supabase;
  final String? _userId;

  SupabaseItemsRepository(this._supabase, {String? userId})
      : _userId = userId ?? _supabase.auth.currentUser?.id;

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

      final data = SupabaseItemMapper.toJson(
        item,
        uploadedImageUrl: uploadedImageUrl,
      );

      await _supabase.from('items').insert(data);
      return const Right(null);
    } catch (e, stackTrace) {
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
      // Could optionally delete the image from storage here if we tracked its path,
      // but simple delete works for now.
      await _supabase.from('items').delete().eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
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
  Future<Either<Failure, Item?>> getItem(String id) async {
    try {
      final response =
          await _supabase.from('items').select().eq('id', id).maybeSingle();
      if (response == null) return const Right(null);
      return Right(_fromMap(response));
    } catch (e, stackTrace) {
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
    try {
      final response = await _supabase
          .from('items')
          .select()
          .eq('collection_id', collectionId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final items = response.map((data) => _fromMap(data)).toList();
      return Right(items);
    } catch (e, stackTrace) {
      return Left(
        NetworkFailure(
          'Failed to get items',
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
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

      final data = SupabaseItemMapper.toJson(
        item,
        uploadedImageUrl: uploadedImageUrl,
      );

      await _supabase.from('items').update(data).eq('id', item.id);
      return const Right(null);
    } catch (e, stackTrace) {
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
      await _supabase.from('items').update({
        'position': newPosition,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', id);
      return const Right(null);
    } catch (e, stackTrace) {
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
      if (_userId == null) {
        return const Left(NetworkFailure('User not authenticated'));
      }

      final response =
          await _supabase.from('items').select().eq('owner_id', _userId!);

      final items = (response as List<dynamic>)
          .map((data) => _fromMap(data as Map<String, dynamic>))
          .toList();

      return Right(items);
    } catch (e, stackTrace) {
      return Left(DatabaseFailure('Failed to get all items',
          error: e, stackTrace: stackTrace));
    }
  }

  Item _fromMap(Map<String, dynamic> map) {
    List<CustomField> parsedCustomFields = [];
    if (map['custom_fields'] != null) {
      final list = map['custom_fields'] as List;
      parsedCustomFields = list.map((f) {
        final fieldMap = f as Map<String, dynamic>;
        return CustomField(
          id: fieldMap['id'] ?? '',
          name: fieldMap['name'] ?? '',
          type: CustomFieldType.values.firstWhere(
            (e) => e.name == fieldMap['type'],
            orElse: () => CustomFieldType.text,
          ),
          value: fieldMap['value'],
        );
      }).toList();
    }

    return Item(
      id: map['id'],
      ownerId: map['owner_id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['image_path'],
      imageUrl: map['image_url'],
      link: map['link'],
      location: map['location'],
      tags: map['tags'],
      customFields: parsedCustomFields,
      status: ItemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ItemStatus.pending,
      ),
      position: (map['position'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      collectionId: map['collection_id'],
    );
  }
}
