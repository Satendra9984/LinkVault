# LinkVault — Asset & Illustration Prompt Library
**Version:** 2.1  
**Date:** April 2026  
**For use with:** ChatGPT (DALL-E 3), Midjourney v6, Adobe Firefly, Stable Diffusion XL, or Figma AI

---

## Part 1 — Strategy & Design System

### 1.1 The Reusability Strategy (Read First)

All LinkVault illustrations follow a **light-first, filter-ready** approach:

1. **Generate on transparent background** — the PNG has no baked-in background colour.
2. **Design for light theme** — shapes, colours, and contrast are tuned for the light app background (`#F8F9FA`).
3. **Adapt to dark theme via Flutter image filters** — no second set of images needed.
4. **Survive primary-colour changes** — because primary accent shapes are isolated, a single `ColorFilter` can remap them when the app palette evolves.

This keeps the asset library small, consistent, and maintainable.

### 1.2 Flutter Dark-Mode Filter Pattern

Apply this in any widget that renders an illustration:

```dart
// lib/core/presentation/widgets/illustration_image.dart

class IllustrationImage extends StatelessWidget {
  const IllustrationImage({
    super.key,
    required this.asset,
    this.width = 200,
    this.height = 200,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColorFiltered(
      colorFilter: isDark
          ? const ColorFilter.matrix(<double>[
              // Invert lightness, keep hue — works on transparent PNG.
              -1,  0,  0, 0, 255,
               0, -1,  0, 0, 255,
               0,  0, -1, 0, 255,
               0,  0,  0, 1,   0,
            ])
          : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
      child: Image.asset(asset, width: width, height: height, fit: BoxFit.contain),
    );
  }
}
```

> **Why inversion works:** A transparent PNG with coral shapes on a white ground → after inversion becomes dark coral/red shapes on a black ground, which maps perfectly to the dark scaffold `#0F0F0F`. The coral primary `#FF6B4A` inverts to `#0094B5` (teal) — if that is undesirable, use a tinted `srcATop` blend instead to keep hue:

```dart
// Tinted variant — keeps primary hue readable in both modes
ColorFilter.mode(
  Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
  BlendMode.srcATop,
)
```

### 1.3 Universal Design Rules for Every Asset

| Rule | Value |
|---|---|
| **Background** | Transparent (PNG alpha). Never bake white or dark fills. |
| **Primary accent** | `#FF6B4A` Coral — the ACTUAL app primary |
| **Primary warm tint** | `#FF8C6B` (30 % lighter coral for depth/highlights) |
| **Neutral stroke / outline** | `#2D3436` Charcoal at 60–80 % opacity |
| **Neutral fill** | `#95A5A6` (slate) for supporting / secondary shapes |
| **Surface suggestion** | `#F8F9FA` warm-white for any implied background plane |
| **Success accent** | `#27AE60` green — use sparingly |
| **Premium gold** | `#D4AF37` — for premium / paywall screens only |
| **Error / break accent** | `#E74C3C` red — for error-state illustrations only |
| **NO dark backgrounds** | Never `#0F0F0F` or any near-black as a scene BG |
| **NO pure black lines** | Use `#2D3436` charcoal instead |
| **NO pure white fills** | White shapes are invisible on light backgrounds |
| **No characters, no hands, no faces** | Abstract / geometric objects only |
| **No heavy drop shadows** | Soft ambient occlusion only for depth |
| **Artboard** | 800×800 px source; displayed at 160–200 dp in app |

### 1.4 Style Profile — Soft 3D Minimal (Current Standard)

All production illustrations use one unified style:

- **Geometry:** Clean, rounded-corner 3D objects — not cartoon, not hyper-realistic.
- **Lighting:** Soft, diffused top-left key light. No lens flares. No neon glow.
- **Depth:** Subtle ambient occlusion and surface normals only. Objects float slightly above an implied surface.
- **Palette:** Coral `#FF6B4A` hero elements, warm-white/transparent ground, charcoal `#2D3436` strokes at reduced opacity, one neutral grey supporting shape.
- **Output:** PNG with full alpha channel, 800×800 px.

