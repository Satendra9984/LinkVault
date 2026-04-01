import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/sync/data/sync_metadata_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns null when no sync anchor exists', () async {
    final store = SyncMetadataStore();
    final value = await store.getLastSyncedAt('user-1');
    expect(value, isNull);
  });

  test('setLastSyncedAt persists per-user UTC timestamp', () async {
    final store = SyncMetadataStore();
    final t = DateTime.utc(2026, 3, 31, 14, 20, 5);

    await store.setLastSyncedAt('user-1', t);
    final restored = await store.getLastSyncedAt('user-1');

    expect(restored, isNotNull);
    expect(restored!.isUtc, isTrue);
    expect(restored, DateTime.utc(2026, 3, 31, 14, 20, 5));
  });

  test('clearForUser only removes target user key', () async {
    final store = SyncMetadataStore();
    final t1 = DateTime.utc(2026, 3, 31, 10);
    final t2 = DateTime.utc(2026, 3, 31, 11);

    await store.setLastSyncedAt('user-1', t1);
    await store.setLastSyncedAt('user-2', t2);
    await store.clearForUser('user-1');

    expect(await store.getLastSyncedAt('user-1'), isNull);
    expect(await store.getLastSyncedAt('user-2'), t2);
  });
}
