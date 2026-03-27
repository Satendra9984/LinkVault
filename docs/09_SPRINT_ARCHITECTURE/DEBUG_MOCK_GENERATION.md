# Debug mock generation

## Objective

Deterministic debug-only data for local ObjectBox and Supabase-backed flows. Generated rows use **real** domain models and repository/use-case paths (not bypassing schema).

## Code entry points

| Area | Path |
|------|------|
| Service | `lib/features/debug/domain/services/mock_dataset_service.dart` |
| Profiles | `lib/features/debug/domain/services/mock_dataset_profile.dart` |
| Topology + folder flags | `lib/features/debug/domain/services/mock_dataset_blueprint.dart` |
| Debug actions | `lib/features/debug/presentation/providers/debug_providers.dart` |
| UI | `lib/features/debug/presentation/screens/debug_screen.dart` |

## Marker and cleanup

- All generated **collection** titles and **URL** titles include the substring `[DEBUG_MOCK]` (`MockDatasetService.mockTag`).
- Cleanup deletes **only** rows whose title contains that marker.
- The canonical **Library** root (sole `parent_id` null row per user) is never deleted.
- Order: delete URL rows first, then collections **leaf-first** to satisfy FK/parent constraints.

## Why root-level inserts fail on Supabase

Legacy generators created collections with `parent_id = null`. Postgres enforces **one root per user** (`uq_lv_collections_one_root_per_user`). Non-root folders must use `parent_id = <library_root_id>` (or a descendant).

Correct flow: `libraryRootCollectionProvider` / `ensureLibraryRootCollection()` then create folders under that root.

## Backend modes (18 mock test types — group A)

| # | Type | Behavior |
|---|------|----------|
| 1 | Local writable | ObjectBox; writes allowed |
| 2 | Cloud writable | Supabase when `dataBackendSelectionProvider.useCloud` and not read-only |
| 3 | Cloud read-only | `isReadOnlyCloud` — **no** mock generate/cleanup writes; `StateError` with renewal message |
| 4 | Auth offline → local | Same as local when cloud not selected (ADR-0002 routing) |

Implementation: `_throwIfReadOnlyCloud()` gates `regenerateMockDataset` and `deleteGeneratedMocksOnly`.

## Collection topology (group B)

| # | Type | How it appears in generated data |
|---|------|----------------------------------|
| 1 | Canonical Library root | Ensured before insert; not created as a mock row |
| 2 | Depth 1 under root | First slot in depth chain (`mockFolderParentIndices`) |
| 3 | Depth 2 | Second slot |
| 4 | Depth 3 | Third slot |
| 5 | Depth 4 | Fourth slot |
| 6 | Mixed sibling order flags | `MockFolderGenSpec`: `isPinned`, `isArchived` (archived only for slots `i >= 4`) |
| 7 | Mixed display defaults | Rotating `items_layout`, `child_collections_layout`, `items_sort_default`, `open_links_in` |

Mock folder `color_hex` values cycle a fixed palette by **slot index** (deterministic, not random).

When `nonRootCollectionCount < 4`, the blueprint collapses to a single chain under root (see `mockFolderParentIndices`).

## URL / item schema (group C)

Templates cycle in `_urlTemplates` (8 canonical rows), then repeat with index `k` for larger profiles:

| # | Type | Covered by |
|---|------|------------|
| 1 | Minimal valid URL | `example.com` template (sparse optional fields) |
| 2 | Preview metadata | thumbnail + favicon + `dominant_color` |
| 3 | Notes / tags | `annotation` + `tags` |
| 4 | Article-style metadata | `site_name`, `canonical_url`, `content_type`, `published_at` |
| 5 | `unread` | Template + rotation |
| 6 | `read` + `click_count` / `last_accessed_at` | Template + rotation |
| 7 | `archived` + pin mix | Dedicated templates + `k`-based rotation |

URLs are assigned to collections with **round-robin** over `[libraryRootId, ...folderIds]` so **root-level links** and nested-folder links both appear.

## Dataset profiles

| Profile | Non-root folders | URLs |
|---------|------------------|------|
| `small` | 8 | 40 |
| `medium` | 24 | 240 |
| `large` | 60 | 1200 |
| `quotaBoundaryGuest` | 50 | 1200 |
| `cleanupOnly` | 0 | 0 (delete only) |

`quotaBoundaryGuest` aligns with guest folder quota math (root excluded from counts in `TierQuotaGuard`).

## Service API

```dart
Future<void> regenerateMockDataset(MockDatasetProfile profile);
Future<void> deleteGeneratedMocksOnly();
```

## Verification

- `dart analyze` on touched debug files.
- `flutter test` including `test/features/debug/`.
- Manual: Debug screen → Small → open Library in app; confirm folders and URLs; run Cleanup → mocks gone, Library remains.

## UI contract (Debug screen)

- Generate mock dataset (Small / Medium / Large / quota boundary).
- Cleanup generated mock data only.

Legacy actions “Generate N mock collections/items” (null parent, no URLs) are **removed** — they conflict with the one-root constraint and schema.
