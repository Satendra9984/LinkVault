/// Preset sizes for [MockDatasetService.regenerateMockDataset].
///
/// See `docs/09_SPRINT_ARCHITECTURE/DEBUG_MOCK_GENERATION.md` for the 18 mock
/// test types and invariants.
enum MockDatasetProfile {
  /// 1 Library root (ensured) + 8 non-root folders + 40 URLs. Covers all mock types.
  small,

  /// 24 non-root folders + 240 URLs.
  medium,

  /// 60 non-root folders + 1200 URLs (stress).
  large,

  /// 50 non-root folders + 1200 URLs (guest quota boundary: 50 folders, 1200 URLs).
  quotaBoundaryGuest,

  /// Deletes only rows marked with [MockDatasetService.mockTag]; no inserts.
  cleanupOnly,
}

extension MockDatasetProfileCounts on MockDatasetProfile {
  /// Non-root collections to create (Library root is ensured separately).
  int get nonRootCollectionCount => switch (this) {
        MockDatasetProfile.small => 8,
        MockDatasetProfile.medium => 24,
        MockDatasetProfile.large => 60,
        MockDatasetProfile.quotaBoundaryGuest => 50,
        MockDatasetProfile.cleanupOnly => 0,
      };

  /// URLs to create after folders exist.
  int get urlCount => switch (this) {
        MockDatasetProfile.small => 40,
        MockDatasetProfile.medium => 240,
        MockDatasetProfile.large => 1200,
        MockDatasetProfile.quotaBoundaryGuest => 1200,
        MockDatasetProfile.cleanupOnly => 0,
      };
}
