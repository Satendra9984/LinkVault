Key Architecture Decisions to Align On

1. AuthState model — The app has 3 tiers (guest, free, premium). Should AuthState hold the UserTier directly, or just the raw Supabase User? with tier computed separately (e.g. by checking RevenueCat/Supabase profile later)?
We dont have 3 tiers, check @docs/01_PRODUCT/ we have only 2 tiers, free with adpass and Premium.
And what do you proposed for our usecase, which architecture will work best?

2. Router redirect guard — GoRouter's redirect callback is the standard approach. Proposed flow:


What are your thoughts on each of these?
