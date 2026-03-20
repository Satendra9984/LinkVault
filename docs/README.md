# LinkVault — Documentation Index

**Version:** 1.0  
**Last Updated:** March 20, 2026  
**Project:** LinkVault — URL & Link Organizer (Full Reboot)  
**Architecture Base:** Curate v1 (Adapted)

---

## Quick Links

| I want to… | Go to |
|---|---|
| Understand the full project plan & sprint schedule | [Master Project Plan](./00_PROJECT_OVERVIEW/Master_Project_Plan.md) |
| Read the product requirements | [Product Requirements Document](./01_PRODUCT/Product_Requirements_Document.md) |
| Know which features are free vs premium | [Premium Feature Gating Matrix](./01_PRODUCT/Premium_Feature_Gating_Matrix.md) |
| Understand the code architecture | [Technical Architecture](./03_ARCHITECTURE/Technical_Architecture.md) |
| Set up the Supabase database | [Supabase Schema Design](./03_ARCHITECTURE/Supabase_Schema_Design.md) |
| Understand offline/cloud sync logic | [Cloud Sync & Scalability](./03_ARCHITECTURE/Cloud_Sync_Scalability_Strategy.md) |
| Understand local vs cloud repository selection | [Data Persistence State Machine](./09_SPRINT_ARCHITECTURE/Data_Persistence_State_Machine.md) |
| Set up RevenueCat + AdMob monetization | [Monetization Strategy & RevenueCat Guide](./05_MONETIZATION/Monetization_Strategy_RevenueCat_Guide.md) |
| Read the coding rules and standards | [Developer Bible](./03_ARCHITECTURE/Developer_Bible.md) |

---

## Document Map

```
docs/
├── README.md                           ← You are here
│
├── 00_PROJECT_OVERVIEW/
│   └── Master_Project_Plan.md          ← Vision, sprints, timeline, success criteria
│
├── 01_PRODUCT/
│   ├── Product_Requirements_Document.md ← PRD: stories, features, KPIs
│   └── Premium_Feature_Gating_Matrix.md ← Feature tiers, enforcement code
│
├── 03_ARCHITECTURE/
│   ├── Technical_Architecture.md       ← Clean Architecture, layers, structure, conventions
│   ├── Supabase_Schema_Design.md       ← Full SQL schema with RLS, triggers, indexes
│   ├── Cloud_Sync_Scalability_Strategy.md ← Offline-first sync, delta sync, conflict resolution
│   └── Developer_Bible.md              ← Non-negotiable coding rules
│
├── 05_MONETIZATION/
│   └── Monetization_Strategy_RevenueCat_Guide.md ← Revenue model, RC setup, AdMob, testing
│
└── 09_SPRINT_ARCHITECTURE/
    └── Data_Persistence_State_Machine.md ← When to use local vs Supabase repo
```

---

## Project Stack Reference

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State management | Riverpod 2.x (only) |
| Local DB | ObjectBox v4 |
| Remote / Auth | Supabase (PostgreSQL + Auth + Storage) |
| Navigation | GoRouter |
| IAP | RevenueCat (`purchases_flutter`) |
| Ads | Google AdMob (`google_mobile_ads`) |
| URL metadata | `html` + `http` (custom parser) |
| In-app browser | `flutter_custom_tabs` |
| Share intent | `receive_sharing_intent` |
| RSS | `xml` |
| OTP input | `pinput` |
| Flavors | `flutter_flavorizr` (dev / production) |
| Env config | `flutter_dotenv` |
| Error handling | `fpdart` (`Either<Failure, T>`) |
| Logging | `logger` |

---

## Architecture in One Diagram

```
[Share Intent / User Input]
         │
         ▼
[Presentation Layer — Screens + Widgets + Riverpod Providers]
         │
         ▼ (calls use cases)
[Application Layer — Use Cases (business logic + validation)]
         │
         ▼ (via repository interface)
[Domain Layer — Entities + Repository Interfaces]
         │
         ▼ (implemented by)
[Data Layer — LocalRepo (ObjectBox) or SupabaseRepo (Supabase)]
         │
         ▼
[Infrastructure — ObjectBox Store / Supabase Client]
```

**Repository selection is automatic via Riverpod:**
```
Guest / Free  →  LocalRepository (ObjectBox, offline-always)
Premium       →  SupabaseRepository (Supabase, syncs to cloud)
```

---

## Key Design Decisions

| Decision | Choice | Reason |
|---|---|---|
| State management | Riverpod only | Single source of truth, compile-time safety |
| Backend | Supabase only | Original app had Firebase + Supabase — caused bugs |
| Local DB | ObjectBox v4 | 10x faster than Isar v3 for reactive queries |
| Nested collections | `parent_id: String?` | Simple, portable, works in ObjectBox and Supabase |
| URL ordering | `position: FLOAT8` | Fractional indexing avoids mass re-numbering |
| Conflict resolution | Last-write-wins by `updated_at` | Simple, correct for single-user app |
| Ad model | 1 rewarded ad/day = 24hr pass | Lower friction than hard paywall, higher ad engagement |
| Shared Supabase project | Same project as Curate | Shared auth.users; enables future cross-app features |
| Shared RevenueCat project | Same project as Curate | Shared entitlements; enables future bundle subscription |
