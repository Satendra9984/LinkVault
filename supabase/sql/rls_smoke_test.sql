-- rls_smoke_test.sql
--
-- Template SQL to smoke-test RLS on LinkVault `lv_*` tables.
--
-- Preconditions:
-- 1) Run migrations 001..010 in the dev Supabase project.
-- 2) Pick two real user UUIDs from auth.users:
--      - UUID_A
--      - UUID_B
-- 3) Create at least one collection owned by UUID_A, and at least one URL
--    in a collection owned by UUID_A.
--
-- Notes on auth.uid() simulation:
-- Supabase derives `auth.uid()` from JWT claims. In SQL, you can often set
-- JWT claim context using `set_config(...)` for the current session.
-- The exact claim keys can vary by Supabase versions/config.
-- If `auth.uid()` returns NULL, try the alternate claim key noted below.

-- ─────────────────────────────────────────────────────────────────────────────
-- Setup: choose UUIDs
-- Replace these placeholders:
--   '00000000-0000-0000-0000-000000000001' (UUID_A)
--   '00000000-0000-0000-0000-000000000002' (UUID_B)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Helper block: simulate a JWT "sub" claim ────────────────────────────────
-- Preferred (common):
--   request.jwt.claim.sub is used by auth.uid() in many setups.
-- Alternative (sometimes needed):
--   request.jwt.claims as a JSON string.

-- ── User A can read their own collections/urls ─────────────────────────────
SELECT
  set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);

-- Expect: only UUID_A-owned collections.
SELECT id, owner_id, title
FROM public.lv_collections
WHERE is_deleted = FALSE
ORDER BY created_at DESC;

-- Expect: only UUID_A-owned urls.
SELECT u.id, u.owner_id, u.collection_id, u.url
FROM public.lv_urls u
JOIN public.lv_collections c ON c.id = u.collection_id
WHERE u.is_deleted = FALSE
ORDER BY u.updated_at DESC;

-- ── User B cannot read UUID_A-owned rows ──────────────────────────────────
SELECT
  set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000002', true);

-- Expect: 0 rows (because RLS requires owner_id = auth.uid()).
SELECT id, owner_id, title
FROM public.lv_collections
WHERE is_deleted = FALSE
ORDER BY created_at DESC;

-- Expect: 0 rows.
SELECT u.id, u.owner_id, u.collection_id, u.url
FROM public.lv_urls u
JOIN public.lv_collections c ON c.id = u.collection_id
WHERE u.is_deleted = FALSE
ORDER BY u.updated_at DESC;

-- ── URL move safety: user cannot move URL to another owner's collection ─────
-- Setup assumptions:
-- - URL_A belongs to UUID_A inside COLLECTION_A_OWNED_BY_A
-- - COLLECTION_B_OWNED_BY_B belongs to UUID_B
SELECT
  set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);

-- Expect: 0 rows updated due to lv_urls_update_own WITH CHECK ownership guard.
UPDATE public.lv_urls
SET collection_id = '00000000-0000-0000-0000-000000000202'
WHERE id = '00000000-0000-0000-0000-000000000101';

-- ── Parent move safety: user cannot set parent to another owner's collection ─
-- Setup assumptions:
-- - COLLECTION_A_CHILD belongs to UUID_A
-- - COLLECTION_B_PARENT belongs to UUID_B
SELECT
  set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-000000000001', true);

-- Expect: 0 rows updated by lv_collections_update_own + owner isolation.
UPDATE public.lv_collections
SET parent_id = '00000000-0000-0000-0000-000000000204'
WHERE id = '00000000-0000-0000-0000-000000000203';

-- ── If auth.uid() is NULL for the above, try this alternate simulation ────
-- SELECT set_config(
--   'request.jwt.claims',
--   '{"sub":"00000000-0000-0000-0000-000000000001","role":"authenticated"}',
--   true
-- );

