# Auth Mailer Deployment Status (Dev + Prod)

**Last updated:** 2026-04-05  
**Rollout status:** Complete — Edge Functions deployed, secrets set, **Auth → Hooks → Send Email** verified in both Supabase projects (manual dashboard check).

**Scope:** `auth-mailer` Edge Function rollout aligned with plan `deploy-auth-mailer-both-projects`.

---

## Original Plan Checklist

Plan source: `deploy-auth-mailer-both-projects` (Cursor plan; not committed).

### 1) Preflight checks

**Status:** Completed

- Supabase CLI usable via `npx supabase` (global `npm install -g supabase` is unsupported).
- Local function: `supabase/functions/auth-mailer/index.ts`
- Project refs (from `.env.dev` / `.env.production`):
  - **curate-dev** → `ntthjutavcgqijasmhlc`
  - **curate-production** → `qeccyfbrhfsgoumawqvv`

### 2) Deploy to curate-dev

**Status:** Completed

- Linked CLI to `ntthjutavcgqijasmhlc`
- Secrets: `RESEND_API_KEY` (from `.env.dev` `SMTP_EMAIL_SERVER`), `RESEND_FROM_EMAIL`, `SEND_EMAIL_HOOK_SECRET`
- Deployed: `auth-mailer` on dev project
- Endpoint smoke: `POST` with valid auth → `{"ok":true}`; missing auth → `401`
- **Auth Send Email hook:** configured and verified in Supabase dashboard (manual)

### 3) Dev validation gate

**Status:** Completed (technical + hook wiring)

- Function endpoint smoke tests passed
- Hooks present in dev project (operator verified)
- **Optional follow-up:** full device matrix (LinkVault dev + Curate dev OTP, duplicate-send spot-check) — run when convenient; not required to close infra rollout

### 4) Deploy to curate-production

**Status:** Completed

- Linked CLI to `qeccyfbrhfsgoumawqvv`
- Secrets: `RESEND_API_KEY` (from `.env.production` `SMTP_EMAIL_SERVER`), `RESEND_FROM_EMAIL`, `SEND_EMAIL_HOOK_SECRET` (distinct from dev)
- Deployed: `auth-mailer` on production project
- Endpoint smoke: `{"ok":true}` with valid auth
- **Auth Send Email hook:** configured and verified in Supabase dashboard (manual)

### 5) Production validation gate

**Status:** Completed (technical + hook wiring)

- Production function deployed and secrets set
- Hooks present in production project (operator verified)
- **Optional follow-up:** one controlled real OTP in production to confirm Resend delivery and template copy end-to-end

### 6) Rollback controls

**Status:** Confirmed

- Per project: disable **Auth → Hooks → Send Email** if the hook misbehaves
- Keep `auth-mailer` deployed for log inspection
- Re-enable SMTP / default Auth email path while debugging if needed

---

## Verification log

| Date (UTC) | Environment | Check | Result |
|------------|-------------|--------|--------|
| 2026-04-05 | curate-dev (`ntthjutavcgqijasmhlc`) | `auth-mailer` deploy + secrets | Pass |
| 2026-04-05 | curate-dev | HTTP smoke (`{"ok":true}` / `401` without auth) | Pass |
| 2026-04-05 | curate-production (`qeccyfbrhfsgoumawqvv`) | `auth-mailer` deploy + secrets | Pass |
| 2026-04-05 | curate-production | HTTP smoke (`{"ok":true}`) | Pass |
| 2026-04-05 | Both | Auth **Send Email** hook configured in dashboard | Pass (manual verification) |

---

## Reference docs (step-by-step manual runbook)

- [SUPABASE_EDGE_FUNCTION_LOCAL_CLI_WORKFLOW.md](./SUPABASE_EDGE_FUNCTION_LOCAL_CLI_WORKFLOW.md) — CLI install, link, secrets, deploy, hook URLs
- [AUTH_EMAIL_TEMPLATES.md](./AUTH_EMAIL_TEMPLATES.md) — Phase 1 dashboard templates + Phase 2 function behavior

---

## Completed artifacts

- `docs/08_OPERATIONS/AUTH_EMAIL_TEMPLATES.md`
- `docs/08_OPERATIONS/SUPABASE_EDGE_FUNCTION_LOCAL_CLI_WORKFLOW.md`
- `supabase/functions/auth-mailer/index.ts`
- `supabase/config.toml` (local CLI metadata; includes function entry after `supabase init`)

---

## Optional follow-ups (not blockers)

1. Run live OTP from **LinkVault** and **Curate** on dev, then a single controlled OTP on prod; confirm inbox + Edge Function logs + Resend activity.
2. Add `emailRedirectTo` in Flutter (`signInWithOtp`) if per-app branded email routing is required — see [AUTH_EMAIL_TEMPLATES.md](./AUTH_EMAIL_TEMPLATES.md) Phase 2.
3. Rotate secrets if any were exposed in shared terminals or chat; see Security note below.

---

## Security note

- This document does not store secret values.
- If `SEND_EMAIL_HOOK_SECRET` or `RESEND_API_KEY` may have been exposed, rotate in Supabase secrets + Resend + re-save hook config if needed.
