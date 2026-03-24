# LinkVault — Monetization Model: Free Cloud, Quotas, Day Pass, Unit Economics

Version: 1.0  
Last Updated: 2026-03-24  
Status: Active  
Owner: Product + Engineering  
Depends On: [Master_Project_Plan.md](../00_PROJECT_OVERVIEW/Master_Project_Plan.md), [Data_Persistence_State_Machine.md](../04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md), [Premium_Feature_Gating_Matrix.md](../01_PRODUCT/Premium_Feature_Gating_Matrix.md)  
Blocks: Sprint 11–12 monetization + sync implementation; repository selector refactor  
Related: [Monetization_Strategy_RevenueCat_Guide.md](Monetization_Strategy_RevenueCat_Guide.md)

---

## Purpose

Document the **canonical monetization and persistence model** for LinkVault after the strategic shift:

- **Existing user base** is largely **ad-supported (Ad Day Pass)** — that structure is retained.
- **Signed-in (authenticated) users** use **Supabase (`lv_*`) as the system of record**, similar to premium, but with **enforced quotas** and **Day Pass** gating — **not** “local-only until premium.”
- **Guest (no account)** remains **local-only (ObjectBox)** for cost control and abuse reduction.
- **Premium** removes ads and raises (or removes) limits; full sync and positioning remain the paid value proposition.

This doc also captures **unit economics framing** (illustrative formulas and sensitivity — not financial promises).

---

## Tier Summary

| Tier | Account | Product data authority | Ads | Limits |
|------|---------|------------------------|-----|--------|
| **Guest** | No | ObjectBox only | Day Pass (app access) | Implicit device-local ceiling only |
| **Free (authenticated)** | Yes | **Supabase `lv_*`** (+ local cache for offline UX) | Day Pass | **Hard quotas** (collections total, URLs total; tune per launch) |
| **Premium** | Yes | Supabase `lv_*` (+ cache/queue) | None | **High / “unlimited”** per product copy |

### Product copy (high level)

- **Free + account:** “Your links are saved to your account in the cloud” with **clear quota labels** in settings (e.g. “125 / 200 collections”).
- **Premium:** “No ads, higher limits, best sync experience.”

---

## Day Pass (unchanged spine)

- **Days 1–3:** No ad gate (trial).
- **Day 4+:** One **rewarded video** per 24h unlocks full app access for that period (per PRD).
- **Grace:** Offline or ad load failure — 24h grace as already specified.
- **Premium:** Bypass ad gate entirely.

**Clarification:** Day Pass gates **application access** (and may gate **writes** if product chooses); it does **not** mean free accounts revert to local-only storage.

---

## Quotas (free authenticated)

Quotas bound **Supabase row growth and egress** so rewarded-ad ARPU can plausibly cover infra.

**Initial recommendation band (calibrated for small DAU; tune with live metrics):**

| Resource | Suggested starting range | Notes |
|----------|-------------------------|--------|
| Total collections (all nesting levels) | 50–150 | Count rows in `lv_collections` for `owner_id`, excluding soft-deleted if policy uses soft delete |
| Total URLs | 3,000–10,000 | Count `lv_urls` per `owner_id` |
| Optional | Per-collection URL cap | Reduces single-folder hoarding edge cases |

**Enforcement (target architecture):**

1. **Server-authoritative:** RPC or insert/update policies that check counts (preferred for honesty).
2. **Client UX:** Pre-check before save; friendly error + paywall/upgrade CTA.
3. **Premium:** Bypass quota checks (entitlement from RevenueCat).

Exact numbers should be **configurable** (remote config or build-time constants) for tuning without app store delay where possible.

---

## Repository selector (conceptual)

**Guest:** inject **local** repositories only.

**Authenticated + not premium:** inject **Supabase** repositories (or hybrid: read-through cache) with **quota enforcement** on writes; **Day Pass** enforced at app shell / mutation policy layer.

**Premium:** inject **Supabase** with **no quota cap** (or much higher caps); sync queue and migration flows per [Cloud_Sync_and_Reconciliation.md](../04_DATA_AND_MIGRATION/Cloud_Sync_and_Reconciliation.md).

**Offline:** authenticated users may use **local cache** + **queued writes** when connectivity returns; policy must match [Data_Persistence_State_Machine.md](../04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md).

---

## Migration and upgrade paths

1. **Guest → sign up:** Upload local collections/URLs to `lv_*` (idempotent), then **cloud is primary**.
2. **Free → Premium:** Increase limits; optional **backfill** if free user was quota-capped; sync semantics unchanged.
3. **Premium → expired:** Downgrade per state machine (read-only vs local continuation) — must not **silently delete** cloud data without product/legal alignment.

---

## Unit economics (illustrative)

**Revenue (rewarded, rough):**

\[
\text{Gross ad revenue/day} \approx \text{Daily completions} \times \frac{\text{eCPM}}{1000}
\]

Daily completions depend on **DAU**, **fill**, **completion rate**, and **eligible users** (Day Pass active).

**Industry benchmark ranges (high variance; use AdMob dashboard as truth):**

- **Tier 1–2 geos:** rewarded eCPM often cited in **roughly ~\$15–\$30** in some markets.
- **Global blend:** often **lower** — model **conservative** blends (e.g. **\$3–\$8** eCPM) for sustainability unless your analytics prove otherwise.

**Costs (Supabase / ops):**

- Fixed **plan base** (e.g. Pro tier) plus **disk, egress, storage** — **egress and chatty sync** dominate at scale more than row count.
- **Mitigations:** pagination, delta sync, avoid shipping large blobs through Postgres responses, thumbnail policy per tier.

**Small DAU sanity check (example only):**

- 3,000 DAU × 60% completion × \$6 eCPM → ~\$10.8/day gross before platform share — often **enough to cover modest Pro + overage** if quotas and egress are disciplined.

**Conclusion:** Ads **can** subsidize Supabase for **bounded** free usage; **do not** assume Tier 1 eCPM for a **global** user base without measurement.

---

## Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Global eCPM dilution | Model blended eCPM; tune quotas from real revenue |
| Egress spikes | Pagination, lazy metadata, CDN/storage for media |
| Quota bypass | Server-side enforcement + RLS |
| User expectation (“free cloud”) | Transparent quota UI + upgrade path |
| Premium conversion | Clear benefits: no ads, higher limits, best sync |

---

## Revision History

| Version | Date | Notes |
|---------|------|--------|
| 1.0 | 2026-03-24 | Initial model: free authenticated = Supabase + quotas + Day Pass; guest local-only. |
