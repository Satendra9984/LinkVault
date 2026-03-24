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
  ON public.lv_collections FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "lv_collections_update_own"
  ON public.lv_collections FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "lv_collections_delete_own"
  ON public.lv_collections FOR DELETE USING (auth.uid() = owner_id);

