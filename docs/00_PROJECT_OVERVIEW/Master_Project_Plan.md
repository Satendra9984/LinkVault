# LinkVault — Master Project Plan

**Version:** 1.5  
**Last Updated:** March 30, 2026  
**Status:** Active — Sprint 7-8 URL Hub stable; **Sprint 11–12 (Monetization + Cloud Sync)** implemented in app (see Sprint 11–12 section + [SPRINT_11_12_Implementation_Snapshot.md](../09_SPRINT_ARCHITECTURE/SPRINT_11_12_MONETIZATION_AND_SYNC/SPRINT_11_12_Implementation_Snapshot.md))  
**Architecture:** Clean Architecture + Feature-First + Curate Foundation

**Execution companion:** [Phase Roadmap, Tasks, Evaluation Gates, and Test Catalog](./Phase_Roadmap_Tasks_and_Test_Catalog.md) — phased checklists, exit gates, and test IDs aligned to this plan.

---

## Project Overview

### Vision

Build a beautifully designed, mobile-first **URL & link management app** that helps people save, organize, and actually revisit links — from articles and tutorials to YouTube videos and product pages — with nested folder-style collections, offline-first local storage, and optional cloud sync.

### One-Line Description

> LinkVault is a fast, offline-first link organizer that lets you save any URL into nested, branded collections — with an account your library lives in the cloud (within fair limits on the free tier), and Premium unlocks higher limits with no ads.

### The Problem

People share links across WhatsApp, Telegram, Instagram DMs, Twitter/X, and browser tabs. These links are lost within hours. Existing solutions are either:
- **Too complex** (Raindrop.io, Notion) — desktop-focused and overwhelming for mobile
- **Too passive** (browser bookmarks) — ugly, flat, no organization
- **Wrong domain** (Pocket) — read-it-later, not link organization
- **RSS-focused** — not about personal link saving

### Our Solution

A mobile-first app where you save any link, sort it into a **nested collection hierarchy** (folders inside folders), tag and annotate links, automatically fetch rich metadata (title, thumbnail, favicon), and access everything instantly offline.

### Core Value Proposition

| Tier | Value |
|---|---|
| **Guest (Ad Day Pass)** | Core features, **local-only** storage (ObjectBox), offline-first — watch 1 ad/day after trial |
| **Free account (Ad Day Pass)** | Core features, **cloud-backed** `lv_*` data with **enforced quotas**, cross-device for account — watch 1 ad/day after trial |
| **Premium** | No ads + **higher / unlimited-style limits** + best sync and backup story |

---

## Current Implementation Snapshot (March 2026)

**Implemented recently (app):**
- Root collections now run through the Hub architecture (Library route retired); see [Library_Screen_Removal_Changelog.md](../09_SPRINT_ARCHITECTURE/SPRINT_7_8_UX_REFACTOR/Library_Screen_Removal_Changelog.md)
- URL tap behavior respects collection `openLinksIn` (`in_app` vs `external_browser`)
- URL long-press options include **View details** (old tap navigation preserved as explicit action)
- Links preload on `ItemsListScreen` open (no longer waits for first Links-tab tap)
- Non-tab flows render full-screen above shell using root navigator routing (bottom nav hidden where expected)
- Edit Collection screen no longer fetches/displays child URL items inline
- **Sprint 11–12:** delta sync service (`CloudDeltaSyncService`), Profile sync card, guest→cloud migration reads **local-only** repos and upserts **`lv_urls`**, downgrade uses **`lv_collections`/`lv_urls`**, RevenueCat `logOut` on sign-out, shared RC stream for subscription-active, AdMob dev test-ID fallback

**Still open (Sprint 7-8 onward):**
- Remaining URL-management QA signoff and any unchecked Sprint 7-8 checklist items below
- Edge-to-edge safe-area hardening for focused search fields in sliver/tab scroll contexts

---

## Success Criteria

- ✅ Launch within 14 weeks
- ✅ 3,000+ downloads Month 1 (existing user base from original LinkVault)
- ✅ 4.5+ App Store / Play Store rating
- ✅ 8-12% free-to-premium conversion
- ✅ $1,500/month MRR by Month 6
- ✅ 45%+ D7 retention

