/// Allowed DB / API values for collection display and URL defaults.
/// See [docs/09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/Collections_Extended_Schema_and_UX_Fields.md].
abstract final class CollectionLayoutMode {
  static const list = 'list';
  static const grid = 'grid';
  static const compactGrid = 'compact_grid';

  static const Set<String> values = {list, grid, compactGrid};

  static String normalize(String? v) => values.contains(v) ? v! : list;
}

/// Use [CollectionLayoutMode] for both URL list layout (`items_layout`) and
/// nested folder layout (`child_collections_layout`).

abstract final class CollectionItemsSortDefault {
  static const manual = 'manual';
  static const addedDesc = 'added_desc';
  static const titleAsc = 'title_asc';
  static const lastOpenedDesc = 'last_opened_desc';

  static const Set<String> values = {
    manual,
    addedDesc,
    titleAsc,
    lastOpenedDesc,
  };

  static String normalize(String? v) =>
      values.contains(v) ? v! : manual;
}

abstract final class CollectionOpenLinksIn {
  static const inApp = 'in_app';
  static const externalBrowser = 'external_browser';

  static const Set<String> values = {inApp, externalBrowser};

  static String normalize(String? v) =>
      values.contains(v) ? v! : inApp;
}
