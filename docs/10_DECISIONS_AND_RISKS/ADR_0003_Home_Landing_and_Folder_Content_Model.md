# ADR-0003: Home Landing Route and Folder Content Model

Version: 1.0  
Last Updated: 2026-03-24  
Status: Approved  
Owner: Product + Engineering  
Depends On: [Home_and_Collections_UX_Architecture.md](../03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md), [Technical_Architecture.md](../03_ARCHITECTURE/Technical_Architecture.md)

---

## Status

Approved

## Date

2026-03-24

## Context

LinkVault needs a **global Home** distinct from **nested folder browsing**, plus clarity on how **child collections** and **URLs** cohabit in one parent folder. The architecture doc listed open product decisions that blocked implementation alignment.

Constraints:

- Minimize route churn for existing auth redirects (`/` already used post-onboarding).
- Preserve nested `parent_id` model and existing screens where possible during transition.
- Pinned and recent surfaces must map to explicit schema fields (`is_pinned`, `last_accessed_at`, etc.).

## Decision

### D1 — Post-auth landing and Home URL

1. **`/` is the Home dashboard** after authentication (no separate `/home` path required for v1).
2. **Root-level folders** are reached from Home via an explicit **“Library”** (or equivalent) control that navigates to **`/collections`** (or the existing shell route that shows root `CollectionsListScreen` with `parent_id == null`).
3. Deep links and notifications may target `/collections`, `/collections/:id`, or item routes directly; they do not need to pass through Home.

**Rationale:** One canonical landing URL avoids duplicate “home” concepts and matches current `GoRouter` redirect behavior. A future ADR may introduce `/home` only if product requires distinct marketing landing vs app shell.

### D2 — Folder content: children vs URLs (interim vs target)

1. **Target architecture:** a **unified folder hub** for each `collection_id` — one screen (or one scroll) with **grouped sections**: **Folders** (child collections) then **Links** (URLs), respecting `child_collections_layout` and `items_layout` when implemented.
2. **Interim (until hub ships):** keep the **split** pattern: **child folders** on `CollectionsListScreen` (filtered by `parent_id`), **URLs** on `ItemsListScreen` (`/collections/:id`). Product must ensure navigation affordances (e.g. from folder into links) stay obvious.

**Rationale:** Unified hub reduces context switching; split matches current codebase and unblocks Home work in parallel.

### D3 — Recent lists: caps and grouping

1. **Cap:** show at most **15** items per Home section for **recent collections** and **recent URLs** (separate caps).
2. **Ordering:** strictly by recency field (`last_accessed_at` preferred; fallback `updated_at` where access is not tracked).
3. **Day grouping:** **not required for v1**; flat lists. Optional “Today / Earlier” grouping may be added later without changing this ADR’s cap policy.

### D4 — Where pinned URLs appear

1. **Home:** always show a **Pinned URLs** section when any exist (subject to global query implementation).
2. **Inside a folder:** show **pinned URLs for that `collection_id` first** in the URL list (existing sort behavior); optionally a **compact horizontal strip** above the main link list if design specifies — not Home-only.

**Rationale:** Pin is a per-collection signal; users expect pins to remain visible in context, not only globally.

## Alternatives Considered

### Landing: introduce `/home` and keep `/` as library

- Pros: explicit naming in URL bar.
- Cons: extra redirect logic; duplicate “first screen” mental model.
- **Rejected for v1.**

### Folder content: tabs-only (no single-scroll target)

- Pros: clear separation.
- Cons: extra tap to see half of folder content; worse for mixed small folders.
- **Rejected as long-term target;** acceptable as interim variant inside unified hub if design requires.

### Recent: unlimited lists

- Cons: performance and scanability on Home.
- **Rejected.**

### Pinned URLs: Home only

- Cons: breaks user expectation inside deep folders.
- **Rejected.**

## Consequences

Positive:

- Implementers can route **`/` → Home** and **`/collections` → root library** without ambiguity.
- Folder hub has a clear **north star** while **split screens** remain valid short-term.
- Home sections have **bounded** row counts for UX and query cost.

Negative:

- **Two navigation patterns** (split vs unified) until Phase 3 hub — docs and QA must track both.
- **Recent URLs across library** may require aggregation work (client filter vs RPC) per [Home_and_Collections_UX_Architecture.md](../03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md).

## Implementation Notes

- **`/` → `HomeDashboardScreen` and `/collections` → root `CollectionsListScreen`** are implemented in `app_router.dart` (see [UI_UX_Flow_Document.md](../02_DESIGN/UI_UX_Flow_Document.md)).
- Align PRD user stories and design visual contract with this ADR.
- When unified hub ships, deprecate redundant entry points only if user testing confirms.

## Verification

- User can open app → see Home → reach root library in ≤2 taps.
- Pinned collection order matches `is_pinned` + `position` rules.
- Recent sections respect 15-cap and defined sort field.
- Folder with both children and URLs: user can reach both without dead ends (interim: via explicit navigation).

## Rollback Strategy

If Home regresses retention in testing, revert `/` to previous shell **without** removing schema fields; file a superseding ADR for landing policy.

## Related Documents

- [Home_and_Collections_UX_Architecture.md](../03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md)
- [Home_Collections_Visual_Contract.md](../02_DESIGN/Home_Collections_Visual_Contract.md)
- [Product_Requirements_Document.md](../01_PRODUCT/Product_Requirements_Document.md) (delta 1.2)

## Supersedes / Superseded By

- None.
