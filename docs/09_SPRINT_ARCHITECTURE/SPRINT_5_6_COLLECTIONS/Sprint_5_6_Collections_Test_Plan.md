# Sprint 5-6 Collections Test Plan

## Traceability

Map checks to master plan verification (Sprint 5-6 in [Master_Project_Plan.md](../../00_PROJECT_OVERVIEW/Master_Project_Plan.md)): create/edit/delete root + nested, breadcrumbs, reorder persistence, pin/archive.

Suggested test IDs (for backlog / QA sheets):

| ID | Area | Description |
| --- | ---- | ----------- |
| S56-U-01 | Unit | Sort: archived last within scope; pinned before unpinned |
| S56-U-02 | Unit | `validateParent(parentId, nodeId, ancestorChain)` rejects self + descendant |
| S56-U-03 | Unit | Fractional index: between prev/next; rebalance when gap collapses |
| S56-R-01 | Local repo | Create child with `parent_id`; query siblings by parent |
| S56-R-02 | Local repo | Delete parent removes children + items (or matches soft-delete policy) |
| S56-R-03 | Supabase | Insert/update `lv_collections` uses `title`, `icon_name`, `color_hex` |
| S56-R-04 | Supabase | Reparent updates visible in stream/select |
| S56-W-01 | Widget | Breadcrumb shows Home > … > current |
| S56-W-02 | Widget | Create form: parent query param applied |
| S56-M-01 | Manual | Drag reorder survives cold restart |
| S56-M-02 | Manual | Pin + archive ordering matches architecture doc |
| S56-SQL-01 | DB | RLS smoke script passes for two users |

## Test matrix

### Unit tests

- **Collection sorting** (`S56-U-01`):
  - Same `parent_id` scope only
  - `is_archived` then `is_pinned` then `position` then `updated_at` tie-break
- **Parent validation** (`S56-U-02`):
  - `parent_id == id` → invalid
  - parent is descendant of `id` → invalid
  - valid branch attachment → ok
- **Fractional indexing** (`S56-U-03`):
  - Move to start / middle / end of sibling list
  - Collapsed float gap triggers rebalance (optional threshold test)

### Repository tests

- **Local** (`S56-R-01`, `S56-R-02`):
  - Nested CRUD; `watch` or query filters by `parent_id`
  - Delete cascade vs soft-delete per product decision
  - `updateCollectionPosition` after reorder
- **Supabase** (`S56-R-03`, `S56-R-04`):
  - Table `lv_collections` / `lv_urls` only
  - Mapper round-trip: DB row → entity → JSON for update
  - RLS: unauthenticated calls fail (integration with test project or mocked client)

### Widget tests

- Root: grid/list renders; only root `parent_id == null` if that’s the screen contract.
- Nested: child strip + items list; breadcrumb widget (`S56-W-01`).
- Create: optional `parent` route/query (`S56-W-02`).
- Edit: pin/archive toggles visible and call update use case.
- Delete: dialog text mentions nested folders + URLs.
- Reorder: `onReorder` fires and repository receives new positions (mock repo).

### Integration / manual tests

- Deep tree (≥4 levels): navigate down and up via breadcrumb.
- Create child from nested screen; verify appears under correct parent only.
- Move child to another parent; counts and lists update.
- Delete intermediate node; verify children inaccessible and data removed per policy.
- **Premium path:** migrate flag + online + subscription → writes hit Supabase.
- **Offline / not online:** selector uses local; user can still organize locally without data loss (verify current implementation matches [Architecture](Sprint_5_6_Collections_Architecture.md)).
- **RLS / SQL:** run [rls_smoke_test.sql](c:/Users/LENOVO/development/saas/link_vault/supabase/sql/rls_smoke_test.sql) scenarios with two JWT subjects.

### Regression (non-collections)

- Auth/profile flows still reach home after Sprint 5-6 changes.
- Router contract regression:
  - Authed navigation: `/` shows `HomeDashboardScreen`; `/collections` shows root `CollectionsListScreen` (Library).
  - Guest mode: deep links to `/collections` still resolve, and Home remains reachable via auth flow completion.
- Items CRUD inside nested `collection_id` unchanged for happy path names

## Exit criteria

- All **S56-*-01** through critical path IDs executed; failures documented or fixed.
- Schema checklist signed off for dev/staging (`004`–`006`, `009` applied).
- No P0 RLS leaks on collection or URL move.
- No cycle saves possible from UI without server error.
- Documentation in this folder matches implemented behavior (update docs if product chooses archive visibility A vs B).
