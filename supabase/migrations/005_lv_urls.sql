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
  status TEXT NOT NULL DEFAULT 'unread'
    CHECK (status IN ('unread', 'read', 'archived')),
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
    to_tsvector(
      'english',
      coalesce(title,'') || ' ' ||
      coalesce(description,'') || ' ' ||
      coalesce(tags,'') || ' ' ||
      url
    )
  );

ALTER TABLE public.lv_urls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "lv_urls_select_own"
  ON public.lv_urls FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "lv_urls_insert_own"
  ON public.lv_urls FOR INSERT
  WITH CHECK (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1
      FROM public.lv_collections c
      WHERE c.id = lv_urls.collection_id
        AND c.owner_id = auth.uid()
    )
  );

CREATE POLICY "lv_urls_update_own"
  ON public.lv_urls FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "lv_urls_delete_own"
  ON public.lv_urls FOR DELETE USING (auth.uid() = owner_id);