---

## User Tiers

**Canonical detail:** [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md) · **ADR:** [ADR_0002](../10_DECISIONS_AND_RISKS/ADR_0002_Free_Tier_Supabase_Quotas_and_Day_Pass.md).

### Guest — Ad-Supported (Local Only)

- ✅ **Ad Day Pass:** Watch 1 rewarded video ad per day for 24hr app access (after trial)
  - First 3 days: Free trial (no ads)
  - 24hr grace period if offline or ad fails to load
- ✅ **Unlimited** nested collections **on device** (ObjectBox)
- ✅ **Unlimited** URLs **on device** (subject to practical device limits)
- ✅ All CRUD features locally
- ✅ Auto-metadata fetch, tags, annotations, pin/archive, global search (local), export/import (local), share-to-app
- ❌ **No** Supabase `lv_*` persistence (no account)

### Free Account — Ad-Supported (Cloud With Quotas)

- ✅ Same **Ad Day Pass** rules as guest (trial, daily rewarded, grace)
- ✅ **Supabase `lv_*`** is the **system of record** for collections and URLs (like premium, but bounded)
- ✅ **Cross-device access** for the same account
- ✅ **Enforced quotas** (e.g. total collections, total URLs — exact numbers in monetization doc / remote config)
- ✅ Offline-friendly UX via **local cache + queue** (policy per [Data_Persistence_State_Machine.md](../04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md))
- ✅ Core CRUD, metadata, search, share intent (within quotas)
- ❌ Ads remain (until Premium)
- ❌ Quota exceed → block new creates or require upgrade (product-defined messaging)

### Premium ($4.99/month · $39.99/year)

- ✅ **No ads forever**
- ✅ **Supabase** persistence with **premium limits** (high caps or “unlimited” per product copy)
- ✅ **Automatic backup** and best-effort sync UX
- ✅ **Cross-device access**
- ✅ Cloud image storage (per storage policy)
- ✅ Data export / import
- ✅ Priority support

---

## Development Phases (Aligned to Execution Companion)

### Phase 0: Rebase Stabilization & Architecture Lock (Sprint 0)

**Goal:** Single canonical entrypoint, clean build, and no conflicting active architecture guidance.

### Phase 1: Foundation (Weeks 1-2)

**Goal:** Scaffold curate-based architecture with LinkVault data model

**Deliverables:**
- Project setup (Clean Architecture, ObjectBox, Supabase, Riverpod, go_router)
- Flavors (dev / production) + dotenv
- Splash screen & onboarding flow
- `lv_*` schema migrations + RLS smoke validation in dev

---

### Phase 2: Auth & Profile (Weeks 3-4)

**Goal:** Production auth posture, profile/settings, and account lifecycle safety.

**Deliverables:**
- Supabase OTP/passwordless auth + guest mode
- Profile CRUD + settings/legal screens
- Delete-account flow with verified cascade semantics
- Guest-to-account continuity rules

---

### Phase 3: Collections & URLs (Weeks 5-8)

**Goal:** Nested collections and robust URL management with stable local-first behavior.

### Phase 4: Search, Tags, RSS, Share (Weeks 9-10)

**Goal:** Discovery and ingestion features complete (search/filter/sort, RSS, share-to-app).

### Phase 5: Monetization & Cloud Sync (Weeks 11-12)

**Goal:** Ad Day Pass + RevenueCat + migration/sync/downgrade reliability.

### Phase 6: Polish, QA & Launch (Weeks 13-14)

**Goal:** Quality, testing, and submission

**Deliverables:**
- Micro-animations & transitions
- Accessibility (VoiceOver / TalkBack)
- Performance optimization
- Crash reporting + analytics stack per product/security decision
- Beta testing (TestFlight + Play Internal)
- App Store & Play Store submission

---

## 14-Week Sprint Plan

### Sprint 1-2: Project Setup & Splash

**Week 1: Architecture Scaffold (from Curate foundation)**

