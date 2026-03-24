# LinkVault — Product Requirements Document (PRD)

**Version:** 1.1  
**Last Updated:** March 24, 2026  
**Status:** Approved for Development  
**Target Launch:** Q3 2026

---

## Executive Summary

**Product Name:** LinkVault  
**Product Type:** Mobile-first URL & link organizer  
**Platform:** iOS + Android (Flutter)  
**Target Launch:** 14 weeks from project start

### One-Line Description

LinkVault is the fastest way to save, organize, and revisit any URL — organized in nested collections, with rich auto-fetched metadata, available offline-first.

### Problem Statement

People encounter hundreds of valuable links daily — through WhatsApp, Twitter/X, Instagram DMs, Telegram, emails, and browser tabs. These links are:
1. Scattered across 5+ apps with no unified home
2. Lost within hours from chat history or closed tabs
3. Impossible to search or find when actually needed
4. Visually bland and offer no context (bare URLs)

Existing solutions are inadequate:
- **Browser bookmarks** — ugly, flat, non-mobile-friendly
- **Notes apps** — no structure, no metadata, no organization
- **Raindrop.io** — powerful but desktop-focused and complex
- **Pocket** — shut down July 2025; read-it-later focus, not organization

### The Solution

A mobile-first, offline-first link vault where:
- Saving a URL takes 2 taps (share sheet → LinkVault → done)
- Links auto-fetch title, description, favicon, thumbnail, dominant color
- Collections are nestable (folders inside folders)
- Everything works offline; cloud sync available for premium users

---

## 1. Product Vision & Strategy

### 1.1 Vision Statement

> *"LinkVault makes your saved links actually useful — organized, searchable, and always accessible."*

### 1.2 Product Positioning

**We are NOT:**
- A read-it-later app (no article extraction in v1)
- A social bookmarking platform
- A browser extension (mobile-first)
- A general note-taking app

**We ARE:**
- A personal link vault for power mobile users
- The best-looking bookmark manager on mobile
- The offline-first alternative to Raindrop.io
- The natural evolution of the original LinkVault app

### 1.3 Target Market

**Primary Audience:**
- Age: 22-40 years
- Behavior: Heavy mobile internet user, frequently saves links from social media and messaging apps
- Pain: "I saved that link somewhere but can't find it"
- Occupation: Students, developers, knowledge workers, creators

**User Personas:**

**Persona 1: "The Power Saver" (Primary — 55%)**
- Rahul, 26, Software Engineer
- Saves 10-20 links/day from Twitter/X, GitHub, YouTube
- Pain: "My browser bookmarks are a disaster. I can't find anything."
- Conversion likelihood: HIGH (10-15%)

**Persona 2: "The Research Organizer" (Secondary — 30%)**
- Priya, 31, Content Writer
- Saves links in WhatsApp groups and loses them within hours
- Wants folders for different projects (Health, Finance, Writing)
- Pain: "I need one place for all my research links"
- Conversion likelihood: MEDIUM (5-8%)

**Persona 3: "The Casual Saver" (Tertiary — 15%)**
- Arjun, 22, Student
- Saves links occasionally, wants a cleaner alternative to notes
- Pain: "I wish my bookmarks looked as good as my notes"
- Conversion likelihood: LOW (3-5%)

### 1.4 Market Opportunity

**Market Timing:**
- ✅ Pocket shut down July 2025 — millions of active users need alternatives
- ✅ 70%+ of web browsing is now on mobile
- ✅ WhatsApp link sharing = massive unaddressed use case in India/SEA
- ✅ Existing LinkVault user base to target for Day-1 downloads

**Competitive Landscape:**

| Competitor | Strength | Weakness | Our Advantage |
|---|---|---|---|
| Raindrop.io | Mature, feature-rich | Desktop-first, complex | Mobile-first, simpler |
| Browser Bookmarks | Built-in, free | Ugly, flat, no metadata | Rich metadata, nested |
| Pocket | Huge user base | Shut down | Direct replacement |
| GoodLinks (iOS) | Beautiful | iOS-only | Cross-platform |
| Notion | Flexible | Overkill, slow | 10x faster to save |

---

## 2. Product Goals & Objectives

### 2.1 Business Goals

