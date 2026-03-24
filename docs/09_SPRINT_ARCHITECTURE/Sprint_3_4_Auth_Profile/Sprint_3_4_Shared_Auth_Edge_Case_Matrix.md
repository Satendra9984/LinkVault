# Sprint 3-4 Shared Auth Edge-Case Matrix

## Purpose

This document lists high-risk edge cases for the LinkVault Sprint 3-4 authentication/profile setup when sharing the same Supabase Auth project with Curate, while keeping app-specific profile tables.

Goal: estimate implementation and testing effort before making architecture changes.

## Scope

- LinkVault auth/profile flow
- Shared Supabase `auth.users` with Curate
- LinkVault app-specific profile table: `lv_user_profiles`
- OTP + Guest mode (current sprint scope)

## Priority Legend

- P0: data loss/security/account lockout
- P1: broken core user journey
- P2: degraded UX with workaround
- P3: minor polish/consistency

## Edge-Case Matrix

### EC-01 Existing Curate user logs into LinkVault, no LinkVault profile
- **Priority:** P1
- **Repro steps:**
  - Use an email that already exists in Curate/Supabase Auth.
  - Sign into LinkVault via OTP.
  - Open Profile screen.
- **Expected behavior:** LinkVault profile is available immediately.
- **Current risk:** `lv_user_profiles` may be missing because trigger only runs on new `auth.users` inserts.
- **Fix strategy:**
  - Add idempotent bootstrap on auth success (`upsert` or `insert ... on conflict do nothing`) into `lv_user_profiles`.
  - Add one-time SQL backfill migration for existing `auth.users`.
- **Effort estimate:** M

### EC-02 Trigger + client bootstrap race creates duplicate or error state
- **Priority:** P2
- **Repro steps:**
  - New user signs up while both DB trigger and client fallback profile creation execute.
  - Observe logs for insert conflict failures.
- **Expected behavior:** No user-facing error; single profile row exists.
- **Current risk:** noisy failure path may break UX if unhandled.
- **Fix strategy:**
  - Ensure all bootstrap writes are idempotent and conflict-safe.
  - Treat duplicate insert as success path.
- **Effort estimate:** S

### EC-03 Guest mode flag conflicts with authenticated state after app restart
- **Priority:** P1
- **Repro steps:**
  - Continue as guest.
  - Login with OTP.
  - Force close app and relaunch.
- **Expected behavior:** user remains authenticated; guest mode disabled.
- **Current risk:** stale `isGuestMode` local flag can route incorrectly.
- **Fix strategy:**
  - On successful verify/login, always clear guest mode.
  - Add startup reconciliation rule: auth session wins over guest flag.
- **Effort estimate:** S

### EC-04 Guest local data appears missing after account login
- **Priority:** P1
- **Repro steps:**
  - Create guest collections/items locally.
  - Sign up/sign in with OTP.
  - Check collections list.
- **Expected behavior:** clear and deterministic continuity rule (either keep local until migrate, or guided migration).
- **Current risk:** users perceive data loss.
- **Fix strategy:**
  - Explicit continuity UX banner and migration CTA.
  - Preserve local data unless user confirms migration.
- **Effort estimate:** M

### EC-05 OTP sent with wrong mode for existing/non-existing account
- **Priority:** P2
- **Repro steps:**
  - Attempt signup for existing account and login for non-existing account.
  - Observe returned error and UI wording.
- **Expected behavior:** actionable message with next step.
- **Current risk:** generic auth errors increase drop-off.
- **Fix strategy:**
  - Improve auth error mapping for signup/login mismatch.
  - Add helper CTA to switch mode in-place.
- **Effort estimate:** S

### EC-06 OTP verify succeeds but profile fetch fails
- **Priority:** P1
- **Repro steps:**
  - Verify OTP successfully.
  - Simulate profile fetch failure (policy mismatch/network).
- **Expected behavior:** graceful retry with fallback bootstrap.
- **Current risk:** authenticated user gets stuck on "profile not found".
- **Fix strategy:**
  - Add profile fetch retry and fallback profile ensure call.
  - Add empty-state action: "Try again".
- **Effort estimate:** S/M

