# Library Root Integrity Runbook

Version: 1.0  
Last Updated: 2026-03-27  
Owner: Engineering

## Purpose

Operational playbook to validate and repair the one-root-per-user invariant before and after rolling out root-hardening changes.

## Invariant

For each owner in `public.lv_collections`, exactly one non-deleted row must satisfy:

- `parent_id IS NULL`
- `is_deleted = false`

## Required migration order

1. `004_lv_collections.sql`
2. `005_lv_urls.sql`
3. `014_uq_library_root_per_user.sql`
4. `015_ensure_library_root_rpc.sql`
5. `016_owner_consistency_constraints.sql`

## Preflight audit query

```sql
SELECT
  owner_id,
  COUNT(*) AS active_root_count
FROM public.lv_collections
WHERE parent_id IS NULL
  AND is_deleted = FALSE
GROUP BY owner_id
HAVING COUNT(*) <> 1
ORDER BY active_root_count DESC, owner_id;
```

If this returns rows, run the repair workflow before applying `014`.

## Duplicate-root repair workflow

1. Pick a canonical root per owner (oldest by `created_at`).
2. Reparent direct children of extra roots to canonical root.
3. Move URLs from extra roots to canonical root.
4. Soft-delete extra roots.
5. Re-run preflight query until zero rows.

### Example repair script (run per owner in transaction)

```sql
BEGIN;

-- Replace literals before running.
-- :owner_id, :canonical_root_id

WITH extra_roots AS (
  SELECT id
  FROM public.lv_collections
  WHERE owner_id = :owner_id
    AND parent_id IS NULL
    AND is_deleted = FALSE
    AND id <> :canonical_root_id
)
UPDATE public.lv_collections c
SET parent_id = :canonical_root_id,
    updated_at = NOW()
WHERE c.owner_id = :owner_id
  AND c.parent_id IN (SELECT id FROM extra_roots);

WITH extra_roots AS (
  SELECT id
  FROM public.lv_collections
  WHERE owner_id = :owner_id
    AND parent_id IS NULL
    AND is_deleted = FALSE
    AND id <> :canonical_root_id
)
UPDATE public.lv_urls u
SET collection_id = :canonical_root_id,
    updated_at = NOW()
WHERE u.owner_id = :owner_id
  AND u.collection_id IN (SELECT id FROM extra_roots);

UPDATE public.lv_collections
SET is_deleted = TRUE,
    deleted_at = NOW(),
    updated_at = NOW()
WHERE owner_id = :owner_id
  AND parent_id IS NULL
  AND is_deleted = FALSE
  AND id <> :canonical_root_id;

COMMIT;
```

## Post-deploy checks

1. Root-count query returns zero anomalies.
2. App logs show successful root ensure and no repeated `23505` spikes.
3. New users receive exactly one root row after first launch.

## Rollback notes

- Dropping `uq_lv_collections_one_root_per_user` re-allows duplicate active roots.
- If rollback is required, keep app-side single-flight enabled and run anomaly monitoring hourly.
