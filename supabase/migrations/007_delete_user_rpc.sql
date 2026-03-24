-- 007_delete_user_rpc.sql
-- Deletes the currently authenticated user from auth.users.
-- ON DELETE CASCADE on lv_* tables handles dependent data cleanup.

CREATE OR REPLACE FUNCTION public.lv_delete_user()
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

  DELETE FROM auth.users
  WHERE id = current_uid;
END;
$$;

REVOKE ALL ON FUNCTION public.lv_delete_user() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.lv_delete_user() TO authenticated;
