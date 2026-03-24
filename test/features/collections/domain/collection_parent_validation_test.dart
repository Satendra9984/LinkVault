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
  test('S56-U-02: root parent is valid', () {
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: 'a',
        proposedParentId: null,
        allCollections: [_col('a'), _col('b')],
      ),
      isNull,
    );
  });

  test('S56-U-02: self parent invalid', () {
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: 'a',
        proposedParentId: 'a',
        allCollections: [_col('a')],
      ),
      isNotNull,
    );
  });

  test('S56-U-02: descendant parent invalid', () {
    final all = [_col('root'), _col('a', parentId: 'root'), _col('b', parentId: 'a')];
    expect(
      validateCollectionParentAssignment(
        editingCollectionId: 'root',
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
