/// Last-write-wins using `updated_at` (see Cloud_Sync_and_Reconciliation.md).
class ConflictPolicy {
  ConflictPolicy._();

  /// True if the remote row should replace the local copy.
  static bool remoteIsNewer(DateTime localUpdated, DateTime remoteUpdated) {
    return remoteUpdated.isAfter(localUpdated);
  }

  /// True if the local row should be pushed over an older server row.
  static bool localIsNewer(DateTime localUpdated, DateTime remoteUpdated) {
    return localUpdated.isAfter(remoteUpdated);
  }
}
