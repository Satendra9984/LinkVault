-- 009_sprint56_collections_rls_and_counts_hardening.sql
-- Sprint 5-6 hardening:
-- 1) URL count correctness on collection moves + soft delete transitions.
-- 2) Child count maintenance for nested collections.
-- 3) RLS update policy safety for lv_urls destination collection ownership.

CREATE OR REPLACE FUNCTION public.lv_update_collection_url_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.is_deleted = FALSE THEN
      UPDATE public.lv_collections
      SET
        url_count = url_count + 1,
        updated_at = NOW()
      WHERE id = NEW.collection_id;
    END IF;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.is_deleted = FALSE THEN
      UPDATE public.lv_collections
      SET
        url_count = GREATEST(url_count - 1, 0),
        updated_at = NOW()
      WHERE id = OLD.collection_id;
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    -- Move between collections (active URL).
    IF OLD.collection_id IS DISTINCT FROM NEW.collection_id
       AND OLD.is_deleted = FALSE
       AND NEW.is_deleted = FALSE THEN
      UPDATE public.lv_collections
      SET
        url_count = GREATEST(url_count - 1, 0),
        updated_at = NOW()
      WHERE id = OLD.collection_id;

      UPDATE public.lv_collections
      SET
        url_count = url_count + 1,
        updated_at = NOW()
      WHERE id = NEW.collection_id;
    END IF;

    -- Soft delete transition.
    IF OLD.is_deleted = FALSE AND NEW.is_deleted = TRUE THEN
      UPDATE public.lv_collections
      SET
        url_count = GREATEST(url_count - 1, 0),
        updated_at = NOW()
      WHERE id = NEW.collection_id;
    END IF;

    -- Restore transition.
    IF OLD.is_deleted = TRUE AND NEW.is_deleted = FALSE THEN
      UPDATE public.lv_collections
      SET
        url_count = url_count + 1,
        updated_at = NOW()
      WHERE id = NEW.collection_id;
    END IF;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.lv_update_parent_child_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.parent_id IS NOT NULL AND NEW.is_deleted = FALSE THEN
      UPDATE public.lv_collections
      SET
        child_count = child_count + 1,
        updated_at = NOW()
      WHERE id = NEW.parent_id;
    END IF;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.parent_id IS NOT NULL AND OLD.is_deleted = FALSE THEN
      UPDATE public.lv_collections
      SET
        child_count = GREATEST(child_count - 1, 0),
        updated_at = NOW()
      WHERE id = OLD.parent_id;
    END IF;

  ELSIF TG_OP = 'UPDATE' THEN
    -- Move between parents while active.
    IF OLD.parent_id IS DISTINCT FROM NEW.parent_id
       AND OLD.is_deleted = FALSE
       AND NEW.is_deleted = FALSE THEN
      IF OLD.parent_id IS NOT NULL THEN
        UPDATE public.lv_collections
        SET
          child_count = GREATEST(child_count - 1, 0),
          updated_at = NOW()
        WHERE id = OLD.parent_id;
      END IF;

      IF NEW.parent_id IS NOT NULL THEN
        UPDATE public.lv_collections
        SET
          child_count = child_count + 1,
          updated_at = NOW()
        WHERE id = NEW.parent_id;
      END IF;
    END IF;

    -- Soft delete transition.
    IF OLD.is_deleted = FALSE
       AND NEW.is_deleted = TRUE
       AND NEW.parent_id IS NOT NULL THEN
      UPDATE public.lv_collections
      SET
        child_count = GREATEST(child_count - 1, 0),
        updated_at = NOW()
      WHERE id = NEW.parent_id;
    END IF;

    -- Restore transition.
    IF OLD.is_deleted = TRUE
       AND NEW.is_deleted = FALSE
       AND NEW.parent_id IS NOT NULL THEN
      UPDATE public.lv_collections
      SET
        child_count = child_count + 1,
        updated_at = NOW()
      WHERE id = NEW.parent_id;
    END IF;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS lv_urls_count_trigger ON public.lv_urls;
CREATE TRIGGER lv_urls_count_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.lv_urls
  FOR EACH ROW EXECUTE FUNCTION public.lv_update_collection_url_count();

DROP TRIGGER IF EXISTS lv_collections_child_count_trigger ON public.lv_collections;
CREATE TRIGGER lv_collections_child_count_trigger
  AFTER INSERT OR UPDATE OR DELETE ON public.lv_collections
  FOR EACH ROW EXECUTE FUNCTION public.lv_update_parent_child_count();

DROP POLICY IF EXISTS "lv_urls_update_own" ON public.lv_urls;
CREATE POLICY "lv_urls_update_own"
  ON public.lv_urls FOR UPDATE
  USING (auth.uid() = owner_id)
  WITH CHECK (
    auth.uid() = owner_id
    AND EXISTS (
      SELECT 1
      FROM public.lv_collections c
      WHERE c.id = lv_urls.collection_id
        AND c.owner_id = auth.uid()
    )
  );
