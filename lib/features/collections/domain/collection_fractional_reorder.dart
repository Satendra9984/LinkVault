import 'entities/collection.dart';

/// Result of computing positions after a sibling reorder.
class CollectionReorderPositions {
  CollectionReorderPositions({
    required this.primaryId,
    required this.primaryPosition,
    this.rebalanceAll,
  });

  /// Moved collection id and its new [Collection.position].
  final String primaryId;
  final double primaryPosition;

  /// When non-null, persist every id → position (fractional gap collapsed).
  final Map<String, double>? rebalanceAll;
}

const double _rebalanceStep = 1024;

/// Computes new position(s) after reordering [siblings] from [oldIndex] to [newIndex].
///
/// [newIndex] must follow [ReorderableListView] semantics: if `newIndex > oldIndex`,
/// subtract one before calling (Flutter adjusts for the removal shift).
///
/// [siblings] must be direct children of the same parent, sorted with
/// [compareCollectionsSiblings].
CollectionReorderPositions computeSiblingReorderPositions({
  required List<Collection> siblings,
  required int oldIndex,
  required int newIndex,
}) {
  if (siblings.isEmpty) {
    throw ArgumentError('siblings must not be empty');
  }
  if (oldIndex < 0 || oldIndex >= siblings.length) {
    throw RangeError.range(oldIndex, 0, siblings.length - 1);
  }
  if (newIndex < 0 || newIndex >= siblings.length) {
    throw RangeError.range(newIndex, 0, siblings.length - 1);
  }
  if (oldIndex == newIndex) {
    final c = siblings[oldIndex];
    return CollectionReorderPositions(
      primaryId: c.id,
      primaryPosition: c.position,
    );
  }

  final reordered = List<Collection>.from(siblings);
  final moved = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, moved);

  final at = newIndex;
  final prev = at > 0 ? reordered[at - 1].position : null;
  final next = at < reordered.length - 1 ? reordered[at + 1].position : null;

  final mid = _midpoint(prev, next);
  if (_needsRebalance(prev, mid, next)) {
    final map = <String, double>{};
    for (var i = 0; i < reordered.length; i++) {
      map[reordered[i].id] = (i + 1) * _rebalanceStep;
    }
    return CollectionReorderPositions(
      primaryId: moved.id,
      primaryPosition: map[moved.id]!,
      rebalanceAll: map,
    );
  }

  return CollectionReorderPositions(
    primaryId: moved.id,
    primaryPosition: mid,
  );
}

double _midpoint(double? prev, double? next) {
  if (prev == null && next == null) return 0;
  if (prev == null) return next! - 1;
  if (next == null) return prev + 1;
  return (prev + next) / 2;
}

bool _needsRebalance(double? prev, double mid, double? next) {
  if (prev != null && mid <= prev) return true;
  if (next != null && mid >= next) return true;
  if (prev != null && next != null && prev == next) return true;
  return false;
}
