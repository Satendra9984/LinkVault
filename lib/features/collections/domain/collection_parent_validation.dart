import 'entities/collection.dart';

/// Validates [proposedParentId] for a collection [editingCollectionId].
///
/// [editingCollectionId] is `null` or empty when creating a new collection.
/// Returns an error message, or `null` if valid.
String? validateCollectionParentAssignment({
  required String? editingCollectionId,
  required String? proposedParentId,
  required List<Collection> allCollections,
}) {
  if (proposedParentId == null || proposedParentId.isEmpty) {
    return null;
  }

  final byId = {for (final c in allCollections) c.id: c};
  if (!byId.containsKey(proposedParentId)) {
    return 'Selected parent no longer exists.';
  }

  final selfId = editingCollectionId?.trim();
  if (selfId != null && selfId.isNotEmpty && proposedParentId == selfId) {
    return 'A collection cannot be its own parent.';
  }

  if (selfId != null && selfId.isNotEmpty) {
    String? cursor = proposedParentId;
    final visited = <String>{};
    while (cursor != null) {
      if (cursor == selfId) {
        return 'Cannot move under a subfolder of this collection (cycle).';
      }
      if (!visited.add(cursor)) break;
      cursor = byId[cursor]?.parentId;
    }
  }

  return null;
}

/// Parent IDs that must not appear in the parent picker when editing [editingId]
/// (self + entire subtree under [editingId]).
Set<String> excludedParentIdsForEditing({
  required String editingId,
  required List<Collection> allCollections,
}) {
  final byId = {for (final c in allCollections) c.id: c};
  final excluded = <String>{editingId};

  void addDescendants(String rootId) {
    for (final c in allCollections) {
      if (c.parentId == rootId) {
        excluded.add(c.id);
        addDescendants(c.id);
      }
    }
  }

  if (byId.containsKey(editingId)) {
    addDescendants(editingId);
  }
  return excluded;
}
