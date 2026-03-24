Version: 1.1  
Last Updated: 2026-03-24  
Status: Active  
Owner: Product + Engineering  
Depends On: [Master_Project_Plan.md](./Master_Project_Plan.md), [Phase_Roadmap_Tasks_and_Test_Catalog.md](./Phase_Roadmap_Tasks_and_Test_Catalog.md), [../README.md](../README.md)  
Blocks: N/A

---

## LinkVault Cursor Usage SOP (Aligned to v1.1 Plan Set)

Use this playbook with:
- [Master_Project_Plan.md](./Master_Project_Plan.md) v1.1
- [Phase_Roadmap_Tasks_and_Test_Catalog.md](./Phase_Roadmap_Tasks_and_Test_Catalog.md) v1.1

When mode recommendations and implementation sequence appear to differ, follow phase ordering and gate criteria from the roadmap first.

Here is the full sprint-by-sprint Cursor mode playbook for your LinkVault project:

---

## Sprint-by-Sprint Cursor Mode Playbook

### Sprint 0 — Rebase Stabilization and Architecture Lock

**Goal:** Single canonical runtime path, dead code removal, baseline compiles.

| Task | Mode | Reason |
|---|---|---|
| Decide which entry point to lock (`main.dart` vs `mains.dart`) | **Premium** | architectural decision with long-term impact |
| Analyze and map all dead/legacy paths (Firebase, Isar, dual BLoC) | **Premium** | multi-file dependency tracing across mixed stacks |
| Execute file removals and path cleanup | **Auto** | mechanical after decision |
| Write ADR-0001 (canonical architecture lock) | **Auto** | drafting from decided content |
| Verify build passes post-cleanup | **Auto** | verification/fix loop |

---

### Sprint 1-2 — Architecture Scaffold + Splash + Onboarding

**Goal:** Fresh feature-first folder structure, flavors, env config, splash, onboarding.

| Task | Mode | Reason |
|---|---|---|
| Port Curate folder structure to LinkVault (`core/`, `features/`, `shared/`) | **Auto** | mechanical structural work |
| Set up `flutter_flavorizr` dev/production flavors | **Auto** | deterministic config setup |
| Wire `.env.dev` / `.env.production` with `flutter_dotenv` | **Auto** | straightforward config |
| Set up ObjectBox bootstrap with `objectbox_store.dart` | **Auto** | follows established Curate pattern |
| Set up Supabase client initialization | **Auto** | follows established pattern |
| Verify flavor isolation (no prod keys in dev build) | **Premium** | security-sensitive check |
| Splash + onboarding screens UI | **Model** | boilerplate UI; low reasoning cost |
| Write shared `Failure` hierarchy and `Either<Failure,T>` error contracts | **Auto** | follows established pattern from docs |

---

### Sprint 3-4 — Authentication and Profile

**Goal:** Supabase OTP auth, guest mode, profile, settings, account deletion.

| Task | Mode | Reason |
|---|---|---|
| Design auth state machine (guest→free→premium transitions) | **Premium** | state-machine reasoning with security implications |
| Implement `AuthRepository` interface + use cases | **Auto** | follows domain contract |
| Implement Supabase OTP datasource | **Auto** | established pattern |
| Wire auth Riverpod providers (`authSessionProvider`, `userTierProvider`) | **Auto** | mechanical wiring |
| Guest mode local-only enforcement in repository selector | **Premium** | tier logic is security/correctness critical |
| Profile screen + edit + avatar | **Model** | UI scaffolding |
| Account deletion via Supabase RPC (`lv_delete_user_data`) | **Premium** | destructive operation; security-sensitive |
| `lv_handle_new_user()` trigger validation in staging | **Premium** | data integrity check |
| Settings screen (theme, export, import) | **Model** | UI boilerplate |

---

### Sprint 5-6 — Collections (Nested Folders)

**Goal:** Full CRUD, unlimited nesting, drag reorder, pin/archive.

| Task | Mode | Reason |
|---|---|---|
| Design `CollectionEntity` and `CollectionRepository` interface | **Auto** | follows established canonical contracts |
| Implement `LocalCollectionRepository` (ObjectBox, reactive stream) | **Auto** | follows defined pattern |
| Implement `SupabaseCollectionRepository` (`lv_collections` RLS) | **Auto** | follows defined pattern |
| Wire `collectionsRepositoryProvider` with tier/state selector | **Premium** | selector logic must be correct for all 8 states |
| Fractional position indexing algorithm (reorder/rebalance) | **Premium** | non-trivial algorithm with edge cases |
| Breadcrumb navigation state (`List<CollectionEntity>` stack) | **Auto** | straightforward state management |
| Collection grid/card UI | **Model** | UI scaffolding |
| Drag-to-reorder integration test | **Auto** | test writing after algorithm is stable |
| Cascade delete verification (child collections + URLs) | **Premium** | data integrity concern; test multiple scenarios |

---

### Sprint 7-8 — URLs Management

**Goal:** URL CRUD, metadata auto-fetch, status tracking, click analytics.

| Task | Mode | Reason |
|---|---|---|
| `UrlEntity` and `UrlRepository` interface | **Auto** | follows established contracts |
| `LocalUrlRepository` (ObjectBox, paginated queries) | **Auto** | follows Curate Sprint 7 pattern |
| `SupabaseUrlRepository` (paginated `.select().range()`) | **Auto** | established pattern; no stream for items per Sprint 7 architecture |
| `UrlMetadataFetcher` utility (HTML parse, OG tags, favicon, timeout) | **Premium** | network + parsing edge cases; failure modes critical |
| Metadata enrichment: async-save-first, enrich-after pattern | **Auto** | follows defined non-blocking rule |
| URL status transitions (`unread/read/archived`) | **Auto** | straightforward state logic |
| Click count tracking and `lastAccessedAt` update on open | **Auto** | simple increment; follows contract |
| Drag-to-reorder URLs within collection | **Auto** | reuses fractional indexing already built |
| Receive sharing intent flow (`ReceiveIntentScreen`) | **Auto** | follows defined flow |
| URL list and detail UI | **Model** | UI scaffolding |

