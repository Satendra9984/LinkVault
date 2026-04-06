# Supabase Edge Function Local CLI Workflow (Windows)

This document explains, end-to-end, how to set up Supabase CLI locally on Windows and deploy the `auth-mailer` Edge Function used for custom auth emails.

It is written for the shared LinkVault + Curate Supabase Auth project and Resend domain `curateapp.in`.

You maintain **two Supabase projects** (curate-dev and curate-production). LinkVault reads credentials from:

- [`.env.dev`](../../.env.dev) — development
- [`.env.production`](../../.env.production) — production

Deploy and configure the Edge Function **once per Supabase project** (dev first, then production).

---

## Supabase projects ↔ env files (LinkVault repo)

| Environment | `APP_ENV` | Env file | Example `SUPABASE_URL` | `project-ref` |
|-------------|-----------|----------|------------------------|---------------|
| **curate-dev** | `dev` | [`.env.dev`](../../.env.dev) | `https://ntthjutavcgqijasmhlc.supabase.co` | `ntthjutavcgqijasmhlc` |
| **curate-production** | `production` | [`.env.production`](../../.env.production) | `https://qeccyfbrhfsgoumawqvv.supabase.co` | `qeccyfbrhfsgoumawqvv` |

**How to read `project-ref` yourself:** from `SUPABASE_URL`, use the hostname segment before `.supabase.co`. That string is the `project-ref` for `supabase link` and for hook URLs.

**Secrets (do not paste real values into git or this doc):**

- `SUPABASE_ANON_KEY` — Flutter app only; not used for Edge Function deploy.
- `SMTP_EMAIL_SERVER` — Resend API key (`re_...`). Use as `RESEND_API_KEY` in `supabase secrets set` for the **matching** project only (`.env.dev` → curate-dev, `.env.production` → curate-production).

Use a **different** `SEND_EMAIL_HOOK_SECRET` for dev vs production.

**Also in this repo:** `curate/.env.dev` and `curate/.env.production` may mirror the same URLs. Prefer **LinkVault root** `.env.*` for LinkVault CLI work unless your team standardizes on the `curate/` package paths.

---

## Scope

This workflow covers:

- installing Supabase CLI on a local Windows machine
- linking CLI to **curate-dev** and **curate-production** (two Supabase projects)
- creating and deploying `auth-mailer` to **both** projects
- configuring Auth `send_email` hook **per project**
- mapping `.env.dev` / `.env.production` to `RESEND_API_KEY` and `project-ref`
- validating behavior and troubleshooting failures

---

## Prerequisites

- Windows 10/11
- PowerShell
- Access to Supabase project dashboard
- Access to Resend account
- Verified sender domain in Resend: `curateapp.in`
- Repository cloned locally (`link_vault`)

Optional but recommended:

- Git installed
- Node.js installed (only needed if you choose npm-based CLI install)

---

## Architecture at a glance

1. App calls `signInWithOtp(...)`.
2. Supabase Auth triggers `send_email` hook.
3. Hook calls Edge Function `auth-mailer`.
4. Function routes template by app signal (`redirect_to`).
5. Function sends via Resend API.
6. Function returns HTTP 200 to Supabase Auth.

---

## 1) Install Supabase CLI

Choose one method.

