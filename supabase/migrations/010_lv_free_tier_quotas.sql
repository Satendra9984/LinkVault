-- 010_lv_free_tier_quotas.sql
-- Server-side enforcement for free-tier caps (align with app TierQuotaLimits.freeAuthenticated*).
-- Premium bypass: lv_user_profiles.is_premium OR premium_expires_at > now().
--
-- Caps (non-premium):
--   Collections (non-deleted rows in lv_collections): 150
--   URLs (non-deleted rows in lv_urls): 5000

CREATE OR REPLACE FUNCTION public.lv_profile_premium_active(p_uid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (
      SELECT (p.is_premium OR (p.premium_expires_at IS NOT NULL AND p.premium_expires_at > now()))
      FROM public.lv_user_profiles p
      WHERE p.id = p_uid
    ),
    false
  );
$$;

CREATE OR REPLACE FUNCTION public.lv_enforce_collection_quota()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cnt INTEGER;
BEGIN
  IF public.lv_profile_premium_active(COALESCE(NEW.owner_id, OLD.owner_id)) THEN
    RETURN COALESCE(NEW, OLD);
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF NEW.is_deleted THEN
      RETURN NEW;
    END IF;
    SELECT COUNT(*)::int INTO cnt
    FROM public.lv_collections c
    WHERE c.owner_id = NEW.owner_id
      AND c.is_deleted = false;
    IF cnt >= 150 THEN
      RAISE EXCEPTION 'lv_collection_quota_exceeded'
        USING ERRCODE = 'check_violation',
              HINT = 'Free plan allows up to 150 collections. Upgrade to raise limits.';
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.is_deleted = true AND NEW.is_deleted = false THEN
      SELECT COUNT(*)::int INTO cnt
      FROM public.lv_collections c
      WHERE c.owner_id = NEW.owner_id
        AND c.is_deleted = false;
      IF cnt >= 150 THEN
        RAISE EXCEPTION 'lv_collection_quota_exceeded'
          USING ERRCODE = 'check_violation',
                HINT = 'Free plan allows up to 150 collections. Upgrade to raise limits.';
      END IF;
    END IF;
    RETURN NEW;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE OR REPLACE FUNCTION public.lv_enforce_url_quota()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cnt INTEGER;
BEGIN
  IF public.lv_profile_premium_active(COALESCE(NEW.owner_id, OLD.owner_id)) THEN
    RETURN COALESCE(NEW, OLD);
  END IF;

  IF TG_OP = 'INSERT' THEN
    IF NEW.is_deleted THEN
      RETURN NEW;
    END IF;
    SELECT COUNT(*)::int INTO cnt
    FROM public.lv_urls u
    WHERE u.owner_id = NEW.owner_id
      AND u.is_deleted = false;
    IF cnt >= 5000 THEN
      RAISE EXCEPTION 'lv_url_quota_exceeded'
        USING ERRCODE = 'check_violation',
              HINT = 'Free plan allows up to 5000 saved links. Upgrade to raise limits.';
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.is_deleted = true AND NEW.is_deleted = false THEN
      SELECT COUNT(*)::int INTO cnt
      FROM public.lv_urls u
      WHERE u.owner_id = NEW.owner_id
        AND u.is_deleted = false;
      IF cnt >= 5000 THEN
        RAISE EXCEPTION 'lv_url_quota_exceeded'
          USING ERRCODE = 'check_violation',
              HINT = 'Free plan allows up to 5000 saved links. Upgrade to raise limits.';
      END IF;
    END IF;
    RETURN NEW;
  END IF;

  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS lv_collections_quota_trigger ON public.lv_collections;
CREATE TRIGGER lv_collections_quota_trigger
  BEFORE INSERT OR UPDATE ON public.lv_collections
  FOR EACH ROW
  EXECUTE FUNCTION public.lv_enforce_collection_quota();

DROP TRIGGER IF EXISTS lv_urls_quota_trigger ON public.lv_urls;
CREATE TRIGGER lv_urls_quota_trigger
  BEFORE INSERT OR UPDATE ON public.lv_urls
  FOR EACH ROW
  EXECUTE FUNCTION public.lv_enforce_url_quota();
