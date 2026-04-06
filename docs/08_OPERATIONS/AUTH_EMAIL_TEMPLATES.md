# Auth Email Templates — Curateapp Shared Auth Project

**Status:** Phase 1 ready to deploy · Phase 2 architecture documented  
**Last Updated:** April 2026  
**Applies to:** LinkVault (`com.vicharshala.link_vault`) + Curate (`com.vicharshala.curate`) — same Supabase Auth project

**Local CLI (Edge Function deploy):** [SUPABASE_EDGE_FUNCTION_LOCAL_CLI_WORKFLOW.md](./SUPABASE_EDGE_FUNCTION_LOCAL_CLI_WORKFLOW.md) — Windows setup, **curate-dev** and **curate-production** projects, secrets from `.env.dev` / `.env.production`.

---

## Problem Statement

LinkVault and Curate share one Supabase Auth project. Supabase Auth templates are configured at the project level — a single set of templates applies to all apps. Historically the templates referenced "Curate" branding, which breaks trust and clarity for LinkVault users who receive a verification email from an app they do not recognise.

**Phase 1 (immediate):** Replace all Supabase template copy with brand-neutral "Curateapp" wording (the shared company domain across both apps). Zero backend change — paste directly into the Supabase dashboard.

**Phase 2 (long-term):** Replace Supabase's built-in email sending entirely using the `send_email` Auth hook + a Supabase Edge Function that calls Resend directly, enabling per-app branded emails.

---

## Template variables reference (Supabase Auth)

| Variable | Value |
|---|---|
| `{{ .Token }}` | 6-digit OTP code shown to the user |
| `{{ .Email }}` | Recipient email address |
| `{{ .SiteURL }}` | Set in Auth → URL Configuration (use `https://curateapp.in` or your landing page) |
| `{{ .ConfirmationURL }}` | Full signed magic-link URL (not used in OTP UX but Supabase always generates it) |
| `{{ .TokenHash }}` | Hashed token (not shown to user) |

---

## Phase 1 — Brand-neutral templates (Supabase dashboard)

Paste each template into **Supabase Dashboard → Auth → Email Templates** and click **Save**.

The HTML uses an inline-style table layout so it renders correctly in Gmail, Apple Mail, and Outlook without external stylesheets.

---

### 1. Confirm Signup

> **When sent:** User enters email and selects "Sign up" → OTP code is emailed to confirm the new account.

**Subject:**
```
Your verification code — Curateapp
```

**HTML body:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Verify your email — Curateapp</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f5;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#1a1a2e;padding:28px 40px;">
              <p style="margin:0;color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;">Curateapp</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px 28px;">
              <p style="margin:0 0 8px;color:#111;font-size:22px;font-weight:700;">Confirm your email</p>
              <p style="margin:0 0 28px;color:#555;font-size:15px;line-height:1.6;">
                Use the code below to complete your account creation. It expires in <strong>10 minutes</strong>.
              </p>

              <!-- OTP block -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <div style="display:inline-block;background:#f0f4ff;border:1.5px solid #c7d2fe;border-radius:10px;padding:18px 40px;margin-bottom:28px;">
                      <p style="margin:0;font-size:38px;font-weight:800;letter-spacing:10px;color:#1a1a2e;font-family:'Courier New',monospace;">{{ .Token }}</p>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 16px;color:#555;font-size:14px;line-height:1.6;">
                If you did not request this code, you can safely ignore this email. No account will be created.
              </p>
              <p style="margin:0;color:#555;font-size:14px;line-height:1.6;">
                Do not share this code with anyone.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px 40px;border-top:1px solid #eee;">
              <p style="margin:0;color:#999;font-size:12px;line-height:1.6;">
                Curateapp · This is an automated email, please do not reply.<br />
                <a href="{{ .SiteURL }}/privacy" style="color:#999;text-decoration:underline;">Privacy Policy</a>
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

**Plain-text body** (set in the "Text" tab of the template editor):
```
Verify your email — Curateapp

Enter this code in the app to confirm your account:

{{ .Token }}

This code expires in 10 minutes.

If you did not request this, ignore this email. No account will be created.
Do not share this code with anyone.

Curateapp
```