---

## Part 2 — Opening Prompt Boilerplate

Every prompt should begin with this boilerplate, then add the scene-specific details:

```
Soft 3D minimal illustration, TRANSPARENT background (full alpha PNG),
no white or dark background plate. Designed for a light-theme mobile app.
Primary accent colour #FF6B4A (coral/orange). Supporting shapes in warm
neutral #95A5A6. Outlines in #2D3436 charcoal at 70% opacity. Soft
ambient occlusion for depth — no hard drop shadows, no neon glow, no
gradients on the primary form. No characters, no hands, no faces.
Centered subject with 20% padding from all edges. 800×800px PNG.
```

---

## SECTION L: App Logo / Brand Mark

### Logo DNA — What Makes This Logo Work

The existing `link_vault_logo_original.png` establishes the brand DNA that all new logo
generations must preserve:

- **Form:** A **Hopf link** — two rings mathematically interlocked, weaving through
  each other. One ring passes in front on the left and behind on the right (or vice
  versa). This is a precise topological form, not two circles side by side. It is a
  perfect metaphor: *links = connections, vault = secure interlock*.
- **Surface:** Deliberately **faceted / low-polygon** — the ring surfaces are
  triangulated into flat polygon faces, like a precision-cut gemstone or crystalline
  mesh. This is NOT smooth 3D rendering. The facets must be large and intentional,
  not noisy micro-triangles.
- **Chromatic story:** A multi-chromatic spectrum split across the two rings. Left
  ring: cyan → teal. Right ring: coral-orange → amber → yellow, with magenta on
  the shadow side. The interlock zone is the darkest point.
- **Composition:** Horizontal-leaning, with a clear void at the centre where the
  rings interlock — the eye is drawn to this window.

**What to avoid:** smooth CGI sphere-like surfaces, generic metallic chrome, neon
glow, wordmarks, any background colour baked in.

**Output files:**
- `assets/images/linkvault_logo.webp` — primary in-app logo (splash, about)
- `assets/images/linkvault_logo.png` — launcher icon source for `flutter_launcher_icons`

---

### L1 — Prompt: Chromatic Crystal (Closest to original DNA, recommended)

**Tool:** ChatGPT / DALL-E 3 or Midjourney v6  
**Best for:** App store listing, splash screen, about page

```
App icon logo design. Two interlocked torus rings woven through each
other like a mathematical Hopf link — one ring clearly passes in front
of the other at one crossing and behind at the other, creating an
unambiguous interlocked chain-link topology. No background.

Surface treatment: each ring is precision-faceted — the exterior is
divided into large flat polygon faces, like a cut gemstone or
triangulated crystal sculpture. The facets are deliberate and clearly
visible, approximately 40–60 polygon faces per ring. Each face is a
single flat colour; the chromatic gradient is built entirely through
the accumulation of adjacent flat-coloured polygons, like pointillism
at the tessellation level. No smooth gradients per face. No smooth
blending between faces.

Chromatic story: the left ring transitions from deep teal (#006B6B) at
the bottom through bright cyan (#00D4E0) at the top highlight. The right
ring transitions from deep magenta (#B01060) at the shadow underside
through coral-orange (#FF6B4A) at the equator to warm amber (#FFB300) at
the topmost highlight. Where the two rings interlock and occlude each
other, the colours mix and darken — this is the visual anchor of the
composition, the deepest and richest zone.

Lighting: a single diffused overhead key light. Polygon faces tilted
upward catch the light sharply — nearly white at the peak. Faces angled
away from the light are 55–65% darker, holding their local hue. The
silhouette of each ring is razor-clean. The inner void of the interlock
is the darkest point in the entire image — deep, like looking into a
crystal cavern.

Background: fully transparent — pure alpha channel. No background plate,
no ambient glow behind the mark, no ground shadow, no environment.

Composition: perfectly centered. The mark is wider than tall, reading
horizontally. 25% empty padding from each edge for Android adaptive icon
safe zone. The inner void of the interlock sits at the visual centre.

Style reference: the mathematical precision of 3D-printed geometric
sculptures. The chromatic intensity of systematic colour progressions
found in contemporary abstract geometric art. The faceted crystalline
aesthetic of low-poly 3D art at its most refined and intentional — like
a gemstone carved by an algorithm.

NOT: smooth 3D CGI render, metallic chrome, plastic sheen, neon glow,
lens flare, bokeh, gradients within individual faces, wordmark,
lettermark, cartoon, flat 2D design, background colour, vignette.

Output: 1024×1024 PNG with full alpha transparency.
```

