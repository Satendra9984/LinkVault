# Sprint 5-6 Collections UI Flows

## Screens in scope

- Collections **root** list (2-column grid; optional list mode with reorder)
- **Nested** collection screen (mixed: child collection shortcuts + URL list for current folder)
- Create collection
- Edit collection
- Delete confirmation
- Reorder interactions (siblings only)

## Entry routes (conceptual)

- Home `/` or `/collections`: root collections only (`parent_id == null`), not the full flat list.
- Open folder: `/collections/:id` — items + nested children for that id.
- Create root: `/collections/create` — optional query `?parent=<uuid>` when creating a child from inside a folder.
- Edit: `/collections/:id/edit`.

## Flow: Root to nested

1. User lands on root collections.
2. Tap collection card / row.
3. Open nested view showing:
   - **Child collections** (horizontal strip, mini-cards, or section header — product choice)
   - **URLs** belonging to this collection
4. Breadcrumb updates along ancestor chain, e.g. `Home > Tech > Flutter > Current`.
5. Breadcrumb segment tap: navigate to that ancestor’s `/collections/:id` (replace stack or push — prefer consistent stack behavior).

## Flow: Create collection

Form fields:

- **Title** (required; max length per validation)
- **Category** (preset list and/or free text; persisted as `category`)
- **Icon** (catalog picker: emoji or predefined keys; persisted as `icon_name` in DB)
- **Color** (picker; `color_hex`)
- **Parent** (optional; `/collections/create?parent=` or in-form picker)

Rules:

- When opened from a nested screen, **default parent** = current collection id.
- **Parent picker:** exclude self when editing; optionally exclude descendants to prevent cycles (app validation).
- Show error if save would create a cycle or cross-owner parent.

## Flow: Edit collection

- Edit title, category, icon, color, parent, pin, archive (as applicable).
- Save updates via active repository (local vs cloud per state machine).
- On parent change, invalidate breadcrumb path and refresh child-collection strip + lists.

## Flow: Delete collection

- Confirm dialog with explicit **cascade** copy:
  - Deletes **all nested subfolders** under this tree
  - Deletes **all URLs** in those folders (or soft-deletes if product uses trash)
- On success: `pop` to parent collection or root if parent was removed.

## Flow: Reorder + pin/archive

- **Reorder:** Only among **siblings** sharing the same `parent_id` (including root siblings where `parent_id` is null).
- **Drag affordance:** Long-press or “Edit order” mode if grid does not support native reorder.
- **Persist:** Update `position` using fractional indexing between neighbors (see [Architecture](Sprint_5_6_Collections_Architecture.md#fractional-indexing-for-reorder)).
- **Pin:** Toggle `is_pinned`; sort pinned group above unpinned within same archive state.
- **Archive:** Toggle `is_archived`; default lists hide archived or move to filter; editing archived folders remains possible.

## Archive visibility (locked: **A**)

- **Home root list** and default home tabs: archived collections are **hidden** (`is_archived`).
- **Nested child strips:** archived subfolders are **hidden**.
- **Search:** archived collections **remain in search results** so users can open **Edit** and unarchive (no separate “Archived” tab yet).

Product override: add a dedicated Archived browse entry point later if needed.

## UX edge cases

- **Empty root:** illustration + CTA “Create collection”.
- **Empty folder:** CTA to add subfolder or add URL.
- **Deep breadcrumbs:** horizontal scroll; truncate middle segments on very small screens if needed.
- **Read-only cloud:** snackbar when subscription inactive but user is on cloud repo.
- **Offline premium:** if selector falls back to local, indicate “changes sync when online” when sync sprint defines behavior.

## Search (out of scope for 5–6 core)

Global collection search may show flat results; tapping a result should open `/collections/:id` with correct breadcrumb when parent chain is loaded.
