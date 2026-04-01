import '../../collections/domain/collection_display_defaults.dart';

/// Resolves how a URL should open: per-item override, else collection default.
String effectiveOpenLinksIn({
  required String? itemOpenLinksInOverride,
  required String? collectionOpenLinksIn,
}) {
  final o = itemOpenLinksInOverride?.trim();
  if (o != null &&
      o.isNotEmpty &&
      CollectionOpenLinksIn.values.contains(o)) {
    return o;
  }
  return CollectionOpenLinksIn.normalize(collectionOpenLinksIn);
}
