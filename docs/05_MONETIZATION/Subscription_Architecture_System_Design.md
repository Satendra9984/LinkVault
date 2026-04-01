# LinkVault Subscription Architecture — A Deep Learning Guide

**Version:** 2.0  
**Last Updated:** 2026-03-30  
**Purpose:** Explain how the entire subscription and monetization system is designed — the concepts, the reasoning behind every decision, how the pieces connect, and how it scales. Written to be read from top to bottom by anyone wanting to deeply understand this system.

---

## How to Read This Document

This is not a checklist or a reference card. It is a guided walkthrough of an entire system's reasoning. Each section builds on the previous one. If you are new to subscription systems, start at Section 1. If you already understand RevenueCat and want to understand our specific design choices, jump to Section 4.

---

## Section 1: What Problem Are We Solving?

Before looking at any technical solution, it is worth understanding exactly what problem we face. Most apps have a simple monetization story: "buy the app once" or "pay monthly for extra features." LinkVault's situation is more nuanced because of three overlapping challenges.

### Challenge 1: We have two apps sharing a user base

LinkVault and Curate are sibling apps built and owned by the same team. They share authentication infrastructure (the same Supabase project), the same RevenueCat billing project, and the same developer account. A user who subscribes to "Premium" in Curate might reasonably expect to also have Premium in LinkVault — and vice versa. This cross-app shared subscription benefit is a design decision we made consciously. It has major architectural implications.

### Challenge 2: We cannot give free users unlimited cloud infrastructure

Running a cloud database (Supabase in this case) costs money. Every row a user stores is disk space. Every query is compute. If we give free users unlimited cloud storage and they never pay, we lose money on every user. This is how many startups go bankrupt — they give away cloud features and underestimate the cost at scale.

The naive solution is "put free users on local storage only, give cloud only to premium." We actually tried this approach initially. But it creates a bad user experience: free users lose their data if they change phones, they cannot access their links on a second device, and the value of paying feels too tied to basic continuity rather than premium features.

Our solution is a middle ground: **free authenticated users get real cloud storage, but with quotas.** The quotas are generous enough that most users never hit them (e.g. 200 collections, 10,000 links), but they prevent any single free user from costing us significant money. Premium users get no quota wall.

### Challenge 3: Subscription billing is unreliable in isolation

When a user buys a subscription on their phone, several systems need to agree that this happened: the App Store or Play Store records the purchase, RevenueCat processes the receipt and projects it into an "entitlement," and your app needs to know the user is now premium. In a perfect world these all happen simultaneously. In reality, each of these steps can be delayed, fail temporarily, or be out of sync. Network timeouts, app restarts, offline mode, and server delays all create windows where the systems disagree. A well-designed system tolerates these windows gracefully instead of breaking.

### The Design Philosophy

Given these three challenges, our architecture is built on four principles:

1. **Separate billing from access.** "Did the user pay?" and "can the user access this feature?" are different questions answered by different systems.

2. **Use multiple sources of truth with a clear hierarchy.** No single service owns entitlement — RevenueCat, Supabase, and local cache each play a role, with a defined priority order.

3. **Guest users are completely local; authenticated users are cloud-backed.** This creates a clean tiering story and keeps costs predictable.

4. **Gate feature actions, not data fetching.** Users can browse their data freely. They hit a gate only when they try to create, edit, or use premium capabilities.

---

## Section 2: The Three Pillars of the System

Think of the entire monetization system as three pillars. Each pillar handles one concern. They talk to each other but are not tightly coupled. This separation is the most important architectural decision in the whole system.

### Pillar 1: The Billing System

The billing system handles money. It consists of the App Store / Play Store (the actual payment processors) and RevenueCat (the orchestration layer that sits on top).

**What RevenueCat actually is:**
RevenueCat is a paid service that sits between your app and the stores. Without RevenueCat, you would need to write code that talks to the Play Store directly, handles Apple's notoriously complex StoreKit, validates receipts on your own server, manages renewal webhooks, handles edge cases like family sharing and cross-device restore, and do all of this for both iOS and Android with completely different APIs. RevenueCat abstracts all of that into one consistent SDK.

The key concept in RevenueCat is an **Entitlement** — a named feature flag (`premium` in our case) that becomes `active: true` when a valid paid subscription is in place. Your app only needs to check "does this user have the `premium` entitlement?" rather than caring about which product they bought, which country they're in, or whether it was monthly or annual.