**Phase 1 (Months 1-3): Launch & Validate**
- Ship MVP on iOS + Android
- 3,000+ downloads (leveraging original app user base)
- Validate Ad Day Pass model
- 4.5+ App Store rating

**Phase 2 (Months 4-6): Monetize**
- $1,500/month MRR
- 8-12% premium conversion
- 45%+ D7 retention

**Phase 3 (Months 7-12): Grow**
- 25,000+ MAU
- $5,000+/month MRR
- Browser extension (Phase 2)

### 2.2 KPIs

**Acquisition:**
- Downloads: 3K Month 1, 8K Month 3, 25K Month 6
- Install-to-activation: >65%

**Engagement:**
- DAU/MAU: 40%+
- Collections created per user: 5+ average
- URLs saved per user: 30+
- Sessions per week: 4+

**Retention:**
- D1: 55%+, D7: 45%+, D30: 28%+

**Monetization:**
- Ad views per DAU session: 0.65
- Premium conversion: 8-12%
- ARPU (all users): $0.40-$0.60/month
- LTV (premium): $60+

---

## 3. User Stories & Use Cases

### 3.1 Core User Journeys

**Journey 1: Quick Save from Browser/WhatsApp**
```
1. User receives a link on WhatsApp
2. Long-presses the link → Share → LinkVault
3. App opens share receive sheet
4. Metadata auto-fetches (title, thumbnail)
5. User selects target collection (or creates new)
6. Taps Save → link saved in 3 seconds total
7. Returns to WhatsApp
```

**Journey 2: Daily Browsing**
```
1. Opens LinkVault
2. Watches 30-sec rewarded ad (Day 4+ free tier)
3. Gets 24hr unlimited access
4. Browses "Dev Resources → Flutter" collection
5. Taps a URL → opens in browser
6. Saves 2 new links from recent YouTube video
7. Searches for "supabase tutorial" → finds link from 3 weeks ago
```

**Journey 3: Premium Conversion**
```
1. User on Day 28 — watches daily ad for 4 weeks
2. Gets "Upgrade to Premium" badge on ad gate
3. Taps "Upgrade" — sees paywall
4. Chooses annual plan ($39.99, save 33%)
5. Completes IAP → ads disappear immediately
6. Cloud sync activates → links appear on tablet
7. Long-term retained user; LTV = $40-80/year
```

### 3.2 Detailed User Stories

**Epic 1: Collection Management**

| ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-1.1 | As a user, I want to create a nested collection so I can organize links in folders | Create collection with title, icon, color; optionally inside a parent collection; shows in grid; breadcrumb updates | P0 |
| US-1.2 | As a user, I want to edit a collection's name, color, and icon | Inline edit screen; changes save immediately | P0 |
| US-1.3 | As a user, I want to delete a collection | Confirmation dialog; all URLs in it also deleted; parent URL count updates | P0 |
| US-1.4 | As a user, I want to reorder collections by drag-and-drop | Long-press drag; position persists; works for nested and root | P1 |
| US-1.5 | As a user, I want to pin a collection to the top | Pin icon in long-press menu; pinned shows before unpinned | P1 |

**Epic 2: URL Management**

| ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-2.1 | As a user, I want to save a URL to a collection | Paste URL or receive from share sheet; auto-fetches metadata within 3s; appears in collection | P0 |
| US-2.2 | As a user, I want to see the URL's title and thumbnail | Card shows favicon, title, domain, thumbnail (if available), dominant color accent | P0 |
| US-2.3 | As a user, I want to edit URL details (title, description, tags) | Tap URL card → detail view → Edit button; all fields editable | P0 |
| US-2.4 | As a user, I want to delete a URL | Swipe or long-press delete; confirmation; count updates on collection | P0 |
| US-2.5 | As a user, I want to open a URL in browser | Tap URL card → opens in flutter_custom_tabs; click_count increments | P0 |
| US-2.6 | As a user, I want to mark a URL as read | Status enum: unread / read / archived; visual badge on card | P1 |
| US-2.7 | As a user, I want to pin a URL to the top of a collection | Pin icon; pinned URLs appear first | P1 |
| US-2.8 | As a user, I want to move a URL to a different collection | Long-press → Move → collection picker dialog | P2 |

**Epic 3: Share-to-App**

| ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-3.1 | As a user, I want to share a URL from any app into LinkVault | Share sheet includes LinkVault; opens receive intent screen | P0 |
| US-3.2 | As a user, I want to quickly assign collection when saving via share | Sheet shows collection picker (recent + search); default to last used | P0 |

**Epic 4: Search & Discovery**

| ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-4.1 | As a user, I want to search across all collections and URLs | Search debounced 300ms; results grouped by type | P0 |
| US-4.2 | As a user, I want to filter by status (unread, read, pinned) | Filter chips on search/home screen | P1 |
| US-4.3 | As a user, I want to sort URLs by date added, last visited, most visited | Sort dropdown in URL list; persists per collection | P1 |
| US-4.4 | As a user, I want to filter by tag | Tap tag chip → shows all URLs with that tag | P1 |

**Epic 5: RSS Feeds**

| ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-5.1 | As a user, I want to add an RSS feed | Enter feed URL; app fetches and parses XML; feed appears in list | P1 |
| US-5.2 | As a user, I want to browse articles in a feed | Feed detail screen with article cards (title, pub date, summary) | P1 |
| US-5.3 | As a user, I want to save an RSS article to a collection | Tap "Save to LinkVault" on article; one-tap save as URL | P1 |

**Epic 6: Monetization**

| ID | User Story | Acceptance Criteria | Priority |
|---|---|---|---|
| US-6.1 | As a free user, I want to watch an ad to get 24hr access | After 3-day trial: ad gate screen; watch 30s rewarded video; 24hr pass granted | P0 |
| US-6.2 | As a user, I want to upgrade to premium | Tap "Upgrade"; paywall shows monthly/annual pricing; IAP completes via RevenueCat | P0 |
| US-6.3 | As a premium user, I want to restore my purchase | Restore Purchases button in settings; verifies with store | P0 |

---

## 4. Functional Requirements

### 4.1 Collections (P0)

- ✅ Create collection: title (required), icon (from preset list), color (preset palette), category
- ✅ Nest collections inside other collections (unlimited depth via `parent_id`)
- ✅ Breadcrumb navigation at top of nested screens
- ✅ Edit collection (all fields)
- ✅ Delete collection with cascade (all child collections + URLs deleted)
- ✅ Drag-to-reorder (fractional `position: FLOAT8` indexing)
- ✅ Pin collection to top
- ✅ Archive collection (hidden from main view, accessible from archived section)
- ✅ URL count badge per collection
- ❌ Collection sharing (Phase 2)

### 4.2 URLs (P0)

- ✅ Add URL (manual paste + from share intent)
- ✅ Auto-metadata fetch: title, description, thumbnail, favicon, dominant color
- ✅ Manual override of title, description
- ✅ Tags (comma-separated, searchable)
- ✅ Status: `unread` / `read` / `archived`
- ✅ Pin URL to top of collection
- ✅ Archive URL
- ✅ Edit all fields
- ✅ Delete with confirmation
- ✅ Click count tracking (`click_count++`)
- ✅ Last accessed tracking
- ✅ Drag-to-reorder within collection
- ❌ Multiple images per URL (Phase 2)
- ❌ Move to collection (Phase 2)

### 4.3 Search (P0)

- ✅ Full-text search: title, description, URL string, tags
- ✅ Search debouncing (300ms)
- ✅ Results grouped: Collections / URLs
- ✅ Inline filter/sort controls

### 4.4 Metadata Auto-Fetch

- ✅ Fetch on URL entry via `http` + `html` package
- ✅ Parse: `<title>`, `og:title`, `og:description`, `og:image`, `og:image`, favicon link
- ✅ Dominant color extracted from thumbnail
- ✅ Timeout: 5s — fallback to manual entry on failure
- ✅ Local cache of fetched metadata (ObjectBox)

### 4.5 RSS Reader (P1)

- ✅ Add RSS/Atom feed by URL
- ✅ Parse XML (title, link, description, pubDate per item)
- ✅ Refresh feeds (pull-to-refresh)
- ✅ Local cache of feed items
- ✅ Save any article to LinkVault as a URL in one tap
- ❌ Push notifications for new feed items (Phase 2)

### 4.6 Share Intent