---

### 2. Magic Link (Sign-in OTP)

> **When sent:** Existing user enters email and selects "Sign in" → OTP code is emailed to authenticate.

**Subject:**
```
Your sign-in code — Curateapp
```

**HTML body:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Sign-in code — Curateapp</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f5;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#1a1a2e;padding:28px 40px;">
              <p style="margin:0;color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;">Curateapp</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px 28px;">
              <p style="margin:0 0 8px;color:#111;font-size:22px;font-weight:700;">Your sign-in code</p>
              <p style="margin:0 0 28px;color:#555;font-size:15px;line-height:1.6;">
                Enter this code in the app to sign in to your account. It expires in <strong>10 minutes</strong>.
              </p>

              <!-- OTP block -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <div style="display:inline-block;background:#f0f4ff;border:1.5px solid #c7d2fe;border-radius:10px;padding:18px 40px;margin-bottom:28px;">
                      <p style="margin:0;font-size:38px;font-weight:800;letter-spacing:10px;color:#1a1a2e;font-family:'Courier New',monospace;">{{ .Token }}</p>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 16px;color:#555;font-size:14px;line-height:1.6;">
                If you did not try to sign in, you can safely ignore this email. Your account remains secure.
              </p>
              <p style="margin:0;color:#555;font-size:14px;line-height:1.6;">
                Do not share this code with anyone.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px 40px;border-top:1px solid #eee;">
              <p style="margin:0;color:#999;font-size:12px;line-height:1.6;">
                Curateapp · This is an automated email, please do not reply.<br />
                <a href="{{ .SiteURL }}/privacy" style="color:#999;text-decoration:underline;">Privacy Policy</a>
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

**Plain-text body:**
```
Sign-in code — Curateapp

Enter this code in the app to sign in:

{{ .Token }}

This code expires in 10 minutes.

If you did not try to sign in, ignore this email. Your account remains secure.
Do not share this code with anyone.

Curateapp
```

---

### 3. Email OTP (fallback / direct OTP)

> **When sent:** Used by Supabase as a direct OTP fallback when the auth flow explicitly uses the `otp` email action type. Treat this the same as magic link.

**Subject:**
```
Your one-time code — Curateapp
```

**HTML body:** *(same structure as Magic Link above, change the headline only)*
Replace the headline `<p>` with:
```html
<p style="margin:0 0 8px;color:#111;font-size:22px;font-weight:700;">Your one-time code</p>
<p style="margin:0 0 28px;color:#555;font-size:15px;line-height:1.6;">
  Enter this code in the app to continue. It expires in <strong>10 minutes</strong>.
</p>
```

**Plain-text body:**
```
One-time code — Curateapp

Enter this code in the app to continue:

{{ .Token }}

This code expires in 10 minutes.

If you did not request this, ignore this email.
Do not share this code with anyone.

Curateapp
```

---

### 4. Change Email (low priority — email is read-only in app currently)

> **When sent:** Only if the app ever enables email changes. Include for completeness.

**Subject:**
```
Confirm your new email address — Curateapp
```

**HTML body:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Confirm new email — Curateapp</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f5;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#1a1a2e;padding:28px 40px;">
              <p style="margin:0;color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.5px;">Curateapp</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px 28px;">
              <p style="margin:0 0 8px;color:#111;font-size:22px;font-weight:700;">Confirm your new email address</p>
              <p style="margin:0 0 28px;color:#555;font-size:15px;line-height:1.6;">
                A request was made to change the email address on your Curateapp account.
                Enter the code below to confirm this new address. It expires in <strong>10 minutes</strong>.
              </p>

              <!-- OTP block -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <div style="display:inline-block;background:#f0f4ff;border:1.5px solid #c7d2fe;border-radius:10px;padding:18px 40px;margin-bottom:28px;">
                      <p style="margin:0;font-size:38px;font-weight:800;letter-spacing:10px;color:#1a1a2e;font-family:'Courier New',monospace;">{{ .Token }}</p>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 16px;color:#555;font-size:14px;line-height:1.6;">
                If you did not request an email change, please secure your account immediately by signing in and checking your settings.
              </p>
              <p style="margin:0;color:#555;font-size:14px;line-height:1.6;">
                Do not share this code with anyone.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="padding:20px 40px;border-top:1px solid #eee;">
              <p style="margin:0;color:#999;font-size:12px;line-height:1.6;">
                Curateapp · This is an automated email, please do not reply.<br />
                <a href="{{ .SiteURL }}/privacy" style="color:#999;text-decoration:underline;">Privacy Policy</a>
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
```

**Plain-text body:**
```
Confirm your new email address — Curateapp

