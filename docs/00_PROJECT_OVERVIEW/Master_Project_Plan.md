# LinkVault — Master Project Plan

**Version:** 1.0  
**Last Updated:** March 20, 2026  
**Status:** Active — Sprint 0 (Project Reboot)  
**Architecture:** Clean Architecture + Feature-First + Curate Foundation

---

## Project Overview

### Vision

Build a beautifully designed, mobile-first **URL & link management app** that helps people save, organize, and actually revisit links — from articles and tutorials to YouTube videos and product pages — with nested folder-style collections, offline-first local storage, and optional cloud sync.

### One-Line Description

> LinkVault is a fast, offline-first link organizer that lets you save any URL into nested, branded collections and sync them across devices when you're ready.

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
| **Free (Ad Day Pass)** | All core features, unlimited local storage, offline-first — watch 1 ad/day |
| **Premium ($X/month)** | No ads + cloud sync across all devices |

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

### Free Tier — Ad-Supported (Local Mode)

- ✅ **Ad Day Pass:** Watch 1 rewarded video ad per day for 24hr unlimited access
  - First 3 days: Free trial (no ads)
  - 24hr grace period if offline or ad fails to load
- ✅ **Unlimited** nested collections (local ObjectBox storage)
- ✅ **Unlimited** URLs / links per collection
- ✅ All CRUD features (create, edit, delete, reorder)
- ✅ Auto-metadata fetch (title, description, thumbnail, favicon, dominant color)
- ✅ Tags, annotations, pin/archive
- ✅ Global search
- ✅ Data export (JSON)
- ✅ Share-to-app from browser (receive sharing intent)
- ❌ No cloud sync
- ❌ No cross-device access

### Premium Tier ($4.99/month · $39.99/year)

- ✅ **No ads forever**
- ✅ All free tier features
- ✅ **Cloud sync** powered by Supabase (PostgreSQL)
- ✅ **Automatic backup** — never lose a link
- ✅ **Cross-device access** — same account on phone + tablet
- ✅ Cloud image storage
- ✅ Data export / import
- ✅ Priority support

---

## Development Phases

### Phase 1: Foundation & Core Features (Weeks 1-8)

**Goal:** Scaffold curate-based architecture with LinkVault data model

**Deliverables:**
- Project setup (Clean Architecture, ObjectBox, Supabase, Riverpod, go_router)
- Flavors (dev / production) + dotenv
- Splash screen & onboarding flow
- Auth (Supabase: OTP + Email passwordless)
- Core Collections CRUD (nested folder support)
- Core URLs CRUD (metadata auto-fetch)

---

### Phase 2: Full Feature Build (Weeks 9-12)

**Goal:** Complete the app to feature parity + monetization

**Deliverables:**
- Global search (across all collections & URLs)
- Tags system + filter/sort
- Pin, archive, click tracking
- RSS Feed reader feature (LinkVault differentiator)
- Share-to-app (receive_sharing_intent) flow
- RevenueCat IAP integration
- Ad Day Pass (AdMob rewarded video)
- Cloud sync for premium users
- Data export / import

---

### Phase 3: Polish & Launch (Weeks 13-14)

**Goal:** Quality, testing, and submission

**Deliverables:**
- Micro-animations & transitions
- Accessibility (VoiceOver / TalkBack)
- Performance optimization
- Crash reporting (Firebase Crashlytics)
- Analytics (Firebase Analytics / Mixpanel)
- Beta testing (TestFlight + Play Internal)
- App Store & Play Store submission

---

## 14-Week Sprint Plan

### Sprint 1-2: Project Setup & Splash

**Week 1: Architecture Scaffold (from Curate foundation)**

- [ ] Delete link_vault codebase, initialize fresh Flutter project
- [ ] Import curate architecture: Clean Architecture folders, ObjectBox, Supabase, Riverpod, GoRouter
- [ ] Configure flavors (dev / production) via flutter_flavorizr
- [ ] Set up .env.dev and .env.production with Supabase + RevenueCat + AdMob keys
- [ ] Splash screen (LinkVault logo + loading indicator)
- [ ] Design system foundation (colors, typography, spacing tokens)
- [ ] Supabase project creation + schema (lv_user_profiles, lv_collections, lv_urls)

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

- [ ] Supabase OTP (passwordless email)
- [ ] Guest mode (local-only, no account)
- [ ] Auth state management (Riverpod)
- [ ] Auto-create `lv_user_profiles` row on signup (Supabase trigger)

**Week 4: Profile & Settings**

- [ ] Profile screen: avatar, display name, email
- [ ] Edit profile
- [ ] Settings: Theme (Light/Dark/System), Export data, Import data, About
- [ ] Delete account (SECURITY DEFINER RPC with cascade)
- [ ] Terms of Service & Privacy Policy (bundled Markdown screens)