**What the stores actually do:**
The stores are the actual financial processors. They:
- Display the purchase UI
- Process the payment
- Handle billing cycles, renewals, failed payments, grace periods, and cancellations
- Send receipt data to RevenueCat via secure webhooks

Neither your app nor RevenueCat handles the actual money. The store does. RevenueCat just interprets the store's signals.

### Pillar 2: The Data System

The data system handles where user data lives. It consists of Supabase (our cloud database) and ObjectBox (the on-device local database).

**Why we have both:**
A mobile app always needs a local database. Even if you have cloud sync, reading from disk is 100x faster than a network request. For a link organizer, showing the user's collections instantly when they open the app — without waiting for a network request — is table-stakes UX. ObjectBox is a high-performance local database embedded in the app.

Supabase is the cloud layer. It is a hosted Postgres database with an authentication system built in. It gives users backup, cross-device access, and data safety. Every row in Supabase belongs to a specific user (enforced by Row Level Security).

The data system does not care about subscriptions at all. Its job is to store and sync data. The subscription system (Pillar 1) tells the data system which level of service a user gets.

### Pillar 3: The Policy Engine

The policy engine is the decision-maker. When a user taps a button in the app, the policy engine runs silently and asks: "Is this user allowed to do this right now?" It considers:

- What is the user's subscription status? (from Pillar 1)
- Are they within their quota? (from Pillar 2)
- Are they online? (device network state)
- Have they earned a DayPass? (from the DayPass system)

The policy engine is implemented in the app as a set of providers and guards. It is the bridge between the other two pillars. It reads from both and applies the product rules.

```
              ┌──────────────────────────────────┐
              │        User taps a button         │
              └──────────────┬───────────────────┘
                             ▼
              ┌──────────────────────────────────┐
              │         Policy Engine             │
              │  "Is this user allowed to do X?" │
              └───┬───────────────────┬──────────┘
                  │                   │
       ┌──────────▼──────┐   ┌────────▼──────────┐
       │  Pillar 1        │   │  Pillar 2          │
       │  Billing/        │   │  Data System       │
       │  Entitlement     │   │  (quota check)     │
       └──────────────────┘   └───────────────────┘
```

---

## Section 3: User Tiers — What They Actually Mean

LinkVault has three user tiers. Understanding the difference between them is fundamental to understanding the whole system.

### Guest User

A guest user is someone who has the app installed but has not created an account. They chose "continue as guest" during onboarding, or they have never seen the onboarding and just started using the app.

**What they get:**
- All core functionality (add links, create collections, search, etc.)
- 3-day free trial with no ads
- After trial: daily DayPass via rewarded ad
- All data stored **only on their device** (ObjectBox)

**What they don't get:**
- Backup if they delete the app or change phones
- Access from multiple devices
- Cloud sync

**Why this tier exists and why it's local-only:**
Guest users have not given us their email address. We have no way to identify them across devices or app installs. Giving them cloud storage would be anonymous cloud storage with no way to tie it to a real account — which creates abuse opportunities and cost with no way to upsell. By keeping guests local-only, we also remove any barrier to using the app ("just try it without signing up"), which improves conversion. When they eventually sign up, we migrate their local data to the cloud.

### Free Authenticated User

A free authenticated user has signed up with their email (or Apple/Google sign-in). They have a real account in Supabase Auth.

**What they get:**
- Everything the guest gets, plus:
- Cloud backup and sync (via Supabase `lv_*` tables)
- Cross-device access (their links are available on any phone they sign in to)
- Data safety (even if they lose their phone, their data is in the cloud)
- Subject to **quotas**: e.g. 200 collections, 10,000 links

**After 3-day trial:**
- Must watch one rewarded ad per day to maintain full access
- This is the **DayPass** system — one ad unlocks 24 hours of full access

**Why quotas?**
Every row this user stores costs us money in Supabase hosting. The quotas (soft limits enforced server-side) bound that cost. At 10,000 links per user, the storage cost per user is negligible. But if we let one user store 500,000 links, they become expensive. Quotas are set at levels that virtually no normal user hits, but prevent the rare extreme case that could hurt us financially.

**Why get cloud access without paying?**
Because cloud backup is not our premium differentiator. Our premium differentiator is no ads and higher limits. If we require payment for basic backup, users will use a competitor who offers free backup. By offering cloud backup to all authenticated users, we have a stronger story and we still monetize through ads on the free tier.

