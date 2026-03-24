# LinkVault Supabase Schema and Migrations

Version: 1.0  
Last Updated: 2026-03-23  
Status: Active  
Owner: Engineering  
Depends On: `docs/03_ARCHITECTURE/Technical_Architecture.md`, `docs/03_ARCHITECTURE/Developer_Bible.md`

---

## Purpose

Define the production schema, migration order, row-level security model, indexing strategy, and validation requirements for LinkVault cloud data using `lv_*` tables.

---

## Scope

In scope:

- `lv_user_profiles`
- `lv_collections`
- `lv_urls`
- storage bucket for URL thumbnails
- functions/triggers needed for consistency

Out of scope:

- Curate unprefixed tables (`collections`, `items`, etc.)
- social graph features
- analytics warehouse tables

---

## Architectural Constraints

1. LinkVault and Curate share one Supabase project.
2. LinkVault must use prefixed table names (`lv_*`) to avoid cross-app collisions.
3. Every table must be RLS-protected before app release.
4. Schema must support local-to-cloud migration and soft-delete sync semantics.

---

## Canonical Tables

### `lv_user_profiles`

Purpose:

- profile preferences and sync metadata
- premium state mirror (non-authoritative compared to RevenueCat entitlement)

Key columns:

- `id` UUID PK references `auth.users(id)`
- `display_name`, `avatar_url`
- `is_premium`, `premium_expires_at`
- `last_synced_at`
- `created_at`, `updated_at`

### `lv_collections`

Purpose:

- nested link containers

Key columns:

- `id` UUID PK
- `owner_id` UUID FK to `auth.users`
- `parent_id` self-reference for nesting
- display/config: `title`, `icon_name`, `color_hex`, `category`
- ordering/filtering: `is_pinned`, `is_archived`, `position`
- counters: `url_count`, `child_count`
- sync fields: `is_deleted`, `deleted_at`, `created_at`, `updated_at`

### `lv_urls`

Purpose:

- URL records with metadata, state, and usage fields

Key columns:

- `id` UUID PK
- `owner_id` UUID FK to `auth.users`
- `collection_id` UUID FK to `lv_collections`
- URL + metadata: `url`, `title`, `description`, `thumbnail_url`, `favicon_url`, `dominant_color`
- user metadata: `tags`, `annotation`
- state/order: `status`, `is_pinned`, `position`
- behavior: `click_count`, `last_accessed_at`
- sync fields: `is_deleted`, `deleted_at`, `created_at`, `updated_at`

---

## Migration Order (Mandatory)

Apply in this sequence:

1. Extensions (`pgcrypto`, optionally `uuid-ossp` if needed by tooling)
2. shared utility function `handle_updated_at()`
3. `lv_user_profiles` table + trigger for profile creation
4. `lv_collections` table + indexes + RLS policies
5. `lv_urls` table + indexes + RLS policies
6. trigger/function pack for counter maintenance (`url_count`, `child_count`)
7. search RPC (optional but recommended) and performance helpers
8. storage bucket `lv-thumbnails` + storage policies
9. realtime publication additions (if realtime is enabled for needed tables)

---

## SQL Migration Pack (Reference)

```sql
-- 001_extensions.sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 002_utility_functions.sql
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 003_lv_user_profiles.sql
CREATE TABLE IF NOT EXISTS public.lv_user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  premium_expires_at TIMESTAMPTZ,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE public.lv_user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "lv_profile_select_own"
  ON public.lv_user_profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "lv_profile_update_own"
  ON public.lv_user_profiles FOR UPDATE USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.lv_handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.lv_user_profiles (id, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)))
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_lv_auth_user_created ON auth.users;
CREATE TRIGGER on_lv_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.lv_handle_new_user();
```

```sql
-- 004_lv_collections.sql
CREATE TABLE IF NOT EXISTS public.lv_collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES public.lv_collections(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  icon_name TEXT NOT NULL DEFAULT 'folder',
  color_hex TEXT NOT NULL DEFAULT '#6366F1',
  category TEXT NOT NULL DEFAULT 'general',
  is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  position FLOAT8 NOT NULL DEFAULT 0,
  url_count INT NOT NULL DEFAULT 0,
  child_count INT NOT NULL DEFAULT 0,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lv_collections_owner_parent
ON public.lv_collections(owner_id, parent_id, is_deleted, is_archived);
CREATE INDEX IF NOT EXISTS idx_lv_collections_owner_updated
ON public.lv_collections(owner_id, updated_at DESC);

ALTER TABLE public.lv_collections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lv_collections_select_own"
  ON public.lv_collections FOR SELECT USING (auth.uid() = owner_id);
CREATE POLICY "lv_collections_insert_own"
  ON public.lv_collections FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "lv_collections_update_own"
  ON public.lv_collections FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "lv_collections_delete_own"
  ON public.lv_collections FOR DELETE USING (auth.uid() = owner_id);
```

