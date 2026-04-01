# Sprint 7–8: Full-screen filters refactor

## Goal

Replace modal bottom sheets for **Links (URLs)** and **Folders** hub filters with dedicated full-screen routes so layout, keyboard, and progressive disclosure match section **8.8a** of `docs/02_DESIGN/LinkVault_UI_UX_Specification.md` (Sort By behavior unchanged).

## Architecture

- **State**: Single source of truth remains `ItemsHubUiState` / `ItemsHubUiNotifier` (per `collectionId`) and `ItemsState` / items notifier for URL list options.
- **Navigation**: `go_router` routes:
  - `/collections/:id/filters/urls` → `UrlsFiltersScreen`
  - `/collections/:id/filters/folders` → `FoldersFiltersScreen`
- **Persistence**: Same as hub: URL filter apply persists collection display defaults when a `Collection` is available; folder filter apply persists `childCollectionsLayout` when saving layout.

## UI contract

### URLs (`UrlsFiltersScreen`)

- App bar: title **Filter & sort**, **Reset** (text), back closes without applying unless user taps Apply (draft state is local until Apply).
- Sections: VIEW, SORT BY, STATUS, MORE, domain field, DATE RANGE (parity with previous sheet).
- Footer: full-width **Apply** with safe area / keyboard inset.

### Folders (`FoldersFiltersScreen`)

- App bar: title **Folders**, **Reset**, back.
- **Categories**: trigger opens a **bottom sheet** (`FolderFilterCategoryPicker`) with custom field, filter field, and a **grid of presets not yet selected**; **Done** merges selection. Main screen shows **selected removable chips** and an outline button summarizing count.
- **Selected categories**: always-visible block — empty state copy explains “all categories”; selected shown as removable chips.
- Layout, Sort by (unchanged control), archived toggle, date range — same behavior as before.
- Footer: full-width **Apply**.

### Collection actions sheet

- **View settings** and **Share** removed app-wide until product reintroduces them.

## Acceptance

- Hub toolbar opens full-screen filters instead of bottom sheets.
- Folder category filtering uses one field + Add; selections visible and removable.
- Apply updates hub state and returns; Reset restores defaults locally.
- `dart analyze` clean on touched Dart files.

## Manual QA (focused)

- Open URLs filters from Links toolbar; Apply/Reset; badge on filter icon when non-default.
- Open Folders filters from Folders toolbar; add preset + custom category; verify list filters by `Collection.category` (exact match).
- Non-root collection actions sheet: no View settings / Share.
- Root collection actions: only Add subfolder + Edit (existing behavior).
