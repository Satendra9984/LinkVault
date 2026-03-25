# Sprint 5-6 Collections Schema and RLS Checklist

**Use this doc when applying LinkVault SQL to your Supabase project** (dev → staging → prod). Migrations live in the repo; they are not auto-applied until you run them.

**Operator quick tasks:** (1) Apply **`001` → `013`** in order. (2) Run smoke scenarios in [rls_smoke_test.sql](c:/Users/LENOVO/development/saas/link_vault/supabase/sql/rls_smoke_test.sql) with real user UUIDs. (3) Verify **010** quota behavior for a non-premium test user (150 collections / 5000 URLs) and premium bypass via `lv_user_profiles`. (4) Plan a job or webhook to keep **`is_premium`** aligned with RevenueCat.

---

Primary migration files under [c:/Users/LENOVO/development/saas/link_vault/supabase/migrations](c:/Users/LENOVO/development/saas/link_vault/supabase/migrations):

- `004_lv_collections.sql` — table + base RLS + indexes
- `012_lv_collections_ux_and_url_defaults.sql` — **description**, **last_accessed_at**, **items_layout**, **items_sort_default**, **icon_json**, **open_links_in**, **show_link_previews** (see [Collections_Extended_Schema_and_UX_Fields.md](Collections_Extended_Schema_and_UX_Fields.md))
- `005_lv_urls.sql` — table + base RLS + indexes
- `006_triggers.sql` — `updated_at`, initial `url_count` trigger
- `009_sprint56_collections_rls_and_counts_hardening.sql` — **url_count move + soft-delete**, **child_count**, **stricter `lv_urls` update WITH CHECK**
- `010_lv_free_tier_quotas.sql` — **BEFORE INSERT/UPDATE** triggers: non-premium caps on `lv_collections` (150) and `lv_urls` (5000); premium bypass via `lv_user_profiles`

## Tables and columns

### `public.lv_collections` (004)

Verify columns exist as deployed:

- `id`, `owner_id`, `parent_id`
- `title`, `icon_name`, `color_hex`, `category`
- `is_pinned`, `is_archived`, `position` (`FLOAT8`)
- `url_count`, `child_count`
- `is_deleted`, `deleted_at`, `created_at`, `updated_at`
- After **012**: `description`, `last_accessed_at`, `items_layout`, `items_sort_default`, `icon_json`, `open_links_in`, `show_link_previews`
- After **013**: `items_layout` allows `compact_grid`; `child_collections_layout`

Note: There is no legacy `icon` / `color` column — use **`icon_name`** and **`color_hex`**; optional rich payload in **`icon_json`**.

### `public.lv_urls` (005)

- `id`, `owner_id`, `collection_id`, `url`
- Metadata: `title`, `description`, `thumbnail_url`, `favicon_url`, `dominant_color`, `tags`, `annotation`, `site_name`, `canonical_url`, `content_type`, `published_at`, `status`
- `is_pinned`, `click_count`, `position`, `is_deleted`, `deleted_at`, `last_accessed_at`, timestamps

## Triggers / functions

| Item | Location | Expected behavior |
| ---- | -------- | ----------------- |
| `updated_at` | 006 | Touch `updated_at` on row update |
| `url_count` | 006 + **009** | Increment/decrement on insert/delete; handle **soft-delete toggles**; handle **`collection_id` change** (move between collections) |
| `child_count` | **009** | Increment/decrement on child insert/delete; **`parent_id` moves**; soft-delete toggles as implemented |

After deploy, spot-check: moving one URL between collections adjusts **both** collections’ `url_count`; reparenting a collection adjusts **both** parents’ `child_count`.

## RLS

### `lv_collections`

- Policies `lv_collections_*_own` (004): `auth.uid() = owner_id` on select/insert/update/delete.
- **Cross-owner parent:** inserting/updating a row with `parent_id` pointing at another user’s row should fail FK + RLS visibility; confirm in smoke tests.

### `lv_urls`

- Insert: must require ownership and that `collection_id` exists under same user (check 005 `WITH CHECK`).
- **Update (009):** `USING (auth.uid() = owner_id)` and `WITH CHECK` must include **destination collection ownership** so a user cannot reassign `collection_id` to another user’s folder.

## Indexes

**Deployed (004/005):**

- `idx_lv_collections_owner_parent` on `(owner_id, parent_id, is_deleted, is_archived)`
- `idx_lv_collections_owner_updated` on `(owner_id, updated_at DESC)`
- `idx_lv_urls_collection_pos` on `(collection_id, is_deleted, is_pinned DESC, position)`
- `idx_lv_urls_owner_updated`, `idx_lv_urls_search` (GIN)

**Optional hardening (if slow sorts at scale):** composite index aligned with sort order, e.g. collections by `(owner_id, parent_id, is_deleted, is_archived, is_pinned DESC, position)` — add only if query plans show need.

## Smoke test checklist

Run in dev after migrations **001..010** (see [rls_smoke_test.sql](c:/Users/LENOVO/development/saas/link_vault/supabase/sql/rls_smoke_test.sql)):

- User A sees only own `lv_collections` / `lv_urls`; User B sees none of A’s rows.
- User A **cannot** update a URL’s `collection_id` to a collection owned by B (expect RLS error).
- User A **cannot** set `parent_id` on a collection to B’s collection id (expect failure).
- Reparent collection: old and new parent `child_count` correct.
- Move URL between collections: old and new `url_count` correct.
- Soft-delete URL: `url_count` on collection decreases; restore increases.
