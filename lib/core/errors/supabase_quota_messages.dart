import 'failures.dart';

Failure? tryMapSupabaseAuthFailure(
  Object error,
  StackTrace stackTrace, {
  String? message,
}) {
  final s = error.toString().toLowerCase();

  final looksLikeAuth =
      s.contains('invalid') && (s.contains('jwt') || s.contains('token')) ||
      s.contains('jwt') && (s.contains('expired') || s.contains('invalid')) ||
      s.contains('unauthorized') ||
      s.contains('not authenticated');

  if (!looksLikeAuth) return null;

  return AuthFailure(
    message ?? 'Session expired. Please sign in again.',
    code: 'session_expired',
    error: error,
    stackTrace: stackTrace,
  );
}

/// Maps Postgres trigger exceptions from migration 010 (free-tier quotas).
Failure mapSupabaseQuotaException(
  Object error,
  StackTrace stackTrace, {
  required String fallbackMessage,
}) {
  final authFailure = tryMapSupabaseAuthFailure(error, stackTrace);
  if (authFailure != null) return authFailure;

  final s = error.toString();
  if (s.contains('lv_collection_quota_exceeded')) {
    return ValidationFailure(
      "You've reached the free plan limit of 150 collections. "
      'Upgrade to Premium for higher limits.',
    );
  }
  if (s.contains('lv_url_quota_exceeded')) {
    return ValidationFailure(
      "You've reached the free plan limit of 5000 saved links. "
      'Upgrade to Premium for higher limits.',
    );
  }
  return NetworkFailure(fallbackMessage, error: error, stackTrace: stackTrace);
}