### EC-07 Delete account RPC conflict across Curate and LinkVault
- **Priority:** P0
- **Repro steps:**
  - Apply both apps' migrations in varying orders.
  - Inspect final `public.delete_user()` body.
- **Expected behavior:** deterministic function behavior for both apps.
- **Current risk:** last migration wins (`CREATE OR REPLACE`), causing drift.
- **Fix strategy:**
  - Either centralize one shared RPC contract, or namespace functions per app.
  - Add migration comment and ownership policy.
- **Effort estimate:** M

### EC-08 Delete account RPC callable with invalid context
- **Priority:** P0
- **Repro steps:**
  - Call `delete_user` without auth session/token.
  - Attempt execution from unauthorized role.
- **Expected behavior:** denied with clear error.
- **Current risk:** privilege misuse if grants are too open.
- **Fix strategy:**
  - Keep `SECURITY DEFINER` with explicit `auth.uid()` guard.
  - `REVOKE ALL FROM PUBLIC`, `GRANT EXECUTE TO authenticated`.
- **Effort estimate:** S

### EC-09 RLS mismatch between app tables and auth identity
- **Priority:** P1
- **Repro steps:**
  - Login and attempt profile update/read with valid session.
  - Test across dev/prod.
- **Expected behavior:** user can read/write own profile only.
- **Current risk:** auth succeeds but table access denied.
- **Fix strategy:**
  - Validate RLS policies on `lv_user_profiles` with test user.
  - Add smoke SQL checks in deployment checklist.
- **Effort estimate:** S

### EC-10 OAuth/deep-link residue from Curate affects LinkVault auth flows
- **Priority:** P1
- **Repro steps:**
  - Trigger any auth redirect flow with LinkVault package IDs.
  - Validate callback route handling.
- **Expected behavior:** callbacks resolve to LinkVault scheme.
- **Current risk:** Curate scheme leftovers (`io.supabase.curate://...`) cause redirect failures.
- **Fix strategy:**
  - Standardize LinkVault redirect URI usage in repositories/config.
  - Validate Android/iOS manifest/plist schemes by flavor.
- **Effort estimate:** S

### EC-11 Env mismatch (dev/prod points to different projects)
- **Priority:** P1
- **Repro steps:**
  - Login on dev app, then check expected profile table/project.
  - Repeat on production flavor.
- **Expected behavior:** each flavor points to intended Supabase project.
- **Current risk:** successful auth with "missing profile" due to wrong project/env keys.
- **Fix strategy:**
  - Add startup environment logging (non-secret).
  - Add CI check for required env vars.
- **Effort estimate:** S

### EC-12 Avatar bucket policies differ between apps
- **Priority:** P2
- **Repro steps:**
  - Upload avatar from LinkVault.
  - Read avatar URL immediately.
- **Expected behavior:** upload + read succeed.
- **Current risk:** storage bucket policy not aligned for LinkVault path.
- **Fix strategy:**
  - Define LinkVault avatar bucket/path convention.
  - Add storage policy verification tests.
- **Effort estimate:** M

## Feasibility Summary

- **Approach feasibility (shared auth + separate app tables):** High, with guardrails.
- **Must-have mitigations before broad rollout:**
  - EC-01 (profile bootstrap + backfill)
  - EC-07/EC-08 (delete RPC contract and grants)
  - EC-03/EC-04 (guest/auth continuity rules)
  - EC-09/EC-11 (RLS + environment validation)

## Suggested Implementation Order

1. Add `lv_user_profiles` backfill migration and idempotent runtime bootstrap.
2. Unify/namespace delete-account RPC strategy across Curate and LinkVault.
3. Harden guest-to-account continuity rules and user-facing messaging.
4. Add auth/profile smoke tests for existing Curate users and fresh LinkVault users.
5. Add release checklist checks for env keys, RLS, and deep links.

## Test Execution Checklist (Minimum)

- Existing Curate user -> LinkVault login -> profile exists
- New LinkVault signup -> profile exists
- Guest mode -> login -> restart -> authenticated state persists
- Guest local data -> explicit migration/no-migration paths verified
- Delete account denies unauthenticated calls and succeeds for authenticated user
- RLS prevents cross-user profile access
