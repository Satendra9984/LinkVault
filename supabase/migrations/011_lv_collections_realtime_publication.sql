-- Supabase `.stream()` uses postgres_changes on `supabase_realtime`. Without this table in
-- the publication, the first REST snapshot loads but INSERT/UPDATE/DELETE never push updates.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'lv_collections'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.lv_collections;
  END IF;
END $$;
