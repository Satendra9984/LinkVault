import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// High-level classification of a failed delta sync (for UI + logging).
enum DeltaSyncErrorKind {
  network,
  auth,
  quota,
  rootConflict,
  unknown,
}

/// Maps [error] to a coarse failure bucket for `DeltaSyncResult`.
DeltaSyncErrorKind classifyDeltaSyncFailure(Object error) {
  if (error is SocketException) return DeltaSyncErrorKind.network;
  if (error is HttpException) return DeltaSyncErrorKind.network;
  if (error is TimeoutException) return DeltaSyncErrorKind.network;

  final asString = error.toString().toLowerCase();
  if (asString.contains('socketexception') ||
      asString.contains('failed host lookup') ||
      asString.contains('connection reset') ||
      asString.contains('connection refused') ||
      asString.contains('network is unreachable')) {
    return DeltaSyncErrorKind.network;
  }
  if (asString.contains('clientexception')) {
    return DeltaSyncErrorKind.network;
  }

  if (error is PostgrestException) {
    final msg = error.message.toLowerCase();
    final hint = error.hint?.toString().toLowerCase() ?? '';
    final details = error.details?.toString().toLowerCase() ?? '';
    final code = error.code;

    if (code == 'PGRST301' ||
        msg.contains('jwt') ||
        msg.contains('invalid claim') ||
        msg.contains('not authorized')) {
      return DeltaSyncErrorKind.auth;
    }

    if (hint.contains('quota') ||
        details.contains('quota') ||
        msg.contains('lv_collection_quota') ||
        msg.contains('lv_url_quota') ||
        msg.contains('collection_quota_exceeded') ||
        msg.contains('url_quota_exceeded')) {
      return DeltaSyncErrorKind.quota;
    }

    if (code == '23514' &&
        (msg.contains('quota') || hint.contains('quota'))) {
      return DeltaSyncErrorKind.quota;
    }

    if (code == '23505' &&
        (msg.contains('uq_lv_collections_one_root_per_user') ||
            details.contains('uq_lv_collections_one_root_per_user'))) {
      return DeltaSyncErrorKind.rootConflict;
    }

    return DeltaSyncErrorKind.unknown;
  }

  return DeltaSyncErrorKind.unknown;
}

/// Short user-facing message for Profile / snackbars.
String userFacingDeltaSyncMessage(
  DeltaSyncErrorKind kind,
  String? rawMessage,
) {
  switch (kind) {
    case DeltaSyncErrorKind.network:
      return 'Network error. Check your connection and try again.';
    case DeltaSyncErrorKind.auth:
      return 'Session expired. Please sign in again.';
    case DeltaSyncErrorKind.quota:
      return 'Cloud limit reached. Delete items or upgrade to continue syncing.';
    case DeltaSyncErrorKind.rootConflict:
      return 'Folder structure conflict detected. Please refresh collections and retry sync.';
    case DeltaSyncErrorKind.unknown:
      return rawMessage?.isNotEmpty == true ? rawMessage! : 'Sync failed.';
  }
}