A request was made to change the email address on your Curateapp account.
Enter the code below to confirm:

{{ .Token }}

This code expires in 10 minutes.

If you did not request an email change, secure your account immediately.
Do not share this code with anyone.

Curateapp
```

---

## Phase 1 — Deployment checklist (Supabase dashboard)

1. Open Supabase Dashboard → **Auth** → **Email Templates**.
2. For each template:
   - Select the template type from the left sidebar.
   - Paste the subject into **Subject**.
   - Paste the HTML into the **Body (HTML)** tab.
   - Paste the plain text into the **Body (Text)** tab.
   - Click **Save**.
3. Go to **Auth** → **URL Configuration**:
   - Set **Site URL** to `https://curateapp.in` (your shared company domain).
   - Verify your app deep-link redirects (`com.vicharshala.linkvault://login-callback/`, `com.vicharshala.curate://login-callback/`) are in the **Redirect URLs** allow-list.
4. Send a test OTP to a real inbox and verify the email renders correctly in Gmail + Apple Mail.

---

## Phase 2 — Custom mailer: Resend API + Supabase Auth `send_email` hook

### Why do this?

With Phase 1 in place, both apps get **"Curateapp"** emails — neutral but not branded per app. Phase 2 intercepts the Supabase email send event and routes it through Resend with a per-app HTML template, so:
- LinkVault users get **LinkVault**-branded emails.
- Curate users get **Curate**-branded emails.
- Templates live in code, are version-controlled, and can be updated without touching the Supabase dashboard.

### Architecture

```
Flutter App
  signInWithOtp(
    email: ...,
    redirectTo: 'com.vicharshala.linkvault://login-callback/'  ← app signal
  )
      │
      ▼
Supabase Auth
  generates OTP + would normally send via SMTP
      │
      │  send_email hook fires (HTTP POST)
      ▼
Edge Function: supabase/functions/auth-mailer/index.ts
  1. Verifies the hook secret (HMAC header)
  2. Reads payload.email_data.redirect_to
  3. Detects app from redirect_to scheme:
       com.vicharshala.linkvault  →  AppId.linkVault
       com.vicharshala.curate     →  AppId.curate
       (unknown)                  →  AppId.curateapp (neutral fallback)
  4. Reads payload.email_data.email_action_type:
       signup / magiclink / email_change_new / otp
  5. Selects subject + HTML template per (appId, emailType)
  6. POSTs to Resend API
  7. Returns { } 200  →  Supabase does NOT send its own email
      │
      ▼
Resend API  →  User inbox (per-app branded email)
```

### Supabase Auth hook payload shape

```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com"
  },
  "email_data": {
    "token": "123456",
    "token_hash": "...",
    "redirect_to": "com.vicharshala.linkvault://login-callback/",
    "email_action_type": "signup",
    "site_url": "https://curateapp.in",
    "token_new": "",
    "token_hash_new": ""
  }
}
```

`email_action_type` values:
- `signup` → Confirm Signup
- `magiclink` → Magic Link / Sign-in OTP
- `otp` → Email OTP (direct)
- `email_change_new` → New email confirmation
- `recovery` → Password reset (not used in OTP-only flow)

### Flutter change required

Add `redirectTo` to `signInWithOtp` calls so the hook can detect which app triggered the email:

