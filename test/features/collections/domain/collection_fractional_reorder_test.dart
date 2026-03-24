import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/domain/collection_fractional_reorder.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';

Collection _c(String id, double position) {
  return Collection(
    id: id,
    title: id,
    category: 'g',
    colorHex: '#000000',
    iconName: '📁',
    position: position,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  test('S56-U-03: move to end uses prev + 1', () {
    final s = [_c('a', 0), _c('b', 1)];
    final r = computeSiblingReorderPositions(
      siblings: s,
      oldIndex: 0,
      newIndex: 1,
    );
    expect(r.rebalanceAll, isNull);
    expect(r.primaryId, 'a');
    expect(r.primaryPosition, 2);
  });

  test('S56-U-03: move to start uses next - 1', () {
    final s = [_c('a', 10), _c('b', 20)];
    final r = computeSiblingReorderPositions(
      siblings: s,
      oldIndex: 1,
      newIndex: 0,
    );
    expect(r.primaryId, 'b');
    expect(r.primaryPosition, 9);
  });

  test('S56-U-03: identical positions trigger rebalance', () {
    final s = [_c('a', 0), _c('b', 0), _c('c', 0)];
    // Indices after ReorderableListView adjustment (newIndex > oldIndex => newIndex--).
    final r = computeSiblingReorderPositions(
      siblings: s,
      oldIndex: 0,
      newIndex: 1,
    );
    expect(r.rebalanceAll, isNotNull);
    expect(r.rebalanceAll!.length, 3);
  });
}
