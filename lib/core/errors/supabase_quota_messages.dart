import 'failures.dart';

/// Maps Postgres trigger exceptions from migration 010 (free-tier quotas).
Failure mapSupabaseQuotaException(
  Object error,
  StackTrace stackTrace, {
  required String fallbackMessage,
}) {
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