```dart
// lib/features/auth/data/repositories/supabase_auth_repository.dart

await _supabase.auth.signInWithOtp(
  email: email,
  shouldCreateUser: shouldCreate,
  emailRedirectTo: 'com.vicharshala.linkvault://login-callback/',  // ← add this
);
```

This is the only Flutter code change needed for Phase 2. The `redirectTo` value is already registered in the Supabase Redirect URLs allow-list for OAuth, so adding it here costs nothing.

### Edge Function scaffold

**File:** `supabase/functions/auth-mailer/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';

// ── Types ─────────────────────────────────────────────────────────────────────

type AppId = 'linkvault' | 'curate' | 'curateapp';
type EmailActionType = 'signup' | 'magiclink' | 'otp' | 'email_change_new' | 'recovery';

interface HookPayload {
  user: { id: string; email: string };
  email_data: {
    token: string;
    token_hash: string;
    redirect_to: string;
    email_action_type: EmailActionType;
    site_url: string;
    token_new: string;
    token_hash_new: string;
  };
}

// ── App detection ─────────────────────────────────────────────────────────────

function detectApp(redirectTo: string): AppId {
  if (redirectTo.startsWith('com.vicharshala.link_vault') ||
      redirectTo.startsWith('com.vicharshala.linkvault')) {
    return 'linkvault';
  }
  if (redirectTo.startsWith('com.vicharshala.curate')) {
    return 'curate';
  }
  return 'curateapp'; // neutral fallback
}

// ── Subject lines ─────────────────────────────────────────────────────────────

function getSubject(app: AppId, type: EmailActionType): string {
  const appName = app === 'linkvault' ? 'LinkVault'
                : app === 'curate'    ? 'Curate'
                :                      'Curateapp';
  switch (type) {
    case 'signup':            return `Your verification code — ${appName}`;
    case 'magiclink':
    case 'otp':               return `Your sign-in code — ${appName}`;
    case 'email_change_new':  return `Confirm your new email — ${appName}`;
    default:                  return `Your code — ${appName}`;
  }
}

// ── HTML templates ────────────────────────────────────────────────────────────

interface AppBranding {
  name: string;
  headerBg: string;
  headerColor: string;
  otpBg: string;
  otpBorder: string;
  otpColor: string;
}

const BRANDING: Record<AppId, AppBranding> = {
  linkvault: {
    name:        'LinkVault',
    headerBg:    '#1a1a2e',
    headerColor: '#ffffff',
    otpBg:       '#f0f4ff',
    otpBorder:   '#c7d2fe',
    otpColor:    '#1a1a2e',
  },
  curate: {
    name:        'Curate',
    headerBg:    '#0f172a',
    headerColor: '#ffffff',
    otpBg:       '#fefce8',
    otpBorder:   '#fde047',
    otpColor:    '#0f172a',
  },
  curateapp: {
    name:        'Curateapp',
    headerBg:    '#1a1a2e',
    headerColor: '#ffffff',
    otpBg:       '#f0f4ff',
    otpBorder:   '#c7d2fe',
    otpColor:    '#1a1a2e',
  },
};

function getHeadline(type: EmailActionType): { title: string; body: string } {
  switch (type) {
    case 'signup':
      return {
        title: 'Confirm your email',
        body:  'Use the code below to complete your account creation. It expires in <strong>10 minutes</strong>.',
      };
    case 'email_change_new':
      return {
        title: 'Confirm your new email address',
        body:  'A request was made to change your email address. Enter the code below to confirm. It expires in <strong>10 minutes</strong>.',
      };
    default:
      return {
        title: 'Your sign-in code',
        body:  'Enter this code in the app to sign in to your account. It expires in <strong>10 minutes</strong>.',
      };
  }
}

function buildHtml(app: AppId, type: EmailActionType, token: string, siteUrl: string): string {
  const b = BRANDING[app];
  const { title, body } = getHeadline(type);
  const privacyUrl = `${siteUrl}/privacy`;

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title} — ${b.name}</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f5;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f5;padding:40px 0;">
    <tr><td align="center">
      <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
        <tr>
          <td style="background:${b.headerBg};padding:28px 40px;">
            <p style="margin:0;color:${b.headerColor};font-size:20px;font-weight:700;letter-spacing:0.5px;">${b.name}</p>
          </td>
        </tr>
        <tr>
          <td style="padding:36px 40px 28px;">
            <p style="margin:0 0 8px;color:#111;font-size:22px;font-weight:700;">${title}</p>
            <p style="margin:0 0 28px;color:#555;font-size:15px;line-height:1.6;">${body}</p>
            <table width="100%" cellpadding="0" cellspacing="0">
              <tr><td align="center">
                <div style="display:inline-block;background:${b.otpBg};border:1.5px solid ${b.otpBorder};border-radius:10px;padding:18px 40px;margin-bottom:28px;">
                  <p style="margin:0;font-size:38px;font-weight:800;letter-spacing:10px;color:${b.otpColor};font-family:'Courier New',monospace;">${token}</p>
                </div>
              </td></tr>
            </table>
            <p style="margin:0;color:#555;font-size:14px;line-height:1.6;">
              If you did not request this, you can safely ignore this email. Do not share this code with anyone.
            </p>
          </td>
        </tr>
        <tr>
          <td style="padding:20px 40px;border-top:1px solid #eee;">
            <p style="margin:0;color:#999;font-size:12px;line-height:1.6;">
              ${b.name} · This is an automated email, please do not reply.<br />
              <a href="${privacyUrl}" style="color:#999;text-decoration:underline;">Privacy Policy</a>
            </p>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

function buildPlainText(app: AppId, type: EmailActionType, token: string): string {
  const b = BRANDING[app];
  const { title } = getHeadline(type);
  return `${title} — ${b.name}\n\nEnter this code in the app:\n\n${token}\n\nThis code expires in 10 minutes.\n\nIf you did not request this, ignore this email. Do not share this code with anyone.\n\n${b.name}`;
}

// ── Main handler ──────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  // Supabase sends a webhook secret as Authorization header.
  // Verify it matches HOOK_SECRET env var before processing.
  const hookSecret = Deno.env.get('SEND_EMAIL_HOOK_SECRET') ?? '';
  const authHeader = req.headers.get('authorization') ?? '';
  if (hookSecret && authHeader !== `Bearer ${hookSecret}`) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  let payload: HookPayload;
  try {
    payload = await req.json() as HookPayload;
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  const { user, email_data } = payload;
  const app = detectApp(email_data.redirect_to ?? '');
  const type = (email_data.email_action_type ?? 'magiclink') as EmailActionType;
  const token = email_data.token;
  const siteUrl = email_data.site_url || 'https://curateapp.in';

  const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') ?? '';
  const FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL') ?? 'noreply@curateapp.in';

  const resendPayload = {
    from: `${BRANDING[app].name} <${FROM_EMAIL}>`,
    to:   [user.email],
    subject: getSubject(app, type),
    html:    buildHtml(app, type, token, siteUrl),
    text:    buildPlainText(app, type, token),
  };

  const resendRes = await fetch('https://api.resend.com/emails', {
    method:  'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type':  'application/json',
    },
    body: JSON.stringify(resendPayload),
  });

  if (!resendRes.ok) {
    const errBody = await resendRes.text();
    console.error('[auth-mailer] Resend error:', resendRes.status, errBody);
    // Return a non-200 so Supabase can fall back to its own SMTP if configured.
    return new Response(JSON.stringify({ error: 'Email send failed' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  // Return empty 200 — tells Supabase Auth NOT to send its own email.
  return new Response(JSON.stringify({}), {
    status:  200,
    headers: { 'Content-Type': 'application/json' },
  });
});
```

