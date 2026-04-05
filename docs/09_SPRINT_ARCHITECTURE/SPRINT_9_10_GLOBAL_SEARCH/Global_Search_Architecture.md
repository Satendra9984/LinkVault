# Sprint 9–10 — Global Search Architecture

> Status: **Implemented & verified** (Apr 2026)
> Reference PR branch: `v2_main`

---

## 1. Overview

Global Search allows users to query both **Collections** and **Links** from a single entry point (`/search`), using the same visual structure, behavior, and widget set as the per-collection hub (`items_list_screen.dart`). The implementation follows hub-parity principles throughout: same sliver layout, same list tile widgets, same filter-driven layout toggle, and the same manual search-on-submit model.

---

## 2. Component Map

```
/search  → SearchCollectionsScreen
  ├── NestedScrollView
  │   ├── SliverAppBar (pinned, title "Search", TabBar bottom)
  │   │   tabs: [Collections | Links]
  │   └── TabBarView
  │       ├── Collections tab  ─ CustomScrollView
  │       │   ├── SliverOverlapInjector
  │       │   ├── SliverToBoxAdapter  ← _buildCollectionsToolbar
  │       │   │   [TextFormField + tune IconButton → /search/filters/collections]
  │       │   └── [SliverList(CollectionListTile)
  │       │        | SliverGrid(CollectionCard compact=false)
  │       │        | SliverGrid(CollectionCard compact=true)]
  │       │   or SliverFillRemaining(_buildHistoryView)
  │       └── Links tab  ─ CustomScrollView
  │           ├── SliverOverlapInjector
  │           ├── SliverToBoxAdapter  ← _buildLinksToolbar
  │           │   [TextFormField + tune IconButton → /search/filters/links]
  │           ├── SliverToBoxAdapter  ← offline/DayPass banner (conditional)
  │           └── [SliverList(UrlListRowTile)           ← list mode (safe height)
  │                | SliverGrid(UrlPreviewTile)          ← cards mode (aspect ratio)
  │                | SliverGrid(UrlIconLinkTile)]        ← icons mode (aspect ratio)
  │             + SliverToBoxAdapter ← isLoadingMore spinner
  │           or SliverFillRemaining(_buildHistoryView)

Filter screens
  /search/filters/collections  → SearchFiltersCollectionsScreen
  /search/filters/links        → SearchFiltersLinksScreen
```

---

## 3. State & Provider Graph

```
globalSearchNotifierProvider  (AutoDisposeNotifier<GlobalSearchState>)
  ├── activeTab                  : GlobalSearchTab {collections|links}
  ├── collectionsSearchDraft     : String   (updated on every keystroke)
  ├── collectionsCommittedQuery  : String   (updated only on submit/enter)
  ├── collectionsViewMode        : UrlViewMode {list|cards|icons}
  ├── collectionsFolderSort      : ChildFolderSort
  ├── collectionsShowOnlyPrivate : bool
  ├── collectionsIncludeArchived : bool
  ├── collectionsSelectedCategories : Set<String>
  ├── collectionsUpdated{After|Before} : DateTime?
  ├── linksSearchDraft           : String
  ├── linksCommittedQuery        : String
  ├── linksViewMode              : UrlViewMode {list|cards|icons}
  ├── linksSortOption            : UrlSortOption
  ├── linksStatusFilter          : ItemStatus?
  ├── linksPinnedOnly            : bool
  ├── linksWithDescriptionOnly   : bool
  ├── linksWithImageOnly         : bool
  ├── linksDomainQuery           : String
  └── linksSaved{After|Before}   : DateTime?

globalSearchFilteredCollectionsProvider  (Provider<AsyncValue<List<Collection>>>)
  └── watches: collectionsListProvider, globalSearchNotifierProvider
       [filters on committedQuery + sort/visibility/category/date]

globalSearchLinksNotifierProvider  (AutoDisposeNotifier<GlobalSearchLinksState>)
  ├── phase      : GlobalSearchLinksPhase {idle|loading|loaded|error}
  ├── items      : List<Item>
  ├── page       : int
  ├── hasMore    : bool
  └── isLoadingMore : bool
  methods:
    searchAndReset()  → clears list, page 0, new query
    fetchNextPage()   → appends next 20 items (no-op if loading / !hasMore)
    reset()           → back to idle/empty

globalSearchItemsDataModeProvider  (FutureProvider<GlobalSearchItemsDataMode>)
  → localRepositoryOnly  (free/offline/DayPass expired)
  → activeRepository     (premium or DayPass active)

globalSearchLinksLocalOnlyProvider  (Provider<bool>)
  → true when mode == localRepositoryOnly

searchHistoryProvider  (StreamProvider<List<SearchHistoryModel>>)
  → last 50 queries via ObjectBox
```

---

## 4. Paginated Query Flow (Links tab)

```
User types → linksSearchDraft updated (no network call)
User presses search icon / Enter
  → gn.submitLinksSearch(query)      updates linksCommittedQuery + history
  → linksNotifier.searchAndReset()   → page=0, items=[], phase=loading
      → _fetch(offset:0, append:false)
          → UrlItemsQuery(collectionId: null, limit:20, offset:0, ...)
          → repo.queryUrlItems(q)
              ObjectBox: query + LIMIT 20 (no collectionUid filter)
              Supabase:  WHERE owner_id=x [AND collection_id=...] LIMIT 20
          → state.copyWith(items: result, page:1, hasMore: result.length==20)
          → phase = loaded

Scroll to 80% of maxScrollExtent
  → ScrollNotification in NotificationListener
  → linksNotifier.fetchNextPage() [no-op if isLoadingMore || !hasMore]
      → _fetch(offset: page*20, append:true)
          → result appended to items, page++
```

---