---

### Sprint 9-10 — Search, Tags, and RSS Reader

**Goal:** Global search, filter/sort, tag system, RSS feed reader.

| Task | Mode | Reason |
|---|---|---|
| Local search (ObjectBox full-text, 300ms debounce) | **Auto** | straightforward query |
| Remote search via `lv_search_urls` Supabase RPC | **Auto** | follows defined RPC contract |
| Filter/sort provider and UI chips | **Model** | UI with simple state |
| Tag system (comma-separated, searchable) | **Auto** | simple model already defined |
| RSS feed datasource (XML parse, RSS 2.0 + Atom) | **Auto** | `xml` package, established rules |
| RSS ObjectBox local cache with 7-day eviction | **Auto** | straightforward TTL logic |
| Save RSS article to LinkVault as `UrlEntity` | **Auto** | reuses URL add flow |
| RSS feed list + article UI | **Model** | UI scaffolding |

---

### Sprint 11-12 — Monetization and Cloud Sync

**Goal:** Ad Day Pass, RevenueCat IAP, premium migration, delta sync.

| Task | Mode | Reason |
|---|---|---|
| `AdDayPassService` logic (trial, pass active, grace period) | **Premium** | time-based state machine; edge cases in offline/grace handling |
| RevenueCat initialization with Supabase UID as RC user ID | **Auto** | follows defined pattern |
| Purchase/restore using return value directly (not `getCustomerInfo()` after) | **Premium** | known critical bug pattern; must be correct |
| Paywall screen UI | **Model** | UI scaffolding |
| Entitlement listener wiring to `userTierProvider` | **Auto** | reactive Riverpod connection |
| `CloudMigrationService` (local ObjectBox → Supabase upsert) | **Premium** | most complex data operation; correctness and idempotency critical |
| Migration screen UX (progress, resume, success/failure messaging) | **Auto** | straightforward UI following defined flow |
| Delta sync algorithm (`updated_at`-based pull/push) | **Premium** | conflict resolution, timestamp precision, race conditions |
| Sync queue (offline edits persist, flush on reconnect) | **Premium** | state preservation across app restarts |
| Manual sync action + migration reconciliation checks | **Premium** | verification correctness and rollback safety |
| Sync observability events (`sync_started`, `sync_failed`, `migration_sync_completed`) | **Auto** | deterministic instrumentation wiring |
| Thumbnail upload to `lv-thumbnails` Supabase Storage bucket | **Auto** | follows defined storage policy |
| Repository selector post-migration validation | **Premium** | critical correctness check for all 8 persistence states |
| `ReadOnlyCollectionRepository` for expired premium (downgrade flow) | **Auto** | follows defined read-only wrapper pattern |

---

### Sprint 13 — Polish and Testing

**Goal:** Animations, accessibility, performance, test coverage.

| Task | Mode | Reason |
|---|---|---|
| Loading shimmer animations | **Model** | deterministic UI pattern |
| Card/push-pop transition animations | **Model** | UI polish |
| Empty state illustrations | **Model** | UI scaffolding |
| Accessibility: VoiceOver/TalkBack semantics | **Auto** | systematic widget annotation |
| Unit tests for all use cases | **Auto** | test scaffolding from clear contracts |
| Widget tests for key screens | **Auto** | test scaffolding |
| Migration + sync integration tests | **Premium** | complex multi-step flows with data integrity checks |
| Performance profiling (60fps, <3s cold start, <100ms search) | **Premium** | identifying non-obvious bottlenecks across layers |
| Crash-free rate baseline check | **Auto** | review and annotate |

---

### Sprint 14 — Launch Preparation

**Goal:** Analytics, crash reporting, store submission, beta.

| Task | Mode | Reason |
|---|---|---|
| Analytics event instrumentation (app_open, url_saved, premium_converted) on selected analytics stack | **Auto** | systematic event tagging |
| Crash reporting setup on selected crash stack | **Auto** | SDK setup, follows guide |
| App Store screenshots + metadata copy | **Model** | content/copy work |
| Play Store listing | **Model** | content work |
| TestFlight + Play Internal Testing setup | **Auto** | mechanical release workflow |
| Pre-submission security review (RLS, secrets, account deletion) | **Premium** | security gate before public launch |
| Final store submission | **Auto** | mechanical |

---

## Summary Decision Matrix

| Situation | Mode |
|---|---|
| Anything following a defined architectural contract | Auto |
| Any UI screen, widget, boilerplate test | Model |
| State machine with multi-state edge cases | Premium |
| Sync / migration / conflict resolution logic | Premium |
| Security-sensitive paths (auth, RLS, deletion, purchase) | Premium |
| Data integrity and correctness validation | Premium |
| Performance bottleneck investigation | Premium |
| Formatting, rename, content/copy generation | Model |
| Iterative feature implementation loops | Auto |

---

## Gate-Review Override Rule

Before closing any phase, run one focused gate review using **Premium** if the phase includes:
- auth/session security behavior
- migration/sync/downgrade correctness
- data deletion/cascade behavior
- rollback or recovery behavior

For all other checklist updates, test ID updates, and implementation bookkeeping, use **Auto**.

---

**Rule of thumb**: If you can describe exactly what to do in one sentence and there is no ambiguity about correctness or side effects — use Auto or Model. If you are unsure whether the result could silently break data, auth, sync, or money flows — use Premium.