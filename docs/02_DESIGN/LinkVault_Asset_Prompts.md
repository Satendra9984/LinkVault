# LinkVault — Detailed Asset Illustration Prompts
**Version:** 1.0  
**Date:** March 2026  
**For use with:** Midjourney, DALL-E 3, Adobe Firefly, Stable Diffusion XL, or Figma AI

---

## Universal Design Principles for All Assets

Before using any prompt, read these rules. They ensure every illustration works
on both dark (#0A0A0A) and light (#F4F4F5) backgrounds without modification.

**The dual-mode formula:**
- TRANSPARENT background always — never white, never black fill
- PRIMARY hue: #6366F1 (Indigo-500) for key shapes and focal elements
- SECONDARY hue: soft lavender (#A5B4FC, Indigo-300) for supporting elements
- NEUTRAL shapes: use #64748B (Slate-500) mid-gray — visible on both dark and light
- NO solid white fills (invisible on light bg)
- NO solid black fills (invisible on dark bg)
- Strokes only in accent or neutral tones — never pure white or black outlines
- Depth through color value difference, NOT through shadow

**Style anchor:** Geometric, modern, minimal vector. No characters, no faces, no hands.
Think: abstract shapes that represent the concept. The style closest to
Vercel, Linear, Supabase illustration style — not Material Design, not flat icon packs.

**Size output:** 400×400px for all illustrations (they'll be displayed at 160–200dp)

---

## SECTION A: Onboarding Illustrations (3 required)

### A1 — Onboarding Slide 1: "Save links in 2 taps"

**Concept:** A URL being captured and secured into a vault container.

**Prompt (Midjourney / DALL-E 3):**
```
Minimal geometric vector illustration, transparent background, no white or 
black fills. A stylized smartphone outline in slate-gray (#64748B) with rounded 
corners, showing a simplified share-sheet panel rising from the bottom with 
3 rows. One row is highlighted in indigo-violet (#6366F1) representing "LinkVault". 
Above and around the phone, 3 floating link-cards drift inward — each card is a 
small rounded rectangle with a colored left accent bar (one indigo, one teal, 
one amber) and a 2-line text placeholder (gray horizontal bars). A subtle arc or 
curved dashed line traces from the cards toward the highlighted row, suggesting 
flow and capture. All elements are flat, geometric, no gradients, no shadows, 
no characters, no hands. Indigo-violet as the dominant accent. Clean whitespace. 
400×400px. Modern productivity app style, similar to Linear or Vercel illustrations.
```

**Color tokens used:**
- Phone outline: #64748B stroke, no fill
- Share sheet: #1E293B (dark slate) fill, works on both modes
- Highlighted row: #6366F1 fill, white text placeholder
- Link cards: #6366F1 / #0D9488 / #F59E0B left bars, #334155 card body
- Arc line: #6366F1, 1.5px dashed

**Figma AI prompt (shorter):**
```
Flat vector, transparent bg. Phone outline (slate gray) with share sheet open, 
LinkVault row highlighted in indigo-violet. 3 floating rounded-rect link cards 
with colored left accent bars drifting toward the phone. Curved dashed line 
showing flow. No characters, no fills on background. Minimal, geometric, 
Linear-app style.
```

---

### A2 — Onboarding Slide 2: "Folders inside folders"

**Concept:** Nested folder hierarchy visualized as stacked colored cards with depth.

**Prompt (Midjourney / DALL-E 3):**
```
Minimal geometric vector illustration, transparent background, no white or black 
fills. A central collection of 3 overlapping rounded-rectangle cards arranged in 
a slight fan/staggered layout, showing depth through position offset (each card 
10px offset from the one beneath). The front card is the largest and most detailed: 
it has a 4px top accent bar in indigo-violet (#6366F1), an emoji/folder icon 
placeholder circle in top-left, and 2 rows of gray bar placeholders for title and 
count. Behind it, a slightly smaller card with a teal (#0D9488) top accent bar. 
Behind that, an amber (#F59E0B) accented card. Outside this stack, 2 smaller 
sub-folder cards appear connected by thin slate-gray lines, representing nesting. 
One sub-card has a pink (#EC4899) accent bar. All flat, geometric, no gradients, 
no shadows, no characters. Clean, modern, similar to Craft app style. 400×400px.
```

**Color tokens used:**
- Front card accent: #6366F1
- Mid card accent: #0D9488
- Back card accent: #F59E0B
- Sub-folder accent: #EC4899
- Card bodies: #1E293B (appears slightly different on light/dark but visible both)
- Connecting lines: #475569, 1px

**Figma AI prompt (shorter):**
```
Flat vector, transparent bg. 3 stacked overlapping rounded-rect cards in a fan, 
each with a different colored 4px top accent bar (indigo, teal, amber). Smaller 
nested sub-cards connected by thin slate lines. No gradients, no background, 
no characters. Shows folder-in-folder nesting concept. Minimal, geometric.
```

---

### A3 — Onboarding Slide 3: "Access everywhere, offline-first"

**Concept:** Two device outlines (phone + small tablet) with synchronized content, 
connected by a subtle cloud element. Offline badge shows local-first capability.

**Prompt (Midjourney / DALL-E 3):**
```
Minimal geometric vector illustration, transparent background, no white or black 
fills. Two device outlines in slate gray (#64748B): a smartphone (taller, left-center) 
and a small tablet (wider, right, slightly behind and lower). Both devices show the 
same simplified grid of 4 collection cards inside their screens, with matching colored 
top accent bars — proving synchronization. Between the two devices, a simple geometric 
cloud shape (outline only, indigo-violet stroke, no fill) with two small curved arrows 
pointing both directions (sync symbol) sits centrally. In the top-left corner of the 
phone, a small badge reads "offline" in a rounded rect with slate background and white 
text — demonstrating offline capability. All elements are flat, no gradients, no 
characters, no drop shadows. Indigo-violet (#6366F1) as accent for the sync cloud and 
badges. 400×400px. Modern productivity app illustration style.
```

**Figma AI prompt (shorter):**
```
Flat vector, transparent bg. Phone and tablet outlines (slate gray), each showing 
matching 4-card grid inside screens. Cloud outline with sync arrows between them 
(indigo accent). Small offline badge on phone corner. No fills on bg, no characters, 
no gradients. Shows cross-device sync + offline concept. Minimal geometric.
```

---

## SECTION B: Empty State Illustrations (5 required)

### B1 — Empty Library / No Collections

**Concept:** An empty open vault or folder with a dashed border, inviting creation.

**Prompt:**
```
Minimal geometric SVG-style vector illustration, transparent background. An open 
folder or vault shape drawn with a dashed outline stroke in indigo-violet (#6366F1) 
at 1.5px. The folder is centered, approximately 180×160px in perceived size. Inside 
the folder outline is a large centered plus symbol (+) in indigo-violet, indicating 
creation. The folder shape should be modern — not the classic angled-tab folder — 
instead a rounded rectangle with a small bumped tab on the top-left, all in dashed 
lines only, no fills. Below the folder, a subtle shadow-like ellipse in 
semi-transparent slate (#64748B at 20% opacity) provides grounding without a hard 
shadow. No text, no characters, no gradients. Total illustration: 400×400px centered 
content within the frame. Style: abstract, clean, Notion/Linear empty state art.
```

---

### B2 — Empty Collection / No Links Yet

**Concept:** An unlit bookmark or link icon within a soft container, suggesting 
waiting for content.

**Prompt:**
```
Minimal geometric vector illustration, transparent background. Center of frame: 
a bookmark shape (classic bookmark — rectangle with a V-notch at the bottom) 
drawn as outline-only in slate gray (#94A3B8), 2px stroke, no fill, approximately 
80px tall. To its left, a small chain-link icon (two interlocking ovals) in 
indigo-violet (#6366F1) at 40px, slightly overlapping the bookmark. Behind both 
elements, a large soft circle (200px diameter, #6366F1 at 8% opacity) creates a 
subtle focal halo that works on both light and dark backgrounds. Three small dots 
in indigo-violet are arranged below the main elements, suggesting content that 
could appear. No background fills, no text, no characters. Clean, flat, modern. 
400×400px.
```

---

### B3 — Empty Search / No Results

**Concept:** A magnifying glass with empty interior suggesting nothing found.

**Prompt:**
```
Minimal geometric vector illustration, transparent background. A magnifying glass 
shape centered in the frame: circular lens (96px diameter) in dashed slate-gray 
outline (#94A3B8, 2px dashed), no fill. The handle extends to the bottom-right 
at 45 degrees, slate-gray solid stroke, 3px, rounded cap. Inside the circular 
lens: a small X mark in indigo-violet (#6366F1), 32px wide, made of two rounded 
lines crossing, suggesting no results found. Three small horizontal bars (like 
search result skeletons) appear to the right and below the magnifying glass, 
each partially transparent (40% opacity) in slate gray, representing the 
absence of results. No background, no text, no characters, no gradients. 
400×400px. Clean, modern, abstract.
```

---

### B4 — Empty Folders Tab / No Sub-collections

**Concept:** A parent folder containing only outlines of potential child folders — 
dotted, waiting.

**Prompt:**
```
Minimal geometric vector illustration, transparent background. A larger parent 
folder outline (modern rounded-rect style, no fills, slate-gray stroke #64748B 
at 1.5px) occupies the center. Inside the parent folder boundary, 2 smaller 
child folder outlines appear — both drawn with dashed indigo-violet strokes 
(#6366F1, 1.5px dashed), positioned left and right of center, suggesting they 
want to exist but are empty. Each small folder has a plus (+) symbol in its 
center in indigo-violet. A thin dashed line connects the parent to each child 
folder, showing the nesting relationship. No fills anywhere, no background, 
no characters, no text. 400×400px. Very minimal, geometric, abstract.
```

---

### B5 — Empty Search Query State (Initial state, before typing)

**Concept:** A search field outline with floating category suggestion bubbles 
drifting around it.

**Prompt:**
```
Minimal geometric vector illustration, transparent background. A rounded-rectangle 
search bar outline (280px wide, 48px tall, #94A3B8 stroke 1.5px, no fill) centered 
slightly above mid-frame. Inside the left of the bar, a simplified magnifying glass 
icon in slate gray. Around and drifting outward from the bar: 5 small rounded-pill 
shapes (suggestion chips) at varying angles and distances — each is outline-only in 
indigo-violet (#6366F1, 1px stroke), no fill, with a 2-bar placeholder inside 
representing text. Chips are at different opacities (100%, 70%, 50%, 40%, 30%) 
creating a sense of drift and possibility. No background, no text, no characters, 
no gradients. 400×400px. Modern, airy, clean.
```

---

## SECTION C: Functional / Feature Illustrations (3 optional, high-impact)

### C1 — Ad Gate Screen Illustration (Daily Access Badge)

**Concept:** A stylized ticket or pass shape representing the daily access concept.

**Prompt:**
```
Minimal geometric vector illustration, transparent background. A large ticket shape 
(classic event ticket proportions — 2:1 horizontal, 220×110px) centered in frame. 
The ticket is outline-only with a slate-gray stroke (#64748B, 2px). On the left 
portion of the ticket: a simple star shape (5-pointed outline) in indigo-violet 
(#6366F1, filled). A vertical dashed slate line divides the ticket into left stub 
and main body (classic ticket design). On the main body: three horizontal bar 
placeholders suggesting text, all in slate-gray at 60% opacity. Above the ticket, 
a subtle glow circle (#6366F1 at 6% opacity, 200px diameter) centers behind the 
ticket. Below the ticket, a small "24h" text-shaped element in indigo-violet 
inside a rounded rect badge. No characters, no hands, no background fills, no 
gradients. 400×400px. Clean, abstract, premium.
```

---

### C2 — Premium / Paywall Hero Illustration

**Concept:** An abstract vault door or shield suggesting security and premium access.

**Prompt:**
```
Minimal geometric vector illustration, transparent background. A large shield shape 
(classic heraldic shield, 200px tall) in outline-only, drawn with indigo-violet 
stroke (#6366F1, 2px), no fill. Inside the shield: a stylized padlock shape — the 
lock body is a rounded rectangle in indigo-violet (filled, #6366F1) and the shackle 
(U-shape) is slate gray (#64748B) outline. Around the shield: 4 small diamond/star 
sparkle shapes in indigo-violet at varying sizes (8px, 12px, 8px, 10px), positioned 
at corners suggesting premium quality. A subtle outer ring (dashed, 240px diameter, 
#6366F1 at 20% opacity) encircles the shield. The amber color (#F59E0B) appears only 
on one small crown-like element at the top of the shield (3-point simple crown, 
outline, 2px), suggesting premium status. No gradients, no backgrounds, no characters. 
400×400px. Premium, elegant, minimal.
```

---

### C3 — RSS Feeds Screen Illustration (when no feeds added)

**Concept:** A broadcast/signal tower emitting waves, with a small feed-card floating.

**Prompt:**
```
Minimal geometric vector illustration, transparent background. Center-left: a simple 
broadcast tower shape (vertical line with 3 progressively wider horizontal bars 
representing signal tiers) in slate gray (#64748B, 2px stroke, no fill). To the 
right of the tower, 3 concentric quarter-circle arcs (like a wifi symbol rotated 90°) 
in indigo-violet (#6366F1), drawn as 2px strokes with no fill, at 100%, 70%, 40% 
opacity going outward — representing signal broadcast. One small floating card 
(simplified article card: rounded rect 80×50px in #1E293B fill, with 3 horizontal 
bar placeholders and a tiny image placeholder square) hovers to the right and slightly 
above, as if being received. A thin curved dashed line connects tower to card. No 
background, no characters, no gradients. 400×400px. Clean, abstract, editorial.
```

---

## SECTION D: Technical Rendering Notes

### For AI Image Generators

1. Always start with "Minimal geometric vector illustration, transparent background"
2. Specify exact hex values for key colors — AI models respond to hex cues
3. Say "no gradients" and "no shadows" explicitly every time — models default to them
4. Specify "no characters, no hands, no faces" — models will add them otherwise
5. End with "400×400px" and reference apps (Linear, Vercel, Notion) as style anchors

### For Figma AI or GPT-4 with image generation

Use the shorter "Figma AI prompt" variants provided above. These are optimized 
for instruction-following models vs. diffusion models.

### For a human designer / SVG creation

All illustrations should be delivered as:
- Format: SVG (vector, scalable)
- Background: none (transparent)
- Artboard: 400×400px
- Stroke weights: 1.5px or 2px max (renders cleanly at 160dp display size)
- No raster effects, no blur, no inner/outer glows
- Export: also PNG @3x (1200×1200px) for Flutter asset bundling

### Flutter Asset Integration

```dart
// lib/core/assets/app_assets.dart

class AppAssets {
  // Onboarding
  static const onboarding1 = 'assets/illustrations/onboarding_save.svg';
  static const onboarding2 = 'assets/illustrations/onboarding_organize.svg';
  static const onboarding3 = 'assets/illustrations/onboarding_sync.svg';
  
  // Empty states
  static const emptyLibrary    = 'assets/illustrations/empty_library.svg';
  static const emptyLinks      = 'assets/illustrations/empty_links.svg';
  static const emptySearch     = 'assets/illustrations/empty_search.svg';
  static const emptyFolders    = 'assets/illustrations/empty_folders.svg';
  static const emptySearchInit = 'assets/illustrations/empty_search_init.svg';
  
  // Feature
  static const adGate          = 'assets/illustrations/ad_gate_ticket.svg';
  static const paywall         = 'assets/illustrations/paywall_shield.svg';
  static const emptyRss        = 'assets/illustrations/empty_rss.svg';
}
```

Since all illustrations are transparent SVGs with no color inversions needed,
a single asset works for both light and dark mode — use flutter_svg package:

```dart
SvgPicture.asset(
  AppAssets.emptyLibrary,
  width: 160,
  height: 160,
  // No colorFilter needed — illustration adapts naturally
)
```

---

## SECTION E: Color Token Quick Reference

Use these exact values in prompts for consistency:

| Role                  | Hex       | Name              |
|-----------------------|-----------|-------------------|
| Primary accent        | #6366F1   | Indigo-500        |
| Accent light          | #A5B4FC   | Indigo-300        |
| Accent subtle bg      | #6366F1 @ 8%  | Indigo halo   |
| Neutral mid           | #64748B   | Slate-500         |
| Neutral light         | #94A3B8   | Slate-400         |
| Dark surface          | #1E293B   | Slate-800         |
| Premium gold          | #F59E0B   | Amber-500         |
| Collection teal       | #0D9488   | Teal-600          |
| Collection amber      | #F59E0B   | Amber-500         |
| Collection pink       | #EC4899   | Pink-500          |

---

*End of LinkVault Asset Prompts v1.0*