- [ ] rename link_vault old lib codebase to lib_old, initialize fresh lib
- [ ] Import curate architecture: Clean Architecture folders, ObjectBox, Supabase, Riverpod, GoRouter
- [ ] Configure flavors (dev / production) via flutter_flavorizr
- [ ] Set up .env.dev and .env.production with Supabase + RevenueCat + AdMob keys
- [ ] Splash screen (LinkVault logo + loading indicator)
- [ ] Design system foundation (colors, typography, spacing tokens)
- [ ] Supabase project creation + schema (lv_user_profiles, lv_collections, lv_urls)
- [ ] RLS smoke checks for user isolation on `lv_*` tables

**Week 2: Onboarding**

- [ ] 3-page onboarding (Save Links · Organize · Sync Anywhere)
- [ ] Skip button + dot indicators
- [ ] Onboarding completion tracking (SharedPreferences)
- [ ] Welcome screen: Sign Up / Sign In / Continue as Guest

**Verification:**
- [ ] App launches with splash → onboarding → auth
- [ ] Design system accessible from any file

---

### Sprint 3-4: Authentication & Profile

**Week 3: Auth**

- [x] Supabase OTP (passwordless email)
- [x] Guest mode (local-only, no account)
- [x] Auth state management (Riverpod)
- [x] Auto-create `lv_user_profiles` row on signup (Supabase trigger)
- [x] Runtime profile ensure on authenticated entry (signup, signin, and session-restore paths) with idempotent insert if `lv_user_profiles` is missing
- [x] Guest-to-account continuity (preserve local data during sign-up without ownership leaks)

**Week 4: Profile & Settings**

- [x] Profile screen: avatar, display name, email
- [x] Edit profile
- [x] Settings: Theme (Light/Dark/System), Export data, Import data, About
- [x] Delete account (SECURITY DEFINER RPC with cascade)
- [x] Terms of Service & Privacy Policy (bundled Markdown screens)
- [x] Session revoke/expiry handling for cloud mutations

**Verification:**
- [x] OTP sign-in + sign-up works
- [x] Guest mode uses local storage only
- [x] Auth state persists across restarts
- [x] Existing Curate-authenticated user can sign in to LinkVault and self-heal missing `lv_user_profiles` without admin backfill
- [x] If authenticated profile fetch fails, app shows recovery UI (`Setting up profile`/`Retry`/`Sign out`) instead of hard failure

---

### Sprint 5-6: Collections (Nested Folders)

**Status (March 2026):** Core scope **implemented** in Flutter + Supabase migrations **001–010** (RLS, counts, free-tier quota triggers). **Offline write queue** for signed-in users remains **future** (Sprint 11–12 / state machine v2).

**Sprint 5–6 completion (at a glance)** — use this table if task-list `[x]` markers do not render in your viewer:

| Area | Status |
|------|--------|
| Week 5 list / create / nested / breadcrumbs / repos / selector | **Done** (app) |
| Week 6 edit / delete / reorder / pin / archive | **Done** (app); reorder **list-only**; delete dialog copy **light** |
| Domain unit tests (S56-U-01..03) | **Done** (`flutter test test/features/collections/domain/`) |
| Supabase SQL in repo (migrations 001–010) | **Done** (files in `supabase/migrations/`); **you** apply to each Supabase project |
| Manual QA matrix (Sprint test plan) | **Pending** (your sign-off) |
| Flutter → `lv_urls` for items (not legacy `items`) | **Pending** (align client with schema so URL quotas + RLS apply) |

**Where to do Supabase work (docs under `docs/09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/`):**

| Doc | What you use it for |
|-----|---------------------|
| [**Sprint_5_6_Collections_Schema_and_RLS_Checklist.md**](../09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/Sprint_5_6_Collections_Schema_and_RLS_Checklist.md) | **Primary checklist:** which migrations, columns, triggers, RLS rules, smoke tests after deploy |
| [**README.md**](../09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/README.md) | Index + backlog; points to migrations path and **rls_smoke_test.sql** |
| [Sprint_5_6_Collections_Test_Plan.md](../09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/Sprint_5_6_Collections_Test_Plan.md) | Manual + integration verification (incl. two-user RLS) |
| Repo: [`supabase/migrations/`](../../supabase/migrations) | Apply **001 → 010** in order on **dev**, then **staging/prod** |
| Repo: [`supabase/sql/rls_smoke_test.sql`](../../supabase/sql/rls_smoke_test.sql) | Run (with real JWT / user UUIDs) after deploy |

