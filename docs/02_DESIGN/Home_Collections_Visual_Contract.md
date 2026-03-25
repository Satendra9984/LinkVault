# Home & Collections — Visual Contract (LinkVault)

Version: 1.1  
Last Updated: 2026-03-24  
Status: Active  
Owner: Product + Design  
Depends On: [Home_and_Collections_UX_Architecture.md](../03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md), [ADR_0003_Home_Landing_and_Folder_Content_Model.md](../10_DECISIONS_AND_RISKS/ADR_0003_Home_Landing_and_Folder_Content_Model.md)  
**Companion:** Full flows and ASCII wireframes — [UI_UX_Flow_Document.md](./UI_UX_Flow_Document.md).  
Blocks: None (reference for implementation)

---

## Purpose

Define **visual and layout contracts** for the **Home dashboard** and **nested collections** surfaces. **Flows, screen ownership, and data rules** live only in [Home_and_Collections_UX_Architecture.md](../03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md) — do not duplicate that prose here.

---

## Scope

| In scope | Out of scope |
|----------|----------------|
| Section structure, spacing, typography scale | Full color brand system (use app theme) |
| Horizontal vs vertical lists, card min sizes | Motion specs (defer to component library) |
| Home section headers and empty states | Iconography beyond Material symbols |

---

## Global tokens (use existing app theme)

- **Corner radius:** primary containers **20–24** (match current collection form cards).
- **Page horizontal padding:** **16** outer; inner cards **20** horizontal / **16** vertical text padding where applicable.
- **Section vertical rhythm:** **24** between major Home sections; **16** between subsection header and first row.
- **Typography:** section title **titleMedium** semibold/bold; subtitle / helper **bodySmall** using `onSurfaceVariant`.

---

## Home dashboard

### Layout

- **Vertical scroll** only; no nested horizontal paging at root.
- **Optional** pull-to-refresh spanning full scroll (when cloud sync active).

### Section header pattern

Each block uses:

1. **Title row:** left-aligned title + optional trailing `TextButton` (“See all”) to Library or search.
2. **Optional subtitle:** one line, `onSurfaceVariant`, max 2 lines ellipsized.

### Content rows

| Section | Container | Notes |
|---------|-----------|--------|
| Pinned collections | Horizontal `ListView` **or** 2-column compact grid | Max **8** visible without “See all”; consistent tile height |
| Recent collections | Vertical list of **dense rows** (leading icon + title + chevron) | Cap per ADR-0003 |
| Pinned URLs | Horizontal cards (thumbnail + title) **or** vertical list matching URL card spec | Cap per ADR-0003 |
| Recent URLs | Same as URL row component used in folder | Cap per ADR-0003 |

### Library entry

- **Primary CTA** or **prominent list tile** (“Library” / “All folders”) — full width, same card radius as settings rows.

### Empty state

- If a section has zero items: **hide** the section **or** show a **single line** placeholder (“No pins yet”) — no large illustration required for v1.

---

## Nested collections (`CollectionsListScreen` pattern)

- Reuse **existing** collection card / list tile components.
- **Breadcrumb** or title shows current folder context; truncation with middle-ellipsis for deep paths.
- **FAB** or toolbar actions: create folder, create link (when product places link creation here).

---

## Unified folder hub (future target)

When implemented per ADR-0003:

1. **First group:** “Folders” — header **labelSmall** uppercase or **titleSmall** sentence case (pick one system-wide).
2. **Divider** or **24px** vertical gap.
3. **Second group:** “Links” — same URL row component as Home recent URLs.
4. Do **not** mix folder tiles and URL cards in one undifferentiated grid without group headers.

---

## References

- Flow and IA: [Home_and_Collections_UX_Architecture.md](../03_ARCHITECTURE/Home_and_Collections_UX_Architecture.md)
- Wireframes and route-level flows: [UI_UX_Flow_Document.md](./UI_UX_Flow_Document.md)
- Decisions: [ADR_0003](../10_DECISIONS_AND_RISKS/ADR_0003_Home_Landing_and_Folder_Content_Model.md)
