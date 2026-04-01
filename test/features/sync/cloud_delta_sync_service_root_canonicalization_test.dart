import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/collections/domain/entities/collection.dart';
import 'package:link_vault/features/sync/application/cloud_delta_sync_service.dart';

Collection _c({
  required String id,
  required String title,
  String? parentId,
  bool isDeleted = false,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return Collection(
    id: id,
    title: title,
    category: 'general',
    colorHex: '#6366F1',
    iconName: '📚',
    position: 0,
    parentId: parentId,
    isDeleted: isDeleted,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CloudDeltaSyncService.canonicalizeCollectionsForSync', () {
    test('remaps root id and child parent when local/server root differ', () {
      final source = [
        _c(id: 'local-root', title: 'Library'),
        _c(id: 'child-1', title: 'Child', parentId: 'local-root'),
      ];

      final out = CloudDeltaSyncService.canonicalizeCollectionsForSync(
        source: source,
        localRootId: 'local-root',
        serverRootId: 'server-root',
      );

      expect(out.first.id, 'server-root');
      expect(out.first.parentId, isNull);
      expect(out[1].id, 'child-1');
      expect(out[1].parentId, 'server-root');
    });

    test('returns input unchanged when root ids already match', () {
      final source = [
        _c(id: 'root-a', title: 'Library'),
        _c(id: 'child-1', title: 'Child', parentId: 'root-a'),
      ];

      final out = CloudDeltaSyncService.canonicalizeCollectionsForSync(
        source: source,
        localRootId: 'root-a',
        serverRootId: 'root-a',
      );

      expect(out, source);
    });
  });

  group('CloudDeltaSyncService.assertValidRootRows', () {
    test('accepts payload with at most one active root', () {
      final rows = <Map<String, dynamic>>[
        {'id': 'r1', 'parent_id': null, 'is_deleted': false},
        {'id': 'c1', 'parent_id': 'r1', 'is_deleted': false},
      ];
      expect(() => CloudDeltaSyncService.assertValidRootRows(rows), returnsNormally);
    });

    test('throws when payload has more than one active root row', () {
      final rows = <Map<String, dynamic>>[
        {'id': 'r1', 'parent_id': null, 'is_deleted': false},
        {'id': 'r2', 'parent_id': null, 'is_deleted': false},
      ];
      expect(
        () => CloudDeltaSyncService.assertValidRootRows(rows),
        throwsA(isA<StateError>()),
      );
    });
  });
}