**Your Supabase-side task list (operator):**

1. Open Dashboard → SQL or CLI → run migrations **001** through **010** in order (or `supabase db push` if linked).
2. Confirm tables **`lv_collections`**, **`lv_urls`**, **`lv_user_profiles`** match [Schema and RLS Checklist](../09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/Sprint_5_6_Collections_Schema_and_RLS_Checklist.md).
3. Smoke-test RLS + counts + **quota triggers (010)** using [`rls_smoke_test.sql`](../../supabase/sql/rls_smoke_test.sql) (replace placeholder UUIDs; test free vs `is_premium` bypass).
4. Keep **`lv_user_profiles.is_premium`** (or `premium_expires_at`) consistent with RevenueCat so **010** bypass matches real entitlements.
5. When the app writes URLs to **`lv_urls`**, re-smoke inserts at quota boundary (5000) and collection cap (150).

---

**Week 5: Collections List & Create** *(detail — `[x]` = done)*

- [x] Home screen: Root collections grid (2-column) + list mode toggle
- [x] Collection cards (color, icon, title; subtitle: nested folder count + link count)
- [x] Create collection form: title, icon, color, category, parent (`parentId` / route query)
- [x] Nested support: open collection → child-collection strip + URL list (mixed view)
- [x] Breadcrumb navigation (ancestor chain + tap to navigate)
- [x] Local ObjectBox repository (nested via `parentId`; ObjectBox codegen regenerated for full field parity)
- [x] Supabase repository (`lv_collections`, `parent_id`, RLS); stream + client-side sibling sort (archived / pinned / position / `updated_at`)
- [x] Repository selector (ADR-0002): guest/local; signed-in + online → cloud (free immediately, premium after `hasMigratedToCloud`); offline → ObjectBox; premium lapsed → read-only cloud; `connectivity_plus` → `isOnlineProvider` (debounced)
- [x] CRUD use cases (collections) + client **TierQuotaGuard**; server quotas migration **010** on `lv_collections` / `lv_urls` (premium bypass via `lv_user_profiles`)

**Week 6: Collections Edit, Delete, Reorder**

- [x] Edit collection screen (incl. parent picker; self + subtree excluded from parent choices)
- [x] Delete collection (confirmation); local implementation removes collection + items in ObjectBox — **dialog copy does not yet spell out subtree + URL cascade** (polish vs [Sprint_5_6_Collections_UI_Flows.md](../09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/Sprint_5_6_Collections_UI_Flows.md))
- [x] Drag-to-reorder: **fractional indexing** between sibling `position` values + rebalance when gap collapses — **list mode only** (grid reorder / “Edit order” deferred)
- [x] Pin collections to top (sort + persist)
- [x] Archive collections (option **A**: hidden from home + nested strips; still searchable for edit/unarchive)

**Cross-cutting done in sprint scope**

- [x] Parent cycle validation on save (app) + unit tests (`S56-U-02`)
- [x] Sibling ordering rules + unit tests (`S56-U-01`)
- [x] Fractional reorder + unit tests (`S56-U-03`)
- [x] Pull-to-refresh on nested folder invalidates collections stream (breadcrumb / child strip refresh)
- [x] Sprint docs: [SPRINT_5_6_COLLECTIONS/README.md](../09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/README.md), schema checklist through **010**, RLS smoke template updated

**Verification:**

- [x] **Automated:** `flutter test test/features/collections/domain/` (sort, parent validation, fractional reorder)
- [x] **Schema / SQL:** migrations **001–010** applied in dev; [rls_smoke_test.sql](../../supabase/sql/rls_smoke_test.sql) preconditions updated to **010**
- [x] **Manual QA sheet:** full matrix in [Sprint_5_6_Collections_Test_Plan.md](../09_SPRINT_ARCHITECTURE/SPRINT_5_6_COLLECTIONS/Sprint_5_6_Collections_Test_Plan.md) (deep trees, two-user RLS, premium/migration paths) — run and sign off in release checklist
- [x] Create/edit/delete root + nested collections (implementation; manual spot-check recommended)
- [x] Navigate into sub-collections (breadcrumbs + nested strip)
- [x] Reorder by drag persists (fractional logic; **list view**)

