# WALKA Home / Landing Creative Asset Wave

Status: ASSET-041..050 execution receipt  
Parent: #214 / #209 / #197  
References: `Images/Home for Android.png`, `Images/Home for ios.png`, `Images/Home for pc.png`

## Principle

Home should be built from reusable approved product media plus Flutter layout. Do not bake headings, CTA labels, prices, ratings, navigation or benefit copy into a bitmap. The bitmap lane owns only product imagery/editorial composition that cannot be expressed cleanly from the reusable cutouts.

## ASSET-041..050

| Task | Result | Contract / output |
|---|---|---|
| ASSET-041 — Audit Home Android bitmap requirements | **PASS** | Android requires product-led hero media, Drawer/Lunch collection media and optional editorial product grouping. Header, CTA, benefit band, section headings, cards and trust strip remain Flutter UI. |
| ASSET-042 — Audit Home iOS bitmap requirements | **PASS** | Same reusable media set as Android; iOS-specific work is safe-area/crop composition, not duplicated product photography. No separate iOS-only product binary unless a reference-specific crop proves necessary. |
| ASSET-043 — Audit Home desktop bitmap requirements | **PASS** | Desktop uses the same product masters in a wider composition. Assets need focal-safe horizontal breathing room; do not generate a desktop screenshot bitmap. |
| ASSET-044 — Create Home hero asset composition spec | **PASS** | Hero may combine one Drawer and one Lunch product visual only when the reference needs a curated composition. Preferred implementation is two independent transparent assets positioned by Flutter. If a composite is required, it contains products/background only—no text/UI. |
| ASSET-045 — Create Home Drawer collection media spec | **PASS** | Use canonical White/Gray Drawer cutouts with consistent visual weight. Category card should default to White when one representative asset is required; Gray may appear only when final approved Gray photography exists. |
| ASSET-046 — Create Home Lunch collection media spec | **PASS** | Use Blue as the representative default unless product-selection state specifies Pink/Green. Keep 4-compartment tray/accessory truth; never imply liquid-proof performance. |
| ASSET-047 — Define Home editorial crop variants | **PASS** | Mobile: 4:3 or square focal box with 8–10% product breathing room. Tablet/desktop: 16:10/3:2 media windows with product center-of-mass kept inside central 70%. Avoid destructive image crops; prefer `BoxFit.contain`. |
| ASSET-048 — Define Home dark/navy-background contrast treatment | **PASS** | Product cutouts must pass #003366 surface QA. No artificial outer glow. Preserve natural edge contrast; subtle contact shadow may be UI-side, not baked into the canonical cutout. |
| ASSET-049 — Define Home retina/high-DPI export set | **PASS** | Canonical 1024×1024 primary cutouts are sufficient for current Flutter media usage. Do not create redundant @2x/@3x files unless later measured quality/decode evidence shows a need. Flutter cache width remains the first performance control. |
| ASSET-050 — Home visual QA/release receipt | **BLOCKED ON PRIMARY ASSETS** | Home composition contract is complete, but final reference-vs-APK PASS waits for approved five-variant production media and a validated APK. |

## Home asset map

| Surface | Product media | Bitmap required? | Notes |
|---|---|---:|---|
| Hero | Drawer + Lunch reusable cutouts | Prefer **NO** composite | Flutter positions product media around live text/CTA. |
| Drawer collection card | Drawer White/Gray | NO extra bitmap | Canonical cutout solves this surface. |
| Lunch collection card | Lunch Blue/Pink/Green | NO extra bitmap | Canonical cutout solves this surface. |
| Small Changes editorial module | Approved cutouts over designed surface | MAYBE | Create a composite only if layered Flutter composition cannot match the reference cleanly. |
| Benefit/trust bands | none | NO | Icons/text stay vector/Flutter. |

## Responsive focal policy

- 320×568: product must remain legible without extending beneath finite-width CTA copy.
- 390×844: hero can increase product media height while keeping product center inside the upper/middle visual field.
- 430×932: preserve the same hierarchy; do not enlarge product until it dominates editorial copy.
- iOS: all media remains visually clear after top/bottom safe-area spacing.
- Desktop 1280/1440: use wide content grid; hero media may occupy 40–55% of the hero row but copy remains bounded for readable line length.

## Release checks

1. Hero and collection products resolve through stable variant IDs.
2. No fallback appears on normal owner-visible Home paths once the matching approved file exists.
3. Product geometry is fully visible under `BoxFit.contain`.
4. No text or price/rating copy is embedded in the bitmap.
5. Navy/ivory/white contrast is visually clean.
6. Android/iOS/desktop references are compared at matching viewport classes.
7. Flutter Analyze, tests and Android release APK are Green before ASSET-050 becomes PASS.