- ✅ Register as share target on Android + iOS
- ✅ Receive shared URL → opens save sheet in-app
- ✅ Collection picker from save sheet

### 4.7 Monetization (P0)

**Tier model (canonical):** [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md).

**Guest (no account):**
- Product data **local-only** (ObjectBox)
- Same Ad Day Pass rules for **app access** after trial

**Free account (authenticated, not premium):**
- Product data **authoritative in Supabase `lv_*`** with **enforced quotas** (total collections, total URLs — tunable)
- Same Ad Day Pass rules after trial
- **Quota exceeded:** block new creates (or defined soft behavior) with clear UX + upgrade path
- Offline: cache + queue behavior per [Data_Persistence_State_Machine.md](../04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md)

**Ad Day Pass:**
- ✅ 3-day free trial (no ads)
- ✅ Day 4+: ad gate shows if >24hrs since last valid pass
- ✅ Rewarded video ad: 30-60s
- ✅ Pass granted: 24hr from ad watch time
- ✅ Grace periods: 24hr if offline or ad fails to load
- ✅ Premium users bypass entirely

**Premium (RevenueCat):**
- ✅ Monthly: $4.99/month (`lv_premium_monthly`)
- ✅ Annual: $39.99/year (`lv_premium_annual`)
- ✅ No ads
- ✅ **Higher / unlimited-style limits** (no free-tier quota wall)
- ✅ Restore purchases

### 4.8 Settings (P1)

- ✅ Theme: Light / Dark / System
- ✅ Export data (JSON: all collections + URLs)
- ✅ Import data (JSON)
- ✅ Clear all data (with confirmation + double-confirm)
- ✅ Storage usage
- ✅ Premium status + manage subscription
- ✅ About: version, Privacy Policy, Terms of Service, Contact

---

## 5. Non-Functional Requirements

### 5.1 Performance

- App cold start: <2.5 seconds
- Screen transitions: <150ms
- URL search results: <100ms (local ObjectBox)
- Metadata fetch: <5s with timeout fallback
- Frame rate: 60fps sustained

### 5.2 Reliability

- Zero data loss on crash (ObjectBox ACID transactions)
- Offline-first: **guest** has full local core CRUD; **authenticated** users rely on **cache + queue** when offline (writes sync when online per policy)
- Ad grace period ensures no user lockout
- Crash-free rate: 99.5%+

### 5.3 Security

- Supabase RLS on all tables — users see only their own data
- No plaintext credentials in code (dotenv-based config)
- Auth tokens managed by Supabase SDK (secure storage)
- Export file contains no auth tokens

### 5.4 Platform

| Platform | Minimum | Target |
|---|---|---|
| iOS | 14.0+ | 17.0 |
| Android | API 26 (8.0) | API 34 (14) |

---

## 6. Monetization Strategy

### 6.1 Revenue Model

Two streams:
1. **Ad Revenue** — AdMob rewarded video (Day Pass for guest + free account after trial)
2. **Premium Subscriptions** — RevenueCat IAP (no ads + higher limits)

**Infra note:** Free **account** users consume **Supabase** resources; **quotas** and **egress discipline** are required for sustainability. See [Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md](../05_MONETIZATION/Monetization_Model_Free_Cloud_Quotas_and_Unit_Economics.md).

### 6.2 Revenue Projections

| Month | Users | DAU (40%) | Ad Revenue | Premium Revenue | Total |
|---|---|---|---|---|---|
| 1 | 3,000 | 1,200 | ~$108 | ~$360 | ~$468 |
| 3 | 8,000 | 3,200 | ~$288 | ~$960 | ~$1,248 |
| 6 | 20,000 | 8,000 | ~$720 | ~$2,400 | ~$3,120 |
| 12 | 50,000 | 20,000 | ~$1,800 | ~$6,000 | ~$7,800 |

*Illustrative only — validate against AdMob actual eCPM (rewarded differs from banner CPM). See unit economics formulas in monetization model doc.*

---

## Document Revision History

| Version | Date | Changes |
|---|---|---|
| 1.1 | March 24, 2026 | Monetization: guest local-only; **free account = Supabase + quotas + Day Pass**; premium = higher limits + no ads. |
| 1.0 | March 20, 2026 | Initial PRD — full reboot |
