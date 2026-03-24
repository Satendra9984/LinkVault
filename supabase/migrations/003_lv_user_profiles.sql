-- 003_lv_user_profiles.sql

CREATE TABLE IF NOT EXISTS public.lv_user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url TEXT,
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  premium_expires_at TIMESTAMPTZ,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.lv_user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "lv_profile_select_own"
  ON public.lv_user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "lv_profile_update_own"
  ON public.lv_user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.lv_handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.lv_user_profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'name',
      split_part(NEW.email, '@', 1)
    )
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_lv_auth_user_created ON auth.users;
CREATE TRIGGER on_lv_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.lv_handle_new_user();

