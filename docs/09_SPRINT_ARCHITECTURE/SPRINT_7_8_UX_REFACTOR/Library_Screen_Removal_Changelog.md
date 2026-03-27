# Library Screen Removal — Change Log

**Sprint:** 7–8 UX Refactor  
**Date:** March 2026  
**Status:** Specification approved — pending implementation  
**Spec reference:** `docs/02_DESIGN/LinkVault_UI_UX_Specification.md` v2.1, Section 7 and Section 8

**Implementation note (real library root):** The tab route `/collections` uses `CollectionsBranchRootScreen` → `ItemsListScreen` with the persisted **library root** collection id (exactly one `parent_id IS NULL` row per user). Legacy multi–top-level rows are migrated under a new default **Library** folder; legacy item `collection_id` values `root` / `ROOT` are reassigned to that id. `collections_list_screen.dart` is kept **unreferenced** as an emergency rollback artifact until QA sign-off.

---

## 1. Motivation

### 1.1 The Problem with Two Screens

The original architecture had two collection-browsing screens:

1. **LibraryScreen** (`CollectionsListScreen`, route `/collections`) — showed all root collections in a flat grid or list. No URL content, no tabs, limited filter options.
2. **CollectionHubScreen** (`ItemsListScreen`, route `/collections/:id`) — showed one collection's child folders and URLs in a rich two-tab layout with filters, sorts, multiple view modes, and contextual FABs.

This split created several UX problems:
- Users had to navigate **Home → Library → Collection Hub** to reach any content (three taps minimum).
- The Library had fewer features than the Hub (no URL tab, simpler filters, no FAB with extended label).
- Root-level collections felt "second class" — they could not be searched, date-filtered, or viewed in compact mode from the Library.
- The Home tab already navigated directly to the Hub bypassing Library — so Library's role as a "gateway" was already broken in practice.

### 1.2 The Solution

Replace the Library screen with the **Unified Collection Hub operating at root level**. The Collections tab (formerly "Library") now loads `CollectionHubScreen` directly, using a **root context** (no `collectionId` / `parent_id IS NULL` query). All root-level collections appear in the Folders tab; all uncategorized URLs appear in the Links tab.

**Benefits:**
- Consistent UX — the same screen handles all levels of the collection tree.
- All Hub features (compact layout, date filters, category filters, context actions sheet, scroll-aware FAB) are available at root level.
- Navigation simplified to two taps: Home → tap collection chip → Hub.
- Removes ~400 lines of dead code (`CollectionsListScreen`).

---

## 2. What Is Removed

### 2.1 Files

| File | Action |
|---|---|
| `lib/features/collections/presentation/screens/collections_list_screen.dart` | Delete |

### 2.2 Routes

| Route | Old Behavior | New Behavior |
|---|---|---|
| `/collections` (tab) | Loads `CollectionsListScreen` | Loads `ItemsListScreen` in root mode |
| `/collections/:id` | Unchanged | Unchanged |

### 2.3 Providers

| Provider | Action |
|---|---|
| `homeCollectionsProvider` | Can be repurposed or removed; root Hub uses the standard `collectionsListProvider` filtered by `parentId == null` |
| `collectionsViewModeProvider` | Merge into the Hub's existing layout state if still needed |

---

## 3. What Replaces It

### 3.1 Root-Mode ItemsListScreen

