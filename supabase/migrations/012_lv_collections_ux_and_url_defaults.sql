-- 012_lv_collections_ux_and_url_defaults.sql
-- Optional UX + URL-list defaults on collections (see docs for semantics).

ALTER TABLE public.lv_collections
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS last_accessed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS items_layout TEXT NOT NULL DEFAULT 'list',
  ADD COLUMN IF NOT EXISTS items_sort_default TEXT NOT NULL DEFAULT 'manual',
  ADD COLUMN IF NOT EXISTS icon_json JSONB,
  ADD COLUMN IF NOT EXISTS open_links_in TEXT NOT NULL DEFAULT 'in_app',
  ADD COLUMN IF NOT EXISTS show_link_previews BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE public.lv_collections
  DROP CONSTRAINT IF EXISTS lv_collections_items_layout_check;
ALTER TABLE public.lv_collections
  ADD CONSTRAINT lv_collections_items_layout_check
  CHECK (items_layout IN ('list', 'grid'));

ALTER TABLE public.lv_collections
  DROP CONSTRAINT IF EXISTS lv_collections_items_sort_default_check;
ALTER TABLE public.lv_collections
  ADD CONSTRAINT lv_collections_items_sort_default_check
  CHECK (items_sort_default IN (
    'manual',
    'added_desc',
    'title_asc',
    'last_opened_desc'
  ));

ALTER TABLE public.lv_collections
  DROP CONSTRAINT IF EXISTS lv_collections_open_links_in_check;
ALTER TABLE public.lv_collections
  ADD CONSTRAINT lv_collections_open_links_in_check
  CHECK (open_links_in IN ('in_app', 'external_browser'));

COMMENT ON COLUMN public.lv_collections.description IS 'Optional user-facing notes; search/subtitle.';
COMMENT ON COLUMN public.lv_collections.last_accessed_at IS 'Updated when user opens collection or a URL inside (app-defined).';
COMMENT ON COLUMN public.lv_collections.items_layout IS 'Default link list layout: list | grid.';
COMMENT ON COLUMN public.lv_collections.items_sort_default IS 'Default URL sort: manual | added_desc | title_asc | last_opened_desc.';
COMMENT ON COLUMN public.lv_collections.icon_json IS 'Optional rich icon {type,value,color}; when null use icon_name + color_hex.';
COMMENT ON COLUMN public.lv_collections.open_links_in IS 'Default open behavior for links in this collection.';
COMMENT ON COLUMN public.lv_collections.show_link_previews IS 'Whether to show thumbnails/previews for URLs in this collection.';
