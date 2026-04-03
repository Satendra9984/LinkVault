-- Account-aware install trial: once consumed, signed-in users cannot reclaim
-- the 3-day install trial after reinstall (local install date resets).

ALTER TABLE public.lv_user_profiles
  ADD COLUMN IF NOT EXISTS install_trial_consumed BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.lv_user_profiles.install_trial_consumed IS
  'When true, this account is not eligible for the device 3-day install free trial (anti reinstall abuse).';