---

### Sprint 7-8: URLs Management

**Week 7: URL List & Add**

- [x] URL list inside collection: list/card/icon modes + toggle in hub
- [x] URL card/tile variants with favicon/title/domain/thumbnail support
- [x] Add URL flow:
  - Paste URL → auto-fetch metadata (title, description, thumbnail, favicon, dominant color)
  - Manual override of title, description
  - Tags (comma-separated)
  - Annotation / notes field
  - Status: `unread`, `read`, `archived`
- [x] ObjectBox local repository
- [x] Supabase remote repository
- [x] CRUD use cases
- [x] Share-intent ingestion resilience (cold start + foreground stream + validation)
- [x] Tap URL opens via collection setting `openLinksIn` (`in_app`/`external_browser`)
- [x] Long-press options include **View details**
- [x] Links preload on screen open (not only after Links-tab selection)

**Week 8: URL Detail, Edit, Reorder**

- [x] URL detail screen: rich metadata display, open in browser, copy URL
- [x] Edit URL screen
- [x] Delete URL (with confirmation)
- [x] Drag-to-reorder within collection
- [x] Pin URL to top of collection
- [x] Click count tracking (`click_count++` on open)
- [x] Last accessed tracking

**Router & navigation UX (Sprint 7-8 additions):**
- [x] `StatefulShellRoute.indexedStack` keeps only tab roots in shell branches (`/`, `/collections`, `/search`, `/profile`)
- [x] Full-screen routes moved to root navigator overlay (`/collections/create`, `/collections/:id/edit`, item create/detail/edit, profile subpages)
- [x] Bottom nav stays hidden for full-screen flows while tab stack state is preserved

**Verification:**
- [x] Add URL → metadata auto-fetched correctly
- [x] View, edit, delete URLs
- [x] Open URL in browser / in-app view (`url_launcher` launch modes)
- [x] Click count increments
- [ ] Manual regression matrix signoff for Sprint 7-8 UX refactor screens

---

### Sprint 9-10: Search, Tags & RSS Reader

**Week 9: Global Search & Tags**

- [ ] Global search across all collections and URLs (title, description, tags, URL)
- [ ] Search debouncing 300ms
- [ ] Filter by: all / unread / read / archived / pinned
- [ ] Sort by: date added / date modified / most visited / alphabetical
- [ ] Tags: add comma-separated tags to URLs, filter by tag

**Week 10: RSS Feed Reader**

- [ ] RSS Feed management: add feed URLs
- [ ] Feed list screen: display all feeds
- [ ] Feed detail screen: articles from a feed
- [ ] Save RSS article as URL to any collection (one-tap)
- [ ] Feed refresh with pull-to-refresh
- [ ] Local caching of feed items (ObjectBox)
- [ ] Export/import contract finalized (versioned schema, validation, merge/replace behavior)

**Verification:**
- [ ] Search finds URLs by title, description, tag, domain
- [ ] Filters/sort work correctly
- [ ] RSS feeds load and display
- [ ] Save to collection from RSS works

---

### Sprint 11-12: Monetization & Cloud Sync

**Week 11: Ad Day Pass & RevenueCat**

- [x] AdMob rewarded video integration *(dev falls back to Google test units if `.env` test IDs empty; prod warns if rewarded IDs missing)*
- [x] Ad gate screen (watch ad to continue)
- [x] Ad Day Pass logic:
  - Day 1-3: Free trial (no ads)
  - Day 4+: 1 ad per day for 24hr access
  - 24hr grace: offline or ad load failure *(grace aligned with full-screen gate + `DayPassGate`)*
