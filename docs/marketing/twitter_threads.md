# Twitter / X Posts & Threads — LinkVault Launch

---

## THREAD 1 — BuildInPublic Launch Thread (Post this first)

Post as a thread. Each block = one tweet. Reply to yourself to chain them.

```
Tweet 1:
I shipped v0.4.0 of my Android app today.

100+ downloads. Fully bootstrapped. No investors. No team.

Here's what I built, why I built it, and what I learned doing it alone. 🧵

---

Tweet 2:
The problem:

Every developer I know has a browser bookmarks folder that looks like this:

📁 Bookmarks Bar
  └─ 847 unsorted links
  └─ "read later" folder with 200 links from 2021
  └─ 3 folders named "Important"

You bookmark things. You never find them again.

---

Tweet 3:
I got frustrated enough to build a solution.

LinkVault: a link organizer for Android.

- Save links into named collections
- Search across all your links instantly
- Works fully offline
- Cloud sync for Premium users

Simple. Fast. No algorithm noise.

---

Tweet 4:
Today I shipped v0.4.0. What changed:

✅ Fixed: Signup OTP was completely broken
   (OtpType.signup ≠ OtpType.email — one letter difference, huge impact)

✅ New: Dedicated account deletion screen
   (Play Store requires this for GDPR compliance)

✅ Fixed: Back button crash on verify screen
✅ Improved: Sign out UX with confirmation dialog

---

Tweet 5:
The OTP bug was humbling.

Every new user who tried to sign up got "Token has expired or is invalid."

Account WAS created in Supabase. But verification always failed.
Users couldn't get in despite registering.

Root cause: wrong OtpType enum. One line fixed it.

Ship fast. But test auth flows on real devices.

---

Tweet 6:
What I've learned building solo:

Distribution > Development.

I can ship features in days. Getting users to discover the app? That's the hard part.

100 downloads took 4 months. Getting to 1,000 will require being loud.

So here I am. Being loud. 📢

---

Tweet 7:
Stack used:
→ Flutter (Dart)
→ Supabase (auth + cloud sync)
→ RevenueCat (subscriptions)
→ AdMob (free tier monetization)
→ Clean Architecture + Riverpod

Solo dev, one app, learning everything as I go.

---

Tweet 8:
If you:
→ Save links and never find them again
→ Have 20 browser tabs open right now
→ Want a cleaner system for your web research

Try LinkVault. Free on Android.
Search "LinkVault" on Play Store or comment below.

And if you're building in public — follow along. I post the good and the bad. 🙌

RT if you've ever lost an important link 😅
```

---

## STANDALONE TWEETS (Post 1-2 per day between threads)

```
Tweet A:
"Your bookmarks bar has 847 links. You've opened 4 of them this year."

There's a better way.

[Screenshot of clean LinkVault home]
```

```
Tweet B:
Browser bookmarks are a graveyard.

You save things there. They're never seen again.

I built an app that actually lets you find what you saved.

LinkVault — free on Android.
```

```
Tweet C:
Solo dev milestone: shipped v0.4.0 today.

Fixed a bug where EVERY new signup was silently failing.

Sometimes the most important releases are the bug-fix ones.

Building LinkVault in public. 100+ users. Long way to go.
```

```
Tweet D:
The hardest part of building an indie app isn't the code.

It's the silence after you ship.

Day 1 after launch: 0 new users.
Week 1: 3 users.
Month 1: 20 users.
Month 4: 100+ users.

Slow. Steady. Still building.
```

```
Tweet E:
Productivity tip for developers:

Instead of 20 open tabs → use named collections in a link organizer.

"Flutter docs" collection.
"Current project references" collection.
"Read later" collection.

I use LinkVault (I built it). Happy to share.
```

---

## REPLY STRATEGY

Search these keywords on Twitter daily and reply genuinely:
- "browser bookmarks" → "I built something for this: LinkVault"
- "too many tabs" → reply with your tab problem hook
- "save links" → share your workflow
- "link manager" → share experience and mention your app
- "bookmark manager" → same as above

Keep replies human. Don't paste links in every reply. Build rapport first.

---

## HASHTAGS TO USE

#BuildInPublic #IndieHacker #FlutterDev #AndroidDev #Productivity #SideProject #MadeInIndia
