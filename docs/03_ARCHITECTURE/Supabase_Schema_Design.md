# LinkVault — Supabase Schema Design

**Version:** 1.0  
**Last Updated:** March 20, 2026  
**Database:** PostgreSQL (Supabase)  
**Naming convention:** All LinkVault tables prefixed with `lv_` to coexist in the shared Supabase project (with Curate's tables)

---

## Overview

This schema supports the **premium tier** of LinkVault with:
- User profiles
- Nested collections (unlimited depth via `parent_id`)
- URLs with rich metadata
- Cloud sync for premium users

All tables use **Row Level Security (RLS)** so users can only access their own data.

---

## Schema Diagram

```
auth.users  (Supabase managed)
    │
    ├──> lv_user_profiles
    │
    └──> lv_collections
              │
              ├──> lv_collections (self-referential: parent_id)
              │
              └──> lv_urls
```

---

## Tables

### 1. lv_user_profiles

Extends Supabase `auth.users` with app-specific fields.

```sql
CREATE TABLE public.lv_user_profiles (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username        TEXT UNIQUE,
  display_name    TEXT,
  avatar_url      TEXT,
  -- Subscription / tier
  is_premium      BOOLEAN NOT NULL DEFAULT FALSE,
  premium_expires_at TIMESTAMPTZ,
  -- Preferences
  theme_mode      TEXT NOT NULL DEFAULT 'system' CHECK (theme_mode IN ('light', 'dark', 'system')),
  -- Sync metadata
  last_synced_at  TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_lv_user_profiles_username ON public.lv_user_profiles(username);

-- RLS
ALTER TABLE public.lv_user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.lv_user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.lv_user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.lv_handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.lv_user_profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_lv_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.lv_handle_new_user();
```

---

### 2. lv_collections

Supports **unlimited nesting** via the self-referential `parent_id`.

```sql
CREATE TABLE public.lv_collections (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Nesting support (null = root collection)
  parent_id       UUID REFERENCES public.lv_collections(id) ON DELETE CASCADE,
  
  -- Display
  title           TEXT NOT NULL,
  icon_name       TEXT NOT NULL DEFAULT 'folder',
  color_hex       TEXT NOT NULL DEFAULT '#6366F1',
  category        TEXT NOT NULL DEFAULT 'general',
  
  -- Organization
  is_pinned       BOOLEAN NOT NULL DEFAULT FALSE,
  is_archived     BOOLEAN NOT NULL DEFAULT FALSE,
  position        FLOAT8 NOT NULL DEFAULT 0,    -- fractional index for ordering
  
  -- Layout preferences
  layout_type     TEXT NOT NULL DEFAULT 'list' CHECK (layout_type IN ('list', 'grid')),
  sort_order      TEXT NOT NULL DEFAULT 'manual'
                    CHECK (sort_order IN ('manual', 'date_added', 'date_modified', 'most_visited', 'alphabetical')),
  
  -- Denormalized counters (maintained by triggers)
  url_count       INT NOT NULL DEFAULT 0,
  child_count     INT NOT NULL DEFAULT 0,       -- number of sub-collections
  
  -- Soft delete for sync
  is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at      TIMESTAMPTZ,
  
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_lv_collections_owner_parent
  ON public.lv_collections(owner_id, parent_id, is_deleted, is_archived);
CREATE INDEX idx_lv_collections_owner_updated
  ON public.lv_collections(owner_id, updated_at DESC);
CREATE INDEX idx_lv_collections_parent
  ON public.lv_collections(parent_id)
  WHERE parent_id IS NOT NULL;

-- RLS
ALTER TABLE public.lv_collections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own collections"
  ON public.lv_collections FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own collections"
  ON public.lv_collections FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own collections"
  ON public.lv_collections FOR UPDATE
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete own collections"
  ON public.lv_collections FOR DELETE
  USING (auth.uid() = owner_id);

-- Trigger: update parent's child_count when a sub-collection is added/deleted
CREATE OR REPLACE FUNCTION public.lv_update_parent_child_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.parent_id IS NOT NULL THEN
    UPDATE public.lv_collections
    SET child_count = child_count + 1, updated_at = NOW()
    WHERE id = NEW.parent_id;
  ELSIF TG_OP = 'DELETE' AND OLD.parent_id IS NOT NULL THEN
    UPDATE public.lv_collections
    SET child_count = GREATEST(child_count - 1, 0), updated_at = NOW()
    WHERE id = OLD.parent_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_lv_collection_inserted
  AFTER INSERT ON public.lv_collections
  FOR EACH ROW EXECUTE FUNCTION public.lv_update_parent_child_count();

CREATE TRIGGER on_lv_collection_deleted
  AFTER DELETE ON public.lv_collections
  FOR EACH ROW EXECUTE FUNCTION public.lv_update_parent_child_count();

-- Trigger: auto-update updated_at
CREATE TRIGGER lv_collections_updated_at
  BEFORE UPDATE ON public.lv_collections
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

---

### 3. lv_urls

URL entries — the core data in LinkVault.

```sql
CREATE TABLE public.lv_urls (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  collection_id   UUID NOT NULL REFERENCES public.lv_collections(id) ON DELETE CASCADE,
  
  -- Core URL
  url             TEXT NOT NULL,
  
  -- Auto-fetched metadata
  title           TEXT,
  description     TEXT,
  thumbnail_url   TEXT,
  favicon_url     TEXT,
  dominant_color  TEXT,         -- hex color extracted from thumbnail, e.g. "#4A90E2"
  
  -- User-defined metadata
  tags            TEXT,         -- comma-separated: "flutter,dart,riverpod"
  annotation      TEXT,         -- personal notes / highlights
  
  -- Status & organization
  status          TEXT NOT NULL DEFAULT 'unread'
                    CHECK (status IN ('unread', 'read', 'archived')),
  is_pinned       BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- Analytics
  click_count     INT NOT NULL DEFAULT 0,
  position        FLOAT8 NOT NULL DEFAULT 0,    -- fractional index for ordering
  
  -- Soft delete for sync
  is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at      TIMESTAMPTZ,
  
  last_accessed_at TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_lv_urls_collection_pos
  ON public.lv_urls(collection_id, is_deleted, is_pinned DESC, position);
CREATE INDEX idx_lv_urls_owner_updated
  ON public.lv_urls(owner_id, updated_at DESC);
CREATE INDEX idx_lv_urls_status
  ON public.lv_urls(owner_id, status)
  WHERE is_deleted = FALSE;
-- Full-text search index
CREATE INDEX idx_lv_urls_search
  ON public.lv_urls USING GIN (
    to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(tags, '') || ' ' || url)
  );

-- RLS
ALTER TABLE public.lv_urls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own URLs"
  ON public.lv_urls FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own URLs"
  ON public.lv_urls FOR INSERT
  WITH CHECK (
    auth.uid() = owner_id AND
    EXISTS (
      SELECT 1 FROM public.lv_collections c
      WHERE c.id = lv_urls.collection_id AND c.owner_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own URLs"
  ON public.lv_urls FOR UPDATE
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete own URLs"
  ON public.lv_urls FOR DELETE
  USING (auth.uid() = owner_id);

-- Trigger: maintain url_count on lv_collections
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

CREATE TRIGGER on_lv_url_count_change
  AFTER INSERT OR UPDATE OR DELETE ON public.lv_urls
  FOR EACH ROW EXECUTE FUNCTION public.lv_update_collection_url_count();

CREATE TRIGGER lv_urls_updated_at
  BEFORE UPDATE ON public.lv_urls
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
```

---

## Shared Utility Functions

```sql
-- Reusable updated_at trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Delete LinkVault user data (called on account deletion RPC)
CREATE OR REPLACE FUNCTION public.lv_delete_user_data(user_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM public.lv_urls WHERE owner_id = user_id;
  DELETE FROM public.lv_collections WHERE owner_id = user_id;
  DELETE FROM public.lv_user_profiles WHERE id = user_id;
  DELETE FROM auth.users WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Storage Buckets

### lv-thumbnails

Stores cached URL thumbnails uploaded by premium users.

```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('lv-thumbnails', 'lv-thumbnails', true);

-- Users can upload to their own folder
CREATE POLICY "Users can upload own thumbnails"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'lv-thumbnails' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Anyone can view thumbnails"
ON storage.objects FOR SELECT
USING (bucket_id = 'lv-thumbnails');

CREATE POLICY "Users can delete own thumbnails"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'lv-thumbnails' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

**Folder structure:** `lv-thumbnails/{user_id}/{url_id}.jpg`

---

## Realtime Subscriptions

Enable realtime for cloud sync status updates:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE public.lv_collections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.lv_urls;
```

**Flutter client usage:**
```dart
// Watch for collection changes in real-time (premium users)
final subscription = supabase
    .from('lv_collections')
    .stream(primaryKey: ['id'])
    .eq('owner_id', currentUserId)
    .listen((List<Map<String, dynamic>> data) {
      // Merge into local ObjectBox store
    });
```

---

## Full-Text Search

### Server-side (Supabase RPC)

```sql
-- Search URLs across all collections
CREATE OR REPLACE FUNCTION public.lv_search_urls(
  p_owner_id UUID,
  p_query TEXT,
  p_limit INT DEFAULT 50
)
RETURNS SETOF public.lv_urls AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.lv_urls
  WHERE owner_id = p_owner_id
    AND is_deleted = FALSE
    AND to_tsvector('english',
          coalesce(title, '') || ' ' ||
          coalesce(description, '') || ' ' ||
          coalesce(tags, '') || ' ' ||
          url
        ) @@ plainto_tsquery('english', p_query)
  ORDER BY
    ts_rank(
      to_tsvector('english', coalesce(title, '') || ' ' || coalesce(tags, '')),
      plainto_tsquery('english', p_query)
    ) DESC,
    click_count DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

---

## Sync Strategy (Local → Cloud)

### On Premium Activation (First Sync)

```sql
-- Flutter calls this after uploading all local data
UPDATE public.lv_user_profiles
SET last_synced_at = NOW()
WHERE id = auth.uid();
```

### Delta Sync (Subsequent Syncs)

```dart
// Pull changes since last_synced_at
final changes = await supabase
    .from('lv_collections')
    .select()
    .eq('owner_id', userId)
    .gt('updated_at', lastSyncedAt.toIso8601String());

// Push local changes
await supabase.from('lv_collections').upsert(localNewOrUpdated);
```

### Conflict Resolution

- Strategy: **Last-write-wins** based on `updated_at`
- If `remote.updated_at > local.updated_at` → use remote
- If `local.updated_at > remote.updated_at` → push local to remote

---

## Sample Queries

### Get Root Collections (Ordered)

```sql
SELECT * FROM public.lv_collections
WHERE owner_id = auth.uid()
  AND parent_id IS NULL
  AND is_deleted = FALSE
  AND is_archived = FALSE
ORDER BY is_pinned DESC, position ASC;
```

### Get Child Collections

```sql
SELECT * FROM public.lv_collections
WHERE owner_id = auth.uid()
  AND parent_id = '<parent_id>'
  AND is_deleted = FALSE
ORDER BY is_pinned DESC, position ASC;
```

### Get URLs in Collection (Mixed Pinned + Normal)

```sql
SELECT * FROM public.lv_urls
WHERE owner_id = auth.uid()
  AND collection_id = '<collection_id>'
  AND is_deleted = FALSE
  AND status != 'archived'
ORDER BY is_pinned DESC, position ASC;
```

### Get Full Breadcrumb Path for a Collection

```sql
-- Recursive CTE for breadcrumb
WITH RECURSIVE breadcrumb AS (
  SELECT id, parent_id, title, 0 AS depth
  FROM public.lv_collections
  WHERE id = '<leaf_collection_id>'
  
  UNION ALL
  
  SELECT c.id, c.parent_id, c.title, b.depth + 1
  FROM public.lv_collections c
  INNER JOIN breadcrumb b ON c.id = b.parent_id
)
SELECT * FROM breadcrumb ORDER BY depth DESC;
```

### Most Visited URLs (Last 30 Days)

```sql
SELECT * FROM public.lv_urls
WHERE owner_id = auth.uid()
  AND is_deleted = FALSE
  AND last_accessed_at > NOW() - INTERVAL '30 days'
ORDER BY click_count DESC
LIMIT 10;
```

---

## Performance Considerations

1. **`parent_id` Self-Join** — The `idx_lv_collections_parent` partial index ensures sub-collection queries are fast even at scale
2. **Fractional Position** — `FLOAT8 position` avoids mass re-numbering on reorder; use midpoint algorithm
3. **`url_count` Denormalization** — Trigger-maintained counter; avoids COUNT(*) on display
4. **Full-text GIN Index** — Fast full-text search on `lv_urls` without external search service
5. **`updated_at` Index** — Delta sync uses `updated_at > last_synced_at`; this index makes it O(changes) not O(all)
6. **Soft Delete** — `is_deleted` flag allows sync diffing; hard purge via scheduled job after 30 days

---

## Multi-App Coexistence with Curate

> Both LinkVault and Curate share the same Supabase project. All LinkVault tables are prefixed `lv_`. Curate tables use no prefix (existing tables: `collections`, `items`, `user_profiles`, etc.).

**Same auth.users table** — A user with the same email is one Supabase `auth` user. If they sign in to both apps, they share the same `auth.uid()`. This enables future cross-app features (e.g., "import your Curate links into LinkVault").

**RevenueCat Entitlement Sharing** — Both apps can check the same RevenueCat entitlement `premium` using the same `auth.uid()` as the RC App User ID. A subscription purchased in one app will be recognized in the other.

---

## Schema Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | March 20, 2026 | Initial schema — lv_ prefixed tables, nested collections, URL metadata, full-text search |