- [x] RevenueCat setup (lv_premium_monthly, lv_premium_annual) *(dashboard / store product wiring still validated in sandbox manually)*
- [x] Paywall screen: benefits list, monthly/annual pricing
- [x] Tier enforcement throughout app *(client `TierQuotaGuard` + server triggers; unit tests for guard)*

**Week 12: Cloud Sync**

- [x] **Free account:** data on `lv_*`; **auto delta sync** on launch / resume / reconnect when online (within quotas)
- [x] **Guest → account:** one-time **local ObjectBox → `lv_*` upload** via dedicated local repos; **`lv_urls` upsert** (idempotent storage paths; safe retry if flag not set)
- [x] **Premium:** same delta sync engine; **migration flag** for bulk guest→cloud path
- [x] **Server-side quota enforcement** for free tier (collections + URLs); premium bypass *(existing migrations + client pre-checks)*
- [ ] Image thumbnails: cache locally; **Supabase Storage** policy aligned to tier *(app uses `item-images` uploads; formal per-tier Storage RLS still verify in Supabase console)*
- [x] Delta sync (pull/push by `updated_at`) + **LWW** conflict policy *(see `CloudDeltaSyncService` + `ConflictPolicy`)*
- [x] Offline durability + flush: **local ObjectBox** holds writes offline; **delta push** on reconnect / resume *(no separate outbox table; pending ≈ local rows newer than last sync anchor)*
- [x] Manual sync action + post-migration reconciliation *(manual “Sync now” on Profile; full drift report optional follow-up)*
- [x] Sync status indicator in UI (pending estimate, last success, error hint)
- [x] Downgrade **import/delete** targets **`lv_collections` / `lv_urls`** (fixed from Curate table names)

**Verification:**
- [ ] Day 0-3: No ad gate *(manual device QA)*
- [ ] Day 4+: Ad gate blocks access, watching ad grants 24hr pass *(manual + AdMob sandbox)*
- [ ] Premium purchase via RevenueCat sandbox works *(manual)*
- [ ] Premium users: ad gate bypassed; **free account users:** cloud writes respect quotas and Day Pass rules *(manual)*
- [x] Failed migration keeps cloud-mode flag unset and supports safe retry *(flag only on success; dual `AuthSettings` + `AppSettings` reset on sign-out)*
- [ ] Downgrade behavior matches selected policy with no silent data loss *(manual QA on import + delete remote)*

---

### Sprint 13: Polish & Testing

- [ ] Loading shimmer animations
- [ ] Card swipe animations
- [ ] Smooth push/pop navigation transitions
- [ ] Empty state illustrations
- [ ] Accessibility: VoiceOver + TalkBack
- [ ] WCAG AA color contrast
- [ ] Performance: 60fps, <3s cold start, <100ms search
- [ ] Unit tests for all use cases
- [ ] Widget tests for key screens
- [ ] Manual testing iOS + Android

---

### Sprint 14: Launch Preparation

- [ ] Analytics events (app_open, url_saved, collection_created, premium_converted) via selected stack
- [ ] Crash reporting setup via selected stack
- [ ] App Store screenshots + metadata
- [ ] Play Store listing + feature graphic
- [ ] TestFlight beta (20 testers)
- [ ] Play Console Internal Testing
- [ ] Submit to App Store
- [ ] Submit to Play Store

---

## Technical Architecture Summary

### Repository Pattern (Dual-Mode: Local + Cloud)

```dart
abstract class UrlRepository {
  Future<Either<Failure, List<UrlEntity>>> getUrls(String collectionId);
  // ...
}

class LocalUrlRepository implements UrlRepository { /* ObjectBox */ }
class SupabaseUrlRepository implements UrlRepository { /* Supabase */ }

// Provider selects implementation based on user tier
// Provider selects implementation using auth+tier+migration+online state machine
```

### User Tiers

```dart
enum UserTier {
  guest,    // No account — local ObjectBox only + Ad Day Pass
  free,     // Authenticated — Supabase lv_* + quotas + Ad Day Pass
  premium,  // Authenticated — Supabase lv_* + high limits + no ads
}
```