**Verification:**
- [ ] OTP sign-in + sign-up works
- [ ] Guest mode uses local storage only
- [ ] Auth state persists across restarts

---

### Sprint 5-6: Collections (Nested Folders)

**Week 5: Collections List & Create**

- [ ] Home screen: Root collections grid (2-column)
- [ ] Collection cards (color badge, icon, title, URL count)
- [ ] Create collection form: title, icon, color, category
- [ ] Nested support: tap into collection → sub-collections + URLs mixed view
- [ ] Breadcrumb navigation (Home > Tech > Flutter > Articles)
- [ ] Local ObjectBox repository (nested via `parentId: String?`)
- [ ] Supabase repository (`lv_collections` with `parent_id`, RLS)
- [ ] Repository abstraction (tier-based: free = local, premium = Supabase)
- [ ] CRUD use cases

**Week 6: Collections Edit, Delete, Reorder**

- [ ] Edit collection screen
- [ ] Delete collection (with confirmation, cascades to URLs)
- [ ] Drag-to-reorder using `position: FLOAT8` (fractional indexing)
- [ ] Pin collections to top
- [ ] Archive collections

**Verification:**
- [ ] Create/edit/delete root + nested collections
- [ ] Navigate into sub-collections (breadcrumbs correct)
- [ ] Reorder by drag persists correctly

---

### Sprint 7-8: URLs Management

**Week 7: URL List & Add**

- [ ] URL list inside collection: list view + grid view toggle
- [ ] URL card: favicon, title, domain, thumbnail, tags, pin badge
- [ ] Add URL flow:
  - Paste URL → auto-fetch metadata (title, description, thumbnail, favicon, dominant color)
  - Manual override of title, description
  - Tags (comma-separated)
  - Annotation / notes field
  - Status: `unread`, `read`, `archived`
- [ ] ObjectBox local repository
- [ ] Supabase remote repository
- [ ] CRUD use cases

**Week 8: URL Detail, Edit, Reorder**

- [ ] URL detail screen: rich metadata display, open in browser, copy URL
- [ ] Edit URL screen
- [ ] Delete URL (with confirmation)
- [ ] Drag-to-reorder within collection
- [ ] Pin URL to top of collection
- [ ] Click count tracking (`click_count++` on open)
- [ ] Last accessed tracking

**Verification:**
- [ ] Add URL → metadata auto-fetched correctly
- [ ] View, edit, delete URLs
- [ ] Open URL in browser / in-app view (flutter_custom_tabs)
- [ ] Click count increments

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

**Verification:**
- [ ] Search finds URLs by title, description, tag, domain
- [ ] Filters/sort work correctly
- [ ] RSS feeds load and display
- [ ] Save to collection from RSS works

---

### Sprint 11-12: Monetization & Cloud Sync

**Week 11: Ad Day Pass & RevenueCat**

- [ ] AdMob rewarded video integration
- [ ] Ad gate screen (watch ad to continue)
- [ ] Ad Day Pass logic:
  - Day 1-3: Free trial (no ads)
  - Day 4+: 1 ad per day for 24hr access
  - 24hr grace: offline or ad load failure
- [ ] RevenueCat setup (lv_premium_monthly, lv_premium_annual)
- [ ] Paywall screen: benefits list, monthly/annual pricing
- [ ] Tier enforcement throughout app

**Week 12: Cloud Sync**

- [ ] Auto-sync on launch (premium users)
- [ ] Local → Cloud migration (guest/free upgrade → sync all data to Supabase)
- [ ] Image thumbnails: cache locally, upload to Supabase Storage (premium)
- [ ] Sync status indicator in UI

**Verification:**
- [ ] Day 0-3: No ad gate
- [ ] Day 4+: Ad gate blocks access, watching ad grants 24hr pass
- [ ] Premium purchase via RevenueCat sandbox works
- [ ] Premium users: ad gate bypassed, cloud sync active

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

- [ ] Firebase Analytics events (app_open, url_saved, collection_created, premium_converted)
- [ ] Firebase Crashlytics setup
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
```

### User Tiers

```dart
enum UserTier {
  guest,    // No account — local ObjectBox only
  free,     // Authenticated — local ObjectBox + Ad Day Pass
  premium,  // Authenticated — Supabase cloud + no ads
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
| In-app browser | `flutter_custom_tabs` |
| Sharing intent | `receive_sharing_intent` |
| RSS parsing | `xml` |
| OTP pin input | `pinput` |
| Flavors | `flutter_flavorizr` |
| Env config | `flutter_dotenv` |

---

## Timeline Summary

| Sprint | Weeks | Focus | Key Deliverable |
|---|---|---|---|
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
| Supabase costs at scale | Low | Monitor usage, optimize queries, RLS + indexes |

---

## Schema Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | March 20, 2026 | Initial project plan — full reboot from Curate foundation |
