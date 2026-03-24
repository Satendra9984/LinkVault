# ADR-0002: Free Tier Uses Supabase With Quotas (Guest Stays Local-Only)

Version: 1.0  
Last Updated: 2026-03-24  
Status: Approved  
Owner: Product + Engineering  
Depends On: [ADR_0001_Canonical_Architecture_and_Data_Model.md](ADR_0001_Canonical_Architecture_and_Data_Model.md), [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md)

---

## Status

Approved

## Date

2026-03-24

## Context

The Master Project Plan originally described **free tier as local-only (ObjectBox)** with **cloud sync reserved for premium**. The existing LinkVault user base is largely **ad-supported (Ad Day Pass)**. Product strategy requires:

- Preserving **Day Pass** as the primary monetization spine for non-paying users.
- Giving **account holders** **cross-device continuity** and **remote persistence** comparable to premium, **without** unlimited cloud cost exposure.
- Keeping **guest (no account)** on **local-only** storage to limit abuse and infra cost.

## Decision

1. **Guest:** Product data remains **ObjectBox only**; no `lv_*` writes for collections/URLs.
2. **Authenticated, non-premium (“free account”):** Product data **authoritative in Supabase `lv_*`**, with **hard quotas** (total collections, total URLs; exact numbers product-tuned). **Ad Day Pass** remains required per existing PRD (app access after trial).
3. **Premium:** Same `lv_*` authority with **no quota wall** (or materially higher limits), **no ads**, and full sync/value messaging per paywall.
4. **Quota enforcement** must be **server-aware** (RLS-safe RPC or equivalent), not client-only.
5. **Repository selection** and **Data Persistence State Machine** documentation are updated to reflect this split; implementation must follow.

## Consequences

- **Positive:** Account users get backup and multi-device alignment with minimal premium-only friction; ad ARPU can fund bounded cloud usage.
- **Negative:** Higher baseline Supabase usage than pure local-free model; requires **strict quotas**, **egress discipline**, and monitoring.
- **Migration:** Prior docs/code assuming “free = local repository only” must be refactored; guest-to-account upload path becomes **critical path** for continuity.

## Alternatives Considered

### A) Keep free tier local-only until premium

- **Pros:** Lowest cloud cost.
- **Cons:** Poor fit for users expecting account backup; weaker retention vs competitors.

**Rejected** for LinkVault v1 direction.

### B) Unlimited free cloud funded by ads

- **Pros:** Simple messaging.
- **Cons:** Unbounded cost; unsustainable on blended global eCPM.

**Rejected.**

### C) Free cloud with quotas + Day Pass (chosen)

Balances continuity, cost control, and existing ad habit.

---

## Revision History

| Version | Date | Notes |
|---------|------|--------|
| 1.0 | 2026-03-24 | Initial decision recorded. |