`ItemsListScreen` receives a **sentinel root ID** when loaded as the Collections tab. The sentinel value (e.g., the string `"__root__"` or the authenticated user's UUID) signals the screen and its providers to query root-level data instead of a specific collection.

**Sentinel ID approach (recommended):** Use `"__root__"` as the `collectionId`. Handle this in the providers:

```dart
// In collectionsListProvider filter or a new rootCollectionsProvider:
final rootCollections = allCollections
    .where((c) => c.parentId == null && !c.isDeleted && !c.isArchived)
    .toList();

// In itemsNotifierProvider, when collectionId == '__root__':
// → Query items with collection_id IS NULL (uncategorized URLs)
// → Or skip Links tab at root level (product decision)
```

### 3.2 Navigation Shell

The bottom `NavigationBar` item currently pointing to `/collections` (Library tab) is updated to:
- Label: "Collections" (was "Library")
- Route: `/collections` → renders `ItemsListScreen(collectionId: '__root__')`
- No back button at root (it is a tab, not a pushed route)
- No breadcrumb at root (title = "Collections")

### 3.3 Breadcrumb Logic (ItemsListScreen)

Add a guard in `_buildHubHeaderContent`:

```dart
// Root mode: no breadcrumb, just the title
if (widget.collectionId == '__root__') {
  return Text('Collections', style: display_md);
}
// Child mode: render ancestors breadcrumb as before
```

---

## 4. Required Code Changes

### 4.1 Router (`lib/core/router/app_router.dart`)

```dart
// Before:
GoRoute(
  path: '/collections',
  builder: (context, state) => const CollectionsListScreen(),
  routes: [ ... child routes ... ],
),

// After:
GoRoute(
  path: '/collections',
  builder: (context, state) => const ItemsListScreen(
    collectionId: '__root__',
    collectionName: 'Collections',
  ),
  routes: [
    GoRoute(
      path: ':id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final collectionName = state.extra as String?;
        return ItemsListScreen(
          collectionId: id,
          collectionName: collectionName,
        );
      },
      routes: [ ... existing child routes unchanged ... ],
    ),
  ],
),
```

Remove the `import` of `CollectionsListScreen` from the router.

### 4.2 ItemsListScreen (`lib/features/items/presentation/screens/items_list_screen.dart`)

Add root-mode constants and guards:

```dart
static const String rootCollectionId = '__root__';

bool get _isRootMode => widget.collectionId == rootCollectionId;
```

Guards to add:
- Back button: `leading: _isRootMode ? null : IconButton(Icons.arrow_back, ...)` — no back button at tab root.
- Breadcrumb: skip `_buildHubHeaderContent` ancestors section when `_isRootMode`.
- Title: show `'Collections'` when `_isRootMode` instead of collection name.

### 4.3 Collections Provider (query change)

When `collectionId == '__root__'`, the child collections query must return root collections:

```dart
// collectionsListProvider already fetches all; filter client-side:
final childCollections = _isRootMode
    ? allCollections.where((c) => c.parentId == null && !c.isDeleted).toList()
    : allCollections.where((c) => c.parentId == widget.collectionId && !c.isDeleted).toList();
```

### 4.4 Items Provider (Links tab at root)

**Product decision required:** Should the Links tab at root show:
- (a) Uncategorized URLs (items with `collection_id` pointing to a virtual root) — requires schema support
- (b) No Links tab at root (hide the Links tab entirely in root mode) — simpler, no schema change
- (c) All URLs across all collections (a global view) — powerful but may be overwhelming

**Recommended for v1:** Option (b) — hide the Links tab at root mode, show only Folders tab. Add the Links tab at root in a future sprint when global URL search is implemented.

```dart
// In DefaultTabController:
tabCount: _isRootMode ? 1 : 2,
// Conditionally render only Folders tab when isRootMode
```

### 4.5 Bottom Navigation Bar

Update the navigation destination label in the shell route / `ScaffoldWithNav`:

```dart
NavigationDestination(
  icon: Icon(Icons.folder_outlined),
  label: 'Collections',  // was 'Library'
  selectedIcon: Icon(Icons.folder),
),
```

### 4.6 Home Dashboard (`lib/features/home/presentation/screens/home_dashboard_screen.dart`)

The "See all" / "All →" text button in the Recent Collections section currently pushes `/collections`. Update target if needed — `/collections` will now load the root Hub directly, which is the correct destination.

---

## 5. Migration Notes

### 5.1 Database

**No database changes required.** Root collections continue to be identified by `parent_id IS NULL`. The sentinel `'__root__'` ID is a frontend-only routing construct; it is never persisted to Supabase.

### 5.2 Deep Links

Existing deep links of the form `/collections/:id` are **unaffected**. Only `/collections` (the tab root, with no `:id`) changes behavior.

### 5.3 Existing Data

All user collections and URLs are unchanged. The Library-to-Hub migration is a pure UI/navigation change with zero data migration.

---

## 6. Testing Checklist

- [ ] Collections tab loads root collections in Folders tab
- [ ] No back button visible on Collections tab
- [ ] No breadcrumb shown at root level (title = "Collections")
- [ ] Tapping a root collection opens the child Hub with correct breadcrumb (`Collections › Flutter`)
- [ ] Back button in child Hub returns to parent correctly (not to Library)
- [ ] Search within root Folders tab filters root collections
- [ ] Compact/Grid/List layout toggle works at root level
- [ ] Category filter in Folders tab sheet correctly filters root collections
- [ ] FAB "New folder" at root creates a root collection (no parentId)
- [ ] Deep link `/collections/some-uuid` still works correctly
- [ ] `CollectionsListScreen` is not referenced anywhere in the codebase after removal

---

## 7. Rollback Plan

If root-mode Hub causes regressions, re-add `CollectionsListScreen` route at `/collections` and revert the router change. The Hub screen itself is unchanged — rollback is a single router line change.
