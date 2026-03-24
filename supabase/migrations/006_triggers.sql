-- 006_triggers.sql

CREATE OR REPLACE FUNCTION public.lv_update_collection_url_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE'
     OR (TG_OP = 'UPDATE' AND NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE) THEN
    UPDATE public.lv_collections
    SET
      url_count = GREATEST(url_count - 1, 0),
      updated_at = NOW()
    WHERE id = COALESCE(OLD.collection_id, NEW.collection_id);

  ELSIF TG_OP = 'INSERT'
     OR (TG_OP = 'UPDATE' AND NEW.is_deleted = FALSE AND OLD.is_deleted = TRUE) THEN
    UPDATE public.lv_collections
    SET
      url_count = url_count + 1,
      updated_at = NOW()
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