### Option A: Scoop (recommended on Windows)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
scoop install supabase
```

### Option B: npm

```powershell
npm install -g supabase
```

### Verify install

```powershell
supabase --version
```

If command not found, restart terminal and try again.

---

## 2) Authenticate CLI

From project root:

```powershell
cd "c:\Users\LENOVO\development\saas\link_vault"
supabase login
```

You will **link twice** (once per Supabase project) in sections 5–8 below, or re-link before each deploy. The CLI remembers one linked project at a time under `.supabase/`.

---

## 3) Initialize local Supabase config (if needed)

If the repo does not yet contain CLI config files:

```powershell
supabase init
```

This prepares local Supabase metadata for functions/migrations.

---

## 4) Create function scaffold

```powershell
supabase functions new auth-mailer
```

This creates:

- `supabase/functions/auth-mailer/index.ts`

Paste the function implementation from:

- `docs/08_OPERATIONS/AUTH_EMAIL_TEMPLATES.md`
  - section: **Phase 2 — Custom mailer: Resend API + Supabase Auth `send_email` hook**
  - subsection: **Edge Function scaffold**

---

## 5) Configure secrets (per Supabase project)

After `supabase link --project-ref ...` for **that** project, set secrets **for that same project**:

```powershell
supabase secrets set RESEND_API_KEY="<from SMTP_EMAIL_SERVER in the matching .env file>"
supabase secrets set RESEND_FROM_EMAIL=noreply@curateapp.in
supabase secrets set SEND_EMAIL_HOOK_SECRET="<generate a long random secret; unique per dev vs prod>"
```

Notes:

- `RESEND_FROM_EMAIL` must be verified in Resend for `curateapp.in`.
- `SEND_EMAIL_HOOK_SECRET` must match the **Auth → Hooks → Send Email** `Authorization: Bearer ...` header for **this** Supabase project only.
- Never commit secrets to Git.

---

## 6) Deploy `auth-mailer` (per Supabase project)

```powershell
supabase functions deploy auth-mailer --no-verify-jwt
```

Why `--no-verify-jwt`:

- Supabase Auth hooks are service-origin calls, not user JWT calls.
- You authenticate hook requests via `Authorization: Bearer <SEND_EMAIL_HOOK_SECRET>`.

Repeat **link → secrets → deploy** for the second project (see section 8).

---

## 7) Configure Supabase Auth hook (per Supabase project)

In the **matching** Supabase dashboard (dev or production):

1. Go to **Auth → Hooks → Send Email**
2. Select **HTTP hook**
3. Set URL:
   - **curate-dev:** `https://ntthjutavcgqijasmhlc.supabase.co/functions/v1/auth-mailer`
   - **curate-production:** `https://qeccyfbrhfsgoumawqvv.supabase.co/functions/v1/auth-mailer`
4. Add header:
   - Name: `Authorization`
   - Value: `Bearer <SEND_EMAIL_HOOK_SECRET>` (the secret you set for **this** project)
5. Save

---

## 8) Full sequence: curate-dev, then curate-production

### 8a) curate-dev (`ntthjutavcgqijasmhlc`)

```powershell
cd "c:\Users\LENOVO\development\saas\link_vault"
supabase link --project-ref ntthjutavcgqijasmhlc
supabase secrets set RESEND_API_KEY="<SMTP_EMAIL_SERVER from .env.dev>"
supabase secrets set RESEND_FROM_EMAIL=noreply@curateapp.in
supabase secrets set SEND_EMAIL_HOOK_SECRET="<dev-only secret>"
supabase functions deploy auth-mailer --no-verify-jwt
```

Then in **curate-dev** dashboard: Auth → Hooks → Send Email → URL  
`https://ntthjutavcgqijasmhlc.supabase.co/functions/v1/auth-mailer`  
and `Authorization: Bearer <dev-only secret>`.

### 8b) curate-production (`qeccyfbrhfsgoumawqvv`)

```powershell
cd "c:\Users\LENOVO\development\saas\link_vault"
supabase link --project-ref qeccyfbrhfsgoumawqvv
supabase secrets set RESEND_API_KEY="<SMTP_EMAIL_SERVER from .env.production>"
supabase secrets set RESEND_FROM_EMAIL=noreply@curateapp.in
supabase secrets set SEND_EMAIL_HOOK_SECRET="<production-only secret; different from dev>"
supabase functions deploy auth-mailer --no-verify-jwt
```

Then in **curate-production** dashboard: Auth → Hooks → Send Email → URL  
`https://qeccyfbrhfsgoumawqvv.supabase.co/functions/v1/auth-mailer`  
and `Authorization: Bearer <production-only secret>`.

**Phase 1 email templates** (Supabase Auth → Email Templates) should also be updated **in both** projects if you rely on dashboard templates without the hook.

---

## 9) Auth URL configuration

In **Auth → URL Configuration**:

- Set **Site URL** to:
  - `https://curateapp.in`
- Ensure Redirect URLs include:
  - `com.vicharshala.linkvault://login-callback/`
  - `com.vicharshala.curate://login-callback/`

These deep links are used by mobile apps and by hook template routing logic.

---

## 10) Flutter-side requirement for app detection

For per-app email branding in Phase 2, pass `emailRedirectTo` in OTP call:

