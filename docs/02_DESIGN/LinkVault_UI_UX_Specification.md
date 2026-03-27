# LinkVault — Complete UI/UX Design Specification

**Version:** 2.1  
**Date:** March 2026  
**Status:** Approved for Implementation  
**Author:** Product Design (AI-assisted)  
**Platform:** Flutter · iOS 14+ · Android API 26+

**v2.2 Changes:**
- Section 8 root hub updated to single-content mode (no visible single-tab title at root)
- Section 8 Folders/Links toolbars updated to compact search + adjacent filter controls
- Section 8 empty-state rule updated: hide FAB when empty-state primary CTA is visible
- Section 8 filter sheets updated with intrinsic/max-height and internal scrolling behavior
- Section 8 adds filter implementation-status checklist for engineering handoff

**v2.1 Changes:**
- Section 3: "Library" tab renamed to "Collections"; points to Unified Hub at root level
- Section 6: Home Dashboard adds pinned URLs, recent URLs, quick stats moved above fold, layout toggle for recent collections; new 6.8 PinnedUrlChip and 6.9 RecentUrlTile component specs
- Section 7: LibraryScreen deprecated and removed; component specs 7.4–7.5 retained
- Section 8: Route note updated for root mode; Section 8.5 adds Compact layout wireframe; Section 8.6 adds widget–code mapping table; Section 8.7 adds date chip to toolbar; Section 8.8 adds Date Range filter; new Section 8.8a Folders Filter & Sort Bottom Sheet with category filter

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Design System](#2-design-system)
3. [Navigation Architecture](#3-navigation-architecture)
4. [Splash & Onboarding](#4-splash--onboarding)
5. [Authentication Screens](#5-authentication-screens)
6. [Home Dashboard](#6-home-dashboard)
7. [Library Screen — Removed v2.1](#7-library-screen-removed-in-v21)
8. [Unified Collection Hub](#8-unified-collection-hub)
9. [Create / Edit Collection](#9-create--edit-collection)
10. [Create / Edit URL (Item)](#10-create--edit-url-item)
11. [URL Detail Screen](#11-url-detail-screen)
12. [Global Search](#12-global-search)
13. [RSS Feed Reader](#13-rss-feed-reader)
14. [Profile & Settings](#14-profile--settings)
15. [Monetization Screens](#15-monetization-screens)
16. [Component Library](#16-component-library)
17. [Interaction & Animation Patterns](#17-interaction--animation-patterns)
18. [Screen State Matrix](#18-screen-state-matrix)
19. [AI Image Generation Prompts](#19-ai-image-generation-prompts)

---

# 1. Design Philosophy

## 1.1 Vision Statement

> **"A vault that feels like a studio — organized power with the aesthetic of calm."**

LinkVault is a productivity tool, but it should never feel utilitarian. Every screen should feel intentional, spacious, and satisfying to use. The design language draws from premium note-taking apps (Craft, Notion), premium bookmark managers (Raindrop.io), and mobile-first productivity tools (Things 3, Camo). Dark mode is the default, primary experience — not an afterthought.

## 1.2 The Five Core Principles

### 1. Calm Focus
Every screen has one primary job. Secondary actions are accessible but not competing for attention. The user should never feel cognitively overloaded. Generous whitespace is not wasted space — it is breathing room that signals confidence.

### 2. Progressive Disclosure
Simple entry points that reveal depth on demand. Create collection form shows only 3 fields by default; advanced metadata is behind a chevron. Filter sheet opens from a single button, not 4 rows of always-visible chips.

### 3. Haptic Honesty
Every interaction should communicate clearly through motion, color, and hierarchy. Loading states are smooth skeletons. Success states are affirming but brief. Error states are clear and offer resolution — never just a red icon.

### 4. Color Does Work
Collection `color_hex` from the database is a first-class UI element. It appears as accent bars, icon backgrounds, chip colors, and in-app browser header tints. The palette earns its presence — colors carry meaning and hierarchy.

### 5. Thumb-First Mobile Design
Primary actions are in thumb-reach zones (bottom 60% of screen). FABs are bottom-right. Navigation is bottom. Swipe gestures supplement tap actions. App bars are lean — max 3 icons.

## 1.3 Design Tone

**Adjectives for this product:** Focused · Organized · Capable · Premium · Calm  
**Not:** Loud · Gamified · Cluttered · Sterile · Corporate

## 1.4 Dark Mode Philosophy

Dark mode in LinkVault is the **default** and **primary** design direction. It uses a layered neutral system — not pure black — with surfaces at distinct elevation levels. Color in dark mode is used sparingly and purposefully (accent color, collection colors, status badges). Text uses an off-white to reduce eye strain.

---

# 2. Design System

## 2.1 Color Palette

### Base Surfaces (Dark Mode — Primary)

```
Surface 0 (Background)     #0A0A0A   — True background, behind everything
Surface 1 (Base)           #111111   — Bottom navigation, app-wide base
Surface 2 (Cards)          #181818   — Collection cards, URL cards
Surface 3 (Elevated)       #1F1F1F   — Modal sheets, input fields
Surface 4 (Hover/Active)   #2A2A2A   — Pressed states, selected rows
Surface 5 (Dividers)       #333333   — Hairline dividers between items
```

### Base Surfaces (Light Mode — Secondary)

```
Surface 0 (Background)     #F4F4F5   — True background
Surface 1 (Base)           #FFFFFF   — App-wide base
Surface 2 (Cards)          #F9F9FA   — Cards
Surface 3 (Elevated)       #FFFFFF   — Sheets, inputs with border
Surface 4 (Hover/Active)   #F0F0F1   — Pressed, selected
Surface 5 (Dividers)       #E4E4E7   — Hairlines
```

### Primary Accent

```
Accent 500   #5E6AD2   — Primary brand color (indigo-violet)
Accent 400   #7B84DA   — Hover, lighter variant
Accent 300   #9BA3E3   — Muted accent, secondary
Accent 600   #4A56C8   — Active, pressed
Accent 100   #E8EAFB   — Light chip background, light mode
```

*Design rationale: Indigo-violet is sophisticated and productive. It avoids the orange accent of existing builds, differentiating the new design language while feeling premium. Orange is reserved for premium/upgrade CTAs only.*

### Semantic Colors

```
Success      #22C55E / #16A34A    — Saved, synced, premium active
Warning      #F59E0B / #D97706    — Grace period, expiring trial
Error        #EF4444 / #DC2626    — Validation, destructive actions
Info         #3B82F6 / #2563EB    — Informational banners
Premium Gold #F59E0B              — Premium badge, upgrade CTAs
```

### Status Colors (URL Status Pills)

```
Unread       #5E6AD2 bg + #C7CAF0 text   — Default new link
Read         #22C55E bg (10% opacity) + #4ADE80 text
Archived     #71717A bg (15% opacity) + #A1A1AA text
Pinned       #F59E0B bg (12% opacity) + #FCD34D text (shown as indicator)
```

### Collection Color Palette (User-Selectable, 16 options)

These map to the `color_hex` field in `lv_collections`. Each color is used as:
- Top accent bar on collection cards
- Icon container background (at 15% opacity)
- Left-side accent bar on list tiles
- Chip dot in pinned row

```
Indigo       #6366F1    Teal         #14B8A6
Violet       #8B5CF6    Emerald      #10B981
Pink         #EC4899    Lime         #84CC16
Rose         #F43F5E    Amber        #F59E0B
Red          #EF4444    Orange       #F97316
Coral        #FB7185    Sky          #0EA5E9
Purple       #A855F7    Slate        #64748B
Blue         #3B82F6    Stone        #78716C
```

## 2.2 Typography

### Font Stack

**Primary (UI + Headings):** `Plus Jakarta Sans`
- Variable font with excellent weights from 300–800
- Slightly humanist sans — feels friendly but professional
- Better than Inter for premium apps; more character, same legibility
- Google Fonts, open source

**Secondary (Body + Captions):** `DM Sans`
- Optimized for digital UI at small sizes
- Neutral, highly legible
- Pairs naturally with Plus Jakarta Sans

**Monospace (URLs, domains, code):** `JetBrains Mono`
- For domain names, URL previews
- Readable at 11–12sp
- Distinguishes URL content from titles visually

**Fallback:** `-apple-system, BlinkMacSystemFont, system-ui, sans-serif`

### Type Scale

| Token         | Font             | Size  | Weight  | Line Height | Usage                          |
|---------------|------------------|-------|---------|-------------|--------------------------------|
| `display-lg`  | Plus Jakarta Sans| 28sp  | 700     | 36sp        | Screen hero titles             |
| `display-md`  | Plus Jakarta Sans| 22sp  | 600     | 30sp        | Section headings, modal titles |
| `title-lg`    | Plus Jakarta Sans| 18sp  | 600     | 26sp        | Card titles, app bar           |
| `title-md`    | Plus Jakarta Sans| 16sp  | 600     | 22sp        | Collection names               |
| `title-sm`    | Plus Jakarta Sans| 14sp  | 600     | 20sp        | URL titles                     |
| `body-lg`     | DM Sans          | 16sp  | 400     | 24sp        | Descriptions, body text        |
| `body-md`     | DM Sans          | 14sp  | 400     | 20sp        | Secondary info, metadata       |
| `body-sm`     | DM Sans          | 13sp  | 400     | 18sp        | Tags, captions                 |
| `label-lg`    | Plus Jakarta Sans| 13sp  | 500     | 18sp        | Filter chips, badges           |
| `label-md`    | Plus Jakarta Sans| 11sp  | 600     | 16sp        | Section overlines (uppercase)  |
| `label-sm`    | Plus Jakarta Sans| 10sp  | 500     | 14sp        | Metadata counts                |
| `mono-md`     | JetBrains Mono   | 12sp  | 400     | 18sp        | Domain names, URLs             |

### Text Color Hierarchy (Dark Mode)

```
Primary Text    #F0F0F0   — Titles, primary labels
Secondary Text  #A0A0A0   — Subtitles, counts, timestamps
Tertiary Text   #606060   — Placeholder, disabled
Accent Text     #8B8FF0   — Links, tappable text
Danger Text     #F87171   — Errors, destructive labels
```

## 2.3 Spacing System (8pt Grid)

```
space-1   4px    — Icon-to-label gap, tight internal
space-2   8px    — Chip internal padding, small gaps
space-3   12px   — Card inner padding (compact)
space-4   16px   — Standard horizontal page margin
space-5   20px   — Card inner padding (standard)
space-6   24px   — Between sections
space-7   28px   — Generous section gap
space-8   32px   — Large separation
space-10  40px   — Top of content below app bar
space-12  48px   — Tall button height
space-14  56px   — Bottom nav height
space-16  64px   — FAB area clearance
```

## 2.4 Shape & Radius

```
radius-xs   4px    — Badges, small chips
radius-sm   8px    — Tags, small cards
radius-md   12px   — Filter chips, buttons
radius-lg   16px   — Collection cards, modals
radius-xl   20px   — Bottom sheets (top corners only)
radius-full 999px  — Pills, avatars, FAB
```

## 2.5 Elevation & Borders

Dark mode uses borders (not shadows) for elevation — shadows are invisible on dark backgrounds:

```
Border 0  none                       — Seamless containers
Border 1  1px solid #1E1E1E          — Cards on Surface 0
Border 2  1px solid #252525          — Elevated cards
Border 3  1px solid #2F2F2F          — Active/focus states
Sheet     0 -2px 20px rgba(0,0,0,.5) — Bottom sheet shadow (upward)
```

## 2.6 Iconography

**Library:** Material Symbols (Outlined weight)  
**Style:** Outlined, 24dp default, 20dp compact, `wght=300`  
**Key icons used:**

```
home_outlined           — Home tab
folder_outlined         — Collections / Library tab
search_outlined         — Search tab
person_outlined         — Profile tab
add                     — FAB primary action
create_new_folder       — Add subfolder
link                    — URL / item
bookmark_border         — Save / unread
bookmark                — Saved / read
push_pin_outlined       — Pin action
archive_outlined        — Archive
more_vert               — Overflow menu
tune                    — Filter/sort
view_list               — List layout
grid_view               — Grid layout
view_compact            — Compact layout
chevron_right           — Navigation, expand
expand_more             — Dropdown
close                   — Dismiss
check                   — Confirm, active state
rss_feed                — RSS tab
open_in_new             — Open in browser
content_copy            — Copy URL
delete_outline          — Delete
edit_outlined           — Edit
cloud_sync              — Sync status
cloud_done              — Synced
wifi_off                — Offline indicator
```

## 2.7 Motion & Animation

```
Duration Short   150ms  — Button press, chip toggle
Duration Medium  250ms  — Sheet open/close, tab switch
Duration Long    350ms  — Screen transition, card expand
Duration XLong   500ms  — Skeleton → content crossfade

Easing Standard   cubic-bezier(0.2, 0, 0, 1)   — Most transitions
Easing Enter      cubic-bezier(0, 0, 0.2, 1)   — Elements entering
Easing Exit       cubic-bezier(0.4, 0, 1, 1)   — Elements leaving
Easing Spring     spring(1, 80, 10, 0)          — FAB, success moments
```

---

# 3. Navigation Architecture

## 3.1 Bottom Navigation Bar

Four persistent tabs. Always visible except when:
- Inside a URL detail screen (immersive view)
- Watching a rewarded ad
- Onboarding flow

```
┌───────────────────────────────────────────────┐
│  ⌂ Home  │  ⊞ Collections  │  ⌕ Search  │  ◯ Profile │
└───────────────────────────────────────────────┘
```

**Tab specs:**
- Height: 60px + safe area inset
- Active: accent color icon + label + 2px pill indicator above icon
- Inactive: tertiary color icon + label
- Badge: red dot (notifications) on bell, count on profile if premium expiring
- Haptic: light impact on tab switch

> **v2.1 Change:** The "Library" tab has been renamed and replaced by the "Collections" tab.
> The separate LibraryScreen is removed; the Collections tab now directly renders the
> Unified Collection Hub (Section 8) at root level. See Section 7 for the deprecation notice.

## 3.2 Screen Hierarchy

```
App
├── /splash                         SplashScreen
├── /onboarding                     OnboardingScreen (3 slides)
├── /auth/welcome                   WelcomeScreen
├── /auth/email                     AuthEmailScreen
├── /auth/verify                    AuthVerifyScreen
│
├── / [Bottom Nav]
│   ├── TAB: Home                   HomeDashboardScreen
│   ├── TAB: Collections            CollectionHubScreen (root, /collections)
│   │   └── /collections/:id        CollectionHubScreen (child)
│   │       ├── Tab: Folders        FoldersTab
│   │       │   └── /collections/:id  (recursive)
│   │       └── Tab: Links          LinksTab
│   │           └── /collections/:id/items/:itemId  UrlDetailScreen
│   ├── TAB: Search                 GlobalSearchScreen
│   └── TAB: Profile                ProfileScreen
│       ├── /profile/edit           EditProfileScreen
│       ├── /profile/settings       AppSettingsScreen
│       └── /profile/legal          LegalScreen
│
├── /collections/create             CreateCollectionScreen
├── /collections/:id/edit           EditCollectionScreen
├── /collections/:id/items/create   CreateUrlScreen
├── /collections/:id/items/:id/edit EditUrlScreen
├── /rss                            RssFeedsScreen
├── /rss/:feedId                    RssFeedDetailScreen
├── /paywall                        PaywallScreen
├── /ad-gate                        AdGateScreen
└── /migration                      MigrationScreen
```

**Root vs. child CollectionHubScreen:**  
At `/collections` (root), the Hub loads all collections where `parent_id IS NULL` as a single folders surface (no visible tab title). At `/collections/:id`, it loads the specific collection's children and URLs in two-tab mode. The breadcrumb at root shows "Collections" with no ancestors.

## 3.3 Navigation Patterns

**Push navigation:** Collection hub (child), URL detail, create/edit screens  
**Modal presentation:** Bottom sheets (filters, overflow menus, collection picker)  
**Tab switching:** Home ↔ Collections ↔ Search ↔ Profile  
**Deep linking:** `/collections/:id` from share notifications, widgets

### Breadcrumb Logic
Every CollectionHubScreen shows a breadcrumb in the app bar subtitle position:
```
Collections › Flutter › Libraries › Packages
```
At root level there is no breadcrumb — only the title "Collections" is shown. Each segment is tappable and navigates directly to that level (not just back). Breadcrumb truncates with ellipsis if > 3 levels deep:
```
Collections › … › Libraries › Packages
```

---

# 4. Splash & Onboarding

## 4.1 Splash Screen

**Route:** `/splash`  
**Duration:** 1.5s minimum, waits for auth state resolution

```
┌─────────────────────────────┐
│                             │
│                             │
│                             │
│         ╔══════╗            │
│         ║  LV  ║            │   ← App logo (80×80, rounded-xl)
│         ╚══════╝            │
│                             │
│        LinkVault            │   ← title-lg, Primary text
│                             │
│    ░░░░░░░░░░░░░░░░         │   ← Linear progress, accent color
│                             │
│                             │
│                             │
│  v1.0.0          Anthropic  │   ← label-sm, Tertiary text
└─────────────────────────────┘
```

**Background:** Surface 0 (#0A0A0A)  
**Animation:** Logo fades in (0–400ms), title slides up (300–600ms), progress appears (500ms+)

---

## 4.2 Onboarding Screen

**Route:** `/onboarding`  
**Slides:** 3 pages with PageView, swipeable

### Slide 1 — Save Anywhere

```
┌─────────────────────────────┐
│                        Skip │  ← label-lg, accent color, top-right
│                             │
│                             │
│   ┌─────────────────────┐   │
│   │                     │   │
│   │   [Illustration:    │   │   ← Full illustration, 60% screen height
│   │   Phone with share  │   │     Lottie or static SVG
│   │   sheet + LV logo]  │   │
│   │                     │   │
│   └─────────────────────┘   │
│                             │
│   Save links in 2 taps      │   ← display-md, centered
│                             │
│   From any app. WhatsApp,   │   ← body-md, centered, Secondary text
│   Chrome, Instagram — share │
│   once, find forever.       │
│                             │
│          ● ○ ○              │   ← Dot indicators, accent = active
│                             │
│   ┌─────────────────────┐   │
│   │       Next →        │   │   ← Full-width pill button, accent bg
│   └─────────────────────┘   │
└─────────────────────────────┘
```

### Slide 2 — Organize

```
┌─────────────────────────────┐
│                        Skip │
│   [Illustration: Nested     │
│   folder tree with colors]  │
│                             │
│   Folders inside folders    │   ← display-md
│                             │
│   Create nested collections.│   ← body-md
│   Dev › Flutter › Packages. │
│   Infinite depth.           │
│                             │
│          ○ ● ○              │
│   ┌─────────────────────┐   │
│   │       Next →        │   │
│   └─────────────────────┘   │
└─────────────────────────────┘
```

### Slide 3 — Access Anywhere

```
┌─────────────────────────────┐
│                        Skip │
│   [Illustration: Two        │
│   phones syncing, cloud]    │
│                             │
│   Your links, everywhere    │   ← display-md
│                             │
│   Works offline. Sync to    │   ← body-md
│   any device with Premium.  │
│                             │
│          ○ ○ ●              │
│   ┌─────────────────────┐   │
│   │    Get Started →    │   │   ← Final CTA
│   └─────────────────────┘   │
└─────────────────────────────┘
```

**Interaction details:**
- Swipe left/right to navigate slides
- Skip → completes onboarding, goes to `/auth/welcome`
- Dot indicators: 8px circle, 4px gap; active = accent color 24px wide (pill)
- Page transition: horizontal slide at 300ms standard easing
- Illustration zone: fixed 56% of screen height

---

# 5. Authentication Screens

## 5.1 Welcome Screen

**Route:** `/auth/welcome`

```
┌─────────────────────────────┐
│                             │
│                             │
│         ╔══════╗            │
│         ║  LV  ║            │   ← Logo, 64×64
│         ╚══════╝            │
│                             │
│       LinkVault             │   ← display-lg, Primary text
│  Save links. Find them.     │   ← body-lg, Secondary text
│                             │
│                             │
│   ┌─────────────────────┐   │
│   │      Sign up        │   │   ← Filled button, accent bg
│   └─────────────────────┘   │
│                             │
│   ┌─────────────────────┐   │
│   │      Sign in        │   │   ← Outlined button, accent border
│   └─────────────────────┘   │
│                             │
│   ─────────── or ─────────  │   ← Divider with label
│                             │
│   Continue as Guest →       │   ← Text link, centered, accent color
│                             │
│                             │
│  By continuing, you agree   │   ← label-sm, tertiary text, centered
│  to our Terms & Privacy     │
└─────────────────────────────┘
```

## 5.2 Auth Email Screen

**Route:** `/auth/email`  
**Variant:** `AppOtpType.signup` vs `AppOtpType.magiclink`

```
┌─────────────────────────────┐
│  ←                          │   ← Back button
│                             │
│  Create your account        │   ← display-md  (or "Welcome back")
│  We'll send a code to your  │   ← body-md, Secondary text
│  email to verify.           │
│                             │
│  ─────────────────────────  │
│                             │
│  Email address              │   ← label-lg, Secondary text
│  ┌─────────────────────┐    │
│  │ you@email.com       │    │   ← Input field, Surface 3, rounded-md
│  └─────────────────────┘    │
│                             │
│  [Error: Enter valid email] │   ← body-sm, danger color (only on error)
│                             │
│                             │
│   ┌─────────────────────┐   │
│   │      Continue       │   │   ← Full-width filled button
│   └─────────────────────┘   │
│   (shows spinner when busy) │
│                             │
│  Already have an account?   │   ← centered, body-sm
│  Sign in →                  │   ← accent text link
│                             │
│  ─── Privacy note ───       │
│  Your links stay local      │   ← label-sm, tertiary
│  until you choose to sync.  │
└─────────────────────────────┘
```

**Input states:**
- Default: Surface 3 bg, Border 1
- Focused: Border 3 (accent color), subtle glow
- Error: Danger color border, error message below
- Loading: Input disabled, opacity 0.6

## 5.3 Auth Verify Screen

**Route:** `/auth/verify`

```
┌─────────────────────────────┐
│  ←                          │
│                             │
│        ✉ [Mail icon]        │   ← 56px, accent bg circle
│                             │
│   Check your inbox          │   ← display-md
│                             │
│   Enter the 6-digit code    │   ← body-md, Secondary
│   sent to                   │
│   you@email.com             │   ← body-md, accent color
│                             │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐  │
│  │  │ │  │ │  │ │  │ │  │ │  │  │   ← Pinput, 48×56px each
│  └──┘ └──┘ └──┘ └──┘ └──┘ └──┘  │     auto-verify on complete
│                             │
│  ────── States below ──────  │
│  [Verifying...] spinner     │   ← On complete, auto-submit
│  [Error: Invalid code]      │   ← body-sm, danger
│                             │
│  Didn't receive it?         │   ← body-sm, Secondary
│  Resend code (30s)          │   ← accent, shows countdown
│                             │
│  Wrong email? Change it     │   ← text link
└─────────────────────────────┘
```

**Pinput cell design:**
- Background: Surface 3
- Border default: Border 2
- Border focused: 2px accent color
- Border filled: Border 3
- Border error: 2px danger color
- Font: display-md, monospace
- Cursor: accent color, blinking

---

# 6. Home Dashboard

## 6.1 Overview

The Home screen is the **quick-resume dashboard**. It is NOT a full browser of all collections — that's the Collections tab. Home answers: "What was I working on? What did I recently save?"

**Content hierarchy:**
1. Greeting + day context
2. Quick stats strip (3 counters — always visible, above the fold)
3. Pinned collections (horizontal scroll, if any)
4. Pinned URLs (horizontal scroll, if any)
5. Recently accessed collections (list, max 10, with layout toggle)
6. Recently saved URLs (slim list, max 5)

## 6.2 State: Content (with pinned + recent)

```
┌─────────────────────────────┐
│  [Avatar]  LinkVault  🔔 ⌕  │   ← App bar: avatar, title, bell, search
├─────────────────────────────┤
│                             │
│  Good evening, Rahul ✦      │   ← display-md, Primary text
│  Thursday · 14 links saved  │   ← body-sm, Secondary text
│                             │
│ ─────────────────────────── │
│  ┌──────┐┌──────┐┌──────┐  │   ← QUICK STATS (always above the fold)
│  │  14  ││  3   ││  7   │  │     Stat cards: Total links, Collections,
│  │links ││colls ││unreads│  │     Unread count
│  └──────┘└──────┘└──────┘  │
│                             │
│ ─────────────────────────── │
│  PINNED COLLECTIONS         │   ← label-md (uppercase), Section label
│                             │
│  ┌──────────┐ ┌──────────┐  │
│  │ ▌Flutter │ │ ▌Design  │  │   ← PinnedChip (horizontal scroll)
│  │  24 lnks │ │  11 lnks │  │     See 6.6 for PinnedChip spec
│  └──────────┘ └──────────┘  │
│  ┌──────────┐               │
│  │ ▌Reading │               │
│  │  8 links │               │
│  └──────────┘               │
│                             │
│ ─────────────────────────── │
│  PINNED LINKS               │   ← Only shown if user has pinned URLs
│                             │
│  ┌──────────┐ ┌──────────┐  │
│  │[fav]     │ │[fav]     │  │   ← PinnedUrlChip (horizontal scroll)
│  │Flutter.. │ │Riverpod..│  │     See 6.8 for PinnedUrlChip spec
│  │code..com │ │youtube.. │  │
│  └──────────┘ └──────────┘  │
│                             │
│ ─────────────────────────── │
│  RECENT COLLECTIONS   ⊞ All→│   ← label-md + layout toggle icon + "All" link
│                             │
│  ┌─────────────────────────┐│
│  │ ▌ 📦 reactive    2m ago ││   ← RecentCollectionTile (see 6.7)
│  │    0 links              ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ ▌ 💼 reac        5m ago ││
│  │    0 links              ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ ▌ ⭐ linki       8m ago ││
│  │    0 links              ││
│  └─────────────────────────┘│
│                             │
│ ─────────────────────────── │
│  RECENT LINKS               │   ← label-md, last 5 saved/accessed URLs
│                             │
│  ┌─────────────────────────┐│
│  │[fav] Flutter Guide  2m ││   ← RecentUrlTile (see 6.9)
│  │      codewithandrea.com ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │[fav] Riverpod 3.0   5m ││
│  │      youtube.com        ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

**App bar detail:**
- Avatar: 34px circle, user initials or photo, tappable → `/profile`
- Title: "LinkVault" centered, title-lg
- Bell icon: tappable (placeholder for Phase 2 notifications)
- Search icon: tappable → `/search`

## 6.3 State: Empty (No collections yet)

```
┌─────────────────────────────┐
│  [Avatar]  LinkVault  🔔 ⌕  │
├─────────────────────────────┤
│                             │
│  Good morning, Rahul ✦      │
│  Let's get started          │   ← Subtitle changes when empty
│                             │
│                             │
│     ┌───────────────────┐   │
│     │  [Empty state     │   │
│     │   illustration:   │   │   ← Centered illustration, 200×200
│     │   open vault box] │   │
│     └───────────────────┘   │
│                             │
│    Your vault is empty      │   ← title-lg, centered
│                             │
│    Save your first link or  │   ← body-md, Secondary, centered
│    create a collection to   │
│    get organized.           │
│                             │
│  ┌────────────────────────┐ │
│  │  + Create collection   │ │   ← Filled button
│  └────────────────────────┘ │
│                             │
│  ┌────────────────────────┐ │
│  │  + Add first link      │ │   ← Outlined button
│  └────────────────────────┘ │
└─────────────────────────────┘
```

## 6.4 State: Loading (Skeleton)

```
┌─────────────────────────────┐
│  [●●●]  LinkVault  🔔 ⌕     │   ← Avatar = skeleton circle
├─────────────────────────────┤
│                             │
│  ░░░░░░░░░░░░░░░ (32px h)   │   ← Greeting skeleton
│  ░░░░░░░░░ (16px h)         │   ← Subtitle skeleton
│                             │
│  ░░░ (overline)             │
│  ┌────────┐ ┌────────┐      │
│  │░░░░░░░░│ │░░░░░░░░│      │   ← Pinned chip skeletons
│  └────────┘ └────────┘      │
│                             │
│  ░░░ (overline)             │
│  ┌──────────────────────┐   │
│  │░░░░░░░░░░░░░░░░░░░░░░│   │   ← List tile skeletons (3 rows)
│  └──────────────────────┘   │
│  ┌──────────────────────┐   │
│  │░░░░░░░░░░░░░░░░░░░░░░│   │
│  └──────────────────────┘   │
└─────────────────────────────┘
```

**Skeleton animation:** Shimmer left-to-right, 1.5s loop, Surface 3 → Surface 4 gradient

## 6.5 State: Error

```
┌─────────────────────────────┐
│  [Avatar]  LinkVault  🔔 ⌕  │
├─────────────────────────────┤
│                             │
│     ⚠ [Warning icon]        │   ← 48px, warning color
│                             │
│   Couldn't load your data   │   ← title-lg, centered
│                             │
│   Check your connection or  │   ← body-md, Secondary
│   try again.                │
│                             │
│  ┌────────────────────────┐ │
│  │       Try again        │ │   ← Filled button
│  └────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

## 6.6 PinnedChip Component

```
┌──────────────────┐
│▌ 📦 Flutter      │   ← ▌ = 3px left bar, collection color_hex
│   24 links       │   ← count, label-sm, tertiary
└──────────────────┘
```

- Width: 120px fixed
- Height: 56px
- Background: Surface 2
- Border: Border 1
- Radius: radius-lg (16px)
- Left bar: 3px × full height, `color_hex` from DB
- Icon: 20px, inside 28px circle, `color_hex` at 18% opacity bg
- Title: title-sm, 1 line, ellipsis
- Count: label-sm, tertiary
- Tap: navigate to CollectionHubScreen
- Long-press: bottom sheet (Edit, Unpin, Archive, Delete)

## 6.7 RecentCollectionTile Component

```
┌──────────────────────────────────┐
│▌  [icon]  reactive         2m › │   ← Icon 36px circle, title, time, chevron
│           0 links               │   ← count line, body-sm tertiary
└──────────────────────────────────┘
```

- Height: 60px
- Left bar: 3px, collection `color_hex`
- Background: Surface 2
- Border radius: radius-md (12px)
- Divider between tiles: none (use margin-bottom: 6px)
- Tap: navigate to CollectionHubScreen
- Long-press: bottom sheet (Edit, Pin, Archive, Delete)

**Layout toggle (section header row):**  
Two icon buttons sit in the section header next to the label: `⊞` (grid) and `≡` (list). Active mode icon is accent-colored; inactive is tertiary. Tapping toggles the layout for that section only — persisted in local storage. Grid mode renders `CollectionCard` (2-column); list mode renders `CollectionListTile`.

---

## 6.8 PinnedUrlChip Component

```
┌──────────────────┐
│ [fav 20px]       │   ← Favicon circle, 20px
│ Flutter Guide    │   ← title-sm, 2 lines, ellipsis
│ flutter.dev      │   ← mono-md, tertiary, 1 line
└──────────────────┘
```

- Width: 120px fixed
- Height: 72px
- Background: Surface 2
- Border: Border 1
- Radius: radius-lg (16px)
- Top-left: 3px × 3px accent dot (accent color) indicating pinned state
- Favicon: 20px circle, fallback = domain initial letter
- Title: title-sm, 2-line max, ellipsis
- Domain: mono-md, tertiary, 1 line, ellipsis
- Tap: opens URL detail screen
- Long-press: URL action sheet (Open, Copy, Edit, Unpin, Delete)

---

## 6.9 RecentUrlTile Component

```
┌──────────────────────────────────┐
│  [fav]  Flutter Riverpod Guide  ›│   ← favicon 20px, title, chevron
│         codewithandrea.com · 2m  │   ← domain (mono-md) + timestamp
└──────────────────────────────────┘
```

- Height: 52px
- Background: transparent (uses list row pattern)
- Favicon: 20px circle with fallback initial
- Title: title-sm, 1 line, ellipsis
- Subtitle: `{domain} · {relative time}`, body-sm, tertiary
- Chevron: right side, tertiary
- No left color bar (URLs are not collection-color-coded at this level)
- Tap: opens URL detail screen
- Long-press: URL action sheet

---

# 7. Library Screen (Removed in v2.1)

> **Deprecated and removed as of v2.1.** The dedicated Library screen (`CollectionsListScreen`) has been eliminated. Its functionality is now fully provided by the **Unified Collection Hub** (Section 8) operating at root level via the Collections tab.
>
> **Route change:** `/collections` (tab) now loads `CollectionHubScreen` in root mode rather than a separate `LibraryScreen`. Root mode is folders-only (no visible tab title); child mode retains folders + links tabs. The Hub keeps shared layouts, search, filters, sorting, actions sheet, and empty-state behavior across both modes.
>
> **See:** `docs/09_SPRINT_ARCHITECTURE/SPRINT_7_8_UX_REFACTOR/Library_Screen_Removal_Changelog.md` for the full implementation change log.

---

The component specifications below (7.4 and 7.5) are **retained** because these widgets are still used inside the Unified Collection Hub (Section 8.5).

## 7.4 CollectionCard Component (Grid)

```
┌─────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│   ← 4px top accent bar (color_hex)
│                     │
│  [Icon circle 40px] │   ← Icon 20px inside 40px circle
│  (color_hex at 18%  │     bg at 18% opacity of color_hex
│   opacity bg)       │
│                     │
│  reactive           │   ← title-md, Primary text, 2-line ellipsis
│                     │
│  0 links  📌        │   ← label-sm tertiary + pin icon if pinned
│                     │
└─────────────────────┘
```

- Width: (screen - 32px margin - 12px gap) / 2 = ~162px on 360px screen
- Height: 140px
- Background: Surface 2
- Border: Border 1
- Radius: radius-lg
- Long-press: collection action sheet (Edit, Pin, Archive, Delete)

## 7.5 CollectionListTile Component

```
┌────────────────────────────────────┐
│▌  [icon 36px]  reactive      ›    │
│               0 links · General    │
└────────────────────────────────────┘
```

- Height: 68px
- Left color bar: 3px, color_hex
- Icon: 36px circle with color_hex at 18% opacity bg, 18px icon
- Title: title-md, 1 line
- Subtitle: `{url_count} links · {category}`, body-sm tertiary
- Chevron: right side, tertiary color

---

# 8. Unified Collection Hub

**Route:** `/collections` (root) and `/collections/:id` (child)  
**This is the most complex and most important screen in the app.**

The CollectionHubScreen shows everything inside a collection: child sub-collections (Folders) and saved URLs (Links). It operates in two modes:

- **Root mode** (`/collections`): Single-content surface. Folders content only (all root collections, `parent_id IS NULL`). No visible single-tab title. No back button; no breadcrumb (title = "Collections").
- **Child mode** (`/collections/:id`): Two-tab hub. Folders tab shows direct sub-collections; Links tab shows URLs in that collection. Breadcrumb shows ancestors.

Both modes share the same collapsing header and rich empty states. Child mode keeps two tabs; root mode removes unnecessary tab chrome.

## 8.1 Screen Anatomy

```
┌─────────────────────────────┐
│  ←  Home › reactive    ⊕ ⋮ │   ← STICKY APP BAR (always visible)
├─────────────────────────────┤
│                             │
│  📦                         │   ← COLLAPSING HEADER (scrolls away)
│                             │   ← 48px icon circle
│  reactive                   │   ← display-md, Primary
│  General  ·  2 folders  ·   │   ← body-sm, Secondary
│  0 links                    │
│                             │
│  ─────────────────────────  │
│  [ Folders (2) ][ Links (0)]│   ← TAB BAR (child mode only)
├─────────────────────────────┤
│                             │
│  [TAB CONTENT]              │   ← Scrollable content area
│                             │
│                             │
│                             │
│                [FAB]        │   ← Tab-specific FAB
└─────────────────────────────┘
```

**Scroll behavior:**
- Collapsing header hides on scroll down (translateY: -headerHeight), reappears on scroll up
- In child mode, TabBar sticks to top of screen once header is hidden
- App bar title changes to collection name when header is hidden
- FAB hides on scroll down (to avoid covering content), reappears on scroll up

## 8.2 App Bar (Sticky)

```
│  ←  Home › reactive        [⋮] │
```

- Back button (←): returns to parent screen
- Breadcrumb: label-md, tertiary; last segment is accent color
- `⋮` icon: opens collection overflow sheet
- Primary create actions are not required in app bar for this flow; use empty-state CTA, FAB, and overflow-sheet actions.

**When header collapsed (title mode):**
```
│  ←  reactive               [⋮] │
```

## 8.3 Collapsing Header

```
┌──────────────────────────────────┐
│                                  │
│  [Icon circle 48px]              │
│  (emoji, color_hex bg 18%)       │
│                                  │
│  reactive                        │   ← display-md
│  General · 2 folders · 0 links   │   ← body-sm, Secondary
│                                  │
│  [Description line if set]       │   ← body-md, Secondary (optional)
│                                  │
└──────────────────────────────────┘
```

Height: ~140px. Collapses smoothly on scroll.

## 8.4 TabBar

```
┌──────────────────────────────────┐
│  [ Folders (2) ] │ [ Links (0) ] │
└──────────────────────────────────┘
```

- Underline indicator: 2px, accent color, animates between tabs
- Count in tab label: updates as content changes
- Both tabs lazy-load their content

### Root mode tab behavior

- At root (`/collections`), do not show a single-tab title/chrome.
- Render content directly (folders list) below the header.
- Keep tab UI only when two modes exist (child folders + links).

---

## 8.5 Folders Tab

### State: Content

```
┌─────────────────────────────┐
│  ─────── [Folders] ───────  │
│                             │
│  ┌──────────────────────────────┐ │
│  │ 🔍 Search folders…   [⚲][↕] │ │   ← Single compact row (default)
│  └──────────────────────────────┘ │
│                             │
│  ┌──────────┐ ┌──────────┐  │   ← Same CollectionCard as Library
│  │━━━━━━━━━━│ │━━━━━━━━━━│  │     (grid is default)
│  │  📱      │ │  🛠      │  │
│  │ Mobile UI│ │ Packages │  │
│  │ 12 links │ │ 7 links  │  │
│  └──────────┘ └──────────┘  │
│                             │
│          [FAB: + New folder]│   ← "New folder" label visible on FAB
└─────────────────────────────┘
```

**FAB label:** Extended FAB — `[+ New folder]` when list has content. Shrinks to icon-only FAB when user scrolls.

**Toolbar behavior (Folders):**
- Search and controls are adjacent in one compact row by default.
- Do not render a default stacked layout where filter/sort controls appear below search.
- On narrow widths, controls may compress or wrap only as a fallback without changing the primary one-row hierarchy.

### State: Empty (No sub-collections)

```
┌─────────────────────────────┐
│  ─────── [Folders] ───────  │
│                             │
│                             │
│   [Illustration:            │
│    empty folder with        │   ← 160×160px
│    + icon]                  │
│                             │
│   No folders here yet       │   ← title-md, centered
│                             │
│   Create a subfolder to     │   ← body-sm, Secondary, centered
│   organize this collection. │
│                             │
│  ┌─────────────────────┐    │
│  │  + New folder       │    │   ← Filled button, centered
│  └─────────────────────┘    │
│                             │
│      [No FAB in empty state]│
└─────────────────────────────┘
```

**Empty-state FAB rule (Folders):**
- If primary empty CTA (`+ New folder`) is visible, hide FAB.
- Show FAB only after at least one folder exists.

### Layout Options (set per collection, persists)

Controlled by overflow sheet:

```
⊞ Grid (2-column)      ← Default
≡ List (single column)
⊟ Compact (dense list, smaller tiles)
```

### Compact Layout Wireframe

```
┌────────────────────────────────────┐
│▌ [icon 28px]  Mobile UI   ▸ 12 lnks│  ← 44px row height, single line
│▌ [icon 28px]  Packages    ▸  7 lnks│
│▌ [icon 28px]  State Mgmt  ▸  4 lnks│
│▌ [icon 28px]  Testing     ▸  2 lnks│
└────────────────────────────────────┘
```

**Compact layout specs:**
- Row height: 44px
- Left color bar: 3px, `color_hex`
- Icon circle: 28px (vs 36px in list, 40px in grid), same opacity bg
- Title: title-sm, single line, ellipsis — no subtitle row
- Link count: label-sm, tertiary, right-aligned with `▸` separator
- Padding: 8px vertical, 12px horizontal (vs 12px/16px in list mode)
- Dense `ListTile` with `dense: true` — implemented via `CollectionListTile(compact: true)`
- No dividers between rows; relies on slight bg color contrast

---

## 8.6 Links Tab

### Widget–Code Mapping

Each layout mode in the Links tab maps to a specific Flutter widget in `lib/features/items/presentation/widgets/`:

| Layout | Widget | File | Notes |
|---|---|---|---|
| List (default) | `UrlPreviewTile(compact: false)` | `url_preview_tile.dart` | Shows title, description (2 lines), domain, status badge |
| Cards | `UrlPreviewTile(compact: false)` | `url_preview_tile.dart` | Same widget; full-height with 16:9 thumbnail image top |
| Icons / Compact | `UrlPreviewTile(compact: true)` | `url_preview_tile.dart` | Collapses to favicon + title + domain row, 44px height |
| Favicon display | `UrlFaviconTile` | `url_favicon_tile.dart` | Used internally by `UrlPreviewTile`; Google favicon API with domain-initial fallback |

> **Note:** `item_card.dart` is a legacy widget from an earlier sprint. It should not be used in new layouts. All URL rendering going forward uses `UrlPreviewTile`.

---

### State: Content (List layout, default)

```
┌─────────────────────────────┐
│  ─────── [Links] ────────  │
│                             │
│  ┌──────────────────────────────┐│
│  │ 🔍 Search links…  [📅][⚲][↕] ││   ← Compact search + adjacent controls
│  └─────────────────────────┘│
│                   ↑↑ detail on 8.7
│  ┌─────────────────────────┐│
│  │▌ [fav] Flutter Guide    ││   ← UrlListTile (see 8.10)
│  │        codewithandrea   ││
│  │        flutter  [unread]││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │▌ [yt]  Riverpod 3.0     ││
│  │        youtube.com      ││
│  │        riverpod  [read] ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │▌ [sb]  Supabase RLS     ││
│  │        supabase.com     ││
│  │        backend  [unread]││
│  └─────────────────────────┘│
│                             │
│         [FAB: + Add link]   │   ← Hidden when empty-state CTA is visible
└─────────────────────────────┘
```

### State: Content (Cards layout)

```
┌─────────────────────────────┐
│  ─────── [Links] ────────  │
│  ┌──────────────────────────────┐│
│  │ 🔍 Search links…  [📅][⚲][↕] ││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│   ← UrlCard (see 8.11)
│  │▓▓ [Thumbnail image] ▓▓▓▓││
│  │                          ││
│  │  Flutter Guide           ││
│  │  Complete setup for...   ││
│  │  [favicon] codewithand.. ││
│  │  flutter  state  [unread]││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │▓▓ [Thumbnail image] ▓▓▓▓││
│  │  Riverpod 3.0 Guide      ││
│  │  [favicon] youtube.com   ││
│  │  riverpod  [read]        ││
│  └──────────────────────────┘│
└─────────────────────────────┘
```

### State: Content (Icons/Compact layout)

```
┌─────────────────────────────┐
│  ─────── [Links] ────────  │
│  ┌──────────────────────────────┐│
│  │ 🔍 Search links…  [📅][⚲][↕] ││
│  └──────────────────────────┘│
│  [fav] Flutter Guide        ↗│  ← Compact: favicon, title, external icon
│  [yt]  Riverpod 3.0 Guide   ↗│  ← 44px height, no metadata shown
│  [sb]  Supabase RLS         ↗│
│  [gh]  Flutter SDK Source   ↗│
│  [tw]  Thread on widgets    ↗│
└─────────────────────────────┘
```

### State: Empty (No links)

```
┌─────────────────────────────┐
│  ─────── [Links] ────────  │
│                             │
│   [Illustration: bookmark   │
│    with dotted border +     │   ← 160×160px
│    link icon]               │
│                             │
│   No links yet              │   ← title-md, centered
│                             │
│   Add your first URL to     │   ← body-sm, Secondary, centered
│   start building this       │
│   collection.               │
│                             │
│  ┌─────────────────────┐    │
│  │  + Add link         │    │   ← Filled button
│  └─────────────────────┘    │
│                             │
│  ─── or share from ───      │   ← body-sm, tertiary
│  any app using the          │
│  share button               │
│                             │
│      [No FAB in empty state]│
└─────────────────────────────┘
```

**Empty-state FAB rule (Links):**
- If primary empty CTA (`+ Add link`) is visible, hide FAB.
- Show FAB only after at least one link exists.

### State: Filtered Empty ("No results")

```
┌─────────────────────────────┐
│  ─────── [Links tab] ─────  │
│  ┌──────────────────────────┐│
│  │ All  [Unread]  Read  ↕↾ 🔍││   ← Active filter chip shown
│  └──────────────────────────┘│
│                             │
│   🔍 [Search icon, muted]   │
│                             │
│   Nothing matches           │   ← title-md, centered
│                             │
│   No unread links in        │   ← body-sm, Secondary, centered
│   this collection.          │
│                             │
│  ┌─────────────────────┐    │
│  │  Clear filters      │    │   ← Outlined button
│  └─────────────────────┘    │
└─────────────────────────────┘
```

### State: Loading

- Filter toolbar visible immediately (structural)
- 5 UrlListTile skeletons with shimmer
- Skeleton: left accent bar (Surface 4), favicon circle, two text lines

## 8.7 Filter Toolbar (Links Tab)

The links toolbar occupies one compact row where search and controls are adjacent. It should not default to stacked rows because that wastes vertical space on mobile.

```
┌────────────────────────────────────────────┐
│ [🔍 Search links…] [📅] [⚲] [↕]               │
└────────────────────────────────────────────┘
```

**Search + control behavior:**
- Inline search field sits on the left.
- Control icons/chips sit adjacent on the right:
  - `📅` quick date chip
  - `⚲` full filter sheet
  - `↕` quick sort/menu
- Active filter count badge appears on `⚲` when non-default.
- On narrow screens, controls may wrap only as fallback while preserving compact hierarchy.
- Default behavior must not place filter controls on a dedicated row below search.

**Chip specs:**
- Height: 32px
- Padding: 8px horizontal
- Radius: radius-full (pill)
- Default: Surface 3 bg, Border 1, body-sm tertiary
- Active: accent bg (12% opacity), accent border, accent text
- Multiple filters can be active simultaneously

## 8.8 Filter & Sort Bottom Sheet (Links Tab)

Opened by tapping the Filters button. Implements `UrlsFilterSortSheet` in `lib/features/items/presentation/widgets/unified_collection_sheets.dart`.

```
┌─────────────────────────────┐
│         ──────              │   ← Handle bar, 40×4px, Surface 5
│                             │
│  Filter & sort       Reset  │   ← title-md + Reset text button (accent)
│                             │
│  VIEW                       │   ← label-md overline
│  [List] [Cards] [Icons]     │   ← Segmented control, 3 options
│                             │
│  STATUS                     │   ← label-md overline
│  [All] [Unread] [Read]      │   ← Filter chips, multi-select
│  [Archived]                 │
│                             │
│  SPECIAL                    │   ← label-md overline
│  [Pinned] [Has description] │   ← Filter chips
│  [Has image]                │
│                             │
│  DOMAIN                     │   ← label-md overline
│  ┌─────────────────────┐    │
│  │ e.g. youtube.com    │    │   ← Text input, filters by domain substring
│  └─────────────────────┘    │
│                             │
│  DATE RANGE                 │   ← label-md overline (new in v2.1)
│  Saved after                │
│  ┌─────────────────────┐    │
│  │ Pick date...      📅│    │   ← Date picker row, uses created_at
│  └─────────────────────┘    │
│  Saved before               │
│  ┌─────────────────────┐    │
│  │ Pick date...      📅│    │
│  └─────────────────────┘    │
│                             │
│  SORT BY                    │   ← label-md overline
│  ● Manual order             │   ← Radio group
│  ○ Recently added           │
│  ○ Recently edited          │
│  ○ Most visited             │
│  ○ Alphabetical A→Z         │
│  ○ Alphabetical Z→A         │
│                             │
│  ┌─────────────────────┐    │
│  │    Apply filters    │    │   ← Full-width filled button
│  └─────────────────────┘    │
└─────────────────────────────┘
```

**Date filter behavior:**
- Both date fields are optional; either or both can be set
- Selecting "Saved after: Jan 1" shows only URLs with `created_at >= Jan 1`
- Selecting both creates an inclusive date range
- Active date filter adds `📅` badge to the Filters button and highlights the `📅` toolbar chip

**Sheet behavior:**
- Opens with spring animation (250ms)
- Draggable handle: user can dismiss by dragging down
- `Reset` clears all filters back to default
- `Apply` dismisses sheet and applies filters
- Active filter count shows as badge on the Filters button in toolbar
- Uses adaptive sizing:
  - Intrinsic height for short content.
  - Expands up to ~85% viewport for long content.
  - Internal content area scrolls beyond max height.

## 8.8a Filter & Sort Bottom Sheet (Folders Tab)

Separate sheet for the Folders tab. Implements `ChildFoldersFilterSortSheet` in `lib/features/items/presentation/widgets/unified_collection_sheets.dart`.

```
┌─────────────────────────────┐
│         ──────              │
│                             │
│  Folder options      Reset  │
│                             │
│  LAYOUT                     │   ← label-md overline
│  [Grid] [List] [Compact]    │   ← Segmented control, 3 options
│                             │
│  CATEGORY                   │   ← label-md overline (new in v2.1)
│  [⭐ Favorites] [📁 General]│   ← Multi-select chips (wrap layout)
│  [💻 Dev] [📚 Reading]      │     14 options matching Section 9.2
│  [🎨 Design] [💡 Ideas]     │     No selection = show all categories
│  [💼 Work] [🎯 Goals]  ...  │
│                             │
│  SORT BY                    │   ← label-md overline
│  ● Title A → Z              │   ← Radio group
│  ○ Most links               │
│  ○ Recently updated         │
│  ○ Most visited             │
│  ○ Alphabetical A→Z         │
│  ○ Alphabetical Z→A         │
│                             │
│  DATE RANGE                 │   ← label-md overline
│  Updated after              │
│  ┌─────────────────────┐    │
│  │ Pick date...      📅│    │
│  └─────────────────────┘    │
│  Updated before             │
│  ┌─────────────────────┐    │
│  │ Pick date...      📅│    │
│  └─────────────────────┘    │
│                             │
│  Show archived folders [○]  │   ← SwitchListTile
│                             │
│  ┌─────────────────────┐    │
│  │    Apply            │    │   ← Full-width filled button
│  └─────────────────────┘    │
└─────────────────────────────┘
```

**Category filter behavior:**
- Filters child collections by their `category` field
- Multi-select: user can pick one or more categories; no selection = show all
- Category chips use the same icon + label as Section 9.2
- Active category selection adds a badge count to the Folders toolbar filter button

**Date/sort parity behavior (Folders):**
- Date range fields are optional; either or both can be set.
- Date filters apply to folder timestamps (`updated_at`) and can be combined with category/sort.
- Sort options align with links-sheet capabilities where meaningful for folders.
- Active date/category/sort selections contribute to the folders filter badge when non-default.

**Sheet sizing behavior (Folders + Links):**
- Bottom sheets should not occupy full screen by default.
- Height should match content up to max threshold.
- If options exceed threshold, body becomes scrollable while header/actions stay reachable.

## 8.8b Filter Implementation Status & Engineering Checklist

This section tracks filters visible in UI vs implementation state.

### Visible in UI (design-approved)
- Links: search, status chips, date chip, filter sheet, sort controls.
- Folders: search, filter/sort affordance, category + sort + archived controls in sheet.

### Implementation status marker
- **UI visible but integration pending** means one or more of:
  - query-layer wiring incomplete
  - persistence defaults not applied
  - badge/count state not synchronized

### Next implementation checklist
- Wire all visible filter controls to repository query behavior (or clearly defined client-side filtering).
- Persist last-used filter/sort state per collection where specified.
- Keep filter count badge accurate for non-default state only.
- Verify root mode hides links-specific controls.
- Add tests for:
  - compact toolbar wrapping behavior
  - empty-state FAB suppression
  - adaptive bottom-sheet height + scroll.

## 8.9 Collection Overflow Sheet (⋮ menu)

```
┌─────────────────────────────┐
│         ──────              │
│                             │
│  reactive                   │   ← Collection name
│  General · 2 folders        │   ← metadata
│                             │
│  ─────────────────────────  │
│                             │
│  ✏️  Edit collection        │
│  📁+ Add subfolder          │
│  🔗  Add link               │
│  ─────────────────────────  │
│  📌 Pin collection          │   ← toggles
│  📦 Archive collection      │
│  ─────────────────────────  │
│  ⚙️  View settings          │   ← layout defaults, sort defaults
│  ─────────────────────────  │
│                             │
│  🗑️  Delete collection      │   ← danger color
│                             │
└─────────────────────────────┘
```

**Sheet behavior and safety:**
- Overflow sheet must be scrollable when content exceeds available viewport height.
- Use adaptive sheet sizing (content-sized by default, capped max height) with internal scrolling beyond cap.
- Must not produce render overflow on small-height devices or large text scale.
- All actions (including delete) must remain reachable.

**Delete:** Shows confirmation dialog before executing:
```
┌────────────────────────────────┐
│                                │
│  Delete "reactive"?            │   ← title-md
│                                │
│  This will permanently delete  │   ← body-md, Secondary
│  this collection and all 24    │
│  links inside it.              │
│                                │
│  [Cancel]    [Delete forever]  │   ← Cancel (outlined) | Delete (danger filled)
└────────────────────────────────┘
```

---

## 8.10 UrlListTile Component

Used in List layout mode.

```
┌──────────────────────────────────────┐
│▌  [fav]  Flutter Riverpod 3.0 Guide  │
│          codewithandrea.com · 2d ago │
│          [flutter] [state]  [unread] │
└──────────────────────────────────────┘
```

**Detailed breakdown:**
```
│ ▌ │ [fav 20px] │ TITLE (title-sm, 1-2 lines)              │
│   │            │ DOMAIN (mono-md, tertiary) · TIMESTAMP    │
│   │            │ [TAG chips] [STATUS pill]                 │
```

- Height: 72px (no tags), 88px (with tags)
- Left color bar: 3px, collection `color_hex` (optional, togglable in settings)
- Favicon: 20×20px circle, fallback = domain initial letter
- Title: title-sm, 2-line max, ellipsis
- Domain: mono-md, tertiary
- Timestamp: `relative` (2d ago, just now, etc.)
- Tags: body-sm chips, Surface 3 bg, max 3 shown + "+N more"
- Status pill: label-sm, color per status definition
- Pin indicator: accent dot top-right if `is_pinned = true`
- Swipe right: Quick-read (mark as read) — green reveal
- Swipe left: Delete — red reveal with trash icon
- Long-press: URL action sheet
- Tap: opens URL detail screen

## 8.11 UrlCard Component

Used in Cards layout mode.

```
┌──────────────────────────────┐
│  ┌────────────────────────┐  │
│  │ [Thumbnail image        │  │   ← 16:9 aspect, dominant_color fallback
│  │  or dominant color      │  │
│  │  placeholder]           │  │
│  └────────────────────────┘  │
│  [fav 16px] codewithandrea   │   ← favicon + domain, body-sm tertiary
│  Flutter Riverpod 3.0 Guide  │   ← title-md, 2 lines max
│  Complete setup guide for    │   ← body-sm, Secondary, 2 lines, ellipsis
│  building...                 │
│  [flutter] [state] [unread]  │   ← chips at bottom
└──────────────────────────────┘
```

- Background: Surface 2
- Border: Border 1
- Radius: radius-lg
- Top image area: `thumbnail_url` if available, else solid `dominant_color`; else gradient from Surface 3 to Surface 2

## 8.12 URL Long-Press Action Sheet

```
┌─────────────────────────────┐
│         ──────              │
│                             │
│  [fav] Flutter Guide        │   ← Title
│  codewithandrea.com         │   ← domain, mono-md
│                             │
│  ─────────────────────────  │
│                             │
│  ↗  Open in browser         │
│  📋 Copy URL                │
│  ✏️  Edit                   │
│  📁 Move to collection      │
│  ─────────────────────────  │
│  📌 Pin to top              │   ← toggle
│  📦 Mark as read            │   ← toggle
│  🗃  Archive                │
│  ─────────────────────────  │
│  🗑️  Delete link            │   ← danger color, at bottom
│                             │
└─────────────────────────────┘
```

---

# 9. Create / Edit Collection

**Route:** `/collections/create` and `/collections/:id/edit`  
The same form is used for both. Edit pre-populates all fields.

## 9.1 Layout

```
┌─────────────────────────────┐
│  ←  New collection          │   ← App bar: back + title
│                (Save →)     │   ← or "Save" text button in bar
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │  PREVIEW CARD           ││   ← Live preview of card as user fills
│  │  ─────────────          ││     Updates in real-time
│  │  [Icon]                 ││
│  │  Collection name        ││
│  │  0 links                ││
│  └─────────────────────────┘│
│                             │
│  ─────────────────────────  │
│  BASICS                     │   ← label-md overline
│                             │
│  Collection name  *         │   ← Required field label
│  ┌─────────────────────────┐│
│  │ e.g. Flutter Resources  ││   ← Input, Surface 3
│  └─────────────────────────┘│
│  [Error: Name is required]  │   ← validation (shows on submit)
│                             │
│  Description (optional)     │
│  ┌─────────────────────────┐│
│  │ Optional — shown in     ││   ← Multiline, 3 rows
│  │ search and on cards     ││
│  └─────────────────────────┘│
│                             │
│  Category                   │
│  ┌─────────────────────────┐│
│  │ ⭐ Favorites         ▾  ││   ← Dropdown selector
│  └─────────────────────────┘│
│                             │
│  ─────────────────────────  │
│  APPEARANCE                 │   ← label-md overline
│                             │
│  Cover color                │
│  ┌──┐┌──┐┌──┐┌──┐┌──┐      │
│  │▓▓││▓▓││▓▓││▓▓││▓▓│...   │   ← Color swatches, 32px circles
│  └──┘└──┘└──┘└──┘└──┘      │     16 options from palette (section 2.1)
│                             │
│  Icon                       │
│  [📦][📁][🔗][📱][💼][📝]...│   ← Emoji icon picker grid
│  [🎨][🛠][📚][⭐][🎯][💡]... │   ← 3 rows × 6 cols visible, scrollable
│                             │
│  ─────────────────────────  │
│  PARENT COLLECTION          │   ← label-md overline
│                             │
│  Parent                     │
│  ┌─────────────────────────┐│
│  │ 📁 Root (Home)       ▾  ││   ← Dropdown/picker
│  └─────────────────────────┘│
│  (opens collection picker   │
│   modal)                    │
│                             │
│  ─────────────────────────  │
│  DISPLAY DEFAULTS  ▾        │   ← Collapsed section, expandable
│  (folder layout, link       │
│   layout, sort order,       │
│   open links setting)       │
│                             │
│  ┌─────────────────────────┐│
│  │       Save              ││   ← Full-width sticky button at bottom
│  └─────────────────────────┘│
└─────────────────────────────┘
```

## 9.2 Category Options

From the DB schema `category TEXT NOT NULL DEFAULT 'general'`:

```
⭐ Favorites
📁 General
💻 Development
📚 Reading
🎨 Design
💡 Ideas
💼 Work
🎯 Goals
🧪 Research
🛒 Shopping
🎵 Entertainment
📰 News
✈️ Travel
❤️ Personal
```

## 9.3 Display Defaults (Collapsed section)

```
┌─────────────────────────────┐
│  DISPLAY DEFAULTS  ▲        │   ← Expanded state
│                             │
│  Folders layout             │   ← label-md
│  [List] [Grid] [Compact]    │   ← Segmented control
│                             │
│  Links layout               │
│  [List] [Cards] [Icons]     │
│                             │
│  Default sort               │
│  ┌─────────────────────────┐│
│  │ Manual order         ▾  ││
│  └─────────────────────────┘│
│                             │
│  Open links                 │
│  [In app] [Browser]         │
│                             │
│  Show link previews         │
│  Thumbnails when available  [○]│
│                             │
└─────────────────────────────┘
```

## 9.4 Edit State

Identical to create, with:
- App bar title: "Edit collection"
- All fields pre-populated from DB
- "Delete collection" danger text button at very bottom (separated by divider)
- Save = update, not create

## 9.5 States

**Loading (Edit):** Skeleton fields while loading collection data  
**Saving:** Button shows spinner, inputs disabled  
**Success:** Snackbar "Collection saved", pops back  
**Error:** Snackbar "Couldn't save. Try again." with retry  
**Validation error:** Inline below each invalid field  

---

# 10. Create / Edit URL (Item)

**Route:** `/collections/:id/items/create` and `.../items/:id/edit`

Fields derived from `005_lv_urls.sql` schema:
- `url` (required)
- `title` (required — auto-fetched, overridable)
- `description` (optional — auto-fetched, overridable)
- `thumbnail_url` (auto-fetched, overridable)
- `favicon_url` (auto-fetched)
- `dominant_color` (auto-detected)
- `tags` (comma-separated)
- `annotation` (user note)
- `status` (unread/read/archived)
- `is_pinned`
- `site_name`, `canonical_url`, `content_type`, `published_at` (advanced/auto)

## 10.1 Layout

```
┌─────────────────────────────┐
│  ←  New link                │
│               (Save →)      │
├─────────────────────────────┤
│                             │
│  URL  *                     │
│  ┌─────────────────────────┐│
│  │ https://example.com/... ││   ← Input, monospace font for URL
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│   ← PREVIEW CARD (appears after URL entered)
│  │ [FETCHING METADATA...]  ││   ← Shows shimmer while fetching
│  │                         ││
│  │ [Or: fetched preview]   ││
│  │ [favicon] [domain]      ││
│  │ Title from og:title     ││
│  │ Description snippet...  ││
│  └─────────────────────────┘│
│                             │
│  Title  *                   │
│  ┌─────────────────────────┐│
│  │ Auto-filled from URL    ││   ← Pre-filled, editable
│  └─────────────────────────┘│
│                             │
│  Description                │
│  ┌─────────────────────────┐│
│  │ Auto-filled from og:    ││   ← Multiline, 3 rows
│  │ description             ││
│  └─────────────────────────┘│
│                             │
│  Collection  *              │
│  ┌─────────────────────────┐│
│  │ 📦 reactive          ▾  ││   ← Collection picker
│  └─────────────────────────┘│
│                             │
│  ─────────────────────────  │
│  IMAGE                      │   ← label-md overline
│                             │
│  ┌──────────┐               │
│  │ [thumb]  │  × Clear      │   ← Thumbnail preview (auto-fetched)
│  │  preview │               │
│  └──────────┘               │
│  Or: [ + Upload image ]     │   ← Optional manual upload
│                             │
│  ─────────────────────────  │
│  METADATA                   │   ← label-md overline
│                             │
│  Tags                       │
│  ┌─────────────────────────┐│
│  │ flutter, state, riverpod││   ← Comma-separated input
│  └─────────────────────────┘│
│  [flutter] [state] [×]      │   ← Live chip preview below input
│                             │
│  Notes / Annotation         │
│  ┌─────────────────────────┐│
│  │ Add a note...           ││   ← Multiline, 4 rows
│  └─────────────────────────┘│
│                             │
│  Status                     │
│  [Unread] [Read] [Archived] │   ← Segmented control
│                             │
│  Pin to top  [toggle]       │   ← Switch row
│                             │
│  ─────────────────────────  │
│  ADVANCED  ▾                │   ← Collapsed: site_name, canonical_url,
│                             │     content_type, published_at
│                             │
│  ┌─────────────────────────┐│
│  │         Save            ││   ← Sticky footer
│  └─────────────────────────┘│
└─────────────────────────────┘
```

## 10.2 Metadata Fetch UX

When user enters/pastes a URL:
1. After 800ms debounce (or on blur): trigger metadata fetch
2. Show inline loading state in the preview card:

```
┌─────────────────────────────┐
│  Fetching preview...        │   ← body-sm, Secondary
│  ░░░░░░░░░░░░░░░░ (favicon) │   ← shimmer favicon circle
│  ░░░░░░░░░░░░░░░░░░░░░ (title)│
│  ░░░░░░░░░░░░░ (description)│
└─────────────────────────────┘
```

3. On success, animate in:
```
┌─────────────────────────────┐
│ [fav] codewithandrea.com    │
│ Flutter Riverpod 3.0 Guide  │
│ A complete guide to...      │
│ [thumbnail image]           │
└─────────────────────────────┘
```

4. Auto-fill Title and Description fields (if empty)
5. On failure: show inline warning, fields remain empty, user fills manually:
```
⚠ Couldn't fetch preview. Enter details manually.
```

## 10.3 Advanced Section (Expanded)

From schema fields:

```
Site name              ┌──────────────┐
                       │ Auto-filled  │
                       └──────────────┘

Canonical URL          ┌──────────────┐
                       │ Auto-filled  │
                       └──────────────┘

Content type           ┌───────────▾──┐
                       │ Article      │
                       └──────────────┘
(options: article, video, product, document, other)

Published date         ┌──────────────┐
                       │ MM/DD/YYYY   │   ← Date picker
                       └──────────────┘
```

## 10.4 States

**From share intent (pre-filled URL):**
- URL field pre-populated
- Metadata fetch starts immediately
- Title field shows "Fetching…" placeholder
- Save button disabled until title is confirmed

**Saving state:**
- All inputs disabled
- Button shows `[Saving…]` with spinner
- Progress indicator in app bar

**Error state:**
- Snackbar with retry option

**Validation errors (inline):**
- URL: "Enter a valid URL"
- Title: "Title is required"
- Tags: no validation (free text)

---

# 11. URL Detail Screen

**Route:** `/collections/:id/items/:itemId`  
Opened by tapping a URL card/tile. Shows full metadata and quick actions.

## 11.1 Layout

```
┌─────────────────────────────┐
│  ←                    ✏️ ⋮ │   ← App bar: back, edit, overflow
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │ [Thumbnail image        ││   ← Full-width, 16:9, dominant_color fallback
│  │  or dominant_color bg]  ││
│  └─────────────────────────┘│
│                             │
│  [favicon 20px] domain.com  │   ← favicon + domain
│  site_name (if different)   │   ← body-sm, Secondary
│                             │
│  Flutter Riverpod 3.0       │   ← display-md, Primary
│  Complete Guide             │
│                             │
│  Complete setup for state   │   ← body-md, Secondary, up to 4 lines
│  management in Flutter...   │
│                             │
│  ─────────────────────────  │
│                             │
│  [flutter] [state] [guide]  │   ← Tag chips
│                             │
│  ─────────────────────────  │
│                             │
│  Status         [unread ▾]  │   ← Dropdown to change status
│  Pinned         [toggle]    │
│  Collection     📦 reactive │   ← tappable, navigates
│  Added          2 days ago  │
│  Last visited   Yesterday   │
│  Visited        3 times     │   ← click_count
│                             │
│  ─────────────────────────  │
│  NOTES                      │
│                             │
│  My note about this article │   ← annotation text, body-md
│  goes here...               │
│                             │
│  ─────────────────────────  │
│                             │
│  ┌─────────────────────────┐│
│  │  ↗  Open in browser     ││   ← Primary action, filled button
│  └─────────────────────────┘│
│                             │
│  [📋 Copy] [📤 Share] [🗑]  │   ← Secondary actions row
│                             │
└─────────────────────────────┘
```

## 11.2 Overflow Sheet (⋮)

```
│  ✏️  Edit link             │
│  📁  Move to collection    │
│  📌  Pin / Unpin           │
│  📦  Mark as read/unread   │
│  🗃   Archive               │
│  ─────────────────────────  │
│  🗑️  Delete link            │   ← danger
```

---

# 12. Global Search

**Route:** `/search`  
**Tab:** 3rd bottom tab  
Searches across all collections AND all URLs.

## 12.1 State: Default (Empty query)

```
┌─────────────────────────────┐
│  ┌─────────────────────────┐│
│  │ 🔍 Search everything…   ││   ← Autofocused search input
│  └─────────────────────────┘│
│                             │
│  RECENT SEARCHES            │   ← label-md overline
│  🕐 flutter                 │
│  🕐 supabase tutorial       │
│  🕐 design systems          │
│                             │
│  SUGGESTED                  │   ← label-md overline
│  📌 Pinned items (12)       │
│  🕐 Recently added          │
│  📦 All collections (5)     │
└─────────────────────────────┘
```

## 12.2 State: Typing (Debounced Results)

```
┌─────────────────────────────┐
│  ┌─────────────────────────┐│
│  │ 🔍 flutter          ×   ││   ← × to clear
│  └─────────────────────────┘│
│                             │
│  ┌──────────────────────────┐│
│  │ [All] [Collections] [Links]│  ← Type filter tabs
│  └──────────────────────────┘│
│                             │
│  COLLECTIONS (2)            │   ← label-md overline
│  ┌─────────────────────────┐│
│  │▌ 📦 Flutter          ›  ││   ← Matching collections
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │▌ 📁 Flutter Packages ›  ││
│  └─────────────────────────┘│
│                             │
│  LINKS (8)                  │   ← label-md overline
│  ┌─────────────────────────┐│
│  │ [fav] Flutter Guide     ││   ← URL results
│  │ In: 📦 reactive         ││   ← Shows parent collection
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ [fav] Riverpod 3.0      ││
│  │ In: 📦 Flutter          ││
│  └─────────────────────────┘│
│  [Show all 8 links →]       │   ← Pagination
└─────────────────────────────┘
```

**Search matching:**
- Title: weight 3 (primary)
- Tags: weight 2
- Description: weight 2
- Domain/URL: weight 1
- Annotation: weight 1
- Results highlight matched text (bold the matched substring)

## 12.3 State: No Results

```
┌─────────────────────────────┐
│  ┌─────────────────────────┐│
│  │ 🔍 xyz123           ×   ││
│  └─────────────────────────┘│
│                             │
│   🔍 [icon, muted]          │
│                             │
│   No results for "xyz123"   │   ← title-md, centered
│                             │
│   Try different keywords    │   ← body-sm, Secondary
│   or check spelling.        │
│                             │
│  ┌─────────────────────┐    │
│  │  Clear search       │    │
│  └─────────────────────┘    │
└─────────────────────────────┘
```

## 12.4 State: Loading

- Search field shows spinner (replacing 🔍 icon while debounce fires)
- Previous results fade to 50% opacity during re-fetch

---

# 13. RSS Feed Reader

**Route:** `/rss` (accessible from Home or Profile/Settings)

## 13.1 RSS Feeds List

```
┌─────────────────────────────┐
│  ←  RSS Feeds          [+]  │   ← + adds new feed
├─────────────────────────────┤
│                             │
│  3 feeds · last synced 2m   │   ← body-sm, Secondary
│                             │
│  ┌─────────────────────────┐│
│  │ [ico] The Verge         ││   ← Feed tile
│  │       12 new articles   ││
│  │       theverge.com      ││
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ [ico] Hacker News       ││
│  │       30 new articles   ││
│  │       news.ycombinator  ││
│  └─────────────────────────┘│
│                             │
│            [FAB: + Feed]    │
└─────────────────────────────┘
```

## 13.2 Feed Detail Screen

```
┌─────────────────────────────┐
│  ←  The Verge           ⋮  │
├─────────────────────────────┤
│  Pull to refresh            │   ← Pull-to-refresh indicator
│                             │
│  ┌─────────────────────────┐│
│  │ [thumb]  Article title  ││   ← RSS article card
│  │          2 hours ago    ││
│  │          Short summary  ││
│  │                [Save +] ││   ← One-tap save to LinkVault
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │ [thumb]  Another article││
│  │          5 hours ago    ││
│  │                [Save +] ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

**Save + button:** Opens a mini collection picker bottom sheet:
```
│  Save to collection         │
│  Recent: 📦 Flutter   [Save]│
│  📦 reactive         [Save] │
│  📁 Browse all...           │
```

---

# 14. Profile & Settings

## 14.1 Profile Screen

**Route:** `/profile`

```
┌─────────────────────────────┐
│  Profile                    │   ← display-md
├─────────────────────────────┤
│                             │
│  ┌─────────────────────────┐│
│  │  [Avatar 60px]          ││   ← Avatar circle
│  │  Rahul Verma            ││   ← display-md
│  │  rahul@email.com        ││   ← body-md, Secondary
│  │               Edit →    ││   ← text link
│  └─────────────────────────┘│
│                             │
│  ─────────────────────────  │
│  SUBSCRIPTION               │   ← label-md overline
│                             │
│  ┌─────────────────────────┐│
│  │ ★ Free tier             ││   ← Premium status card
│  │   Watching 1 ad/day     ││
│  │   [Upgrade to Premium]  ││   ← accent button inside card
│  └─────────────────────────┘│
│  (Premium variant:)         │
│  ┌─────────────────────────┐│
│  │ ★ Premium               ││
│  │   Cloud sync active     ││
│  │   Renews Mar 2027       ││
│  └─────────────────────────┘│
│                             │
│  ─────────────────────────  │
│  STORAGE                    │   ← label-md overline
│                             │
│  ┌─────────────────────────┐│
│  │ [====-----] 2.3MB / ∞   ││   ← Storage bar
│  │ 47 collections          ││
│  │ 312 links               ││
│  └─────────────────────────┘│
│                             │
│  ─────────────────────────  │
│  PREFERENCES                │   ← label-md overline
│                             │
│  Theme              Light ▾ │   ← dropdown or toggle
│  Open links        In app › │
│  Default sort      Manual › │
│                             │
│  ─────────────────────────  │
│  DATA                       │   ← label-md overline
│                             │
│  Export data (JSON)      >  │
│  Import data             >  │
│  Clear all data          >  │   ← triggers confirmation
│                             │
│  ─────────────────────────  │
│  SUPPORT                    │   ← label-md overline
│                             │
│  About LinkVault         >  │
│  Privacy Policy          >  │
│  Terms of Service        >  │
│  Rate the app            >  │
│                             │
│  ─────────────────────────  │
│                             │
│  Sign out                   │   ← danger color text, centered
│                             │
└─────────────────────────────┘
```

## 14.2 Edit Profile Screen

```
┌─────────────────────────────┐
│  ←  Edit profile            │
│               (Save →)      │
├─────────────────────────────┤
│                             │
│  [Avatar 80px]  Change →    │
│                             │
│  Display name               │
│  ┌─────────────────────────┐│
│  │ Rahul Verma             ││
│  └─────────────────────────┘│
│                             │
│  Email                      │
│  ┌─────────────────────────┐│
│  │ rahul@email.com         ││   ← Read-only (OTP-based auth)
│  └─────────────────────────┘│
│  (You can't change your     │
│   email address.)           │
│                             │
│  ─────────────────────────  │
│  DANGER ZONE                │   ← label-md overline, danger color
│                             │
│  Delete account          >  │   ← danger color, opens confirmation
│                             │
└─────────────────────────────┘
```

## 14.3 App Settings Screen

```
┌─────────────────────────────┐
│  ←  Settings                │
├─────────────────────────────┤
│                             │
│  APPEARANCE                 │
│  Theme                      │
│  [Light] [Dark] [System]    │   ← Segmented control
│                             │
│  LINKS                      │
│  Open links by default      │
│  [In app] [Browser]         │
│                             │
│  Show link previews  [○]    │   ← thumbnails on/off
│  Show favicons       [●]    │
│                             │
│  COLLECTIONS                │
│  Default folders layout     │
│  [Grid] [List] [Compact]    │
│                             │
│  Default links layout       │
│  [List] [Cards] [Icons]     │
│                             │
│  SYNC (Premium only)        │
│  Auto-sync               ●  │   ← greyed out if free tier
│  Sync on WiFi only       ○  │
│  Last synced: 2m ago        │
│                             │
│  NOTIFICATIONS              │
│  New link saved          ○  │
│  Sync complete           ○  │
│                             │
└─────────────────────────────┘
```

---

# 15. Monetization Screens

## 15.1 Ad Gate Screen

**Route:** `/ad-gate`

```
┌─────────────────────────────┐
│                             │
│                             │
│  ┌─────────────────────────┐│
│  │  🎫 [Ticket icon]       ││   ← Illustration, 100×100
│  └─────────────────────────┘│
│                             │
│   Daily access required     │   ← display-md, centered
│                             │
│   Your free trial has ended.│   ← body-md, Secondary, centered
│   Watch a short ad each day │
│   to keep full access, or   │
│   upgrade to Premium.       │
│                             │
│  ─────────────────────────  │
│                             │
│  ✓ Unlimited collections    │   ← benefit list, body-md
│  ✓ All link features        │
│  ✓ Works offline            │
│                             │
│  ─────────────────────────  │
│                             │
│  ┌─────────────────────────┐│
│  │ ▶ Watch ad · Get access ││   ← Primary, filled, accent
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │ ★ Go Premium — No ads   ││   ← Secondary, outlined, gold accent
│  └─────────────────────────┘│
│                             │
│  [Grace period banner]      │   ← Only shown if offline/ad failed:
│  You're offline. Full       │   ← Surface 3, warning color border
│  access until tomorrow.     │
│                             │
└─────────────────────────────┘
```

## 15.2 Paywall Screen

**Route:** `/paywall`

```
┌─────────────────────────────┐
│                          ×  │   ← Close button, top right
│                             │
│  ─────────────────────────  │
│  LINKVAULT PREMIUM          │   ← label-md overline, centered
│                             │
│   Your links,               │   ← display-lg, centered, 2 lines
│   without limits.           │
│                             │
│  ─────────────────────────  │
│  ✓ No ads, ever             │   ← benefit list with checkmark
│  ✓ Cloud sync across devices│
│  ✓ Automatic backup         │
│  ✓ Cross-device access      │
│  ✓ Priority support         │
│                             │
│  ─────────────────────────  │
│                             │
│  ┌─────────────────────────┐│
│  │ ★ BEST VALUE            ││   ← Annual plan card (highlighted)
│  │   Annual · $39.99/year  ││   ← 2px gold border
│  │   $3.33/month           ││
│  │   [Subscribe]           ││
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   Monthly · $4.99/month ││   ← Monthly plan card
│  └─────────────────────────┘│
│                             │
│  Restore purchases          │   ← centered text link
│                             │
│  Cancel anytime · Billed    │   ← label-sm, tertiary, centered
│  through App Store          │
└─────────────────────────────┘
```

**Loading state:** Full-screen spinner until RevenueCat offerings loaded  
**Purchasing state:** Full-screen overlay dim + spinner  
**Success:** Snackbar "Welcome to Premium!" → navigate to `/migration`

---

# 16. Component Library

## 16.1 Buttons

### Filled Button (Primary)
```
┌──────────────────────────────┐
│         Action label         │   ← Height: 52px, full-width or auto
└──────────────────────────────┘
Background: Accent 500
Text: White
Radius: radius-md (12px)
Press state: Accent 600, scale 0.98
Loading state: spinner replaces icon, label stays
Disabled: 40% opacity
```

### Outlined Button (Secondary)
```
┌──────────────────────────────┐
│         Action label         │   ← Same height, with 1.5px accent border
└──────────────────────────────┘
Background: transparent
Border: 1.5px Accent 500
Text: Accent 500
Press: Surface 3 bg fill
```

### Text Button / Link
```
Action label →           ← No border, no background
Text: Accent 500 or tertiary
Press: underline briefly
```

### Danger Button
```
┌──────────────────────────────┐
│       Delete collection      │
└──────────────────────────────┘
Background: Error at 12% opacity
Text: Error color
Border: 1.5px error
Use for destructive actions only
```

### FAB (Floating Action Button)
```
Extended:   [+ New folder]   ← Pill shape, accent bg, white text+icon
Collapsed:  [+]              ← 56×56px circle, accent bg, icon only
Transition: Shrinks to icon when scrolling down, expands on scroll up
Position: Bottom-right, 20px margin from screen edge, 80px above nav bar
```

## 16.2 Input Fields

```
Label text             ← label-lg, Secondary, 8px above
┌────────────────────┐
│ Placeholder text   │  ← Body-md, tertiary
└────────────────────┘
Helper text            ← body-sm, tertiary, 4px below
Error text             ← body-sm, danger color, 4px below

Height: 52px (single-line), auto (multiline)
Background: Surface 3
Border default: 1px Border 2
Border focused: 2px Accent 500
Border error: 2px Error color
Radius: radius-md (12px)
Padding: 16px horizontal, 14px vertical
```

## 16.3 Chips / Tags

### Filter Chip
```
[ Label ]   ← Pill, 32px height, 12px horizontal padding
Default: Surface 3 bg, Border 1, tertiary text
Active: Accent at 12% bg, Accent border, Accent text
```

### Tag Chip (on URL cards)
```
[ tag ]   ← Pill, 20px height, 6px horizontal padding
Background: Surface 3
Text: secondary color, label-sm
Dismissible variant: [ tag × ]
```

### Status Pill
```
[ unread ]  ← 24px height, 8px horizontal
Unread: Accent 500 at 15% bg, Accent text
Read: Success at 12% bg, success text
Archived: Gray at 15% bg, tertiary text
```

### Collection Color Swatch
```
[●]   ← 32px circle, solid fill = color_hex
Active: 3px white ring + 1px gap (inset)
```

## 16.4 Bottom Sheet

All bottom sheets follow this structure:

```
┌─────────────────────────────┐
│                             │
│           ─────             │   ← Handle: 40×4px, Surface 5, rx=2
│                             │   ← 8px gap below handle
│  [Title if applicable]      │   ← title-md, 20px from edges
│                             │
│  [Content]                  │
│                             │
│                             │
└─────────────────────────────┘
```

- Background: Surface 1 (#111111)
- Top corners: radius-xl (20px)
- Shadow: 0 -4px 24px rgba(0,0,0,0.5)
- Drag to dismiss: enabled on handle and sheet body
- Max height: 90% of screen
- Scrollable content: when content exceeds available height
- Barrier: 50% black overlay behind

## 16.5 Snackbars

```
┌────────────────────────────────┐
│  ✓ Collection saved    [Undo]  │   ← Success, 48px height
└────────────────────────────────┘

┌────────────────────────────────┐
│  ✕ Couldn't save.  [Try again] │   ← Error variant
└────────────────────────────────┘
```

- Position: above bottom nav
- Duration: 3s (4s for errors)
- Background: Surface 4 (slightly lighter than cards)
- Text: primary color
- Action: accent color text
- Radius: radius-md
- Animation: slide up from bottom

## 16.6 Skeleton / Loading State

```
All skeletons use:
  Background: Surface 3
  Animation: shimmer (Surface 3 → Surface 4 → Surface 3)
  Duration: 1.5s infinite
  Easing: linear

Skeleton variants:
  Text line (full width):   height 14px, radius-sm, width 100%
  Text line (short):        height 14px, radius-sm, width 60%
  Avatar circle:            diameter matches actual avatar
  Card:                     exact dimensions of actual card
  Chip:                     matches chip dimensions
```

## 16.7 Empty State

```
┌─────────────────────────────┐
│                             │
│                             │
│   [Illustration 160×160]    │   ← SVG illustration, centered
│                             │
│   Title                     │   ← title-lg, centered
│                             │
│   Supporting description    │   ← body-md, Secondary, centered
│   that explains what to do. │     max 3 lines
│                             │
│  ┌─────────────────────┐    │
│  │  Primary CTA        │    │   ← Filled button (optional)
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘
```

Vertical centering: true center of content area (not mathematical center of screen)

## 16.8 Confirmation Dialogs

```
┌────────────────────────────────┐
│                                │
│  Are you sure?                 │   ← title-md
│                                │
│  This action cannot be undone. │   ← body-md, Secondary
│                                │
│  ┌───────────┐  ┌───────────┐  │
│  │  Cancel   │  │  Delete   │  │   ← Cancel (outlined) | Action (filled danger)
│  └───────────┘  └───────────┘  │
│                                │
└────────────────────────────────┘
```

- Presented as dialog (not sheet) for destructive actions
- Background: Surface 2
- Border: Border 2
- Radius: radius-xl
- Scrim: 60% black overlay

---

# 17. Interaction & Animation Patterns

## 17.1 Navigation Transitions

| Transition | Type | Duration |
|---|---|---|
| Push (drill into folder) | Slide left | 300ms |
| Pop (back) | Slide right | 250ms |
| Tab switch | Crossfade | 200ms |
| Modal push (create/edit) | Slide up | 300ms |
| Bottom sheet open | Spring up | 280ms |
| Bottom sheet close | Ease out | 220ms |

## 17.2 Scroll Behaviors

**Collapsing header (CollectionHub):**
- On scroll down > 20px: header slides out upward (translateY: -headerHeight)
- On scroll up any: header slides back in
- TabBar snaps to top of screen and becomes sticky
- App bar title crossfades in when header hides

**FAB hide on scroll:**
- Scroll down > 50px: FAB translates down off-screen (300ms spring)
- Scroll up: FAB returns (250ms spring)
- Extended FAB → icon-only: when content is long and user has scrolled once

**Pull-to-refresh:**
- Overscroll > 60px: refresh indicator appears (accent colored spinner)
- Release: data refreshes
- Snackbar confirms: "Updated" with timestamp

## 17.3 Swipe Actions (UrlListTile)

**Swipe right (reveal actions — green):**
```
│ ✓ Mark read │ ...content... │
```
- Threshold 40px: start revealing
- Threshold 80px: snap to action
- Beyond 80%: auto-trigger action

**Swipe left (delete — red):**
```
│ ...content... │ 🗑 Delete │
```
- Same threshold logic
- Auto-trigger: shows confirmation inline before deleting

## 17.4 Long-Press Behaviors

- **Any collection card or tile:** 150ms haptic + scale down to 0.96, then action sheet opens
- **Any URL card or tile:** same pattern
- **Drag-to-reorder (only in manual order mode):** long-press 400ms activates drag, card lifts (scale 1.02, shadow), drop target shows insertion line

## 17.5 Micro-interactions

**Saving a URL (success):**
1. Save button pulse (accent flash, 200ms)
2. Check icon replaces save icon (300ms)
3. Snackbar slides up: "Link saved to [collection]"
4. Screen pops back

**Marking as read:**
- Status pill crossfades from `unread` (accent) to `read` (green) — 200ms
- Haptic: light tap

**Pinning:**
- Pin icon fills with accent color — 150ms
- Slight bounce animation on icon

**Deleting a collection (destructive):**
1. Confirmation dialog
2. On confirm: card scales to 0, fades out (300ms)
3. Other cards reflow into place (400ms spring)
4. Snackbar: "Deleted [name]" with Undo button (5s window)

## 17.6 Loading States Philosophy

Never show a blank white/dark screen. Always show:
- Skeleton for list/grid content
- Spinner in buttons when actions are in-progress
- Progress indicator in app bar for screen-level loading
- Inline shimmer for metadata fetch (add URL screen)

## 17.7 Haptic Feedback Map

| Action | Haptic Type |
|---|---|
| Tap bottom tab | Light |
| Long-press card | Medium |
| Toggle filter chip | Selection |
| Drag-to-reorder lift | Medium |
| Drag-to-reorder drop | Rigid |
| Successful save | Success (double soft) |
| Delete confirm | Warning (sharp) |
| Ad watch complete | Success |

---

# 18. Screen State Matrix

This matrix ensures every screen handles all states in implementation.

| Screen | Loading | Empty | Error | Content | Creating | Saving | Offline |
|---|---|---|---|---|---|---|---|
| Home | ✓ skeleton | ✓ empty CTA | ✓ retry | ✓ | — | — | ✓ banner |
| Library | ✓ skeleton | ✓ empty CTA | ✓ retry | ✓ | — | — | ✓ offline badge |
| CollectionHub/Folders | ✓ skeleton | ✓ empty CTA | ✓ retry | ✓ | — | — | ✓ |
| CollectionHub/Links | ✓ skeleton | ✓ empty CTA | ✓ retry | ✓ | — | — | ✓ |
| CollectionHub/Links (filtered) | — | ✓ filtered empty | — | ✓ | — | — | — |
| Create Collection | — | — | — | ✓ form | ✓ | ✓ spinner | — |
| Edit Collection | ✓ prefill | — | ✓ | ✓ form | — | ✓ spinner | — |
| Create URL | — | — | ✓ fetch fail | ✓ form | ✓ | ✓ spinner | ✓ skip fetch |
| URL Detail | ✓ skeleton | — | ✓ | ✓ | — | — | ✓ |
| Search | — | ✓ no query | ✓ | ✓ results | — | — | ✓ |
| Search (no results) | — | ✓ no results | — | — | — | — | — |
| Profile | ✓ | — | ✓ | ✓ | — | ✓ | — |
| Paywall | ✓ offers | — | ✓ | ✓ | — | ✓ purchasing | — |
| Ad Gate | — | — | ✓ ad fail | ✓ | — | — | ✓ grace |

---

## 18.1 Offline State

LinkVault is offline-first. When offline (free or guest tier):

**Global offline indicator:**
```
┌─────────────────────────────┐
│  📵 Offline — showing local │   ← Banner at top of screen
│  data                   ×   │     Warning color, dismissible
└─────────────────────────────┘
```

**Premium users offline:**
```
│  📵 Cloud sync paused      │   ← Less alarming, data is local
│  Changes will sync when    │
│  you're back online.       │
```

**Behavior when offline:**
- All locally stored data remains accessible
- Creating/editing works (queued for sync if premium)
- Metadata fetch fails gracefully (manual entry mode)
- RSS feeds show cached data, no refresh
- Search works on local data

---

# 19. AI Image Generation Prompts

Use these prompts for generating placeholder illustrations or onboarding artwork.

## 19.1 Onboarding Illustrations

**Slide 1 — Save links:**
```
Minimal flat illustration, dark background #0A0A0A, a smartphone showing 
a share sheet with LinkVault app icon highlighted, floating link cards 
(article, youtube, github) swirling into a vault icon, indigo-violet 
accent colors #5E6AD2, clean vector style, no gradients, generous whitespace
```

**Slide 2 — Organize:**
```
Minimal flat illustration, dark background, nested folder hierarchy 
shown as colorful nested cards with different color accent bars 
(indigo, teal, amber, pink), Plus Jakarta Sans font labels on folders, 
depth effect through card layering, no gradients
```

**Slide 3 — Sync:**
```
Minimal flat illustration, dark background, two smartphones side by side 
with identical collection grids, a subtle cloud icon between them with 
soft connecting lines, indigo accent, clean and minimal
```

## 19.2 Empty State Illustrations

**Empty Library:**
```
Simple line art, dark theme, an open empty folder with dashed border 
outline, a single + icon inside, indigo-violet accent, 160×160px style, 
no fill, minimal
```

**Empty Links:**
```
Simple line art, dark theme, a bookmark icon with dotted border, a broken 
link symbol nearby, subtitle space below, indigo-violet accent, minimal
```

**Empty Search:**
```
Simple line art, dark theme, a magnifying glass with a faint question mark 
inside, no fill, indigo-violet accent color on glass rim
```

## 19.3 AI Screen Generation Prompt (Full App)

Use this as the master prompt for Figma AI or Midjourney-style tools:

```
Design a high-fidelity mobile app UI for "LinkVault" — a premium link 
organizer app for iOS/Android. 

Visual direction: Dark mode primary, sophisticated and minimal. Color: 
deep black surfaces (#0A0A0A base, #181818 cards), indigo-violet accent 
(#5E6AD2), no colorful gradients, subtle borders only.

Typography: Plus Jakarta Sans for headings, DM Sans for body. Clear 
hierarchy, generous whitespace, 8pt grid.

Screens needed: 
1. Home dashboard with greeting, horizontal pinned collection chips 
   (each with a colored left accent bar), and recent collections list
2. Library screen with 2-column collection cards grid, each card has 
   a 4px top colored accent bar and an emoji icon
3. Collection hub with collapsing header (root: folders-only, child: Folders + Links tabs), 
   URL list items with favicon, title, domain, tags and status pill
4. Create collection form with live card preview, color swatches, 
   icon picker grid
5. Add link form with URL input, live metadata preview card, tags input

Style: NOT a generic dark app — feels like a premium productivity tool 
(think Linear, Craft, Things 3 aesthetic). Surfaces have depth through 
border contrast, not shadows. Collection colors are expressive but 
controlled (left accent bars, icon backgrounds). No heavy gradients.
Clean, spacious, confident.
```

---

## Document Revision History

| Version | Date | Changes |
|---|---|---|
| 2.2 | March 2026 | Root single-content mode UX, compact search+filter toolbars, empty-state FAB rules, adaptive filter sheet sizing, filter implementation checklist |
| 2.0 | March 2026 | Full rewrite — all screens, all states, design system, component library |
| 1.0 | (Previous) | Initial wireframe sketches |

---

*End of LinkVault UI/UX Design Specification v2.2*
