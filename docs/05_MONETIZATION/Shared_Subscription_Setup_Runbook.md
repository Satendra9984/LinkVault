# LinkVault — Complete Subscription Setup & Testing Guide

**Version:** 4.0  
**Last Updated:** 2026-03-31  
**Covers:** Current State Diagnosis · Google Play Console · RevenueCat Dashboard (2026 UI) · Supabase Webhook · Flutter Env Files · End-to-End Testing

> **What changed in v4.0:** Part 0 rewritten to reflect current completed state (RC products, entitlements, offerings are all done). Part 2 corrected — shared Test Store is correct by design, no separate LV Dev entry needed. Parts 3–5 marked COMPLETED. Part 7 clarified (dev key correct, only production Android key needs updating). Part 8.3 promoted from "future work" to a full actionable Edge Function build guide. Pre-Release Checklist updated with current status of each item.

---

## Table of Contents

- [Part 0 — Current State Diagnosis (Read This First)](#part-0--current-state-diagnosis-read-this-first)
- [Part 1 — Google Play Console: Create LinkVault Subscriptions](#part-1--google-play-console-create-linkvault-subscriptions)
- [Part 2 — RevenueCat: Add LinkVault App Entries to the Existing Project](#part-2--revenuecat-add-linkvault-app-entries-to-the-existing-project)
- [Part 3 — RevenueCat: Create LinkVault Products](#part-3--revenuecat-create-linkvault-products)
- [Part 4 — RevenueCat: Attach LinkVault Products to the Shared Entitlement](#part-4--revenuecat-attach-linkvault-products-to-the-shared-entitlement)
- [Part 5 — RevenueCat: Update the Offerings](#part-5--revenuecat-update-the-offerings)
- [Part 6 — RevenueCat: Verify Sandbox Testing Access](#part-6--revenuecat-verify-sandbox-testing-access)
- [Part 7 — Flutter: Fix the LinkVault Env Files](#part-7--flutter-fix-the-linkvault-env-files)
- [Part 8 — Supabase: Monetization Support Fields](#part-8--supabase-monetization-support-fields)
- [Part 9 — Testing End-to-End](#part-9--testing-end-to-end)
- [Appendix — Quick Reference & Troubleshooting](#appendix--quick-reference--troubleshooting)

---

## Part 0 — Current State Diagnosis (Read This First)

Before touching any platform, you need to understand exactly what already exists and what is broken. This saves you from redoing already-done work and from missing the actual gaps.

> **Updated 2026-03-31** — This section reflects the current actual state after completing RC product setup. Several items previously listed as MISSING are now DONE.

### What Already Exists

The RevenueCat project that Curate uses is a **shared project**. LinkVault is added to this same project — not a new one. Here is what is now configured inside it:

| Item | Status | Notes |
|------|--------|-------|
| RevenueCat project | ✅ Done | Shared "Vicharshala Apps" project |
| `premium` entitlement | ✅ Done | Project-scoped; all Curate + LV products attached |
| Curate Android (Production) app | ✅ Done | `com.vicharshala.curate`, API key `goog_QqOMaPjDDwwLUBJYYYzzNPASTus` |
| Shared Test Store app | ✅ Done | One Test Store per RC project (shared by Curate Dev + LV Dev), API key `test_axvoWchnyWRCRhgmabmqoTqyxtH` |
| `curate_premium_monthly:monthly-base` | ✅ Done | Attached to `premium` entitlement |
| `curate_premium_annual:annual-base` | ✅ Done | Attached to `premium` entitlement |
| LinkVault Android (Production) app | ✅ Done | `com.vicharshala.link_vault`, own `goog_` key — **not yet copied into `.env.production`** |
| LinkVault Play Store subscriptions | ✅ Done | `lv_premium_monthly` and `lv_premium_annual` created and activated |
| LV Production RC products | ✅ Done | `lv_premium_monthly:monthly-base`, `lv_premium_annual:annual-base` |
| LV Test Store RC products | ✅ Done | `lv_premium_monthly`, `lv_premium_annual` (inside shared Test Store tab) |
| LV products attached to `premium` entitlement | ✅ Done | All 4 LV products attached |
| `default` offering packages updated | ✅ Done | `$rc_monthly` and `$rc_annual` include LV products |
| `.env.production` RC keys | ⚠️ **ACTION NEEDED** | Both keys still set to Curate's `goog_` key — must be updated to LV's own key |

### Understanding the Shared Test Store — Why the Dev Key Is Correct

A common question: "the dev key in `.env.dev` is the same as Curate's — is that a bug?"

**No. It is by design and you cannot change it.**

RevenueCat enforces exactly **one Test Store per project**. This is a hard platform limit. There is no option to create a second Test Store for LinkVault. Because there is only one Test Store app entry for the entire project, both Curate Dev and LinkVault Dev must use the same `test_` API key.

The shared Test Store still works correctly because:
- Both apps have their own distinct product identifiers (`curate_premium_monthly` vs `lv_premium_monthly`) inside the same Test Store
- Both sets of products are attached to the shared `premium` entitlement
- RC serves the correct product to the paywall based on which products are in the active offering packages
- Test purchases grant the `premium` entitlement project-wide, so a purchase in LinkVault Dev also unlocks Curate Dev (which is the intended shared premium behaviour)

**Current dev key state — no action needed:**
```
REVENUE_CAT_ANDROID_KEY=test_axvoWchnyWRCRhgmabmqoTqyxtH   ← correct, shared Test Store
REVENUE_CAT_IOS_KEY=test_axvoWchnyWRCRhgmabmqoTqyxtH        ← correct, same key for iOS
```

### What Is Still Broken

**Problem 1 — LinkVault production Android key is Curate's key**

In `.env.production`:
```
REVENUE_CAT_ANDROID_KEY=goog_QqOMaPjDDwwLUBJYYYzzNPASTus   ← Curate's key, not LV's
```

LinkVault Android (Production) has its own `goog_` key in RevenueCat — it was generated when the app entry was created. But this key has never been copied into `.env.production`. The current value is Curate's key.

**Effect:** Every production LinkVault purchase is recorded under Curate's app entry in RevenueCat. Revenue analytics are mixed. You cannot track LinkVault's subscribers separately from Curate's.

**Fix:** Go to RC Dashboard → Apps & Providers → LinkVault Android (Production) → API Keys → copy the `goog_` key → paste it into `.env.production` as `REVENUE_CAT_ANDROID_KEY`. This is the only outstanding action. See Part 7.

**Problem 2 — LinkVault production iOS key has wrong prefix**

In `.env.production`:
```
REVENUE_CAT_IOS_KEY=goog_QqOMaPjDDwwLUBJYYYzzNPASTus   ← wrong prefix + wrong app
```

`goog_` is a Google/Android prefix. RevenueCat routes receipts based on key prefix: `goog_` sends to Google's servers, `appl_` sends to Apple's servers. An Android key on iOS means every iOS purchase is sent to Google for validation — Google always rejects a receipt from an app it doesn't know — and the entitlement is never granted. This is a live production bug for any iOS user.

iOS support requires creating an Apple App Store app entry in RC first (App Store Connect setup). Until then, leave the iOS key as a placeholder. See Part 7.

### Summary Table — Current Status

| # | Problem | Where | Status | Fix |
|---|---------|-------|--------|-----|
| 1 | LV production Android key is Curate's key | `.env.production` | ⚠️ Open | Get LV's own `goog_` key from RC — Part 2 + Part 7 |
| 2 | LV production iOS key uses `goog_` prefix | `.env.production` | ⚠️ Open (iOS not launched) | Create LV iOS app entry in RC, get `appl_` key — Part 7 |
| 3 | Play Store subscriptions | Play Console | ✅ Done | `lv_premium_monthly` + `lv_premium_annual` created |
| 4 | LV app entry in RevenueCat | RC Dashboard | ✅ Done | LinkVault Android (Production) exists |
| 5 | LV products in RevenueCat | RC Dashboard | ✅ Done | All 4 products created |
| 6 | LV products attached to `premium` | RC Dashboard | ✅ Done | All 4 attached |
| 7 | LV products in offerings | RC Dashboard | ✅ Done | Both packages updated |

### LinkVault Bundle IDs (for reference throughout this guide)

| Flavor | Bundle ID |
|--------|-----------|
| Production | `com.vicharshala.link_vault` |
| Dev | `com.vicharshala.link_vault.dev` |

---

## Part 1 — Google Play Console: Create LinkVault Subscriptions

> **Why this must happen first:** RevenueCat's product catalog references store product IDs. If you try to create products in RevenueCat before they exist in the Play Console, RevenueCat cannot validate them against Google's API. Always create store products first, then create the corresponding RevenueCat products.

> **Note:** Your app must have been uploaded to at least an Internal Testing track in Play Console before the Subscriptions section becomes available. If you have not yet uploaded any APK/AAB for LinkVault, do that first.

### Step 1 — Navigate to Subscriptions

1. Open [Google Play Console](https://play.google.com/console).
2. Click on your **LinkVault** app in the app list.
3. In the left sidebar, scroll down until you see the **Monetize** section.
4. Under Monetize, click **Products** → **Subscriptions**.
5. You will see a list (currently empty for LinkVault) and a blue **Create subscription** button at the top right.

### Step 2 — Create the Monthly Subscription

1. Click **Create subscription**.
2. In the **Product ID** field, enter exactly: `lv_premium_monthly`
   > **Why this naming?** `lv_` is the LinkVault namespace prefix (just as `curate_` is used for Curate). The `_premium_monthly` suffix makes it clear what tier and billing cycle this is. Product IDs are permanent — you cannot change them after the product has had even one subscriber. Choose carefully.
3. In the **Name** field, enter: `LinkVault Premium (Monthly)`
4. Click **Create**.
5. You are now on the subscription's detail page. Scroll to the **Subscription Details** section.
6. In the **Description** field, enter: `Unlimited links, ad-free experience, and cross-device sync.`
7. Click **Save changes** (bottom right of the page).

> **Do not close this page yet.** You need to add a Base Plan before this subscription does anything.

### Step 3 — Add the Monthly Base Plan

A subscription product in Google Play is just a container. It does nothing until you add a Base Plan, which defines how often the user is billed, how much they pay, and what happens when a payment fails.

1. Scroll down the monthly subscription page to the **Base plans and offers** section.
2. Click **Add base plan**.
3. Fill in these fields:
   - **Base plan ID:** `monthly-base`
     > This ID, combined with the product ID, forms the RevenueCat identifier: `lv_premium_monthly:monthly-base`. Use this exact ID.
   - **Base plan type:** Select **Auto-renewing** (users are billed every month automatically until they cancel).
   - **Billing period:** Select **Monthly (1 month)**.
4. Scroll to **Renewal settings**:
   - **Grace period:** Select **3 days**
     > Grace period is the window after a failed payment where Google retries the charge and the user keeps access. Without this, a user whose card is temporarily declined loses access immediately. 3 days covers most transient bank issues.
   - **Account hold:** Toggle this **ON**
     > Account hold is a 30-day window after the grace period fails. The user's subscription is paused (they lose access), but if they update their payment method within 30 days, access is immediately restored without needing to resubscribe. Without this, a payment failure = permanent cancellation.
5. Scroll to **Price and availability** and click **Set prices**.
6. Under USD, enter **4.99**. Click **Update prices**.
   > Google will auto-convert to all other currencies using current exchange rates. Review a few regional prices and override if needed (e.g., India pricing is often set much lower manually).
7. Click **Save** at the bottom of the page.
8. **CRITICAL — Activate the base plan:** At the top of the base plan configuration, click the **Activate** button. The base plan is inactive by default and invisible to the Play Store until activated.

> **What happens if you forget to activate?** The subscription exists in Play Console but is invisible to users and cannot be purchased. RevenueCat fetches product details from Google at runtime — if the base plan is inactive, Google returns nothing and the paywall appears with no products.

### Step 4 — Create the Annual Subscription

1. Go back to **Products → Subscriptions**.
2. Click **Create subscription**.
3. **Product ID:** `lv_premium_annual`
4. **Name:** `LinkVault Premium (Annual)`
5. Click **Create**.
6. **Description:** `Save 33% — unlimited links, ad-free, and cross-device sync billed annually.`
7. Click **Save changes**.

### Step 5 — Add the Annual Base Plan

1. Scroll to **Base plans and offers** → **Add base plan**.
2. Fill in:
   - **Base plan ID:** `annual-base`
   - **Base plan type:** **Auto-renewing**
   - **Billing period:** **Yearly (1 year)**
3. Renewal settings:
   - **Grace period:** **7 days** (longer for annual because the user has paid a full year — give more time to resolve billing issues)
   - **Account hold:** **ON**
4. Click **Set prices** → enter **39.99** USD → **Update prices**.
5. Click **Save**.
6. Click **Activate**.

### Step 6 — (Optional but Recommended) Add a Free Trial Offer for Annual

Offering a 7-day free trial on the annual plan significantly increases annual conversions. The user tries the premium experience for free, and if they don't cancel, they are billed $39.99 after 7 days.

1. On the `lv_premium_annual` subscription page, find the `annual-base` row in the Base plans list.
2. On the right side of that row, click **Add offer**.
3. **Offer ID:** `annual-free-trial`
4. **Eligibility:** Select **New customer acquisition** (only users who have never had a premium subscription get the trial).
5. Scroll to **Phases** → **Add phase**.
6. **Type:** **Free trial**.
7. **Duration:** **7 days**.
8. Click **Apply** → **Save**.
9. Click **Activate** on the offer.

### End State — What Play Console Should Show

| Product ID | Name | Base Plan ID | Status |
|-----------|------|-------------|--------|
| `lv_premium_monthly` | LinkVault Premium (Monthly) | `monthly-base` | Active |
| `lv_premium_annual` | LinkVault Premium (Annual) | `annual-base` | Active |

---

## Part 2 — RevenueCat: Add LinkVault App Entry to the Existing Project

> **Current status:** LinkVault Android (Production) app entry is **already created** in RC. The only outstanding task in this part is copying its `goog_` API key into `.env.production`. If you have not done this yet, follow Step 2 below.

> **Critical — use the existing Curate project, do NOT create a new one.** Entitlements in RevenueCat are project-scoped. If you create a new project for LinkVault, it will have a completely separate `premium` entitlement, a completely separate customer database, and shared premium (one purchase unlocking both apps) becomes impossible. Always add LinkVault as new *app entries* inside the *same project*.

### Understanding the Dashboard Navigation (2026 UI)

When you open [app.revenuecat.com](https://app.revenuecat.com), the left sidebar has:

```
Project: [Your Project Name]
├── Customers
├── Charts
├── Product Catalog
│   ├── Products
│   ├── Entitlements
│   └── Offerings
├── Paywalls
├── Apps & Providers          ← This is where app entries live
└── Project Settings
```

"Apps & Providers" is where you manage which apps are registered in this project. Each app entry corresponds to one app on one platform (one bundle ID on one store).

### Why There Is No Separate "LinkVault Dev" App Entry — and Why That Is Correct

RevenueCat allows exactly **one Test Store per project**. This is not a configuration choice — it is a hard platform constraint. You cannot create a second Test Store app entry.

This means:
- **Curate Dev** and **LinkVault Dev** both share the single Test Store entry.
- Both apps use the same `test_` API key (`test_axvoWchnyWRCRhgmabmqoTqyxtH`).
- This is intentional and works correctly because each app has its own distinct product identifiers within the shared Test Store.

When the RC SDK initialises with the shared `test_` key, it fetches the `default` offering. The offering packages contain products from both Curate Dev and LinkVault Dev. RC automatically serves only the products belonging to the right app — but because it's the same test key, both sets are accessible, which is fine for development testing.

**No action is needed for the dev configuration.** The current `test_` key in `.env.dev` is correct.

### Step 1 — Verify LinkVault Android (Production) Exists

1. Go to [app.revenuecat.com](https://app.revenuecat.com).
2. Make sure you are in the Curate/Vicharshala project (check the project name in the top left).
3. In the left sidebar, click **Apps & Providers**.
4. Confirm you see **LinkVault Android (Production)** (or similar name with bundle ID `com.vicharshala.link_vault`) in the list.

If it does not exist yet (unlikely — it was created when the LV products were added), follow the creation steps in the expansion below before continuing.

<details>
<summary>How to create LinkVault Android (Production) if it is missing</summary>

1. Click **+ New** or **Add App Config**.
2. In the platform picker, select **Google Play Store**.
3. Fill in:
   - **App Name:** `LinkVault (Android)`
   - **Android Package:** `com.vicharshala.link_vault`
     > Must exactly match `applicationId` in `android/app/build.gradle.kts`. Any mismatch causes product lookups to fail.
4. **Service Account Credentials (JSON):** RevenueCat needs this to talk to Google Play's billing API and validate purchase receipts.

   **Recommended — reuse the same service account JSON as Curate:**
   - Open [Google Play Console](https://play.google.com/console) → **Setup → API Access**.
   - Find your existing `revenuecat` service account.
   - Click **Manage** → **App Permissions** → add `com.vicharshala.link_vault`.
   - Ensure permissions include **View financial data** and **Manage orders and subscriptions**.
   - Re-download the JSON from Google Cloud Console → IAM & Admin → Service Accounts → your account → Keys → Add Key → JSON.

   **Alternative — new dedicated service account:**
   Follow the same steps as the Curate setup guide. Name it `revenuecat-linkvault` to keep it distinct.

5. Upload the JSON to RevenueCat.
6. Click **Save Changes**.

</details>

### Step 2 — Copy the LinkVault Production API Key

This is the one action still outstanding. LinkVault's own `goog_` key exists in RC but has never been copied into `.env.production`.

1. In Apps & Providers, click on **LinkVault Android (Production)**.
2. Scroll down to the **API Keys** section.
3. Click **Show Key** (or copy icon) next to the `goog_` key.
4. Copy the full key — it will look like `goog_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`.
5. Open `.env.production` in the LinkVault repo root.
6. Replace the current value:
   ```
   # Before (wrong — Curate's key):
   REVENUE_CAT_ANDROID_KEY=goog_QqOMaPjDDwwLUBJYYYzzNPASTus

   # After (correct — LV's own key):
   REVENUE_CAT_ANDROID_KEY=goog_<YOUR_LINKVAULT_PRODUCTION_KEY>
   ```
7. Save the file.

> **Why do different app entries have different keys?** The API key tells RevenueCat which app entry you are initialising as. When a purchase is made, RC looks at the active key to know which app's product catalog and analytics bucket to use. Using Curate's key for LinkVault means all LV purchases are attributed to Curate in RC's dashboard. You lose per-app analytics and the ability to run app-specific experiments and paywalls.

### End State — What Apps & Providers Shows

| App Name | Platform | Bundle ID | API Key Prefix | Status |
|----------|----------|-----------|----------------|--------|
| Curate (Android) | Google Play | `com.vicharshala.curate` | `goog_QqO...` | ✅ Exists |
| Shared Test Store | RevenueCat Test | All dev bundle IDs | `test_axv...` | ✅ Exists (shared) |
| LinkVault (Android) | Google Play | `com.vicharshala.link_vault` | `goog_LV...` | ✅ Exists — **key not yet in .env.production** |
| LinkVault (iOS) | Apple App Store | `com.vicharshala.link_vault` | `appl_...` | ⚠️ Not yet (iOS launch not done) |

---

## Part 3 — RevenueCat: Create LinkVault Products

> ✅ **Status: COMPLETED** — All four LinkVault products have been created in the RC dashboard (confirmed from dashboard screenshot dated 2026-03-31). You do not need to run any steps in this part unless you are re-doing the setup from scratch or adding new products in the future.
>
> **Products created:**
> - `lv_premium_monthly:monthly-base` — LinkVault Android (Production)
> - `lv_premium_annual:annual-base` — LinkVault Android (Production)
> - `lv_premium_monthly` — Shared Test Store (LV tab)
> - `lv_premium_annual` — Shared Test Store (LV tab)

The steps below are kept as a reference for understanding the setup or recovering from accidental deletion.

---

RevenueCat products are the bridge between what you created in Google Play and RevenueCat's entitlement system. You create one product per subscription per app entry.

> **Common mistake:** Creating products inside the wrong app entry. Products are tied to their app entry. A product created inside "Curate (Android)" only works when RC is initialized with Curate's API key. Always double-check which app you are inside before creating a product.

### Current RC UI Quick Map (New Product Form)

RevenueCat's current dashboard uses a multi-field form instead of a single combined identifier. Here is how all the fields in that form map to your values:

**For Google Play Store products:**

| Form field | What it means | Your value |
|-----------|---------------|-----------|
| **Display name** | Human label shown in RC dashboard only | `LinkVault Premium Monthly` |
| **Product type** | What kind of purchase | `Subscription` |
| **Subscription** | The Play Store product ID you created in Play Console | `lv_premium_monthly` |
| **Base plan Id** | The base plan ID you created under that subscription | `monthly-base` |
| **Backwards compatible** | Legacy support for RC SDK v5 and below | Leave OFF for new apps |
| **RevenueCat product identifier** | Auto-generated by RC from the two fields above | `lv_premium_monthly:monthly-base` (auto) |

> **Why are Subscription and Base plan Id two separate fields?** Google Play uses a two-level hierarchy: a subscription product is a container, and the base plan inside it is what actually defines the billing cycle and price. RevenueCat needs both to construct the correct purchase intent. In the old RC UI, you typed the combined `subscription:baseplan` yourself; the new UI collects them separately and combines them internally — same result.

> **What is "Backwards compatible"?** This tells RevenueCat whether this base plan was marked as backwards-compatible in Play Console, which allows older RC SDK versions (v5 and below) to purchase it. For a new LinkVault setup using RC SDK v6+, leave this OFF. Setting it incorrectly does not break purchases but may confuse the backwards-compatible fallback logic in offerings.

**For Test Store products:**

| Form field | What it means | Your value |
|-----------|---------------|-----------|
| **Display name** | Human label in RC dashboard | `LinkVault Premium Monthly (Test)` |
| **Product type** | What kind of purchase | `Subscription` |
| **Subscription** | Plain product identifier (no base plan) | `lv_premium_monthly` |
| **Base plan Id** | Not used for Test Store — leave empty | *(leave blank)* |
| **Duration** | Billing period | `1 month` |
| **Price** | Price displayed in test dialog | `4.99 USD` |
| **RevenueCat product identifier** | Auto-generated | `lv_premium_monthly` (auto) |

> **Why no Base plan Id for Test Store?** Test Store is RevenueCat's own simulated store — it has no Google Play product catalog behind it and no concept of base plans. The product identifier is just a plain string.

---

### Step 1 — Navigate to Products

1. In the RevenueCat left sidebar, click **Product Catalog → Products**.
2. You will see a tab row at the top: one tab per app entry in your project. Click the tab for the app you want to work in.
   > In the older UI, this was a dropdown. In the current UI, it is a row of tabs — one for each app entry. Confirm the active tab shows **LinkVault (Android)** before creating production products.

### Step 2 — Create Production Products (inside the LinkVault Android tab)

Click the **LinkVault (Android)** tab. Then click **+ New**.

**Monthly product:**

1. **Display name:** `LinkVault Premium Monthly`
2. **Product type:** `Subscription`
3. **Subscription:** `lv_premium_monthly`
   > Enter only the Play product ID here. Do not include the colon or base plan — that goes in the next field.
4. **Base plan Id:** `monthly-base`
5. **Backwards compatible:** leave **OFF**
6. Click **Save** (or **Add**).
7. RC auto-generates the identifier as `lv_premium_monthly:monthly-base`. Verify this appears in the product list.

**Annual product:**

1. Click **+ New**.
2. **Display name:** `LinkVault Premium Annual`
3. **Product type:** `Subscription`
4. **Subscription:** `lv_premium_annual`
5. **Base plan Id:** `annual-base`
6. **Backwards compatible:** leave **OFF**
7. Click **Save**.
8. RC auto-generates `lv_premium_annual:annual-base`. Verify it appears.

### Step 3 — Create Dev (Test Store) Products (inside the LinkVault Android Dev tab)

Click the **LinkVault (Android Dev)** tab. Then click **+ New**.

> **Important:** The form looks slightly different for Test Store products. There is no Base plan Id field. There are Duration and Price fields instead.

**Monthly test product:**

1. **Display name:** `LinkVault Premium Monthly (Test)`
2. **Product type:** `Subscription`
3. **Subscription:** `lv_premium_monthly`
   > Use the same base name as production. This makes it easy to match test and production products at a glance.
4. **Base plan Id:** *(not shown / leave blank — not applicable for Test Store)*
5. **Duration:** `1 month`
6. **Price:** `4.99 USD`
7. Click **Save**.
8. RC identifier is `lv_premium_monthly` (no colon — plain ID for Test Store).

**Annual test product:**

1. Click **+ New**.
2. **Display name:** `LinkVault Premium Annual (Test)`
3. **Product type:** `Subscription`
4. **Subscription:** `lv_premium_annual`
5. **Base plan Id:** *(not shown / leave blank)*
6. **Duration:** `1 year`
7. **Price:** `39.99 USD`
8. Click **Save**.
9. RC identifier is `lv_premium_annual`.

### End State — Products You Should Have Created

| RC Product Identifier | App Tab | Store | Form values used |
|-----------------------|---------|-------|-----------------|
| `lv_premium_monthly:monthly-base` | LinkVault (Android) | Google Play | Subscription: `lv_premium_monthly`, Base plan: `monthly-base` |
| `lv_premium_annual:annual-base` | LinkVault (Android) | Google Play | Subscription: `lv_premium_annual`, Base plan: `annual-base` |
| `lv_premium_monthly` | LinkVault (Android Dev) | Test Store | Subscription: `lv_premium_monthly`, Duration: 1 month |
| `lv_premium_annual` | LinkVault (Android Dev) | Test Store | Subscription: `lv_premium_annual`, Duration: 1 year |

---

## Part 4 — RevenueCat: Attach LinkVault Products to the Shared Entitlement

> ✅ **Status: COMPLETED** — All four LinkVault products are confirmed attached to the `premium` entitlement (confirmed from dashboard screenshot dated 2026-03-31). You do not need to run any steps in this part.
>
> The steps below are kept as reference for understanding how entitlements work and for recovery if products are accidentally detached.

---

> **This is the most critical step for shared premium.** An entitlement is only granted when a user has an active subscription to a product that is attached to it. If a product is not attached to the `premium` entitlement, purchasing it grants nothing — the user pays but gets no access.

> **Do NOT create a new entitlement.** The `premium` entitlement already exists (it was created for Curate). Because it is project-scoped, it applies automatically to all apps in the project. You just need to attach the new LinkVault products to it.

### Step 1 — Navigate to the Existing Entitlement

1. In the left sidebar, click **Product Catalog → Entitlements**.
2. Click on the **`premium`** entitlement to open it.

### Step 2 — Attach LinkVault Products

1. Scroll down to the **Attached Products** section.
2. Click **Attach**.
3. A dialog shows all available products across all apps. Select:
   - `lv_premium_monthly:monthly-base` (Google Play, LinkVault Android)
   - `lv_premium_annual:annual-base` (Google Play, LinkVault Android)
   - `lv_premium_monthly` (Test Store, LinkVault Android Dev)
   - `lv_premium_annual` (Test Store, LinkVault Android Dev)
4. Click **Add**.

### How This Creates Shared Premium

After this step, the `premium` entitlement has products from both apps attached. Here is the logic:

- If a user buys `curate_premium_monthly:monthly-base` → they get the `premium` entitlement → they open LinkVault → LinkVault checks `entitlements.active['premium']` → it is `true` → premium access granted without buying again.
- If a user buys `lv_premium_monthly:monthly-base` → they get the `premium` entitlement → they open Curate → same result.

One purchase, both apps unlocked. This is the entire mechanism of shared premium.

### End State — Attached Products on the `premium` Entitlement

| Product | App | Environment |
|---------|-----|-------------|
| `curate_premium_monthly:monthly-base` | Curate (Android) | Production |
| `curate_premium_annual:annual-base` | Curate (Android) | Production |
| `curate_premium_monthly` | Curate (Android Dev) | Dev |
| `curate_premium_annual` | Curate (Android Dev) | Dev |
| `lv_premium_monthly:monthly-base` | LinkVault (Android) | Production |
| `lv_premium_annual:annual-base` | LinkVault (Android) | Production |
| `lv_premium_monthly` | LinkVault (Android Dev) | Dev |
| `lv_premium_annual` | LinkVault (Android Dev) | Dev |

---

## Part 5 — RevenueCat: Update the Offerings

> ✅ **Status: COMPLETED** — The `default` offering's `$rc_monthly` and `$rc_annual` packages have been updated to include LinkVault products (confirmed from dashboard screenshot dated 2026-03-31). You do not need to run any steps in this part.
>
> The steps below are kept as reference for understanding how offerings work and for any future offering changes.

---

Offerings are what the app's paywall screen fetches and displays. When your Flutter code calls `Purchases.getOfferings()`, RevenueCat returns the `default` offering. The offering contains packages. Each package contains products from multiple app entries. RevenueCat serves the correct product for the current session automatically based on which API key initialized the SDK.

This means the `default` offering is shared — you do not create separate offerings for LinkVault and Curate. You just add LinkVault's products to the existing packages.

### Critical Rule: One Product Per App Entry Per Package

**This is the constraint that causes the most confusion in multi-app setups.**

Each package can hold **one product per app entry**. "App entry" means a specific entry in Apps & Providers — so "LinkVault (Android)" is one app entry, "Curate (Android)" is another, "Curate (Android Dev)" is another, and "LinkVault (Android Dev)" is another.

The rule in practice:
- You CAN have one Curate Android product + one Curate Dev product + one LinkVault Android product + one LinkVault Dev product all in the same package — because those are four separate app entries.
- You CANNOT have two products from the same app entry in one package.

**This is why the RC package UI shows "you can only select one product per app."** The UI enforces one selection per app entry row. If you have two Test Store apps (Curate Dev and LinkVault Dev), you get two separate Test Store rows, each allowing one product.

### Why You May See Only One Test Store Row

If the package editor shows only one "Test Store" row (instead of one row for Curate Dev and one for LinkVault Dev), it means **LinkVault's Test Store app entry was not yet created** in Apps & Providers.

**Remediation steps if this happens:**

1. Stop — do not try to attach the second Test Store product yet.
2. Go back to **Apps & Providers** → scroll to **Test configuration**.
3. Create a new Test Store app entry specifically for LinkVault (App Name: `LinkVault (Android Dev)`, Bundle ID: `com.vicharshala.link_vault.dev`). See Part 2, Step 3.
4. Create the two Test Store products (`lv_premium_monthly`, `lv_premium_annual`) inside that new LinkVault Dev app entry. See Part 3, Step 3.
5. Return to the offering package — you should now see a separate row for LinkVault (Android Dev) alongside the Curate (Android Dev) row.
6. Select one product from each row.

### Understanding How Multi-App Offerings Work

Once all app entries and products exist, the target structure is:

```
default offering
├── $rc_annual package
│   ├── Curate (Android):            curate_premium_annual:annual-base   ← served when goog_ Curate key active
│   ├── Curate (Android Dev):        curate_premium_annual               ← served when test_ Curate key active
│   ├── LinkVault (Android):         lv_premium_annual:annual-base       ← served when goog_ LV key active
│   └── LinkVault (Android Dev):     lv_premium_annual                   ← served when test_ LV key active
└── $rc_monthly package
    ├── Curate (Android):            curate_premium_monthly:monthly-base
    ├── Curate (Android Dev):        curate_premium_monthly
    ├── LinkVault (Android):         lv_premium_monthly:monthly-base
    └── LinkVault (Android Dev):     lv_premium_monthly
```

RC's serving logic: at runtime, RC looks at all products in the package and finds the one belonging to the app entry that matches the active API key's store and bundle ID. All other products in the package are invisible to that session.

### Step 1 — Navigate to Offerings

1. In the left sidebar, click **Product Catalog → Offerings**.
   > In the current RC UI, Offerings may be listed directly under Product Catalog or as a top-level sidebar item — both lead to the same place.
2. Click into the **`default`** offering.

### Step 2 — Update the Annual Package

1. Click into the **`$rc_annual`** package (or click **Edit** on the package row).
2. You should see existing Curate products already attached — one per app entry row.
3. In the **Products** section, find the **LinkVault (Android)** row and select: `lv_premium_annual:annual-base`
4. Find the **LinkVault (Android Dev)** row and select: `lv_premium_annual`
   > If the LinkVault (Android Dev) row does not appear, follow the remediation steps above to create the Test Store app entry first.
5. Click **Save**.

### Step 3 — Update the Monthly Package

1. Go back to the `default` offering.
2. Click into the **`$rc_monthly`** package.
3. In the **Products** section:
   - **LinkVault (Android)** row → select `lv_premium_monthly:monthly-base`
   - **LinkVault (Android Dev)** row → select `lv_premium_monthly`
4. Click **Save**.

### Step 4 — Verify the Final Offering State

After saving, open each package and confirm:

| Package | App Entry | Product selected |
|---------|-----------|-----------------|
| `$rc_annual` | Curate (Android) | `curate_premium_annual:annual-base` |
| `$rc_annual` | Curate (Android Dev) | `curate_premium_annual` |
| `$rc_annual` | LinkVault (Android) | `lv_premium_annual:annual-base` |
| `$rc_annual` | LinkVault (Android Dev) | `lv_premium_annual` |
| `$rc_monthly` | Curate (Android) | `curate_premium_monthly:monthly-base` |
| `$rc_monthly` | Curate (Android Dev) | `curate_premium_monthly` |
| `$rc_monthly` | LinkVault (Android) | `lv_premium_monthly:monthly-base` |
| `$rc_monthly` | LinkVault (Android Dev) | `lv_premium_monthly` |

> **Why does the offering matter so much?** When your Flutter paywall calls `Purchases.getOfferings()`, if the returned offering has packages with no products for the current app/platform, the SDK treats those packages as empty and they do not appear on the paywall. A user would see a blank paywall with no purchase options. The offering is the only way RC knows what to show on the paywall — always verify it after any product changes.

---

## Part 6 — RevenueCat: Verify Sandbox Testing Access

This is a **project-level setting** — it applies to all apps in the project. If it was already set to "Anybody" when setting up Curate, it is already correct and you can skip this part. But verify it anyway, because it was the root cause of empty entitlements in Curate's debugging session.

### What This Setting Controls

Located at **Project Settings → General → Sandbox Testing Access**, this decides who gets entitlements from test/sandbox purchases.

| Setting | Behaviour |
|---------|-----------|
| **Anybody** | All sandbox purchases grant entitlements — correct for development |
| **Allowed App User IDs only** | Only explicitly allowlisted IDs get entitlements |
| **Nobody** | No sandbox purchase ever grants entitlements |

### Why "Allowed App User IDs only" Is Dangerous

This was the root cause bug in Curate's setup. The allowlist requires **App User IDs** — not email addresses. An App User ID looks like `$RCAnonymousID:10de34f3818449fc9007f1d7106610db`. These IDs change every time the user reinstalls the app if using anonymous sessions. Adding your email to the allowlist does nothing — RevenueCat cannot match an email to an anonymous App User ID.

The visible symptom: RevenueCat's customer profile shows the purchase recorded correctly with full transaction history and an active subscription, but all products appear under "Unattached products" — meaning RC received the purchase but refused to grant the entitlement because the user ID was not on the allowlist.

### Step 1 — Verify the Setting

1. In RevenueCat, go to **Project Settings** (gear icon in the left sidebar or bottom left).
2. Click **General**.
3. Find **Sandbox Testing Access**.
4. Confirm it is set to **Anybody**.
5. If not, change it to **Anybody** and save.

---

## Part 7 — Flutter: Fix the LinkVault Env Files

> ⚠️ **One action is still required here:** `.env.production` is using Curate's RC key. You need to replace it with LinkVault's own `goog_` key. The dev key is already correct — do not change it.

### Where Each Key Comes From

| Env file | Variable | What value to use | Where to find it | Status |
|----------|----------|-------------------|-----------------|--------|
| `.env.dev` | `REVENUE_CAT_ANDROID_KEY` | `test_axvoWchnyWRCRhgmabmqoTqyxtH` | Shared Test Store (same as Curate Dev) | ✅ Already correct |
| `.env.dev` | `REVENUE_CAT_IOS_KEY` | `test_axvoWchnyWRCRhgmabmqoTqyxtH` | Same shared Test Store key | ✅ Already correct |
| `.env.production` | `REVENUE_CAT_ANDROID_KEY` | `goog_<LV_PROD_KEY>` | RC → Apps & Providers → LinkVault Android (Production) → API Keys | ⚠️ **Must update** |
| `.env.production` | `REVENUE_CAT_IOS_KEY` | `appl_<LV_IOS_KEY>` | RC → Apps & Providers → LinkVault (iOS) → API Keys | ⚠️ Needs iOS entry first |

### `.env.dev` — No Changes Required

The current state is correct. Both keys point to the shared Test Store, which is the only Test Store that exists in the RC project:

```
# Current state — correct, no action needed
REVENUE_CAT_ANDROID_KEY=test_axvoWchnyWRCRhgmabmqoTqyxtH
REVENUE_CAT_IOS_KEY=test_axvoWchnyWRCRhgmabmqoTqyxtH
```

> **Why the same key for both iOS and Android in dev?** The Test Store is a platform-agnostic simulated store — there is no concept of an "Android" or "iOS" Test Store product. The same `test_` key initialises the RC SDK on both platforms and shows the same Test Store dialog. This is fine for development; only production keys are platform-specific.

### `.env.production` — Action Required: Replace Android Key

**Step 1 — Get LinkVault's production Android key from RevenueCat:**

1. Open [app.revenuecat.com](https://app.revenuecat.com) → **Apps & Providers**.
2. Click on **LinkVault Android (Production)** (bundle ID `com.vicharshala.link_vault`).
3. Scroll to **API Keys**.
4. Click the copy icon next to the `goog_` key. It looks like `goog_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`.

**Step 2 — Update `.env.production`:**

```
# Before (wrong — Curate's key):
REVENUE_CAT_ANDROID_KEY=goog_QqOMaPjDDwwLUBJYYYzzNPASTus

# After (correct — LinkVault's own key):
REVENUE_CAT_ANDROID_KEY=goog_<paste the key you copied>
```

**Step 3 — iOS key (deferred until iOS launch):**

Leave the iOS key as a placeholder for now. When iOS is ready:

1. Create a **LinkVault (iOS)** app entry in RC → Apps & Providers → Add App Config → App Store.
2. Configure it with the App Store Connect integration.
3. Copy the resulting `appl_` key.
4. Set `REVENUE_CAT_IOS_KEY=appl_<that key>`.

> **Why `appl_` and not `goog_` for iOS?** The key prefix tells RevenueCat which receipt validation server to use. `goog_` routes to Google Play's servers; `appl_` routes to Apple's App Store Connect servers. A receipt from an iOS purchase sent to Google's servers is always rejected because Google has never heard of that purchase. The result is a silent failure: the purchase goes through the App Store payment flow but no entitlement is ever granted. Never use a `goog_` key for iOS.

### Startup Verification Log

`bootstrap.dart` already logs the RC key prefix when the app starts:

```dart
debugPrint('💰 RevenueCat configured (${AppConfig.instance.environmentName})');
```

To confirm the correct key is active after updating `.env.production`, run a production build and look in the startup logs for:

```
Expected dev Android:    💰 RevenueCat configured (dev)   + key prefix = test_axv...
Expected prod Android:   💰 RevenueCat configured (prod)  + key prefix = goog_XYZ...   (your new LV key)
WRONG if you see:        💰 RevenueCat configured (prod)  + key prefix = goog_QqO...   (Curate's key)
```

### Verify the Flutter Purchase Code

The purchase and restore flow already uses the `CustomerInfo` returned directly from the SDK call — no separate `getCustomerInfo()` call after purchase. This was confirmed in the code audit of `revenuecat_premium_repository.dart`. The correct pattern is in place:

```dart
// CORRECT — CustomerInfo from purchase() directly (already implemented)
final info = await Purchases.purchase(PurchaseParams.package(package));
final isPremium = info.customerInfo.entitlements.active.containsKey('premium');

// CORRECT — CustomerInfo from restorePurchases() directly (already implemented)
final info = await Purchases.restorePurchases();
final isPremium = info.entitlements.active.containsKey('premium');
```

No code changes needed here.

---

## Part 8 — Supabase: Monetization Support Fields

Supabase is the cloud data layer. It does not handle billing, but it stores a mirror of the user's premium status that the app and server-side logic can reference without calling RevenueCat.

### Step 1 — Verify `lv_user_profiles` Has Monetization Columns

Connect to your Supabase project (the production one at `qeccyfbrhfsgoumawqvv.supabase.co`) and run:

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'lv_user_profiles'
  AND column_name IN ('is_premium', 'premium_expires_at');
```

If both rows are returned, the columns exist. If the query returns 0 rows, run this migration:

```sql
ALTER TABLE public.lv_user_profiles
  ADD COLUMN IF NOT EXISTS is_premium BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS premium_expires_at TIMESTAMPTZ;
```

> **Why `NOT NULL DEFAULT false`?** New users start as non-premium automatically. `NOT NULL` prevents the ambiguous `NULL` state — is `NULL` the same as `false`? Avoid that question entirely by disallowing `NULL`.

> **Why `premium_expires_at TIMESTAMPTZ`?** Storing the expiry time lets you run analytics queries like "how many users expire in the next 7 days?" and lets the app surface proactive renewal prompts without calling RevenueCat.

### Step 2 — Verify RLS Policies Are Active

Run this to confirm RLS is enabled on the key tables:

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename LIKE 'lv_%';
```

All rows in the result should show `rowsecurity = true`. If any show `false`, enable it:

```sql
ALTER TABLE public.lv_user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lv_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lv_urls ENABLE ROW LEVEL SECURITY;
```

Confirm the user-isolation policies exist:

```sql
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'lv_user_profiles';
```

You should see policies for SELECT and UPDATE that include `id = auth.uid()` or `owner_id = auth.uid()` in their definition.

### Step 3 — RevenueCat → Supabase Webhook

> ⚠️ **Status: Not yet built.** This is the next important infrastructure task after fixing `.env.production`.

#### Why This Matters

Currently, `lv_user_profiles.is_premium` is only updated when a user signs in (the auth flow calls `Purchases.getCustomerInfo()` and syncs the result to Supabase). This means:

- A user who subscribes, then closes the app, and opens it weeks later will be fine — sign-in syncs the status.
- But server-side quota enforcement (`lv_profile_premium_active()` in Supabase) reads `is_premium` directly from the database. Between sign-in events, `is_premium` may be stale. For example, if a user's subscription expires but they stay signed in, the database still shows `is_premium = true` until their next explicit sign-in.

A RevenueCat webhook solves this by pushing status changes to Supabase in real time — no user action needed.

#### How It Works (Concept)

```
User's subscription renews on Google Play
    ↓
Google Play notifies RevenueCat (RTDN — Real Time Developer Notification)
    ↓
RevenueCat processes the renewal, updates its own customer record
    ↓
RevenueCat POSTs a webhook event to your URL
    ↓
Supabase Edge Function receives the event
    ↓
Edge Function updates lv_user_profiles.is_premium + premium_expires_at
    ↓
Server-side quota checks now reflect current status
```

#### Step 3a — Create the Supabase Edge Function

Create `supabase/functions/revenuecat-webhook/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// RC webhook secret — set in Supabase secrets: supabase secrets set RC_WEBHOOK_SECRET=<value>
const RC_WEBHOOK_SECRET = Deno.env.get("RC_WEBHOOK_SECRET") ?? "";

// Events that grant or extend premium access
const GRANT_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "TRANSFER",
]);

// Events that revoke premium access
const REVOKE_EVENTS = new Set([
  "EXPIRATION",
  "SUBSCRIBER_ALIAS",
]);

serve(async (req: Request) => {
  // Validate webhook secret (RC sends it as Authorization header)
  const authHeader = req.headers.get("Authorization") ?? "";
  if (authHeader !== RC_WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }

  const event = await req.json();
  const eventType: string = event.event?.type ?? "";
  const appUserId: string = event.event?.app_user_id ?? "";  // = Supabase user ID
  const expiresAtMs: number | null = event.event?.expiration_at_ms ?? null;

  if (!appUserId) {
    return new Response("Missing app_user_id", { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,   // service role bypasses RLS
  );

  let isPremium: boolean | null = null;
  let premiumExpiresAt: string | null = null;

  if (GRANT_EVENTS.has(eventType)) {
    isPremium = true;
    premiumExpiresAt = expiresAtMs
      ? new Date(expiresAtMs).toISOString()
      : null;
  } else if (REVOKE_EVENTS.has(eventType)) {
    isPremium = false;
    // Keep existing expiry as a historical record — do not clear it
  } else if (eventType === "CANCELLATION") {
    // User cancelled but still has access until the current period ends
    // Do NOT set is_premium = false yet; it will become false on EXPIRATION
    isPremium = null; // no change
  } else if (eventType === "BILLING_ISSUE") {
    // Grace period — user keeps access while Google retries billing
    isPremium = null; // no change
  }

  if (isPremium !== null) {
    const updatePayload: Record<string, unknown> = {
      is_premium: isPremium,
      updated_at: new Date().toISOString(),
    };
    if (premiumExpiresAt !== null) {
      updatePayload.premium_expires_at = premiumExpiresAt;
    }

    const { error } = await supabase
      .from("lv_user_profiles")
      .update(updatePayload)
      .eq("id", appUserId);

    if (error) {
      console.error("Supabase update failed:", error);
      return new Response("DB error", { status: 500 });
    }
  }

  return new Response("OK", { status: 200 });
});
```

#### Step 3b — Deploy the Edge Function

```bash
# From the LinkVault repo root
supabase functions deploy revenuecat-webhook --project-ref qeccyfbrhfsgoumawqvv
```

Set the required secrets:
```bash
# The webhook authorization secret — you choose this string, then enter it in RC
supabase secrets set RC_WEBHOOK_SECRET="your-chosen-secret-string" \
  --project-ref qeccyfbrhfsgoumawqvv

# Service role key — found in Supabase Dashboard → Project Settings → API → service_role key
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="eyJ..." \
  --project-ref qeccyfbrhfsgoumawqvv
```

The deployed function URL is: `https://qeccyfbrhfsgoumawqvv.supabase.co/functions/v1/revenuecat-webhook`

#### Step 3c — Configure RevenueCat to Send Webhooks

1. Open [app.revenuecat.com](https://app.revenuecat.com) → **Project Settings** → **Integrations**.
2. Scroll to **Webhooks** → click **+ New**.
3. Fill in:
   - **URL:** `https://qeccyfbrhfsgoumawqvv.supabase.co/functions/v1/revenuecat-webhook`
   - **Authorization header:** the same secret string you set in `RC_WEBHOOK_SECRET`
   - **Events to send:** Select all — or at minimum: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`, `EXPIRATION`, `BILLING_ISSUE`
4. Click **Save** → **Test Webhook** to verify RC can reach the function.

#### Event Handling Reference

| RC Event | `is_premium` action | `premium_expires_at` action | Why |
|----------|--------------------|-----------------------------|-----|
| `INITIAL_PURCHASE` | Set to `true` | Set to end of first period | New subscriber — grant access |
| `RENEWAL` | Keep `true` | Update to new period end | Recurring billing — extend access |
| `UNCANCELLATION` | Set to `true` | Set to period end | User re-enabled before expiry |
| `PRODUCT_CHANGE` | Keep `true` | Update to new plan's end | Upgrade/downgrade |
| `CANCELLATION` | No change | No change | Access continues until `EXPIRATION` |
| `BILLING_ISSUE` | No change | No change | Grace period active — don't revoke yet |
| `EXPIRATION` | Set to `false` | Keep as record | Actual end of access |
| `TRANSFER` | Set to `true` for new owner | Update | Subscription moved to different user |

---

## Part 9 — Testing End-to-End

Testing happens in two phases. Never ship a new IAP change without both phases passing.

### Phase 1 — Dev Build + Test Store

**Purpose:** Fast iteration testing. Validates purchase logic, UI transitions, entitlement reading, and cancellation handling without involving real money or real Google Play billing.

**Step 1 — Run the dev flavor:**
```bash
flutter run --flavor dev --dart-define-from-file=.env.dev
```

**Step 2 — Check startup logs:**

With verbose logging enabled (`Purchases.setLogLevel(LogLevel.verbose)` in debug mode), you should see:
- The key prefix log: should start with `test_axvoWchnyWRCRhgmabmqoTqyxtH` — this is the shared Test Store key, correct for both Curate Dev and LinkVault Dev
- `Offerings fetched: default (2 packages)` — confirms the offering is correctly configured

If offerings fail to load or return 0 packages, the products are not yet attached to the offering (go back to Part 5).

**Step 3 — Trigger the paywall and make a test purchase:**

The Test Store shows a dialog with three buttons:

| Button | What It Simulates | When to Use |
|--------|------------------|-------------|
| **Validate Purchase** | Successful payment, entitlements granted | Happy path — run this first |
| **Cancel** | User taps the system back button on payment sheet | Verify no entitlement is granted, UI handles gracefully |
| **Failure** | Payment declined / network error | Verify error message appears, user can retry |

**Step 4 — After "Validate Purchase" — expected logs:**
```
[RC] Post-purchase entitlements: [premium]
```

The app should immediately transition to premium state.

**Step 5 — Full scenario matrix (run all before any release):**

| Scenario | Expected Result | How to Trigger |
|----------|----------------|----------------|
| Purchase monthly plan | `premium` active, app unlocked | Test Store → Validate |
| Purchase annual plan | `premium` active, app unlocked | Test Store → Validate |
| User cancels payment | No entitlement, graceful UI | Test Store → Cancel |
| Payment fails | Error message, no entitlement | Test Store → Failure |
| Relaunch after purchase | `premium` persists | Kill app, reopen |
| Restore purchases | `premium` re-granted | Tap Restore in app |
| DayPass gate with premium | Gate is bypassed silently | Navigate to any gated action |
| Premium check on DayPass screen | Shows "You have Premium" state | Open DayPass screen as premium user |

### Phase 2 — Production Build + Google Play License Tester

**Purpose:** Full pipeline validation. The purchase goes through the real Google Play billing servers, RevenueCat validates it with Google's API, and your app receives a real `CustomerInfo` from the production billing pipeline. This catches issues that the Test Store cannot simulate (key mismatches, Service Account permission problems, Play Console product activation).

**Step 1 — Set up a Google Play License Tester:**

1. Go to [Google Play Console](https://play.google.com/console) → **Setup → License Testing**.
2. Click **Add license tester**.
3. Enter a Gmail address you control (must be different from the primary account on your test device — use a secondary Gmail account or a secondary user profile on the device).
4. Save.

> **Warning:** Do NOT use your personal Gmail account for testing. License testers get free purchases, but only if configured correctly. If you test with an unlisted account, you will be charged real money.

**Step 2 — Build the production flavor:**

```bash
# APK for direct installation (sideloading)
flutter build apk --flavor production --dart-define-from-file=.env.production

# AAB for uploading to Play Store
flutter build appbundle --flavor production --dart-define-from-file=.env.production
```

Install the APK directly on a test device signed in with the license tester Gmail account.

**Step 3 — Verify the production flow:**

- [ ] The key prefix log shows `goog_` and it is LinkVault's own key (not `goog_QqOMaPjDDwwLUBJYYYzzNPASTus` which is Curate's)
- [ ] The real Google Play billing sheet appears (full payment UI, not the Test Store dialog)
- [ ] Purchase completes with no real charge (license tester accounts are not billed)
- [ ] RevenueCat dashboard → Customers → find the test user → transaction history shows the purchase
- [ ] `premium` entitlement is active in `CustomerInfo`
- [ ] App unlocks premium features
- [ ] Uninstall → reinstall → sign in → Restore Purchases → entitlement returns

### Phase 3 — Shared Entitlement Cross-App Smoke Test

This test verifies the core shared premium promise: one subscription unlocks both apps.

**Run this test before launch:**

1. Install **LinkVault dev** and **Curate dev** on the same device (or two devices sharing the same account).
2. Sign in to both apps with the **same email/Supabase account**.
3. In **LinkVault dev**, open the paywall and make a Test Store "Validate Purchase".
4. Confirm `premium` is active in LinkVault.
5. Open **Curate dev** (without purchasing anything in Curate).
6. Check if Curate shows premium access.
   > If yes: shared entitlement is working correctly. The `premium` entitlement returned `true` because the LinkVault Test Store product is attached to it, and Curate checks the same entitlement.
   > If no: check that the LinkVault Test Store products are actually attached to the `premium` entitlement (Part 4). Also verify Sandbox Testing Access is "Anybody" (Part 6).
7. Repeat in reverse: buy in Curate, verify LinkVault gets premium.
8. Cancel subscription in RevenueCat customer dashboard → verify both apps eventually show expired state.

---

## Appendix — Quick Reference & Troubleshooting

### API Key Prefix Reference

| Prefix | Platform | Environment | Example Usage |
|--------|----------|-------------|--------------|
| `test_` | Any (TestStore) | Dev / Testing only | Never ship in production builds |
| `goog_` | Android (Google Play) | Production | `.env.production` `REVENUE_CAT_ANDROID_KEY` |
| `appl_` | iOS (Apple App Store) | Production | `.env.production` `REVENUE_CAT_IOS_KEY` |

> **Rule:** iOS keys must start with `appl_`. Android production keys must start with `goog_`. Mixing them causes silent validation failure — purchases go through but entitlements are never granted.

### Product ID Format by Store

| Store | Format | Example |
|-------|--------|---------|
| Google Play | `subscription_id:base_plan_id` | `lv_premium_monthly:monthly-base` |
| RevenueCat Test Store | `product_id` only | `lv_premium_monthly` |
| Apple App Store | `product_id` only | `lv_premium_monthly` |

### RevenueCat Dashboard Navigation Map (2026 UI)

| What you need to do | Where to go |
|--------------------|-------------|
| Create production app (Play Store or App Store) | Apps & Providers → Add App Config |
| Create dev app (Test Store) | Apps & Providers → scroll down → **Test configuration** section (not Add App Config) |
| Get API keys for an app | Apps & Providers → click the app entry → API Keys section |
| Create products | Product Catalog → Products → select the correct app tab → + New |
| Create or view entitlements | Product Catalog → Entitlements |
| Attach products to entitlements | Entitlements → `premium` → Attached Products → Attach |
| Create or edit offerings | Product Catalog → Offerings (or top-level Offerings in sidebar) |
| Add products to packages | Offerings → `default` → click package → select one product per app entry row → Save |
| **Change Sandbox Testing Access** | **Project Settings → General → Sandbox Testing Access** |
| View a customer's purchase history | Customers → search by App User ID or email |
| Archive unused products/entitlements | Product Catalog → Products / Entitlements → three-dot menu → Archive |

### Troubleshooting

| Symptom | Most Likely Cause | Fix |
|---------|------------------|-----|
| Paywall appears blank / no packages | Offering has no products for the current app/platform | Part 5 — verify LV products are in both packages |
| TestStore dialog doesn't appear | Wrong API key prefix (`goog_` used instead of `test_`) | Part 7 — verify `.env.dev` key starts with `test_` |
| Purchase recorded in RC but shows "Unattached products" | Sandbox Testing Access is blocking the user | Part 6 — set to "Anybody" |
| Entitlements empty after TestStore purchase | Product not attached to `premium` entitlement | Part 4 — attach products |
| Production Android purchase fails silently | `.env.production` still using Curate's `goog_` key | Part 7 — replace with LV's own `goog_` key from RC |
| Production iOS purchase fails silently | `goog_` key used for iOS | Part 7 — create iOS app entry in RC, use `appl_` key |
| Dev build behaves identically to Curate dev | Expected — both share the same Test Store | No action needed; this is by design |
| Test Store shows Curate product names on LV paywall | LV test products not attached to offering packages | Part 5 — add `lv_premium_*` to `$rc_monthly` and `$rc_annual` |
| Restore purchases does nothing | No prior purchase for this App User ID | Make a purchase first, then test restore |
| Entitlements empty immediately after purchase | `purchase()` return value discarded | Verify `CustomerInfo` from `purchase()` is used directly |
| Premium shows in LV but not Curate after shared purchase | LV products not attached to `premium` entitlement | Part 4 — verify all LV products are attached |
| Offerings call returns null after adding LV | Products not activated in Play Console | Part 1 Steps 3 and 5 — click Activate |
| RC auto-generated identifier shows plain `lv_premium_monthly` | Base plan Id field was left empty when creating the product | Edit the product in RC and add `monthly-base` to Base plan Id |
| `is_premium` in Supabase is stale after subscription change | No RC webhook configured | Part 8 Step 3 — deploy Edge Function and configure RC webhook |

### Pre-Release Checklist

Use this as the final gate before any production release that includes subscription changes.

**RevenueCat — Current Status:**
- [x] LinkVault (Android) app entry exists in Apps & Providers
- [x] Shared Test Store used for both Curate Dev and LV Dev (one Test Store per project — this is correct)
- [x] Production products in **LinkVault (Android) tab**: `lv_premium_monthly:monthly-base` and `lv_premium_annual:annual-base`
- [x] Test Store products in **Test Store tab** (LV section): `lv_premium_monthly` and `lv_premium_annual`
- [x] All 4 LV products attached to the `premium` entitlement
- [x] `$rc_annual` package: LV (Android) → `lv_premium_annual:annual-base`, Test Store (LV) → `lv_premium_annual`
- [x] `$rc_monthly` package: LV (Android) → `lv_premium_monthly:monthly-base`, Test Store (LV) → `lv_premium_monthly`
- [x] Sandbox Testing Access → **Anybody**
- [ ] **RC webhook configured** (Part 8, Step 3) — not yet done

**Google Play Console:**
- [x] `lv_premium_monthly` subscription exists and `monthly-base` plan is **Active**
- [x] `lv_premium_annual` subscription exists and `annual-base` plan is **Active**
- [x] Grace period enabled (3 days monthly, 7 days annual)
- [x] Account hold enabled for both
- [ ] License tester Gmail configured under Setup → License Testing

**Flutter / Env Files:**
- [x] `.env.dev` `REVENUE_CAT_ANDROID_KEY` = `test_axvoWchnyWRCRhgmabmqoTqyxtH` (shared Test Store — correct, no change needed)
- [ ] **`.env.production` `REVENUE_CAT_ANDROID_KEY` = LinkVault's own `goog_` key** — ⚠️ still uses Curate's key
- [ ] `.env.production` `REVENUE_CAT_IOS_KEY` = `appl_...` (requires iOS app entry in RC first)
- [x] `purchase()` uses `CustomerInfo` from return value directly (confirmed in code audit)
- [x] `restorePurchases()` uses `CustomerInfo` from return value directly (confirmed in code audit)

**Supabase:**
- [x] `lv_user_profiles` has `is_premium` and `premium_expires_at` columns (migration `003`)
- [x] `lv_profile_premium_active()` server-side quota function exists (migration `010`)
- [x] RLS enabled on all `lv_*` tables
- [ ] RC → Supabase webhook Edge Function deployed (Part 8, Step 3)

**Testing:**
- [ ] Phase 1 (Test Store): all 8 scenarios in the matrix pass
- [ ] Phase 2 (Play license tester): full production flow passes with LV's own `goog_` key
- [ ] Phase 3 (cross-app smoke test): shared entitlement confirmed in both directions
