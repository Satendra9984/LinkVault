# Collections extended schema and UX fields

**Purpose:** Document columns added for richer collection UX and for upcoming URL (link) screens. **Migrations:** [`012_lv_collections_ux_and_url_defaults.sql`](../../../supabase/migrations/012_lv_collections_ux_and_url_defaults.sql), [`013_lv_collections_layout_modes.sql`](../../../supabase/migrations/013_lv_collections_layout_modes.sql).

**Apply after** `001`–`011`, then **`012`** then **`013`** in order. Update [Sprint_5_6_Collections_Schema_and_RLS_Checklist.md](Sprint_5_6_Collections_Schema_and_RLS_Checklist.md) operator notes when promoting to a new environment.

---

## Column reference

| Column | Type | Default | Role |
|--------|------|---------|------|
| `description` | `TEXT` | null | Optional subtitle, search context, notes. |
| `last_accessed_at` | `TIMESTAMPTZ` | null | “Recent collections,” resume-style ordering. |
| `items_layout` | `TEXT` | `'list'` | Layout for **saved links**: `list` \| `grid` \| `compact_grid`. |
| `child_collections_layout` | `TEXT` | `'list'` | Layout for **nested folder** tiles: `list` \| `grid` \| `compact_grid`. |
| `items_sort_default` | `TEXT` | `'manual'` | Default sort: `manual` \| `added_desc` \| `title_asc` \| `last_opened_desc`. |
| `icon_json` | `JSONB` | null | Rich icon payload; when null, client uses `icon_name` + `color_hex`. |
| `open_links_in` | `TEXT` | `'in_app'` | `in_app` \| `external_browser`. |
| `show_link_previews` | `BOOLEAN` | `TRUE` | Thumbnails / preview cards for URLs. |

**CHECK constraints** enforce allowed enum-like strings (see migration).

---

## Client constants

Dart helpers live in [`lib/features/collections/domain/collection_display_defaults.dart`](../../../lib/features/collections/domain/collection_display_defaults.dart): `CollectionLayoutMode` (shared by URL + folder layouts), `CollectionItemsSortDefault`, `CollectionOpenLinksIn`.

---

## `icon_json` shape (recommended)

Aligned with legacy `lib_old` `CollectionIcon`:

```json
{
  "type": "emoji",
  "value": "📁",
  "color": "#6B7280"
}
```

- `type`: `emoji` | `icon` | `image` (extend as needed).
- `value`: emoji character, icon key, or image URL when `type` is `image`.
- `color`: tint / accent for the icon where applicable.

When `icon_json` is null, the app should render using **`icon_name`** and **`color_hex`** (current production path).

---

## `last_accessed_at` — when to update

The app calls **`ICollectionsRepository.recordCollectionAccess(id)`** when:

- The user opens **Edit list** ([`EditCollectionScreen`](../../../lib/features/collections/presentation/screens/edit_collection_screen.dart)), and  
- The user opens the **items / URL list** for a collection ([`ItemsListScreen`](../../../lib/features/items/presentation/screens/items_list_screen.dart)).

You can extend this (e.g. when opening a single URL) without rewriting unrelated fields.

---

## What stays on `lv_urls` (not duplicated here)

Per-link data belongs on the URL row: notes, tags, per-link pin, `position`, `last_accessed_at`, `click_count`, preview URLs, etc. Collection columns above are **defaults** and **folder-level** behavior for everything inside.

---

## RLS

No change: existing `lv_collections` policies still apply; new columns are readable/writable under the same `owner_id` rules.

---

## Import / backup

When extending export/import JSON, include optional keys: `description`, `lastAccessedAt`, `itemsLayout`, `itemsSortDefault`, `iconJson`, `openLinksIn`, `showLinkPreviews`. Older backups without these keys should default per migration defaults and Dart `normalize()` helpers.

---

## Related

- App navigation and Home vs nested UX: [`docs/03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md`](../../03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md)
- Gap analysis vs `lib_old`: [`lib_old/src/urls_store/domain/entities/collection_entity.dart`](../../../lib_old/src/urls_store/domain/entities/collection_entity.dart)
- Base table: [`supabase/migrations/004_lv_collections.sql`](../../../supabase/migrations/004_lv_collections.sql)
