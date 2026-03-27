import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/domain/collection_parent_validation.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';

Collection _col(String id, {String? parentId}) {
  return Collection(
    id: id,
    parentId: parentId,
    title: id,
    category: 'g',
    colorHex: '#000000',
    iconName: '📁',
    position: 0,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  test('library root (sole null parent) may have null proposed parent', () {
    final lib = _col('lib-id');
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: 'lib-id',
        proposedParentId: null,
        allCollections: [lib],
      ),
      isNull,
    );
  });

  test('nested folder cannot use null parent', () {
    final lib = _col('lib-id');
    final child = _col('a', parentId: 'lib-id');
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: 'a',
        proposedParentId: null,
        allCollections: [lib, child],
      ),
      isNotNull,
    );
  });

  test('create requires explicit parent', () {
    final lib = _col('lib-id');
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: null,
        proposedParentId: null,
        allCollections: [lib],
      ),
      isNotNull,
    );
  });

  test('S56-U-02: self parent invalid', () {
    final lib = _col('lib-id');
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: 'a',
        proposedParentId: 'a',
        allCollections: [lib, _col('a', parentId: 'lib-id')],
      ),
      isNotNull,
    );
  });

  test('S56-U-02: descendant parent invalid', () {
    final lib = _col('lib-id');
    final all = [
      lib,
      _col('a', parentId: 'lib-id'),
      _col('b', parentId: 'a'),
    ];
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: 'lib-id',
        proposedParentId: 'b',
        allCollections: all,
      ),
      isNotNull,
    );
  });

  test('excludedParentIdsForEditing includes subtree', () {
    final all = [_col('a'), _col('b', parentId: 'a'), _col('c', parentId: 'b')];
    final ex = excludedParentIdsForEditing(editingId: 'a', allCollections: all);
    expect(ex, {'a', 'b', 'c'});
  });
}
