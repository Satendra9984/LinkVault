import 'package:link_vault/features/collections/domain/collection_display_defaults.dart';

/// Pure topology: for folder slot index `i` (0..n-1), parent slot index or -1 for Library root.
///
/// When [nonRootCount] >= 4, slots 0..3 form a depth-1..4 chain under root; remaining slots are
/// direct children of the library root (sibling ordering / layout variety).
/// Depth under library root for folder slot [i] (1 = direct child of root).
int mockFolderDepth(int i, List<int> parentIndices) {
  var d = 0;
  var c = i;
  while (true) {
    final p = parentIndices[c];
    if (p < 0) return d + 1;
    d++;
    c = p;
  }
}

List<int> mockFolderParentIndices(int nonRootCount) {
  if (nonRootCount <= 0) return const [];
  if (nonRootCount < 4) {
    final parents = List<int>.filled(nonRootCount, -1);
    parents[0] = -1;
    for (var i = 1; i < nonRootCount; i++) {
      parents[i] = i - 1;
    }
    return parents;
  }
  final parents = List<int>.filled(nonRootCount, -1);
  parents[0] = -1;
  for (var i = 1; i < 4; i++) {
    parents[i] = i - 1;
  }
  for (var i = 4; i < nonRootCount; i++) {
    parents[i] = -1;
  }
  return parents;
}

/// Folder display flags for slot [i] (deterministic).
class MockFolderGenSpec {
  final bool isPinned;
  final bool isArchived;
  final String itemsLayout;
  final String childCollectionsLayout;
  final String itemsSortDefault;
  final String openLinksIn;

  const MockFolderGenSpec({
    required this.isPinned,
    required this.isArchived,
    required this.itemsLayout,
    required this.childCollectionsLayout,
    required this.itemsSortDefault,
    required this.openLinksIn,
  });

  factory MockFolderGenSpec.forIndex(int i) {
    final layouts = [
      CollectionLayoutMode.list,
      CollectionLayoutMode.grid,
      CollectionLayoutMode.compactGrid,
    ];
    final childLayouts = [
      CollectionLayoutMode.grid,
      CollectionLayoutMode.compactGrid,
      CollectionLayoutMode.list,
    ];
    final sorts = [
      CollectionItemsSortDefault.manual,
      CollectionItemsSortDefault.addedDesc,
      CollectionItemsSortDefault.titleAsc,
      CollectionItemsSortDefault.lastOpenedDesc,
    ];
    return MockFolderGenSpec(
      isPinned: i % 5 == 1,
      // Archived folders: only root-level generated slots (i>=4) to avoid odd parent/child UX.
      isArchived: i >= 4 && i % 11 == 4,
      itemsLayout: layouts[i % layouts.length],
      childCollectionsLayout: childLayouts[i % childLayouts.length],
      itemsSortDefault: sorts[i % sorts.length],
      openLinksIn: i % 2 == 0
          ? CollectionOpenLinksIn.inApp
          : CollectionOpenLinksIn.externalBrowser,
    );
  }
}