---

### Environment secrets required

Set these in **Supabase Dashboard → Edge Functions → Manage secrets** (or via `supabase secrets set`):

| Secret name | Value |
|---|---|
| `RESEND_API_KEY` | Your Resend API key (`re_...`) |
| `RESEND_FROM_EMAIL` | Verified sending address, e.g. `noreply@curateapp.in` |
| `SEND_EMAIL_HOOK_SECRET` | A random strong string — you set this in the Supabase Hook config and repeat it here |

---

### Deployment steps (Phase 2)

1. **Add the Flutter change:**
   In `lib/features/auth/data/repositories/supabase_auth_repository.dart`, add `emailRedirectTo` to `signInWithOtp`:
   ```dart
   await _supabase.auth.signInWithOtp(
     email: email,
     shouldCreateUser: shouldCreate,
     emailRedirectTo: 'com.vicharshala.linkvault://login-callback/',
   );
   ```

2. **Create the Edge Function:**
   ```
   supabase/functions/auth-mailer/index.ts
   ```
   Paste the scaffold from above.

3. **Deploy the Edge Function:**
   ```bash
   supabase functions deploy auth-mailer --no-verify-jwt
   ```
   The `--no-verify-jwt` flag is required because Supabase Auth calls the hook without a user JWT; the shared hook secret handles authentication instead.

