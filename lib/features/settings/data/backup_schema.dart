/// Backup JSON contract: versions and root keys for export/import.
///
/// v1.0: legacy `collections` / `items` (camelCase per-item fields).
/// v2.0: canonical `lv_collections` / `lv_urls` rows (`snake_case` aligned with Supabase).
abstract final class BackupSchema {
  static const version1_0 = '1.0';
  static const version2_0 = '2.0';

  static const keyVersion = 'version';
  static const keyExportedAt = 'exportedAt';
  static const keyAppVersion = 'appVersion';
  static const keyPlatform = 'platform';

  /// v1 root keys
  static const keyCollections = 'collections';
  static const keyItems = 'items';

  /// v2 root keys (Supabase table-aligned sections)
  static const keyLvCollections = 'lv_collections';
  static const keyLvUrls = 'lv_urls';

  /// Optional: embedded local thumbnail (not a DB column); import supports it on v2 rows.
  static const keyImageBase64 = 'imageBase64';
  static const keyImageBase64Snake = 'image_base64';
}
