import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/domain/collection_sibling_order.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';

Collection _c(
  String id, {
  double position = 0,
  bool pinned = false,
  bool archived = false,
  DateTime? updatedAt,
}) {
  final t = updatedAt ?? DateTime(2024, 1, 1);
  return Collection(
    id: id,
    title: id,
    category: 'g',
    colorHex: '#000000',
    iconName: '📁',
    position: position,
    isPinned: pinned,
    isArchived: archived,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  test('S56-U-01: archived after active', () {
    final a = _c('a', archived: false);
    final b = _c('b', archived: true);
    expect(compareCollectionsSiblings(a, b), lessThan(0));
    expect(compareCollectionsSiblings(b, a), greaterThan(0));
  });

  test('S56-U-01: pinned before unpinned when same archive flag', () {
    final p = _c('p', pinned: true);
    final u = _c('u', pinned: false);
    expect(compareCollectionsSiblings(p, u), lessThan(0));
  });

  test('S56-U-01: position then updatedAt tie-break', () {
    final early = _c('a', position: 1, updatedAt: DateTime(2024, 1, 1));
    final late = _c('b', position: 1, updatedAt: DateTime(2024, 6, 1));
    expect(compareCollectionsSiblings(early, late), greaterThan(0));
  });
}