---

### L2 — Prompt: Molten Glass Sculpture (Organic premium variant)

**Tool:** ChatGPT / DALL-E 3  
**Best for:** When you want warmth and craftsmanship over geometric precision

```
App icon logo. Two interlocked torus rings — a Hopf link — sculpted
from hand-blown molten glass. The rings weave through each other: one
passes visibly in front at the left crossing, behind at the right,
creating the unmistakable topology of a chain link. No background.

Surface quality: translucent borosilicate glass with internal chromatic
striations, like handmade studio art glass pulled and shaped while
molten. The surface has very subtle tension lines — the kind left when
molten glass cools under gravity. Not cracked, not rough. Just the
faintest memory of fluid motion, frozen in place. Subsurface light
scattering causes colour to bloom from within the glass body, not just
reflect off its surface.

Left ring: translucent aquamarine glass. Deep teal (#006B6B) at the
core where the glass is thickest. Bright cyan-white (#B0F0FF) where the
glass is thinnest and light punches straight through.

Right ring: amber-coral art glass in sunset tones. Coral-orange
(#FF6B4A) at the equator, sunburst amber (#FFB300) at the belly where
the light saturates the glass, deep magenta-rose (#C01070) at the
shadowed underside where the glass is thickest and the colour richest.

Interlock zone: where the glass rings pass through each other, the
material is at its densest. The colours here are at maximum saturation
and depth — a dark chromatic jewel at the visual centre.

Lighting: a strong directional rim light from the upper left creates a
brilliant highlight streak along each ring's shoulder ridge. The
opposite side falls into deep chromatic shadow. No flat ambient fill —
this is high-contrast sculptural lighting. A faint secondary bounce
light from below lifts the shadow side just enough to reveal the colour
without flattening the drama.

Background: TRANSPARENT — pure alpha channel. No floor reflection,
no glow, no environment, no background plate.

Composition: horizontally centred mark, wider than tall. 25% padding
from each edge. The inner window of the interlock is the visual anchor.

Style references: hand-blown art glass sea-forms and sculptural vessels.
The rich chromatic layering of leaded stained-glass windows. Macro
refraction photography of light through coloured glass. The material
weight and presence of large-scale polished sculpture — without
reflective mirror surfaces.

NOT: metallic chrome, plastic, neon glow, cartoon, wordmark, smooth
CGI, photorealistic studio product shot, background, any named artist
or brand.

1024×1024 PNG, full alpha transparency.
```

---

### L3 — Prompt: Holographic Foil (Collectible, high-energy variant)

**Tool:** Midjourney v6 — paste directly  
**Best for:** Marketing materials, app store feature graphic, social assets

```
/imagine app icon logo, two interlocked torus rings in Hopf link
topology, one ring clearly passing in front of the other at each
crossing, surface shimmers like premium holographic laser foil pressed
into a crystalline faceted form, each ring has a distinct base hue
that bleeds at the interlock: left ring deep teal to electric cyan,
right ring deep magenta to coral-orange to amber, faceted surface
treatment like a precision diamond cut applied to a torus shape with
40-60 visible flat polygon faces per ring, razor-clean silhouette edges,
extremely high contrast specular highlights on the ridge of each ring,
deep dark interior void at the interlock, transparent background no
background plate no shadow no glow, centered composition 25% padding
from every edge, horizontal mark wider than tall, style reminiscent of
limited edition collectible art toy packaging chromatics meets
mathematical low-poly crystalline sculpture, hyper-saturated balloon-
like surface tension with gemstone faceting, NOT smooth metallic NOT
neon NOT glowing NOT wordmark NOT lettermark NOT background colour
--ar 1:1 --v 6.1 --style raw --no background glow shadow ground
vignette
```