### Premium User

A premium user has an active subscription managed by RevenueCat.

**What they get:**
- No ads ever — DayPass system is completely bypassed
- No quota wall — they can store as many collections and links as they want
- Higher priority sync performance
- Better messaging: "unlimited" collections and links

**Pricing:**
- Monthly: $4.99/month
- Annual: $39.99/year (saves ~33%)

The annual plan is strategically important because it reduces churn — a user who pays $39.99 upfront is less likely to cancel than a user billed $4.99 monthly who thinks "do I use this enough?"

---

## Section 4: The DayPass System — How Ad-Monetization Works

The DayPass system is a clever monetization mechanism that gives free users a way to maintain full app access through watching ads. Understanding it deeply requires understanding how rewarded ad monetization works in mobile apps.

### What is a Rewarded Ad?

A rewarded ad is a video advertisement that the user explicitly opts to watch in exchange for a reward (in our case, 24 hours of full app access). The user sees a prompt, taps "Watch Ad", watches a 15-30 second video, and earns their reward. This is very different from banner ads that are forced and passive.

Rewarded ads have significantly higher eCPM (effective cost per thousand impressions) than banner ads — typically $10-$30 per 1000 views in Tier 1 countries like the US, UK, and Australia. This means that if 3,000 users watch one ad each day, we earn roughly $30-$90/day in ad revenue, which can cover meaningful Supabase hosting costs.

### DayPass Access States

The DayPass system has five possible states:

**1. freeTrial**
The user installed the app within the last 3 days. No ads required. This is the first-impression grace period — we don't want to show ads to someone who just discovered the app. This reduces first-day uninstalls significantly.

**2. active**
The user has a valid DayPass. They watched an ad within the last 24 hours (or have stacked multiple ads for extended coverage). The DayPass "expires at" timestamp is in the future. Full app access granted.

**3. expired**
The DayPass has expired and the user has not yet watched an ad today. They cannot take feature-gated actions until they either watch an ad (getting a new DayPass) or upgrade to premium. This is the monetization gate.

