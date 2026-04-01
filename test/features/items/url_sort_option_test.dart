import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/items/domain/entities/item.dart';
import 'package:link_vault/features/items/domain/url_sort_option.dart';

Item _item({
  required String id,
  required String title,
  double position = 0,
  DateTime? createdAt,
  DateTime? updatedAt,
  int clickCount = 0,
}) {
  final now = DateTime(2025, 1, 1);
  return Item(
    id: id,
    collectionId: 'c1',
    title: title,
    status: ItemStatus.read,
    position: position,
    clickCount: clickCount,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  group('compareItemsByUrlSort', () {
    test('uses id as tie-breaker when primary compares equal', () {
      final a = _item(id: 'a', title: 'Same', position: 1);
      final b = _item(id: 'b', title: 'Same', position: 1);
      expect(
        compareItemsByUrlSort(UrlSortOption.position, a, b),
        lessThan(0),
      );
    });
  });
}
