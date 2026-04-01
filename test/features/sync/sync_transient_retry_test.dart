import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/sync/application/sync_transient_retry.dart';

void main() {
  test('withTransientRetry succeeds after transient failures', () async {
    var attempts = 0;
    final v = await withTransientRetry(
      maxAttempts: 5,
      delayForAttempt: (_) => Duration.zero,
      operation: () async {
        attempts++;
        if (attempts < 3) throw SocketException('fail');
        return 7;
      },
    );
    expect(v, 7);
    expect(attempts, 3);
  });

  test('withTransientRetry does not retry non-transient errors', () async {
    var attempts = 0;
    await expectLater(
      () => withTransientRetry(
        maxAttempts: 5,
        delayForAttempt: (_) => Duration.zero,
        operation: () async {
          attempts++;
          throw FormatException('not transient');
        },
      ),
      throwsA(isA<FormatException>()),
    );
    expect(attempts, 1);
  });
}