---

### L4 — Prompt: Precision Geometric (Most legible at small sizes)

**Tool:** GPT-4o / Figma AI — instruction-following format  
**Best for:** When you need deterministic, readable output at every size

```
Create a 1024×1024 app icon on a transparent background for an app
called LinkVault. Symbol only — no text, no wordmark.

The symbol: two torus rings interlocked in a mathematical Hopf link.
They must weave through each other: ring A passes in front of ring B
on the left side, and behind ring B on the right side. This creates
an unambiguous chain-link interlocking, not two circles side by side.

Surface: each ring has a faceted, low-polygon exterior — NOT smooth.
Precisely triangulated like a cut gemstone. The facets must be large
and clearly visible as distinct flat faces (approximately 40–60 per
ring). Each polygon face is a single flat colour. The colour gradient
across each ring is built entirely from adjacent flat-coloured polygons,
not from smooth gradient fills.

Colours:
- Left ring: deep teal (#006B6B) at shadowed areas, bright cyan
  (#00D4E0) at the illuminated top. Build the transition polygon by
  polygon.
- Right ring: deep magenta (#B01060) at the shadowed underside,
  coral-orange (#FF6B4A) at the equator, warm amber (#FFB300) at the
  illuminated top. Build the transition polygon by polygon.
- Interlock zone (where rings overlap): this must be the darkest
  region — the rings occlude each other here, creating maximum depth
  and the visual centre of gravity.

Lighting: single overhead diffused light source. Upward-facing facets
are significantly brighter than downward-facing facets. No even
ambient fill. No neon. No glow. No lens flare.

Composition: perfectly centred on the canvas. Horizontal orientation
— wider than tall. 25% padding from every edge (Android adaptive icon
safe zone). The inner void of the interlock is at the visual centre.

Do NOT include: background colour, shadow on the ground, ambient glow
behind the mark, text, letters, chrome effect, smooth blended surfaces,
neon, bokeh, depth of field blur, environment lighting, vignette.

Output: 1024×1024 PNG with full alpha transparency channel.
```

---

### Logo Prompt Engineering Tips

**Getting the faceted surface right:**  
If the AI produces smooth surfaces, add: *"The polygon faces MUST be clearly visible
as distinct flat-coloured shapes with sharp edges between them. The surface should
look like a low-poly 3D mesh render with flat shading — think mathematical origami
or crystalline mineral, not smooth CGI."*

**Getting the interlock topology right:**  
If the rings look like they are just side by side or overlapping without weaving,
add: *"The interlocking is topologically like a chain link or a Hopf fibration —
ring A must visibly pass THROUGH the interior of ring B. One ring cannot simply
sit on top of the other."*

**Getting transparency:**  
DALL-E 3 sometimes ignores transparency requests. In a follow-up prompt, ask:
*"Regenerate with a pure white background and I will remove it in editing"* — then
use any background-removal tool. Or explicitly ask for *"white background, isolated
object, no shadow on ground"* and remove it via `remove.bg` or Photoshop.

**Midjourney iteration loop:**  
1. Run with `--style raw` first (less post-processing).  
2. If too smooth: add `--no smooth surfaces gradients chrome`.  
3. Use `/vary (subtle)` on good results rather than full re-generation.  
4. Use `--iw 1.5` with `link_vault_logo_original.png` as image prompt to
   anchor the style.

