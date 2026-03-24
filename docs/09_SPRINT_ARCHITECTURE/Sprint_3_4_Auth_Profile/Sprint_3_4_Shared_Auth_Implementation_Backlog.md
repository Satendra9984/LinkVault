# Sprint 3-4 Shared Auth Implementation Backlog

## Purpose

This backlog converts the shared-auth edge-case matrix into executable tickets with acceptance criteria, dependencies, and sequencing.

Reference document: `docs/09_SPRINT_ARCHITECTURE/Sprint_3_4_Auth_Profile/Sprint_3_4_Shared_Auth_Edge_Case_Matrix.md`

## Definition of Done (Global)

- Each ticket has code changes + test evidence.
- No regression in OTP login, guest mode, and profile update paths.
- Migrations are idempotent and safe for existing Supabase projects.
- Auth/profile behavior is deterministic for both:
  - existing Curate users
  - brand-new LinkVault users

## Phase 1 — Data Integrity and Account Safety (Must-Do First)

### TKT-AUTH-001: Backfill LinkVault profiles for existing auth users
- **Priority:** P0
- **Problem:** Existing Curate users can authenticate but miss `lv_user_profiles`.
- **Scope:**
  - Add SQL migration to insert missing rows into `public.lv_user_profiles` from `auth.users`.
  - Use conflict-safe insert (`ON CONFLICT DO NOTHING`).
- **Acceptance criteria:**
  - Running migration on populated DB creates missing `lv_user_profiles` rows.
  - Re-running migration produces no duplicates and no failures.
  - Existing users can open Profile in LinkVault after login.
- **Depends on:** existing migrations `001-003`.

### TKT-AUTH-002: Runtime idempotent profile bootstrap on auth success
- **Priority:** P0
- **Problem:** Future edge cases can still occur if trigger/backfill misses scenarios.
- **Scope:**
  - Ensure auth-success path calls idempotent profile-ensure function.
  - Make bootstrap non-fatal and user-safe.
- **Acceptance criteria:**
  - For any authenticated user without profile row, app self-heals and creates row.
  - No user-visible crash/blocked screen if profile is initially missing.
  - Duplicate insert race is handled gracefully.
- **Depends on:** TKT-AUTH-001.

### TKT-AUTH-003: Standardize delete-account RPC contract across apps
- **Priority:** P0
- **Problem:** `public.delete_user()` can be overwritten by migration order.
- **Scope (choose one strategy):**
  - Shared canonical `public.delete_user()` function across Curate and LinkVault, or
  - Namespaced RPCs (`lv_delete_user`, `curate_delete_user`) and app-specific callers.
- **Acceptance criteria:**
  - Function behavior is deterministic regardless of migration order.
  - Unauthenticated calls fail.
  - Authenticated user can delete own account and cascades occur.
  - Grants/revokes follow least privilege.
- **Depends on:** none, but should complete before release testing.

## Phase 2 — Session and Continuity Hardening

### TKT-AUTH-004: Guest/auth state reconciliation on startup
- **Priority:** P1
- **Problem:** Stale local guest flag can conflict with real auth session.
- **Scope:**
  - Introduce deterministic precedence rule (`authenticated session > guest flag`).
  - Ensure successful login always clears guest mode.
- **Acceptance criteria:**
  - After login + restart, user remains authenticated and not guest.
  - Sign-out resets guest/auth local session state predictably.
- **Depends on:** TKT-AUTH-002.

### TKT-AUTH-005: Guest-to-account continuity UX and policy
- **Priority:** P1
- **Problem:** users perceive data loss when guest local data is not visible after auth.
- **Scope:**
  - Implement explicit continuity rule and user messaging.
  - Add clear CTA for migration/merge path (or explicit defer path).
- **Acceptance criteria:**
  - Users see deterministic state and guidance after guest->auth transition.
  - No silent data disappearance behavior.
  - Ownership boundaries remain secure (no leakage).
- **Depends on:** TKT-AUTH-004.

### TKT-AUTH-006: OTP mismatch and retry UX hardening
- **Priority:** P2
- **Problem:** signup/signin mismatch and OTP retry errors create drop-off.
- **Scope:**
  - Improve auth error mapping for unknown account / already registered / expired OTP.
  - Add in-screen mode switch guidance.
- **Acceptance criteria:**
  - Error copy is actionable and mode-appropriate.
  - Resend flow works and does not trap user.
- **Depends on:** none.

## Phase 3 — Platform and Environment Guardrails

### TKT-AUTH-007: Environment and deep-link validation safeguards
- **Priority:** P1
- **Problem:** env/project mismatch or callback scheme drift causes false "missing profile" symptoms.
- **Scope:**
  - Add startup diagnostics (non-secret) for env/project.
  - Validate redirect/deep-link schemes for active flavor.