**4. grace**
A special fallback state. The last ad attempt failed to load (network issue, ad network timeout, no ads available in the user's region). Rather than punishing the user for a technical failure outside their control, we give them a grace period of continued access. This is important for user trust — a user who wants to earn access but cannot because of a server error should not be denied access.

**5. premium**
The user has an active RevenueCat premium entitlement. The DayPass system is completely bypassed — they never see ad-related prompts.

### Why Store DayPass Data Locally?

DayPass status is stored in ObjectBox (the local database) rather than Supabase. This is intentional for two reasons:

1. **Speed**: checking "can this user take this action?" happens every time they tap a button. Reading from the local database is ~1ms. Reading from Supabase over the network is ~100-500ms. Showing a spinner every time someone tries to add a link would be terrible UX.

2. **Offline support**: users should be able to see their DayPass status and understand why they're being gated even when offline. Local storage makes this work seamlessly.

The trade-off is that DayPass data is device-specific. If a user watches an ad on their phone and then switches to their tablet, the tablet's DayPass status is separate. This is an acceptable trade-off because DayPass is primarily about ad revenue per device session, not per account.

### The Stacking Mechanism

An important DayPass design decision is that ad watches stack. If a user watches two ads in one day, they get 48 hours of access, not just 24. If they watch three, they get 72 hours.

This works by keeping an absolute "expiresAt" timestamp rather than just "when was the last ad watched". When a new ad is earned:
- If the current pass is still valid: add 24 hours to the existing expiry
- If the current pass has expired: start fresh from now + 24 hours

This rewards engaged users and gives them a way to "prepay" access for upcoming days when they might not have time to watch an ad.

---

## Section 5: RevenueCat — Understanding the Subscription Layer

RevenueCat is the most complex third-party system in our monetization stack. Let's break down exactly how it works and why each component exists.

### The Hierarchy: Projects → Apps → Products → Entitlements → Offerings

RevenueCat has a hierarchical data model. Understanding this hierarchy is the key to understanding the whole billing system.

**Project**: The top-level container. We have one project called "Vicharshala Apps" that contains both LinkVault and Curate. The project is the boundary of the shared user database — any user who exists in one app exists in all apps under the same project.

**Apps**: Each app entry in RevenueCat corresponds to one app on one store. Our project has (or will have):
- Curate (Android) — Google Play Store
- Curate (iOS) — Apple App Store
- Curate Dev — Test Store (for development)
- LinkVault (Android) — Google Play Store
- LinkVault (iOS) — Apple App Store
- LinkVault Dev — Test Store (for development)

Each app entry has its own API key. When your Flutter app initializes RevenueCat with an API key, RevenueCat knows which "app" the session belongs to.

**Products**: Products are the actual purchasable items. A product maps to a specific subscription in a specific store. For example:
- `lv_premium_monthly:monthly-base` is the LinkVault monthly subscription in Google Play
- `lv_premium_annual:annual-base` is the LinkVault annual subscription in Google Play
- `lv_premium_monthly` is the LinkVault monthly subscription in Apple's App Store (different format, no base plan)

Products exist per-app because each store has its own product catalog system.

**Entitlements**: An entitlement is the feature access right that a product grants. We have one entitlement: `premium`. It is project-scoped, meaning it exists once and is shared across all apps in the project. When a user has any active subscription (monthly, annual, Curate, LinkVault), they have the `premium` entitlement active.

This is the key to shared subscriptions: **multiple products across multiple apps all grant the same entitlement.** If a user buys Curate Premium on their iPhone, RevenueCat records that the user has the `premium` entitlement. When they open LinkVault on their Android phone, LinkVault asks RevenueCat "does this user have `premium`?" and gets `true`. One purchase, two apps unlocked.

**Offerings**: An offering is the set of products you present to users on the paywall screen. The `default` offering is what appears when you show the purchase UI. Each offering contains packages (monthly, annual), and each package points to the appropriate product for the current app/store context.

```
RevenueCat Project: "Vicharshala Apps"
│
├── Apps
│   ├── LinkVault (Android)  →  API Key: goog_abc...
│   ├── LinkVault (iOS)      →  API Key: appl_abc...
│   ├── LinkVault (Dev)      →  API Key: test_abc...
│   ├── Curate (Android)     →  API Key: goog_xyz...
│   └── ...
│
├── Entitlements
│   └── "premium"  ← Single entitlement, shared across ALL apps
│        └── Attached products:
│             ├── lv_premium_monthly:monthly-base  (LV Android)
│             ├── lv_premium_annual:annual-base    (LV Android)
│             ├── lv_premium_monthly               (LV iOS)
│             ├── lv_premium_annual                (LV iOS)
│             ├── curate_premium_monthly:monthly-base (Curate Android)
│             └── ...all of them
│
└── Offerings
    └── "default"
         ├── Monthly Package → lv_premium_monthly:monthly-base (when using LV Android key)
         └── Annual Package  → lv_premium_annual:annual-base  (when using LV Android key)
```

### Why API Key Prefixes Matter

RevenueCat uses three key prefixes that actually affect behavior:

- `test_` — Routes to Test Store. Purchases are simulated. Use this in dev builds.
- `goog_` — Routes to Google Play. Receipts are validated with Google's servers.
- `appl_` — Routes to Apple App Store. Receipts are validated with Apple's servers.

If you accidentally use a `goog_` key for an iOS app, RevenueCat will try to validate Apple receipts through Google's validation pipeline, which will always fail. The purchase appears to succeed on the device, but no entitlement is granted. This is a silent failure that is very hard to debug. The key prefix is not just a label — it is a routing instruction.

### App User ID — The Identity Bridge

RevenueCat needs to know who the user is. Without an identity, purchases cannot be associated with accounts, restore doesn't work across reinstalls, and shared entitlements across devices cannot function.

In LinkVault, we use the Supabase user ID (`auth.uid()`) as the RevenueCat App User ID. This is the right approach because:

1. **Stability**: The Supabase user ID never changes for a given account. If a user reinstalls the app and signs in again, they get the same Supabase ID and therefore the same RevenueCat identity.

2. **Backend linking**: When RevenueCat sends webhooks to our backend (more on this later), the App User ID in the webhook matches the user ID in our Supabase database. We can update the right row.

3. **Cross-device**: If a user has LinkVault on their phone and tablet, both devices authenticate with the same Supabase account, get the same user ID, and therefore RevenueCat returns the same entitlement state on both.

### How Purchase Works Step by Step

Understanding the exact sequence of what happens when a user buys a subscription is important for diagnosing issues:

1. User opens the PayWall screen in the app.
2. App calls RevenueCat SDK to fetch "offerings" — the list of available products with their prices from the store.
3. User taps "Subscribe Monthly".
4. App calls `Purchases.purchase()` with the selected package.
5. RevenueCat SDK calls the native store billing API (Google Play Billing / StoreKit).
6. Store shows the native payment sheet.
7. User confirms payment with fingerprint/face ID.
8. Store processes the payment and sends a receipt/token to RevenueCat.
9. RevenueCat validates the receipt with the store's server, records the subscription, and marks the `premium` entitlement as active.
10. RevenueCat returns a `CustomerInfo` object to the app (directly in the `purchase()` response).
11. App reads `customerInfo.entitlements.active['premium']` → this is `true`.
12. App updates local premium cache in ObjectBox.
13. App invalidates the Riverpod auth provider so all UI rebuilds to reflect premium state.
14. RevenueCat asynchronously fires a webhook to our backend (if configured).
15. Backend webhook handler updates `lv_user_profiles.is_premium = true` for this user.

The critical rule: **always use the `CustomerInfo` returned directly by `purchase()`.** Never call `getCustomerInfo()` separately after a purchase. The separate call hits RevenueCat's cache, which may not yet reflect the newly-processed purchase, causing a "purchase succeeded but no entitlement" bug. This was the root cause of a real debugging session we had in Curate in March 2026.

---

## Section 6: Supabase — The Data Layer and Its Design Rationale

Supabase is a hosted Postgres database with authentication built in. It is the cloud authority for all data belonging to authenticated users. Understanding why the schema is designed the way it is requires understanding the constraints we are working within.

### The Shared Project Challenge

Both LinkVault and Curate use the same Supabase project. This means they share:
- The same authentication system (`auth.users` table)
- The same database
- The same billing for compute and storage

This creates a naming collision risk: if Curate creates a table called `collections` and LinkVault also creates a table called `collections`, we have a problem. The solution is namespace prefixing: all LinkVault tables start with `lv_`. All Curate tables have no prefix (they were first). This is a permanent convention — changing it later would be a costly migration.

### Table Design and Why Each Table Exists

**`lv_user_profiles`**

Purpose: Extended user profile data for LinkVault users.

Why it exists separately from `auth.users`: The built-in `auth.users` table in Supabase is managed by the authentication system and cannot be freely modified with custom columns. We need to store:
- Display name and avatar (for profile UI)
- `is_premium` and `premium_expires_at` (monetization mirror)
- `last_synced_at` (sync metadata)

All of this goes in `lv_user_profiles`, which has `id UUID PRIMARY KEY REFERENCES auth.users(id)`, creating a one-to-one relationship.

The `is_premium` column deserves special explanation: this is a **mirror** of what RevenueCat says. It is not the source of truth. The source of truth is RevenueCat's entitlement system. But we store this mirror because:

1. **Server-side policy enforcement**: When a user tries to write a collection to Supabase, the RLS (Row Level Security) policy or an RPC function can check `is_premium` to decide if they're within quota, without making a separate API call to RevenueCat.

2. **Analytics and reporting**: We can run SQL queries against Supabase to see "how many premium users do we have?" without calling RevenueCat's API.

3. **Resilience**: If RevenueCat is temporarily unavailable, our server-side policies still have the last-known premium state.

The mirror is updated via webhooks from RevenueCat (discussed in Section 7).

**`lv_collections`**

Purpose: Stores link collections/folders belonging to a user.

Key design decisions:
- `parent_id UUID REFERENCES lv_collections(id)` — self-referencing foreign key enables unlimited nesting depth without extra tables. A collection can have a parent collection, which can have a parent, and so on.
- `position FLOAT8` — fractional positioning allows reordering without renumbering all siblings. If you have items at positions 1.0, 2.0, 3.0 and want to insert between 1 and 2, you just use 1.5. No updates to neighbors needed.
- `is_deleted BOOLEAN + deleted_at TIMESTAMPTZ` — soft delete. Never actually remove rows during sync operations. This is critical for conflict resolution in a multi-device sync scenario: if device A deletes a collection while device B is offline, when device B comes online we need to know "this was intentionally deleted" vs "this row never existed on device B."
- `url_count INT + child_count INT` — denormalized counters maintained by database triggers. Rather than running `SELECT COUNT(*) FROM lv_urls WHERE collection_id = X` every time we display a collection, we maintain the count incrementally. This makes the collections list load fast even for users with thousands of links.

**`lv_urls`**

Purpose: Stores the actual links with their metadata.

Key design decisions:
- `collection_id UUID NOT NULL REFERENCES lv_collections(id)` — every link belongs to exactly one collection. This is a strict one-to-many relationship.
- `owner_id UUID NOT NULL REFERENCES auth.users(id)` — stored separately from the collection's owner_id as a performance optimization. Queries filtering by user and collection can use this directly without joining.
- Metadata fields (`title`, `description`, `thumbnail_url`, `favicon_url`, `tags`, `annotation`) — these come from automatic URL metadata fetching. The app fetches page metadata (Open Graph tags, favicon, etc.) when a link is added and stores it here.
- `click_count INT + last_accessed_at TIMESTAMPTZ` — usage tracking for personal analytics. "Show me my most visited links this month."
- `is_deleted BOOLEAN` — same soft-delete rationale as collections.

### Row Level Security — Why Every Table Has It

Row Level Security (RLS) is a Postgres feature that enforces data access policies at the database level. Without RLS:
- An app bug that constructs the wrong query could return another user's data
- A compromised API key could read any data in the table
- Any authenticated user with the Supabase client could potentially access other users' data

With RLS enabled:
- `SELECT * FROM lv_urls` returns only the current authenticated user's rows
- `INSERT INTO lv_collections (owner_id, ...)` fails if `owner_id != auth.uid()`
- Even if the app has a bug, the database enforces ownership

This is defense in depth: the app enforces ownership in its query layer, AND the database enforces it in RLS. Both must have a bug simultaneously for a data leak to occur.

### Quota Enforcement — Why Server-Side Matters

Quota enforcement happens at two levels:

1. **Client-side** (in the app): Before a user tries to create a new collection, the app checks "does this user have fewer than 200 collections?" If not, it shows a quota message and doesn't call the backend. This gives fast feedback.

2. **Server-side** (in Supabase): An RPC function or RLS policy actually verifies the count before allowing the insert. If the client-side check is bypassed (API call directly to Supabase, reversed-engineered app, etc.), the server still enforces the quota.

Client-only quotas are not real quotas. Any motivated user can bypass them by calling the API directly. Server-side enforcement is the only real protection.

---

## Section 7: The Entitlement Resolution System — How the App Knows if You're Premium

This is the subtlest part of the architecture. At any given moment, the app needs to answer "is this user premium?" The complication is that this question can be answered by multiple different systems, and they are not always in agreement.

### The Three Sources of Premium Truth

**Source 1: RevenueCat Live Entitlement**
RevenueCat maintains a live stream of the user's entitlements. When the app calls `Purchases.getCustomerInfo()`, it returns the current state from RevenueCat's servers, which in turn have the latest from the stores. This is the most accurate source.

The limitation: it requires a network call. In offline mode, you cannot call RevenueCat. Also, every call adds latency. We can't check RevenueCat on every button tap.

**Source 2: Supabase Profile Mirror (`lv_user_profiles.is_premium`)**
The backend stores a copy of the premium state. This is updated by RevenueCat webhooks (subscription events fire HTTP POST requests to our backend, which updates the database).

The limitation: webhooks can be delayed or missed. There can be a lag between "subscription purchased" and "backend updated." Not reliable for real-time gating in the app.

**Source 3: Local ObjectBox Cache**
The app caches the premium state locally in ObjectBox. When RevenueCat returns `premium: true`, we write that to local cache. Subsequent checks read from cache. This is instantaneous (no network) and works offline.

The limitation: can become stale. If a user's subscription expires, the local cache might still say premium for a while.

### How We Combine These Sources

The design uses an OR logic for allowing premium access, and a tiered approach for freshness:

- When the app starts, it reads the RevenueCat live entitlement (network permitting) and updates the local cache.
- The `isPremiumProvider` in the app computes: `dbPremium (from auth stream) OR rcPremium (from RevenueCat listener stream)`.
- DayPass checks use the local ObjectBox cache first, which was written by the above.
- The local cache is always refreshed whenever RevenueCat's listener fires (which happens on subscription changes) or when the auth state changes.

This means:
- In the normal online case: premium state is current within seconds.
- In offline mode: premium state is whatever was last written to cache. If a user had premium when they went offline, they continue to have access. If their subscription expired while offline, they may have access briefly after coming online (until cache refresh). This is acceptable — it's a window of at most a few hours in practice.

### The Mismatch Problem and Why It's Acceptable

There will always be short windows where the three sources disagree. For example:

- User buys premium on device A.
- RevenueCat records it immediately.
- RevenueCat sends a webhook to our Supabase backend.
- The webhook arrives 2 seconds later and updates `is_premium`.
- Device B opens LinkVault at second 1 — it reads Supabase profile and gets `is_premium = false` (not yet updated).
- At second 3, device B refreshes from RevenueCat — now it knows premium.

The 2-second window of mismatch is invisible to the user. They get premium almost immediately. This is the eventual consistency model: the system converges to the correct state, it just might take a moment.

The unacceptable failure is the permanent mismatch: "user bought premium but never gets it." We guard against this by:
1. Using the direct return value from `purchase()` (always fresh)
2. Having the RevenueCat listener stream in the app, which fires when entitlements change
3. Providing a "Restore purchases" button that forces a fresh entitlement check

---

## Section 8: The Gating System — How Feature Access is Enforced

The gating system is the policy engine that decides what users can do. It is designed after how Curate handles access control, which we call "Curate-style parent-action gating."

### The Core Philosophy: Gate Actions, Not Views

There are two philosophies for access control in apps:

**Philosophy A: Hide everything from non-premium users.** Blur out features, show lock icons, refuse to display content until the user pays. This is aggressive and often drives users away before they see the value.

**Philosophy B: Let users browse and see, gate only when they try to do something.** Users can see their collections, browse their links, and use read-only features freely. When they try to create, edit, or use a premium capability, they hit a gate.

We use Philosophy B. The rationale is:
- Users who can see the value of their data are more motivated to pay to unlock it.
- Browsing your own content is not a premium feature — it's basic utility.
- Gating reduces frustration for trial/grace users who have access but haven't watched an ad yet.

### Parent-Action Gating

"Parent-action gating" means we check access at the point of user intent, not inside the target screen.

Example of what NOT to do: User taps "New Collection" → navigates to CreateCollectionScreen → screen loads → screen checks access → access denied → screen redirects to DayPass. This is bad because the screen loaded unnecessarily, the navigation happened unnecessarily, and the UX is jarring.

Example of what we DO: User taps "New Collection" button → before navigation, check access → if denied, show DayPass screen → if granted, then navigate to CreateCollectionScreen. The user never reaches a screen they cannot use.

This is "gating at the parent screen's action point." The parent screen (collections list) is responsible for checking access before it allows the user to proceed to child screens (create collection).

### DayPass as the Canonical Denial UX

When access is denied (DayPass expired, not premium), we navigate to the DayPass screen at `/daypass`. This screen:
- Shows the user's current status (expired, how long since trial, etc.)
- Offers two options: watch an ad or upgrade to premium
- Returns a typed result: `true` (access granted) or `false` (user dismissed)

The calling code waits for this result:
```
parent screen taps button
   → check access (DayPassGate.check)
   → if expired: navigate to /daypass, await result
      → if true: proceed with the original action
      → if false: do nothing, user chose not to watch
   → if not expired: proceed immediately
```

This is a clean, predictable flow. Every gated action in the app uses this exact pattern. The screen that hosts the DayPass can even return `true` automatically when premium is purchased from within (since premium bypasses the gate entirely).

### Quota Gating vs DayPass Gating

These are different gate types for different situations:

**DayPass gate**: "You need to watch an ad or be premium to use this feature." Applies to all feature actions after the trial period. The blocker is access/subscription, not volume.

**Quota gate**: "You have used this feature too many times as a free user." Applies specifically to create operations (creating collections, adding links) when the user exceeds their allowed count. The blocker is volume, not access. The resolution is to upgrade to premium (which removes the quota), not to watch an ad.

Both types use the same gating framework but route to different resolution UIs: DayPass gate routes to `/daypass`, quota gate routes to `/paywall` with a message about the specific limit hit.

---

## Section 9: Scalability Considerations

How does this system scale as user count grows?

### Supabase Scaling

Supabase pricing is based on compute tier, database size, and egress (data transferred out). With proper design:

- **Indexes** on `owner_id`, `parent_id`, and `updated_at` mean queries are always fast even with millions of rows.
- **Soft deletes** instead of hard deletes keep query patterns consistent and prevent unexpected read latency from index fragmentation.
- **Paginated queries** (load 20 collections at a time, not all 200) limit per-request data size.
- **Delta sync** (only sync rows changed since last sync) means sync bandwidth is proportional to activity, not total data size.

At 10,000 users with 500 links each = 5,000,000 `lv_urls` rows. With proper indexing, a query filtered by `owner_id` (a UUID) scans no more than ~500 rows for the median user. Postgres handles this trivially.

At 1,000,000 users, we would need to consider horizontal partitioning and possibly move to a larger Supabase instance or Supabase Pro. But the schema design supports this without changes.

### RevenueCat Scaling

RevenueCat is a hosted SaaS and handles scaling transparently. Their pricing is based on Monthly Tracked Revenue (MTR). At our scale, costs are minimal. At large scale, RevenueCat pricing grows with revenue, so the cost is always proportional to earnings.

### The DayPass System Scaling

The DayPass system scales because it is local-first. As user count grows, each user's DayPass state is managed on their own device. We do not make server calls to check DayPass status. The only server-dependent part is the ad loading (via AdMob), which is AdMob's problem to scale.

### The Shared Subscription System at Scale

Shared subscriptions (one purchase unlocking multiple apps) scale because:
- RevenueCat's entitlement system is the single source of truth
- It handles the cross-app lookup transparently
- Each app just asks "does user X have the `premium` entitlement?" and gets a cached response

At scale, the main consideration is making sure both apps maintain consistent App User ID conventions so the lookup always works.

---

## Section 10: What We Have Not Yet Built (Current Gaps)

This section documents known incomplete areas of the architecture, so you know where the design is solid vs where it is aspirational.

### RevenueCat → Supabase Webhook

Currently, when a user purchases premium, the app updates the local premium cache and the UI reflects premium. But the `lv_user_profiles.is_premium` column in Supabase is **not yet automatically updated by webhooks**. The mirror is only updated when the app refreshes auth state.

This means server-side quota enforcement based on `is_premium` is not yet reliable. The client-side quota check works, but the server-side gate does not yet use `is_premium` from the profile.

**What needs to be built**: A Supabase Edge Function (or external webhook handler) that receives RevenueCat subscription events and updates `lv_user_profiles`.

### Quota Enforcement at RPC Level

Currently, quota enforcement is implemented client-side only. The server does not yet reject collection creates that exceed the free-tier quota limit.

**What needs to be built**: A Postgres function or RLS policy that counts the user's collections/urls before allowing inserts, returning an error with a specific code the app can handle.

### Graceful Downgrade UX

When a premium subscription expires, the current behavior is not fully defined in code. The user might see their quota data in a read-only state, or they might see a blocking upgrade prompt.

**What needs to be built**: Explicit downgrade state handling in the Data Persistence State Machine.

---

## Summary: The Full Mental Model

To hold the entire system in your head, think of it as three layers with clear responsibilities:

```
┌─────────────────────────────────────────────────────┐
│                    POLICY LAYER                      │
│  DayPassGate + GatingMatrix + QuotaGuard            │
│  "What can this user do right now?"                 │
│  reads from ↓ both layers                           │
└──────────────────────┬──────────────────────────────┘
                       │
        ┌──────────────▼──────────────┐
        │                             │
┌───────▼────────┐          ┌────────▼────────┐
│  BILLING       │          │   DATA          │
│  RevenueCat    │          │   Supabase +    │
│  + App Store   │          │   ObjectBox     │
│  "Did they     │          │  "Where does    │
│   pay?"        │          │   data live?"   │
└────────────────┘          └─────────────────┘
```

The Policy Layer is the app. It reads from both systems and decides what to do. The Billing and Data layers are independent services that do not know about each other. The app is the integrator.

---

## Further Reading (In Order)

1. This document (conceptual architecture) — you are here
2. [Shared_Subscription_Setup_Runbook.md](Shared_Subscription_Setup_Runbook.md) — how to set up all the platforms
3. [Monetization_Strategy_RevenueCat_Guide.md](Monetization_Strategy_RevenueCat_Guide.md) — detailed RevenueCat setup steps and common pitfalls
4. [RevenueCat_Setup_And_Architecture_LinkVault.md](RevenueCat_Setup_And_Architecture_LinkVault.md) — how this maps to the actual Flutter code
5. [Data_Persistence_State_Machine.md](../04_DATA_AND_MIGRATION/Data_Persistence_State_Machine.md) — the complete state machine for storage routing
6. [ADR_0002](../10_DECISIONS_AND_RISKS/ADR_0002_Free_Tier_Supabase_Quotas_and_Day_Pass.md) — the formal decision record for why free users get cloud access with quotas
