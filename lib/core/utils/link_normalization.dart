/// Normalizes URLs for stable de-duplication (import, merge).
String normalizeLinkForDedup(String? raw) {
  if (raw == null) return '';
  final t = raw.trim();
  if (t.isEmpty) return '';
  final u = Uri.tryParse(t);
  if (u != null && u.hasScheme && (u.host.isNotEmpty)) {
    return u.replace(fragment: '').toString().toLowerCase();
  }
  return t.toLowerCase();
}
