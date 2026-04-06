import "@supabase/functions-js/edge-runtime.d.ts";
import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";

type AppId = "linkvault" | "curate" | "curateapp";
type EmailActionType =
  | "signup"
  | "magiclink"
  | "otp"
  | "email_change_new"
  | "recovery";

interface HookPayload {
  user: { id: string; email: string };
  email_data: {
    token: string;
    redirect_to?: string;
    email_action_type?: EmailActionType;
    site_url?: string;
  };
}

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
    name: "LinkVault",
    headerBg: "#1a1a2e",
    headerColor: "#ffffff",
    otpBg: "#f0f4ff",
    otpBorder: "#c7d2fe",
    otpColor: "#1a1a2e",
  },
  curate: {
    name: "Curate",
    headerBg: "#0f172a",
    headerColor: "#ffffff",
    otpBg: "#fefce8",
    otpBorder: "#fde047",
    otpColor: "#0f172a",
  },
  curateapp: {
    name: "Curateapp",
    headerBg: "#1a1a2e",
    headerColor: "#ffffff",
    otpBg: "#f0f4ff",
    otpBorder: "#c7d2fe",
    otpColor: "#1a1a2e",
  },
};

const jsonHeaders = { "Content-Type": "application/json" };

function normalizeHookSecret(secret: string): string {
  if (!secret) return "";
  // Supabase docs commonly format as: v1,whsec_<base64_secret>
  if (secret.startsWith("v1,whsec_")) return secret.replace("v1,whsec_", "");
  return secret;
}

/**
 * Determine which app sent the OTP request.
 *
 * Primary signal: redirect_to (deep-link scheme sent by the Flutter app via
 * emailRedirectTo).  This works only when the deep-link URL has been added to
 * Supabase Auth → URL Configuration → Redirect URLs; otherwise GoTrue strips
 * it before forwarding the payload to the hook.
 *
 * Secondary signal: site_url (set per-project in Supabase Auth settings).
 * Use this as a fallback when redirect_to is absent.
 *
 * Default: "linkvault" — the owner of both Supabase projects (curate-dev /
 * curate-production) in this deployment.
 */
function detectApp(redirectTo: string, siteUrl: string): AppId {
  // Primary: deep-link scheme from the app
  if (
    redirectTo.startsWith("com.vicharshala.link_vault") ||
    redirectTo.startsWith("com.vicharshala.linkvault")
  ) return "linkvault";
  if (redirectTo.startsWith("com.vicharshala.curate")) return "curate";

  // Secondary: site_url configured in Supabase Auth settings
  if (siteUrl.includes("linkvault") || siteUrl.includes("link_vault")) return "linkvault";
  if (siteUrl.includes("curate") && !siteUrl.includes("curateapp")) return "curate";

  // Default: linkvault (owner of these Supabase projects)
  return "linkvault";
}

function getSubject(app: AppId, type: EmailActionType): string {
  const appName = BRANDING[app].name;
  switch (type) {
    case "signup":
      return `Your verification code — ${appName}`;
    case "email_change_new":
      return `Confirm your new email — ${appName}`;
    case "magiclink":
    case "otp":
    default:
      return `Your sign-in code — ${appName}`;
  }
}

function getHeadline(type: EmailActionType): { title: string; body: string } {
  switch (type) {
    case "signup":
      return {
        title: "Confirm your email",
        body:
          "Use the code below to complete your account creation. It expires in <strong>10 minutes</strong>.",
      };
    case "email_change_new":
      return {
        title: "Confirm your new email address",
        body:
          "A request was made to change your email address. Enter the code below to confirm. It expires in <strong>10 minutes</strong>.",
      };
    default:
      return {
        title: "Your sign-in code",
        body:
          "Enter this code in the app to sign in to your account. It expires in <strong>10 minutes</strong>.",
      };
  }
}

function buildHtml(
  app: AppId,
  type: EmailActionType,
  token: string,
  siteUrl: string,
): string {
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

function buildText(app: AppId, type: EmailActionType, token: string): string {
  const appName = BRANDING[app].name;
  const { title } = getHeadline(type);
  return `${title} — ${appName}

Enter this code in the app:

${token}

This code expires in 10 minutes.

If you did not request this, ignore this email. Do not share this code with anyone.

${appName}`;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: jsonHeaders },
    );
  }

  const hookSecret = Deno.env.get("SEND_EMAIL_HOOK_SECRET") ?? "";
  const authHeader = req.headers.get("authorization") ?? "";
  const rawBody = await req.text();
  let payload: HookPayload | null = null;

  // Path A: Supabase Auth Hook signature verification (recommended).
  try {
    const wh = new Webhook(normalizeHookSecret(hookSecret));
    payload = wh.verify(rawBody, Object.fromEntries(req.headers)) as HookPayload;
  } catch {
    // Path B: manual bearer auth fallback for smoke tests / controlled invocations.
    if (!hookSecret || authHeader !== `Bearer ${hookSecret}`) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: jsonHeaders },
      );
    }
    try {
      payload = JSON.parse(rawBody) as HookPayload;
    } catch {
      return new Response(
        JSON.stringify({ error: "Invalid JSON" }),
        { status: 400, headers: jsonHeaders },
      );
    }
  }

  const user = payload.user;
  const data = payload.email_data;
  if (!user?.email || !data?.token) {
    return new Response(
      JSON.stringify({ error: "Missing required fields" }),
      { status: 400, headers: jsonHeaders },
    );
  }

  const siteUrl = data.site_url || "https://linkvault.app";
  const app = detectApp(data.redirect_to ?? "", siteUrl);
  const type = (data.email_action_type ?? "magiclink") as EmailActionType;

  const resendKey = Deno.env.get("RESEND_API_KEY") ?? "";
  const fromEmail = Deno.env.get("RESEND_FROM_EMAIL") ?? "";
  if (!resendKey || !fromEmail) {
    return new Response(
      JSON.stringify({ error: "Server email config missing" }),
      { status: 500, headers: jsonHeaders },
    );
  }

  const resendPayload = {
    from: `${BRANDING[app].name} <${fromEmail}>`,
    to: [user.email],
    subject: getSubject(app, type),
    html: buildHtml(app, type, data.token, siteUrl),
    text: buildText(app, type, data.token),
  };

  const resendRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${resendKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(resendPayload),
  });

  if (!resendRes.ok) {
    const errBody = await resendRes.text();
    console.error("[auth-mailer] resend_error", resendRes.status, errBody);
    return new Response(
      JSON.stringify({ error: "Email send failed" }),
      { status: 500, headers: jsonHeaders },
    );
  }

  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: jsonHeaders,
  });
});
