# Sprint 5-6 Collections Docs

This folder contains sprint-specific architecture, implementation, and testing docs for LinkVault Sprint 5-6 collections work.

**Product source of truth:** [Master Project Plan — Sprint 5-6](../../00_PROJECT_OVERVIEW/Master_Project_Plan.md) (Weeks 5–6: nested folders, breadcrumbs, CRUD, reorder, pin/archive, repository selector).

## Documents

| Document | Purpose |
| -------- | ------- |
| [Sprint_5_6_Collections_Architecture.md](Sprint_5_6_Collections_Architecture.md) | Domain contract, sort order, state machine, fractional indexing, safety rules |
| [Sprint_5_6_Collections_UI_Flows.md](Sprint_5_6_Collections_UI_Flows.md) | Screens, navigation, create/edit/delete/reorder UX |
| [Sprint_5_6_Collections_Schema_and_RLS_Checklist.md](Sprint_5_6_Collections_Schema_and_RLS_Checklist.md) | **`lv_*` Supabase operator checklist:** migrations **001–010**, columns, triggers, RLS, smoke SQL (start here for deploy) |
| [Sprint_5_6_Collections_Test_Plan.md](Sprint_5_6_Collections_Test_Plan.md) | Unit, widget, manual, and schema verification |

## Scope

- **Week 5:** nested collections foundation, create/list/navigate, breadcrumb, mixed child collections + URLs.
- **Week 6:** edit/delete/reorder, pin/archive, schema/trigger/RLS hardening, verification.

## Key constraints

- **Guest:** local-first (ObjectBox). **Free account:** `lv_*` Supabase with **quotas** (per [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md)). **Premium:** `lv_*` with higher limits.
- All cloud flows use strict RLS ownership guarantees.
- **Category / icon:** Sprint 5-6 uses a **catalog-only** icon stored in schema (`icon_name` in Postgres; app domain may expose as “icon key” or emoji string). No arbitrary web icon URLs or user file uploads in this sprint.

## Implementation backlog (status)

Done in app (2026-03): **fractional reorder** (list mode), **`connectivity_plus` → `isOnlineProvider`**, **parent cycle validation** + **edit parent picker excludes subtree**, **option A archive hiding** on home (archived remain **searchable** for edit/unarchive), shared **sibling sort** (archived / pinned / position / `updated_at`) in local + Supabase streams.

Remaining / later:

1. **ObjectBox:** After changing any `@Entity()` model, run `dart run build_runner build --delete-conflicting-outputs` (regenerates `lib/objectbox.g.dart` + `lib/objectbox-model.json`). Commit both files. Existing installs pick up new fields via ObjectBox light migrations; do a clean-install smoke test after additive changes.
2. **Grid reorder:** Reorder is list-only; switch to grid and use list to reorder, or add dedicated “Edit order” later.
3. **Server-side quotas:** Migration `010_lv_free_tier_quotas.sql` enforces caps on **`lv_collections`** / **`lv_urls`**. Ensure the Flutter data layer uses those tables (not a legacy `items` name) so URL inserts hit the same triggers. Keep `lv_user_profiles.is_premium` in sync with RevenueCat for accurate bypass.
4. **Offline write queue:** Full cache+queue for authenticated free tier per state machine v2 (sync sprint).

## Related repo paths (reference)

- Flutter collections feature: [c:/Users/LENOVO/development/saas/link_vault/lib/features/collections](c:/Users/LENOVO/development/saas/link_vault/lib/features/collections)
- Supabase migrations: [c:/Users/LENOVO/development/saas/link_vault/supabase/migrations](c:/Users/LENOVO/development/saas/link_vault/supabase/migrations)
- RLS smoke template: [c:/Users/LENOVO/development/saas/link_vault/supabase/sql/rls_smoke_test.sql](c:/Users/LENOVO/development/saas/link_vault/supabase/sql/rls_smoke_test.sql)