- **Acceptance criteria:**
  - Dev/prod builds clearly identify active environment.
  - Callback route and scheme are correct for LinkVault flavors.
- **Depends on:** none.

### TKT-AUTH-008: RLS smoke suite for `lv_user_profiles`
- **Priority:** P1
- **Problem:** auth succeeds while table access fails due policy drift.
- **Scope:**
  - Add SQL smoke checks for select/update own profile.
  - Add negative test for cross-user access denial.
- **Acceptance criteria:**
  - Authenticated user can read/update own row.
  - Access to other users' rows is denied.
  - Results documented in release checklist.
- **Depends on:** TKT-AUTH-001.

### TKT-AUTH-009: Avatar storage policy verification
- **Priority:** P2
- **Problem:** profile avatar upload/read may fail due bucket policy mismatches.
- **Scope:**
  - Define LinkVault avatar bucket/path convention.
  - Verify upload/read/update policy behavior for authenticated user.
- **Acceptance criteria:**
  - Upload succeeds; public/private URL behavior matches design.
  - Profile avatar updates are persisted and readable.
- **Depends on:** TKT-AUTH-008.

## Phase 4 — Test Automation and Release Gate

### TKT-AUTH-010: E2E auth/profile regression pack
- **Priority:** P1
- **Problem:** manual-only testing misses cross-app/shared-auth regressions.
- **Scope:**
  - Add integration test checklist (manual + automatable cases).
  - Include existing Curate user login scenario explicitly.
- **Acceptance criteria:**
  - Test pack covers:
    - existing Curate user -> LinkVault profile available
    - new LinkVault signup -> profile created
    - guest -> auth -> restart persistence
    - delete-account auth guard + cascade behavior
  - Pre-release gate requires pass.
- **Depends on:** TKT-AUTH-001..009.

## Suggested Delivery Sequence (2-Week Execution)

### Week A
- TKT-AUTH-001
- TKT-AUTH-002
- TKT-AUTH-003
- TKT-AUTH-004

### Week B
- TKT-AUTH-005
- TKT-AUTH-006
- TKT-AUTH-007
- TKT-AUTH-008
- TKT-AUTH-009
- TKT-AUTH-010

## Effort Snapshot

- **High risk / high impact:** A001, A002, A003
- **Medium implementation effort:** A005, A007, A010
- **Quick wins:** A004, A006, A008

## Release Readiness Checklist

- [ ] Existing Curate user login creates/loads `lv_user_profiles` reliably.
- [ ] Delete-account RPC strategy is finalized and non-conflicting across apps.
- [ ] Guest/auth reconciliation is deterministic across restarts.
- [ ] RLS and env/deep-link smoke checks are passing.
- [ ] Auth/profile regression pack is executed and signed off.

## Manual QA Checklist (Sprint 3-4 Shared Auth)

### EC-01/06 Existing Curate user self-heal
- [ ] Login in LinkVault using an email that already exists in Curate.
- [ ] Open Profile and verify it loads (or self-heals then loads).
- [ ] Confirm logs include `profile_self_heal_decision missing=true` and `profile_bootstrap_success`.

### EC-09 RLS insert policy
- [ ] Confirm `008_lv_user_profiles_insert_policy.sql` is applied.
- [ ] Re-test missing-profile login path and verify no RLS violation on insert.

### EC-03 Guest/auth reconciliation
- [ ] Continue as guest.
- [ ] Login with OTP.
- [ ] Restart app and verify authenticated state wins over stale guest mode.

### EC-04 Continuity UX clarity
- [ ] Auth email screen displays continuity guidance for Curate users.
- [ ] Auth screen displays local-data preservation message.

### EC-05 OTP mismatch + retry UX
- [ ] Sign-in with unknown email shows actionable guidance.
- [ ] Sign-up with existing email shows actionable guidance.
- [ ] Verify screen `Wrong email? Change it` returns to auth email flow.
- [ ] `Resend Code` only shows success snackbar when resend call succeeds.

### EC-02 Race-condition hardening
- [ ] Rapid repeated auth/profile entries do not produce user-facing failure.
- [ ] Duplicate profile create race is treated as non-fatal (check `duplicate_race=true` log).

### EC-07/08 Delete RPC namespacing and safety
- [ ] Confirm LinkVault calls `lv_delete_user` (not shared `delete_user`).
- [ ] Delete-account flow signs out cleanly after successful deletion.
- [ ] Unauthenticated invocation is rejected.

### EC-12 Avatar resilience
- [ ] Avatar upload success updates profile URL and renders on profile screen.
- [ ] Permission/policy failure returns user-safe message (not raw exception).
- [ ] Logs include `avatar_upload_attempt` and corresponding success/failure markers.
