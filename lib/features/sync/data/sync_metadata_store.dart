import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-user delta-sync cursor (durable across restarts).
class SyncMetadataStore {
  SyncMetadataStore();

  static const _kLastSync = 'lv_last_cloud_sync_at_v1_';

  Future<DateTime?> getLastSyncedAt(String userId) async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('$_kLastSync$userId');
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Future<void> setLastSyncedAt(String userId, DateTime t) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('$_kLastSync$userId', t.toUtc().toIso8601String());
  }

  Future<void> clearForUser(String userId) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('$_kLastSync$userId');
  }
}