### Key Technologies

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Local DB | `objectbox` v4 |
| Remote DB / Auth | `supabase_flutter` |
| Routing | `go_router` |
| Monetization | `purchases_flutter` (RevenueCat) + `google_mobile_ads` |
| URL metadata | `html` + `http` (custom parser) |
| In-app/external link opening | `url_launcher` (`LaunchMode.inAppBrowserView` / `LaunchMode.externalApplication`) |
| Sharing intent | `receive_sharing_intent` |
| RSS parsing | `xml` |
| OTP pin input | `pinput` |
| Flavors | `flutter_flavorizr` |
| Env config | `flutter_dotenv` |

---

## Timeline Summary

| Sprint | Weeks | Focus | Key Deliverable |
|---|---|---|---|
| 0 | Pre-week 1 | Rebase lock | Single entrypoint, stable baseline, docs lock |
| 1-2 | 1-2 | Setup + Splash | Architecture scaffold, Splash, Onboarding |
| 3-4 | 3-4 | Auth + Profile | OTP login, Guest mode, Settings |
| 5-6 | 5-6 | Collections | Nested folder CRUD, breadcrumbs |
| 7-8 | 7-8 | URLs | Rich URL cards, metadata fetch, click tracking |
| 9-10 | 9-10 | Search + RSS | Global search, tags, RSS feed reader |
| 11-12 | 11-12 | Monetization + Sync | Ad Day Pass, RevenueCat, Cloud sync |
| 13 | 13 | Polish | Animations, accessibility, tests |
| 14 | 14 | Launch | Beta, analytics, submission |

**Total: 14 weeks**

---

## Post-MVP Features (Phase 2)

- Collection sharing via shareable link (premium)
- Browser extension (Chrome / Safari / Firefox)
- Web app (PWA read-only view)
- AI-powered auto-tagging of saved links
- Bulk operations (select all, move to collection, delete)
- Import from Raindrop.io / Pocket (JSON)
- Offline reading mode (article extraction)
- Widget (iOS / Android home screen quick-save)
- Collaborative collections (co-edit with others)

---

## Risks & Mitigations

| Risk | Probability | Mitigation |
|---|---|---|
| Metadata fetch rate-limits or failures | Medium | Graceful fallback (show URL only), retry on next open |
| App Store IAP rejection | Low | Follow guidelines, clear subscription terms, test thoroughly |
| AdMob policy violations | Low | Standard rewarded video pattern, no deceptive wording |
| Low conversion rate | Medium | Clear value communication, trial period before ad gate |
| Supabase costs at scale | Medium | **Quotas on free tier**, pagination, delta sync, monitor egress; see monetization unit economics doc |

---

## Schema Version History

| Version | Date | Changes |
|---|---|---|
| 1.5 | March 30, 2026 | **Sprint 11–12 delivery:** Day Pass grace parity, RevenueCat `logOut` on sign-out + single RC stream alias, AdMob dev fallbacks/diagnostics, quota tests, migration via **local-only** repos + `lv_urls`, cloud downgrade to `lv_*`, `CloudDeltaSyncService` + Profile sync UI, `SyncMetadataStore` (prefs) + sign-out clear. |
| 1.4 | March 30, 2026 | Added Sprint 7-8 implementation snapshot and completed URL/UX/router checklist items: tap `openLinksIn`, long-press **View details**, preload-on-open, shell-vs-root full-screen routing, and Edit Collection simplification; added remaining QA/safe-area follow-ups. |
| 1.3 | March 24, 2026 | **Sprint 5-6 plan checkboxes:** marked collections sprint items completed/tested in app + DB where applicable; noted gaps (grid reorder, delete dialog copy, full manual QA matrix, offline queue). |
| 1.2 | March 24, 2026 | **Monetization model:** guest = local-only; **free account = Supabase + quotas + Day Pass**; premium = higher limits + no ads. Cross-links to `docs/05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md` and ADR-0002. |
| 1.1 | March 24, 2026 | Aligned phase model and sprint expectations with execution companion; clarified migration/sync/downgrade, state-machine repository selection, and launch telemetry wording. |
| 1.0 | March 20, 2026 | Initial project plan — full reboot from Curate foundation |
