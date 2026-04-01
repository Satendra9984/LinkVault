import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/sync/domain/conflict_policy.dart';

void main() {
  test('remoteIsNewer when remote updated_at is strictly after local', () {
    final local = DateTime.utc(2025, 1, 1);
    final remote = DateTime.utc(2025, 1, 2);
    expect(ConflictPolicy.remoteIsNewer(local, remote), isTrue);
    expect(ConflictPolicy.remoteIsNewer(remote, local), isFalse);
  });

  test('localIsNewer mirrors remoteIsNewer', () {
    final a = DateTime.utc(2025, 1, 1);
    final b = DateTime.utc(2025, 1, 3);
    expect(ConflictPolicy.localIsNewer(b, a), isTrue);
    expect(ConflictPolicy.localIsNewer(a, b), isFalse);
  });
}
