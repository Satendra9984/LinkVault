import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:link_vault/features/sync/domain/delta_sync_error_kind.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('classifyDeltaSyncFailure', () {
    test('SocketException is network', () {
      expect(
        classifyDeltaSyncFailure(SocketException('test')),
        DeltaSyncErrorKind.network,
      );
    });

    test('PostgrestException PGRST301 is auth', () {
      final e = PostgrestException(
        message: 'JWT expired',
        code: 'PGRST301',
        details: '',
      );
      expect(classifyDeltaSyncFailure(e), DeltaSyncErrorKind.auth);
    });

    test('collection quota message maps to quota', () {
      final e = PostgrestException(
        message: 'lv_collection_quota_exceeded',
        code: '23514',
        details: '',
      );
      expect(classifyDeltaSyncFailure(e), DeltaSyncErrorKind.quota);
    });

    test('lv_url_quota in message maps to quota', () {
      final e = PostgrestException(
        message: 'lv_url_quota_exceeded',
        code: '23514',
        details: '',
      );
      expect(classifyDeltaSyncFailure(e), DeltaSyncErrorKind.quota);
    });

    test('root unique-constraint conflict maps to rootConflict', () {
      final e = PostgrestException(
        message:
            'duplicate key value violates unique constraint "uq_lv_collections_one_root_per_user"',
        code: '23505',
        details: 'Conflict',
      );
      expect(classifyDeltaSyncFailure(e), DeltaSyncErrorKind.rootConflict);
    });
  });

  group('userFacingDeltaSyncMessage', () {
    test('network kind returns stable copy', () {
      expect(
        userFacingDeltaSyncMessage(DeltaSyncErrorKind.network, 'x'),
        contains('Network error'),
      );
    });

    test('rootConflict returns dedicated message', () {
      expect(
        userFacingDeltaSyncMessage(DeltaSyncErrorKind.rootConflict, 'x'),
        contains('Folder structure conflict'),
      );
    });
  });
}
