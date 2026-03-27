-- 015_ensure_library_root_rpc.sql
-- Atomic ensure/get for the user's persisted Library root collection.
CREATE OR REPLACE FUNCTION public.ensure_library_root(p_owner_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_root_id UUID;
BEGIN
  SELECT c.id
  INTO v_root_id
  FROM public.lv_collections c
  WHERE c.owner_id = p_owner_id
    AND c.parent_id IS NULL
    AND c.is_deleted = FALSE
  ORDER BY c.created_at ASC
  LIMIT 1
  FOR UPDATE;

  IF v_root_id IS NULL THEN
    INSERT INTO public.lv_collections (
      owner_id,
      parent_id,
      title,
      icon_name,
      color_hex,
      category,
      is_pinned,
      is_archived,
      position,
      is_deleted
    ) VALUES (
      p_owner_id,
      NULL,
      'Library',
      '📚',
      '#6366F1',
      'general',
      FALSE,
      FALSE,
      0,
      FALSE
    )
    RETURNING id INTO v_root_id;
  END IF;

  RETURN v_root_id;
END;
$$;

REVOKE ALL ON FUNCTION public.ensure_library_root(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ensure_library_root(UUID) TO authenticated;
