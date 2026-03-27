-- 016_owner_consistency_constraints.sql
-- Enforce owner consistency between parent/child collections and URLs/collections.

CREATE OR REPLACE FUNCTION public.enforce_lv_collections_owner_consistency()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_parent_owner UUID;
BEGIN
  IF NEW.parent_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT c.owner_id
  INTO v_parent_owner
  FROM public.lv_collections c
  WHERE c.id = NEW.parent_id;

  IF v_parent_owner IS NULL THEN
    RAISE EXCEPTION 'parent collection not found: %', NEW.parent_id;
  END IF;

  IF v_parent_owner IS DISTINCT FROM NEW.owner_id THEN
    RAISE EXCEPTION 'parent owner mismatch for collection %', NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS lv_collections_owner_consistency_trg ON public.lv_collections;
CREATE TRIGGER lv_collections_owner_consistency_trg
  BEFORE INSERT OR UPDATE OF parent_id, owner_id
  ON public.lv_collections
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_lv_collections_owner_consistency();

CREATE OR REPLACE FUNCTION public.enforce_lv_urls_owner_consistency()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_collection_owner UUID;
BEGIN
  SELECT c.owner_id
  INTO v_collection_owner
  FROM public.lv_collections c
  WHERE c.id = NEW.collection_id;

  IF v_collection_owner IS NULL THEN
    RAISE EXCEPTION 'collection not found for url: %', NEW.collection_id;
  END IF;

  IF v_collection_owner IS DISTINCT FROM NEW.owner_id THEN
    RAISE EXCEPTION 'url owner mismatch for collection %', NEW.collection_id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS lv_urls_owner_consistency_trg ON public.lv_urls;
CREATE TRIGGER lv_urls_owner_consistency_trg
  BEFORE INSERT OR UPDATE OF collection_id, owner_id
  ON public.lv_urls
  FOR EACH ROW
  EXECUTE FUNCTION public.enforce_lv_urls_owner_consistency();
