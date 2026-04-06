-- 019_lv_delete_linkvault_data_rpc.sql
-- Deletes LinkVault-specific user data while preserving the shared auth account.

CREATE OR REPLACE FUNCTION public.lv_delete_linkvault_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  current_uid uuid := auth.uid();
BEGIN
  IF current_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Delete child data first for explicitness. Foreign keys also enforce cleanup.
  DELETE FROM public.lv_urls
  WHERE owner_id = current_uid;

  DELETE FROM public.lv_collections
  WHERE owner_id = current_uid;

  DELETE FROM public.lv_user_profiles
  WHERE id = current_uid;
END;
$$;

REVOKE ALL ON FUNCTION public.lv_delete_linkvault_data() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.lv_delete_linkvault_data() TO authenticated;