**Flutter integration:**
```dart
// pubspec.yaml — launcher icon source (must be PNG)
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/images/linkvault_logo.png"
  remove_alpha_ios: true
  min_sdk_android: 21

// In-app splash / about screen
Image.asset(AppAssets.appLogo, width: 120, height: 120)

// AppAssets constants (already wired)
// appLogo     → assets/images/linkvault_logo.webp
// appLogoPng  → assets/images/linkvault_logo.png  (launcher only)
```

---

## SECTION A: Onboarding Illustrations

### A0 — Welcome / Hero Slide

**Status:** `assets/images/onboarding_welcome.png` — review against new style guide.

**Concept:** A welcoming hero shot — floating link cards and a glowing vault, suggesting "your links, organised".

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background, no background plate.
A stylized open vault (rounded cubic form, coral #FF6B4A fill, charcoal
#2D3436 outlines at 70% opacity) centered slightly above mid-frame, its
door swung open. Floating around the vault: 3 small rounded-rect link
cards at staggered heights and slight rotations. Each card has a coral
left accent bar and two grey placeholder text lines. Cards have a subtle
warm-white (#F8F9FA) face with a faint #95A5A6 outline. A soft warm
ambient glow #FF6B4A at 6% opacity radiates from the vault. No text on
the illustration. No characters. No hard shadows. 800×800px transparent
PNG. Style: modern productivity app — think Linear, Craft, Notion.
```

---

### A1 — "Save links in 2 taps"

**Status:** `assets/images/onboarding_save.png` — review against new style guide.

**Concept:** A smartphone share-sheet with a LinkVault row highlighted, link cards flying in.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A stylised
smartphone (rounded slab form, #95A5A6 neutral grey, charcoal #2D3436
outline at 70% opacity). The screen shows a simplified share-sheet panel
rising from the bottom — one row highlighted in coral #FF6B4A representing
LinkVault. Above the phone: 3 small floating rounded-rect link cards
drifting inward, each with a coral left accent bar and 2-line grey text
placeholder. A faint curved dashed arc (#FF6B4A, 1.5px) traces from the
cards toward the highlighted row. No text labels. No characters. No hands.
Soft ambient depth. 800×800px transparent PNG.
```

---

### A2 — "Folders inside folders"

**Status:** `assets/images/onboarding_organize.png` — review against new style guide.

**Concept:** Nested collection cards with depth, showing hierarchy.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A stack of 3
overlapping rounded-rect cards arranged in a fan with 12px stagger. Front
card: widest, coral #FF6B4A top accent bar (4px), a small neutral circle
placeholder (emoji/icon area), and 2 grey text-bar rows. Mid card: warm
neutral #95A5A6 top accent. Back card: soft charcoal #2D3436 accent. Two
smaller sub-folder cards float outside the stack, connected to the main
stack by 1px charcoal dashed lines — one with a coral accent, one neutral.
No text, no characters. Soft ambient occlusion. Transparent background.
800×800px PNG.
```

---

### A3 — "Access everywhere, offline-first"

**Status:** `assets/images/onboarding_act.png` — review against new style guide.

**Concept:** Phone + tablet in sync, with cloud and offline badge.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. Two device forms: a
smartphone (left-center, taller, neutral grey #95A5A6 casing, charcoal
outline) and a small tablet (right, wider, slightly behind). Both screens
show a matching 2×2 grid of small collection cards (tiny coral accent
bars). Between the devices: a simple geometric cloud shape (outline only,
coral #FF6B4A 2px stroke, no fill) with two small curved sync arrows
pointing in opposite directions. Top-left corner of the phone: a small
rounded badge with coral fill and a white "✓" — representing offline
availability. No text labels. No characters. Soft depth. 800×800px
transparent PNG.
```

---

## SECTION B: Empty State Illustrations

### B1 — Empty Library / No Collections

**Status:** `assets/images/empty_library.png` — placeholder generated; needs AI replacement.

**Concept:** An open vault with a dashed outline, waiting to be filled.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. An open vault form
(rounded cubic body, coral #FF6B4A fill, charcoal #2D3436 outline at 70%
opacity) centered in the frame. The vault door is swung open — door is a
flat rounded panel with a lighter coral tint (#FF8C6B) on its face. Inside
the vault interior: empty space with a large centered "+" icon in coral,
suggesting creation. Below the vault, a very subtle soft ellipse shadow in
#95A5A6 at 20% opacity grounds the form. No text. No characters. No
background. 800×800px transparent PNG. Style: Notion / Linear empty-state
illustration quality.
```

---

### B2 — Empty Collection / No Links Yet

**Status:** Pending generation.

**Concept:** A bookmark + chain-link icon in a soft halo, waiting for content.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. Center of frame: a
bookmark form (rectangle with V-notch at bottom, coral #FF6B4A fill,
charcoal outline at 70% opacity, approximately 120px perceived height).
Overlapping its lower-left: a chain-link icon (two interlocking oval
rings) in warm neutral #95A5A6. Behind both elements: a large soft
circle (280px perceived diameter, coral #FF6B4A at 6% opacity) creates a
focal halo. Below: three small horizontal pill shapes in #95A5A6 at
30% opacity, suggesting absent content rows. No background. No text. No
characters. 800×800px transparent PNG.
```

---

### B3 — Empty Search / No Results

**Status:** `assets/images/empty_search.png` — has dark background; replace with transparent version.

**Concept:** A magnifying glass with an empty interior cross, no-results skeleton bars.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A magnifying glass
form (circular lens, 130px perceived diameter, coral #FF6B4A outline 3px,
no fill inside the lens). Handle extends bottom-right at 45°, coral
stroke 4px, rounded cap. Inside the lens: a small "×" in coral, two
rounded strokes crossing at centre. To the right and below: 3 horizontal
skeleton bars in #95A5A6 at 35% opacity (widths: 100%, 75%, 50%),
representing absent results. No dark background. No characters. No text.
Soft ambient depth on the glass form only. 800×800px transparent PNG.
```

---

### B4 — Empty Folders Tab / No Sub-collections

**Status:** Pending generation.

**Concept:** A parent folder containing dotted ghost child folders.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A parent folder
form (modern rounded-rect shape, warm neutral #95A5A6 fill at 40%
opacity, charcoal #2D3436 outline at 60% opacity, approximately 200×160px
perceived). Inside the parent boundary: 2 smaller child folder outlines
— both drawn with dashed coral strokes (#FF6B4A, 2px dashed), positioned
left and right, each with a small coral "+" inside. Thin dashed charcoal
lines connect the parent to each child folder. No solid fills on child
folders. No text, no characters, no background. 800×800px transparent PNG.
```

---

### B5 — Empty Search Query (Before Typing)

**Status:** Pending generation.

**Concept:** A search bar with floating suggestion chips drifting around it.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A rounded-rectangle
search bar (360px wide, 56px tall perceived) with a warm neutral #95A5A6
outline (2px) and no fill. Inside left: a small magnifying-glass icon in
coral #FF6B4A. Around the bar: 5 rounded-pill suggestion chips floating at
different angles and distances — each outline-only in coral #FF6B4A (1.5px
stroke), no fill, with a 2-bar grey placeholder inside. Chips at
decreasing opacity outward (100%, 75%, 55%, 40%, 25%), suggesting
possibility. No background. No text labels. No characters. 800×800px
transparent PNG.
```

---

## SECTION C: Functional / Feature Illustrations

### C1 — Ad Gate / Daily Access Pass

**Status:** `assets/images/illustration_reward.png` — placeholder; needs AI replacement.

**Concept:** A stylised ticket or pass representing the 24-hour daily access concept.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A large ticket form
(classic proportions 2.5:1 horizontal, perceived 280×112px) slightly
elevated, with a warm neutral #95A5A6 body and charcoal #2D3436 outline at
70% opacity. Left stub: a coral #FF6B4A filled star (5-point, 28px). A
vertical dashed charcoal line divides stub from main body. Main body: three
short grey horizontal bar placeholders (text rows). Above the ticket: a
faint coral glow circle (#FF6B4A at 5% opacity, 220px diameter). Below:
a small rounded badge with coral fill containing "24h" text form (not
actual text — use a narrow rounded rectangle pair to imply it). No
characters, no hands. Soft ambient depth. 800×800px transparent PNG.
```

---

### C2 — Premium / Paywall Hero

**Status:** `assets/images/premium_header.png` — placeholder; needs AI replacement.

**Concept:** A shield with a padlock interior and premium crown, radiating quality.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A shield form
(classic heraldic proportions, perceived 200px tall) with coral #FF6B4A
fill, highlight edge in #FF8C6B, and charcoal #2D3436 outline at 70%
opacity. Inside the shield: a padlock — lock body is a small rounded
rectangle in warm white (#F8F9FA), shackle is a charcoal U-arc outline.
At the top of the shield: a 3-point crown form in premium gold #D4AF37,
outline only. Around the shield: 4 small diamond sparkle shapes in coral
at sizes 10px, 14px, 10px, 12px — positioned at the outer corners. A
faint dashed ring (#FF6B4A at 18% opacity, 260px diameter) encircles the
shield. No gradient bakes, no characters. 800×800px transparent PNG.
```

---

## SECTION D: Error State Illustrations

### D1 — Network Error

**Status:** `assets/images/error_network.png` — has dark background; replace with transparent version.

**Concept:** A broken Wi-Fi signal with a cloud and globe disconnected.

**Prompt:**
```
Soft 3D minimal illustration, TRANSPARENT background. A Wi-Fi symbol
(4 concentric arcs, top 3 in warm neutral #95A5A6, bottom arc in coral
#FF6B4A). The right half of the arcs appear cracked or split — a clean
geometric fracture line. Bottom-left: a small cloud form (outline only,
coral #FF6B4A 2px stroke). Bottom-right: a small globe form (outline,
charcoal #2D3436 at 70% opacity). Between cloud and globe: an "×" symbol
in coral, indicating disconnection. A faint dashed arc links cloud to
globe. No dark scene background. No characters. Soft ambient depth on the
Wi-Fi form. Error accent #E74C3C may appear on the fracture edge only.
800×800px transparent PNG.
```

---

## SECTION E: Technical Rendering Notes

### For AI image generators (diffusion models)

Use this checklist for every generation run:

1. Open with: `"Soft 3D minimal illustration, TRANSPARENT background (full alpha PNG), no background plate."`
2. Always name hex values explicitly: `"coral #FF6B4A"`, `"charcoal #2D3436 at 70% opacity"` — models respond to hex cues.
3. Say `"no dark background"`, `"no neon glow"`, `"no hard shadows"`, `"no gradients on fills"` — models add them by default.
4. Say `"no characters, no hands, no faces"` — models will add them otherwise.
5. Close with `"800×800px PNG with full alpha transparency"` and reference apps: `"style similar to Linear, Craft, Notion empty states"`.
6. For Midjourney add: `--no background --ar 1:1 --v 6.1 --style raw`

### For Figma AI or GPT-4o (instruction-following models)

Use the shorter instruction-imperative phrasing. These models follow directives more reliably than diffusion prose. Lead with the output specification, then constraints, then scene details.

### For a human designer / SVG workflow

- Format: SVG source + PNG export
- Background: none (transparent artboard)
- Artboard: 800×800 px
- Max stroke weight: 2px (renders cleanly at 160 dp display size)
- No raster effects, blur, or inner/outer glows
- Export: PNG @2x (1600×1600 px) for Flutter asset bundling
- Naming: `snake_case.png` matching `AppAssets` constants

---

## SECTION F: Flutter Integration Reference

### AppAssets constants (current)

```dart
// lib/core/constants/app_assets.dart

class AppAssets {
  static const String _imagesPath = 'assets/images';

  // Branding
  static const String appLogo = '$_imagesPath/linkvault_logo.webp';
  static const String appLogoPng = '$_imagesPath/linkvault_logo.png'; // launcher only

  // Onboarding
  static const String onboardingSave     = '$_imagesPath/onboarding_save.png';
  static const String onboardingOrganize = '$_imagesPath/onboarding_organize.png';
  static const String onboardingAct      = '$_imagesPath/onboarding_act.png';

  // Empty states
  static const String emptyLibrary     = '$_imagesPath/empty_library.png';
  static const String emptyCollections = '$_imagesPath/empty_collections.png';
  static const String emptySearch      = '$_imagesPath/empty_search.png';

  // Error states
  static const String errorNetwork = '$_imagesPath/error_network.png';

  // Monetization
  static const String premiumHeader      = '$_imagesPath/premium_header.png';
  static const String illustrationReward = '$_imagesPath/illustration_reward.png';

  AppAssets._();
}
```

### Recommended usage in screens

```dart
// Standard light-mode usage
Image.asset(
  AppAssets.emptySearch,
  width: 180,
  height: 180,
  fit: BoxFit.contain,
)

// With IllustrationImage (handles dark-mode filter automatically)
IllustrationImage(
  asset: AppAssets.emptySearch,
  width: 180,
  height: 180,
)
```

---

## SECTION G: Colour Token Quick Reference

Use these **exact** values in every prompt. They match `color_palette.dart` directly.

| Role | Hex | Dart constant |
|---|---|---|
| **Primary coral** | `#FF6B4A` | `AppColors.primary` |
| **Primary warm tint** | `#FF8C6B` | — (lighten primary ~30%) |
| **Dark-mode primary** | `#FF7043` | `darkPrimary` in theme |
| **Charcoal (text/outline)** | `#2D3436` | `AppColors.text` |
| **Background warm-white** | `#F8F9FA` | `AppColors.background` |
| **Surface white** | `#FFFFFF` | `AppColors.surface` |
| **Neutral mid** | `#95A5A6` | `AppColors.statusPending` |
| **Success green** | `#27AE60` | `AppColors.success` |
| **Error red** | `#E74C3C` | `AppColors.error` |
| **Premium gold** | `#D4AF37` | `AppColors.premiumGold` |
| **Warning amber** | `#F39C12` | `AppColors.warning` |

---

## SECTION H: Asset Status Tracker

| File | Screen | Style | Status |
|---|---|---|---|
| `linkvault_logo.webp` | Splash / About (in-app) | Brand mark | Active |
| `linkvault_logo.png` | Launcher icons (Android + iOS) | Brand mark | Active |
| `link_vault_logo_original.png` | Design reference only | Legacy source | Keep as reference |
| `onboarding_welcome.png` | Onboarding slide 0 | Soft 3D | Needs style-guide alignment |
| `onboarding_save.png` | Onboarding slide 1 | Soft 3D | Needs style-guide alignment |
| `onboarding_organize.png` | Onboarding slide 2 | Soft 3D | Needs style-guide alignment |
| `onboarding_act.png` | Onboarding slide 3 | Soft 3D | Needs style-guide alignment |
| `empty_library.png` | Home (no collections) | Soft 3D | Placeholder — regenerate |
| `empty_collections.png` | Collections tab | Soft 3D | Dark BG — regenerate with transparent |
| `empty_search.png` | Search tab | Soft 3D | Dark BG — regenerate with transparent |
| `error_network.png` | Network error state | Soft 3D | Dark BG — regenerate with transparent |
| `premium_header.png` | Paywall screen | Soft 3D | Placeholder — regenerate |
| `illustration_reward.png` | Ad gate screen | Soft 3D | Placeholder — regenerate |
| `empty_links.png` | Collection detail | Soft 3D | Pending (Sprint 14) |
| `empty_folders.png` | Folders tab | Soft 3D | Pending (Sprint 14) |
| `empty_search_init.png` | Search (before typing) | Soft 3D | Pending (Sprint 14) |
| `empty_rss.png` | RSS screen | Soft 3D | Pending — RSS scope activation |

---

*End of LinkVault Asset Prompts v2.1*