4. **Register the hook in Supabase:**
   - Supabase Dashboard → **Auth** → **Hooks** → **Send Email**
   - Select **HTTP hook**
   - URL: `https://<your-project-ref>.supabase.co/functions/v1/auth-mailer`
   - Add header: `Authorization: Bearer <SEND_EMAIL_HOOK_SECRET>`
   - Save.

5. **Set secrets:**
   ```bash
   supabase secrets set RESEND_API_KEY=re_your_key
   supabase secrets set RESEND_FROM_EMAIL=noreply@curateapp.in
   supabase secrets set SEND_EMAIL_HOOK_SECRET=your_random_secret
   ```

6. **Verify Resend sender domain:**
   Ensure `curateapp.in` has SPF / DKIM / DMARC records configured in your DNS as Resend requires. Since you already use Resend for Curate, this domain is likely already verified — confirm in **Resend Dashboard → Domains**.

7. **Test end-to-end:**
   - Sign up with a real email via LinkVault dev build.
   - Confirm the email arrives with LinkVault branding, correct subject, and OTP code.
   - Repeat with Curate dev build.
   - Check Edge Function logs in Supabase Dashboard → Edge Functions → `auth-mailer` → Logs.

8. **Optionally remove the Resend SMTP config** from Supabase once the hook is confirmed working, to avoid duplicate sends. (The hook returning `200 {}` should already suppress Supabase's own send — but removing SMTP is a clean final step.)

---

### Migration timeline recommendation

| When | Action |
|---|---|
| Now | Implement Phase 1 — paste brand-neutral templates into Supabase dashboard (5 min) |
| Next release cycle | Implement Phase 2 — deploy Edge Function and register hook |
| After Phase 2 verified | Remove custom SMTP config from Supabase (optional cleanup) |

---

## Related docs

- [SUPABASE_EDGE_FUNCTION_LOCAL_CLI_WORKFLOW.md](./SUPABASE_EDGE_FUNCTION_LOCAL_CLI_WORKFLOW.md) — deploy `auth-mailer` for **curate-dev** and **curate-production** Supabase projects (CLI, secrets, hooks).

---

## Decision log

| Decision | Rationale |
|---|---|
| Use "Curateapp" in Phase 1, not a generic "Your account" | `curateapp.in` is the shared company domain across all apps; it is recognisable and avoids anonymous-looking emails that trigger spam filters |
| OTP code in large monospace font | Matches what the app UI shows; reduces copy-paste errors on mobile |
| Plain text body required | Some email clients (corporate, old Android) strip HTML; Supabase sends both if both are provided |
| `emailRedirectTo` in Flutter for Phase 2 | Supabase `send_email` hook payload includes `redirect_to` — this is the only reliable per-app signal without requiring changes to the Supabase project structure |
| `--no-verify-jwt` on the Edge Function | Supabase Auth hook calls do not carry a user JWT; hook secret provides equivalent auth |
| Inline HTML in Edge Function (Option A) | Faster to ship and review; migrate to Resend template IDs (Option B) only if design team needs frequent non-code updates |
| Return `500` on Resend failure | Lets Supabase fall back to its own SMTP if configured, rather than silently losing the email |
