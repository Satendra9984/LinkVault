import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/debug/domain/services/mock_dataset_blueprint.dart';

void main() {
  group('mockFolderParentIndices', () {
    test('n>=4: slots 0-3 form chain from root, rest attach to root', () {
      final p = mockFolderParentIndices(8);
      expect(p.length, 8);
      expect(p[0], -1);
      expect(p[1], 0);
      expect(p[2], 1);
      expect(p[3], 2);
      for (var i = 4; i < 8; i++) {
        expect(p[i], -1);
      }
    });

    test('depth under root: slot 3 is depth 4', () {
      final p = mockFolderParentIndices(8);
      expect(mockFolderDepth(0, p), 1);
      expect(mockFolderDepth(3, p), 4);
      expect(mockFolderDepth(7, p), 1);
    });

    test('n<4: linear chain from root', () {
      final p = mockFolderParentIndices(3);
      expect(p, [-1, 0, 1]);
    });
  });

  group('MockFolderGenSpec', () {
    test('uses allowed layout and sort literals', () {
      final a = MockFolderGenSpec.forIndex(0);
      expect(a.itemsLayout, isNotEmpty);
      expect(a.childCollectionsLayout, isNotEmpty);
      expect(a.itemsSortDefault, isNotEmpty);
      expect(a.openLinksIn, isNotEmpty);
    });
  });
}
