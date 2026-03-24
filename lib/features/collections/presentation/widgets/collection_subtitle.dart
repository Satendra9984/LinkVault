import '../../domain/entities/collection.dart';

/// One-line summary for grid cards and list rows (nested folders + links).
String collectionSummarySubtitle(Collection collection) {
  final parts = <String>[];
  if (collection.childCount > 0) {
    final n = collection.childCount;
    parts.add('$n folder${n == 1 ? '' : 's'}');
  }
  final links = collection.itemCount;
  parts.add('$links link${links == 1 ? '' : 's'}');
  return parts.join(' · ');
}