```dart
await _supabase.auth.signInWithOtp(
  email: email,
  shouldCreateUser: shouldCreate,
  emailRedirectTo: 'com.vicharshala.linkvault://login-callback/',
);
```

Current implementation location:

- `lib/features/auth/data/repositories/supabase_auth_repository.dart`

---

## 11) Validation checklist

After deployment:

1. With a **dev** build (points at `ntthjutavcgqijasmhlc`), trigger LinkVault signup OTP and confirm email + logs on **curate-dev**.
2. Repeat on **production** only after dev is verified (points at `qeccyfbrhfsgoumawqvv`).
3. Trigger Curate signup OTP on each environment as needed.
4. Confirm template / hook behavior matches expectations.
5. Check function logs in **each** project: Edge Functions → `auth-mailer` → Logs.
6. Confirm no duplicate emails are sent.

Expected outcomes:

- HTTP 200 from function on successful sends
- no `401` hook auth errors
- no Resend 4xx/5xx errors

---

## 12) Troubleshooting

### `supabase` command not found

- restart terminal
- reinstall CLI
- verify PATH

### `supabase link` fails

- verify project ref
- ensure you are logged in with account that has project access

### Hook returns 401

- header secret in Supabase Auth hook does not match `SEND_EMAIL_HOOK_SECRET`

### Function logs show Resend auth error

- invalid `RESEND_API_KEY`
- key set in wrong Supabase project (dev key on prod or vice versa)
- copied wrong line from `.env` (use `SMTP_EMAIL_SERVER` for the environment you linked)

### Function logs show sender/domain rejection

- `RESEND_FROM_EMAIL` not verified
- domain DNS (SPF/DKIM/DMARC) incomplete

### Emails not arriving

- inspect Supabase function logs first
- inspect Resend activity logs
- check spam/junk folder

### Duplicate emails

- confirm only one send path is active
- after stable hook operation, consider removing SMTP fallback configuration in Supabase Auth

---

## 13) Rollback plan

If production issues occur:

1. Disable Auth `send_email` hook in Supabase dashboard.
2. Re-enable/retain SMTP-based auth emails.
3. Keep function deployed for debugging.
4. Fix and retest in dev before re-enabling hook.

---

## 14) Recommended workflow per environment

You already run **curate-dev** and **curate-production** as two Supabase projects. Keep:

- separate `SEND_EMAIL_HOOK_SECRET` per project
- separate `RESEND_API_KEY` from the matching `.env` file (`SMTP_EMAIL_SERVER`)
- separate Auth hook URLs (one per project ref)
- Phase 1 dashboard email templates in sync in both projects, or rely on the hook only after Phase 2 is live

---

## 15) Quick command reference

**One-time:** install CLI, login, `supabase init`, `supabase functions new auth-mailer` (and paste code from `AUTH_EMAIL_TEMPLATES.md`).

**curate-dev:**

```powershell
cd "c:\Users\LENOVO\development\saas\link_vault"
supabase link --project-ref ntthjutavcgqijasmhlc
supabase secrets set RESEND_API_KEY="<.env.dev → SMTP_EMAIL_SERVER>"
supabase secrets set RESEND_FROM_EMAIL=noreply@curateapp.in
supabase secrets set SEND_EMAIL_HOOK_SECRET="<dev secret>"
supabase functions deploy auth-mailer --no-verify-jwt
```

**curate-production:**

```powershell
cd "c:\Users\LENOVO\development\saas\link_vault"
supabase link --project-ref qeccyfbrhfsgoumawqvv
supabase secrets set RESEND_API_KEY="<.env.production → SMTP_EMAIL_SERVER>"
supabase secrets set RESEND_FROM_EMAIL=noreply@curateapp.in
supabase secrets set SEND_EMAIL_HOOK_SECRET="<production secret>"
supabase functions deploy auth-mailer --no-verify-jwt
```

---

## 16) Related docs

- [AUTH_EMAIL_TEMPLATES.md](./AUTH_EMAIL_TEMPLATES.md) — Phase 1 templates + Phase 2 Edge Function source
- `lib/features/auth/data/repositories/supabase_auth_repository.dart`
- `.env.dev` / `.env.production` (repo root) — `SUPABASE_URL`, `SMTP_EMAIL_SERVER`