## 5. Tier-Aware Data Mode

| Tier | `globalSearchItemsDataModeProvider` | Effect |
|---|---|---|
| Free / unauthenticated | `localRepositoryOnly` | ObjectBox only; offline banner shown |
| DayPass active | `activeRepository` | Supabase query; full results |
| DayPass expired | `localRepositoryOnly` | ObjectBox only; banner prompts Day Pass |
| Premium | `activeRepository` | Supabase query; full results |

---

## 6. Filter Screens Contract

Both filter screens are **full-screen routes** opened via `context.push(...)`. They read the current state on `initState`, hold local copies, and write back only on "Apply":

| Screen | Route | Writes to |
|---|---|---|
| `SearchFiltersCollectionsScreen` | `/search/filters/collections` | `globalSearchNotifierProvider` (sort, visibility, categories, dates, **viewMode**) |
| `SearchFiltersLinksScreen` | `/search/filters/links` | `globalSearchNotifierProvider` (sort, status, pins, dates, domain, **linksViewMode**) |

Layout toggle (List / Cards / Icons):
- Collections layout: `collectionsViewMode` in `GlobalSearchState` — default `list`, reset to `list` on "Reset".
- Links layout: `linksViewMode` in `GlobalSearchState` — default `list`, reset to `list` on "Reset".
- **No layout toggle in the app bar** — matching the hub pattern.

---

## 7. Shared Widget: `UrlListRowTile`

**Path:** `lib/features/items/presentation/widgets/url_list_row_tile.dart`

Extracted from `items_list_screen.dart`'s `_buildListItem` inner widget. Provides a self-contained, bounded-height `Row`/`Column` row for URL list mode — the fix for the recurring `RenderBox was not laid out` crash.

### Why the crash happened

`UrlPreviewTile` contains an internal `Stack` with `Positioned` children and `Expanded` in its non-compact path. When placed inside a `ListView`/`SliverList` row (which supplies unbounded height), the stack cannot resolve its size → `RenderBox hasSize == false` assertion.

`UrlListRowTile` uses:
- `Row` (bounded width from parent, intrinsic height from children)
- `Expanded` only in the horizontal axis (title/metadata column)
- `Wrap` for tags (wraps, never overflows vertically)

This guarantees finite height in every context without needing bounded vertical constraints from the parent.

### Rendering safety rules

| Widget | Safe in `SliverList`? | Safe in `SliverGrid`? |
|---|---|---|
| `UrlListRowTile` | ✅ bounded height by design | ✅ |
| `UrlPreviewTile` | ❌ use `compact:true` or avoid | ✅ with `childAspectRatio` |
| `UrlIconLinkTile` | ⚠️ (test case-by-case) | ✅ with `childAspectRatio` |
| `CollectionListTile` | ✅ | ✅ |
| `CollectionCard` | ✅ | ✅ with `childAspectRatio` |

---

## 8. Search Toolbar — Draft vs Committed Query

Matching `items_list_screen.dart` behavior exactly:

```
onChanged  → gn.updateXxxSearchDraft(value)   [local only, no network]
onFieldSubmitted / search icon
           → gn.submitXxxSearch(value)         [commits query, adds to history]
           → [links only] linksNotifier.searchAndReset()
clear icon → gn.clearXxxSearch()               [resets draft + committed]
           → [links only] linksNotifier.reset()
```

---

## 9. DB Index Advisory

Apply in Supabase SQL editor if not already present:

```sql
-- Enable pg_trgm for trigram similarity
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- GIN indexes for ilike search on title and url
CREATE INDEX IF NOT EXISTS lv_urls_title_trgm_idx
  ON lv_urls USING gin(title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS lv_urls_url_trgm_idx
  ON lv_urls USING gin(url gin_trgm_ops);

-- Composite index for common filter pattern (owner + deleted + sort)
CREATE INDEX IF NOT EXISTS lv_urls_owner_deleted_created_idx
  ON lv_urls (owner_id, is_deleted, created_at DESC);
```

> **Why:** `ilike` without `trgm` is O(n) per page fetch. Even with `LIMIT 20`, Postgres must scan all rows to find the first 20 matches. A GIN trgm index reduces this to a bitmap scan, effectively O(log n + k) where k = matching rows.

---

## 10. Key Files Changed (Sprint 9–10 in full)

| File | Change |
|---|---|
| `lib/features/items/presentation/widgets/url_list_row_tile.dart` | **NEW** — shared list row widget |
| `lib/features/collections/presentation/screens/search_collections_screen.dart` | **REWRITE** — NestedScrollView/sliver hub parity |
| `lib/features/collections/presentation/providers/search/global_search_state.dart` | `collectionsGridView:bool` → `collectionsViewMode:UrlViewMode` |
| `lib/features/collections/presentation/providers/search/global_search_notifier.dart` | `setCollectionsGridView` → `setCollectionsViewMode` |
| `lib/features/collections/presentation/screens/search_filters_collections_screen.dart` | Added VIEW (list/cards/icons) segment control |
| `lib/features/collections/presentation/providers/search/global_search_links_notifier.dart` | **NEW** — paginated links notifier (page size 20) |
| `lib/features/collections/presentation/providers/search/global_search_query_providers.dart` | Removed raw/filtered links providers; kept collections + mode |
| `lib/features/items/domain/models/url_items_query.dart` | `collectionId` made nullable |
| `lib/features/items/data/repositories/items_repository_impl.dart` | ObjectBox global query (no collectionUid filter when null) |
| `lib/features/items/data/repositories/supabase_items_repository.dart` | Supabase global query (owner_id always; collection_id optional) |
| `lib/features/items/presentation/screens/items_list_screen.dart` | `_buildListItem` delegates to `UrlListRowTile` |
