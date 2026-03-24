-- 008_lv_user_profiles_insert_policy.sql
-- Enables runtime self-healing profile creation from authenticated clients.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'lv_user_profiles'
      AND policyname = 'lv_profile_insert_own'
  ) THEN
    CREATE POLICY "lv_profile_insert_own"
      ON public.lv_user_profiles
      FOR INSERT
      WITH CHECK (auth.uid() = id);
  END IF;
END
$$;