```sql
-- 005_lv_urls.sql
CREATE TABLE IF NOT EXISTS public.lv_urls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  collection_id UUID NOT NULL REFERENCES public.lv_collections(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  thumbnail_url TEXT,
  favicon_url TEXT,
  dominant_color TEXT,
  tags TEXT,
  annotation TEXT,
  status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'read', 'archived')),
  is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
  click_count INT NOT NULL DEFAULT 0,
  position FLOAT8 NOT NULL DEFAULT 0,
  is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  last_accessed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lv_urls_collection_pos
ON public.lv_urls(collection_id, is_deleted, is_pinned DESC, position);
CREATE INDEX IF NOT EXISTS idx_lv_urls_owner_updated
ON public.lv_urls(owner_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_lv_urls_search
ON public.lv_urls USING GIN (
  to_tsvector('english', coalesce(title,'') || ' ' || coalesce(description,'') || ' ' || coalesce(tags,'') || ' ' || url)
);

ALTER TABLE public.lv_urls ENABLE ROW LEVEL SECURITY;
CREATE POLICY "lv_urls_select_own"
  ON public.lv_urls FOR SELECT USING (auth.uid() = owner_id);
CREATE POLICY "lv_urls_insert_own"
  ON public.lv_urls FOR INSERT
  WITH CHECK (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1 FROM public.lv_collections c
      WHERE c.id = lv_urls.collection_id AND c.owner_id = auth.uid()
    )
  );
CREATE POLICY "lv_urls_update_own"
  ON public.lv_urls FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "lv_urls_delete_own"
  ON public.lv_urls FOR DELETE USING (auth.uid() = owner_id);
```

```sql
-- 006_triggers.sql
CREATE OR REPLACE FUNCTION public.lv_update_collection_url_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE) THEN
    UPDATE public.lv_collections
    SET url_count = GREATEST(url_count - 1, 0), updated_at = NOW()
    WHERE id = COALESCE(OLD.collection_id, NEW.collection_id);
  ELSIF TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND NEW.is_deleted = FALSE AND OLD.is_deleted = TRUE) THEN
    UPDATE public.lv_collections
    SET url_count = url_count + 1, updated_at = NOW()
    WHERE id = NEW.collection_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS lv_urls_count_trigger ON public.lv_urls;
CREATE TRIGGER lv_urls_count_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.lv_urls
FOR EACH ROW EXECUTE FUNCTION public.lv_update_collection_url_count();

DROP TRIGGER IF EXISTS lv_collections_updated_at ON public.lv_collections;
CREATE TRIGGER lv_collections_updated_at
BEFORE UPDATE ON public.lv_collections
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS lv_urls_updated_at ON public.lv_urls;
CREATE TRIGGER lv_urls_updated_at
BEFORE UPDATE ON public.lv_urls
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

---

## RLS Validation Checklist

Run after migrations:

1. Authenticated user A can only read/update/delete own rows.
2. Authenticated user B cannot access user A rows.
3. Insert on `lv_urls` fails if `collection_id` belongs to another user.
4. Anonymous session has no table access unless explicitly intended.
5. Storage upload path is scoped to user folder.

---

## Storage Policy (`lv-thumbnails`)

Recommended:

- public read allowed for thumbnail URLs
- write/delete only for authenticated owner under `lv-thumbnails/{userId}/...`
- enforce folder ownership using `storage.foldername(name)`

---

## Backward-Compatible Change Policy

- Additive changes only in minor migrations (new nullable columns, indexes, functions).
- Destructive changes require:
  - ADR approval
  - backfill script
  - rollback script
  - staged rollout verification

---

## Operational Queries

### Root collections

```sql
SELECT * FROM public.lv_collections
WHERE owner_id = auth.uid()
  AND parent_id IS NULL
  AND is_deleted = FALSE
  AND is_archived = FALSE
ORDER BY is_pinned DESC, position ASC;
```

### URLs in a collection

```sql
SELECT * FROM public.lv_urls
WHERE owner_id = auth.uid()
  AND collection_id = $1
  AND is_deleted = FALSE
ORDER BY is_pinned DESC, position ASC;
```

### Delta sync candidate rows

```sql
SELECT * FROM public.lv_urls
WHERE owner_id = auth.uid()
  AND updated_at > $1
ORDER BY updated_at ASC;
```

---

## Revision History

| Version | Date | Notes |
|---|---|---|
| 1.0 | 2026-03-23 | New canonical schema/migration specification for LinkVault `lv_*` model. |
