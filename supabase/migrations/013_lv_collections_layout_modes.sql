-- 013_lv_collections_layout_modes.sql
-- compact_grid for denser URL grids; separate layout for nested folders vs links.

ALTER TABLE public.lv_collections
  ADD COLUMN IF NOT EXISTS child_collections_layout TEXT NOT NULL DEFAULT 'list';

ALTER TABLE public.lv_collections
  DROP CONSTRAINT IF EXISTS lv_collections_items_layout_check;
ALTER TABLE public.lv_collections
  ADD CONSTRAINT lv_collections_items_layout_check
  CHECK (items_layout IN ('list', 'grid', 'compact_grid'));

ALTER TABLE public.lv_collections
  DROP CONSTRAINT IF EXISTS lv_collections_child_collections_layout_check;
ALTER TABLE public.lv_collections
  ADD CONSTRAINT lv_collections_child_collections_layout_check
  CHECK (child_collections_layout IN ('list', 'grid', 'compact_grid'));

COMMENT ON COLUMN public.lv_collections.items_layout IS
  'Layout for saved links: list | grid | compact_grid.';
COMMENT ON COLUMN public.lv_collections.child_collections_layout IS
  'Layout for nested folder tiles: list | grid | compact_grid.';
