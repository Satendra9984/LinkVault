# URL UX Parity Checklist

Date: 2026-03-25

## Verified Against Plan

- [x] Unified folder + URLs surface uses a single Sliver scroll shell.
- [x] Top controls are visible first (layout, status filter, sort chips).
- [x] Child collections strip appears before URL content.
- [x] URL list/card visuals are URL-native (favicon identity + preview hierarchy).
- [x] URL list rows are favicon-first (no legacy thumbnail column).
- [x] URL tiles show unread/read/archived status indicators.
- [x] URL parser extracts title, description, thumbnail, website name, and favicon.
- [x] Create/Edit flow is URL-centric (URL, title, notes, tags, thumbnail, preview identity).
- [x] Detail flow emphasizes URL identity, notes, tags, and utilities (pin/archive/delete).
- [x] Curate-only notes/custom-field UI is removed from create/edit/detail paths.

## Intentional Differences From Old LinkVault

1. Favicon rendering in list/grid uses a lightweight web favicon fallback strategy instead of the legacy heavier image pipeline.
2. Sort controls are chip-based and always visible at the top; old screens split some controls across alternate surfaces.
3. Detail utilities are trimmed to URL lifecycle actions (pin/archive/delete), excluding duplicate/share from this URL-focused pass.
4. Metadata extraction adds in-flight dedupe and small cache to reduce repeated network fetches, which modernizes old behavior.

## Verification Commands

- `flutter analyze --no-pub lib/features/items`
- `flutter analyze --no-pub lib/core/services/url_parsing_service.dart`
- `flutter analyze --no-pub lib/features/items/presentation/widgets/url_preview_tile.dart`

