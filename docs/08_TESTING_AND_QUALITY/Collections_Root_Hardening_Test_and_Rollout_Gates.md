# Collections Root Hardening — Test and Rollout Gates

Version: 1.0  
Last Updated: 2026-03-27  
Owner: Engineering

## Unit test gates

- `ReadOnlyCollectionsRepository.ensureLibraryRootCollection` does not mutate and fails when root is absent/ambiguous.
- Root delete guard blocks deleting top-level rows in both local and cloud repositories.
- Local in-flight ensure guard is scoped by store key and does not leak across stores.

## Integration test gates

- Concurrent ensure calls resolve to one active root per owner.
- Unique-conflict path (`23505`) recovers deterministic existing root.
- Root route (`/collections`) renders folders-only tab (no links tab, no add-link FAB).
- Non-root route (`/collections/:id`) still renders folders + links tabs with lazy links loading.

## Runtime telemetry gates

- Root ensure success rate >= 99.9%.
- `23505` fallback count stable after rollout (no upward trend by release).
- Root anomaly query (`count != 1`) remains zero in production.
- No read-only mutation warnings outside expected premium-lapsed scenarios.

## Rollout stages

1. **Stage A (staging):** apply migrations + run preflight repair + full regression suite.
2. **Stage B (canary):** small user cohort, watch ensure metrics and root anomaly dashboard.
3. **Stage C (full):** deploy globally once canary is stable for 24h.
4. **Stage D (post):** run root anomaly audit daily for 7 days.
