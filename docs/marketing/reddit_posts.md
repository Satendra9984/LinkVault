# Reddit Posts — LinkVault Launch

CRITICAL RULES FOR REDDIT:
- Never open with "download my app" or "I made an app"
- Lead with value, problem, or genuine question
- Screenshots are mandatory — no screenshots = no upvotes
- Be in the subreddit for at least a few days before posting (karma requirement)
- Reply to every comment within 1 hour of posting for algorithmic boost

---

## POST 1 — r/androidapps

**Title:**
```
I built a link organizer app because my browser bookmarks were a disaster — here's what it looks like [screenshots]
```

**Body:**
```
Long time lurker, first time poster here.

I'm a developer and I had the same problem as a lot of people: I'd bookmark things, then never find them again. My browser bookmarks folder was 800+ links with zero organization.

I tried a few apps but none felt right — either too complex, too ugly, or required a paid subscription just to do basic things.

So I built my own. It's called LinkVault.

The core idea is simple: save links into named collections. Like folders, but for web links. You can search across everything, open links in the built-in webview, and optionally sync to cloud if you want links on multiple devices.

[ATTACH SCREENSHOT 1 — Home dashboard]
[ATTACH SCREENSHOT 2 — Collection detail]
[ATTACH SCREENSHOT 3 — Search results]

What's working well:
- Collections make it easy to context-switch (work links vs learning vs shopping)
- Offline works perfectly — all local links available without wifi
- Built-in webview keeps you in the app

What's missing that I'm working on:
- iOS version (Android only right now)
- Import from browser bookmarks
- Sharing links directly from Chrome

It's free with unlimited local storage. Cloud sync is a paid upgrade.

Happy to answer any questions about how it works or how I built it.

App is on Play Store, search "LinkVault" — or ask and I'll post the link.

What do you use to save and organize links?
```

---

## POST 2 — r/productivity

**Title:**
```
What's your system for saving links you actually want to find later?
```

**Body:**
```
Genuine question — I've been frustrated with this for years.

The problem: I save 10–15 links a week (articles, tools, docs, tutorials). Browser bookmarks became unmanageable. Notes apps feel wrong for URLs. Pocket/Instapaper are great for reading but not for organizing by project/context.

My current system: I built an Android app (LinkVault) that uses named "collections" — basically project-specific folders. I have:
- Learning Queue (courses, articles I want to study)
- Dev Resources (Flutter docs, GitHub repos, Stack Overflow threads)
- Design Refs (Dribbble, UI examples)
- Tools (APIs and services I've evaluated)

[ATTACH SCREENSHOT 1 — Home screen showing collections]

It works offline, syncs to cloud optionally, and searches across everything instantly.

But I'm curious what other people use. There must be better solutions I haven't discovered.

Do you just... leave tabs open? Use a notes app? Something else entirely?
```

---

## POST 3 — r/SideProject

**Title:**
```
I shipped v0.4.0 of my link organizer app today — 100+ downloads, solo dev, building in public
```

**Body:**
```
Hey r/SideProject — sharing my update because this community gave me the confidence to start.

**What I built:** LinkVault — an Android app to save and organize links in named collections. Think bookmark manager, but actually usable.

**Why I built it:** I was losing important links constantly. Browser bookmarks are chaos. I needed a system and couldn't find one I liked, so I built it.

**Current state:**
- 100+ downloads on Play Store (free)
- Flutter + Supabase + RevenueCat stack
- Solo dev, nights and weekends

**What shipped in v0.4.0 today:**
- Fixed a critical signup bug (OTP verification was using the wrong token type — every new user signup failed silently)
- Added a proper account deletion screen (required for Play Store GDPR compliance)
- Fixed a navigation crash on the verify screen
- Improved sign-out UX

[ATTACH SCREENSHOT 1 — Home]
[ATTACH SCREENSHOT 6 — Dark mode]

**What I've learned:**
Distribution is 10x harder than development. I can ship features. Getting people to find the app is where I struggle most.

**What I'm working on next:**
- Better onboarding
- Browser extension for saving from desktop
- iOS version (maybe)

Any advice on growing a utility app as a solo dev with no marketing budget?
```

---

## POST 4 — r/webdev / r/learnprogramming

**Title:**
```
How do you manage all the links you save while learning? (Also: I built a solution)
```

**Body:**
```
When I was learning web development, I was saving 10+ links every day:

- Documentation pages
- Tutorials I wanted to follow
- Stack Overflow answers
- GitHub repos with examples
- YouTube videos I never had time for

After 3 months: 300+ bookmarks with zero organization. I never used 90% of them.

I built an Android app for this specifically — named collections per topic, offline access, instant search.

[ATTACH SCREENSHOT 2 — Collection with dev links]

But I'm more curious: how do the rest of you handle this?

Do you use Notion? A notes app? Just keep tabs open? Or do you just accept the chaos?
```

---

## POST 5 — r/privacy

**Title:**
```
I built a link organizer app that doesn't track you — local-first, cloud sync is opt-in
```

**Body:**
```
Most "save links" apps are cloud-first and monetize through your data or require a subscription.

I built LinkVault with a local-first approach:

- All links save locally by default, no account needed
- Cloud sync is 100% opt-in (requires creating an account and upgrading to Premium)
- No data selling, no algorithmic recommendations, no "link suggestion" feed
- Free tier: unlimited local storage, full search, organized collections

The app works completely offline. You only involve the server if you choose to.

[ATTACH SCREENSHOT 1 — Home dashboard]

Stack: Flutter (offline-capable), Supabase (cloud sync for those who want it), RevenueCat (subscription management).

Any other privacy-focused people with link-saving workflows to share?
```
