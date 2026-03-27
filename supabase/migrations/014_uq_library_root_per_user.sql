-- 014_uq_library_root_per_user.sql
-- Enforce one non-deleted root collection per user.
CREATE UNIQUE INDEX IF NOT EXISTS uq_lv_collections_one_root_per_user
  ON public.lv_collections (owner_id)
  WHERE parent_id IS NULL AND is_deleted = false;
