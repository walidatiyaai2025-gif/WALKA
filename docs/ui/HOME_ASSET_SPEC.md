# WALKA Home / Landing Production Media Contract

Tracking: #209 / #214  
Tasks: ASSET-041..050  
References: `Images/Home for Android.png`, `Images/Home for ios.png`, `Images/Home for pc.png`  
Implementation checklist: `docs/ui/REFERENCE_ELEMENT_CHECKLISTS.md`  
Product truth: `docs/PRODUCT_MASTER.md`

## Objective

Define exactly which image assets the Home experience may need, which content must remain Flutter-native, how reusable Drawer/Lunch product media should be framed, and how one approved master survives Android, iOS and desktop compositions without baking UI into bitmaps.

## ASSET-041 — Android bitmap requirements audit

The Android Home reference requires product-dominant media but does not justify baking whole sections into screenshots. Production image needs are limited to:
- Drawer primary product cutout;
- Lunch primary product cutout;
- optional editorial hero composite only if the reference hierarchy cannot be reproduced from reusable cutouts + Flutter surfaces;
- no bitmap for headings, CTA buttons, benefit strip, trust strip, navigation or section labels.

Android production status: **BLOCKED on canonical Drawer/Lunch cutouts**. Existing painted fallback remains valid until approved product binaries are admitted.

## ASSET-042 — iOS bitmap requirements audit

The iOS reference uses the same product families and product truth. iOS does **not** receive different product photography solely because of platform. Reuse the same canonical cutouts and change layout/safe-area treatment in Flutter.

Create an iOS-specific bitmap only when the approved reference needs a materially different editorial crop that cannot be achieved with `BoxFit.contain`/layout positioning without clipping product geometry.

## ASSET-043 — Desktop bitmap requirements audit

Desktop Home must not stretch phone artwork. Preferred hierarchy:
1. same transparent product cutouts;
2. desktop Flutter grid/wide shell;
3. wide editorial derivative only when reference composition demands extra negative space or product grouping.

A desktop derivative must come from the same approved master. Do not upscale a phone crop.

## ASSET-044 — Home hero composition specification

Preferred hero construction:
- Flutter renders ivory/navy surfaces, typography, CTA and responsive spacing;
- transparent approved product cutout occupies media zone;
- optional decorative accent remains abstract/non-product and may use gold line/shape treatment;
- product must remain fully visible with `BoxFit.contain` and 8–12% safe canvas padding;
- no prices, ratings, badges or unsupported product counts inside the bitmap.

If a combined Drawer + Lunch editorial hero is required, both products must come from approved canonical masters and use coherent lighting, apparent scale and perspective. Do not imply that the products are physically the same size.

## ASSET-045 — Drawer collection media specification

Use canonical `assets/products/drawer/white.png` or the currently selected released Drawer variant through the resolver. Collection imagery must:
- communicate the expandable 8-compartment organizer identity;
- preserve complete outer geometry;
- avoid baked category text;
- remain readable on warm ivory/light cards;
- use the same optical center and scale policy as Search/Favorites/PDP thumbnails.

## ASSET-046 — Lunch collection media specification

Use canonical Lunch variant cutout through the resolver. Collection imagery must preserve:
- product structure;
- 4-compartment stainless tray when visible in the admitted source;
- authentic PP/stainless material separation;
- approved color identity;
- no visual treatment implying full leakproof or per-compartment leakproof behavior.

## ASSET-047 — Editorial crop variants

Only two crop classes are permitted unless a later reference proves another need:
- `mobile`: center-biased product focal area, safe for compact/standard/large phone widths;
- `wide`: desktop/tablet derivative with intentional negative space.

Do not create Android and iOS duplicates when the pixels are identical. Prefer one mobile derivative and platform-specific Flutter positioning.

## ASSET-048 — Navy/dark-background contrast treatment

When product art sits on WALKA navy `#003366`:
- remove white matte halos;
- preserve real rim highlights rather than drawing an artificial outline;
- White Drawer may use a very restrained contact shadow/highlight only if needed to separate its silhouette;
- dark molded/shadow regions must remain distinguishable from the background;
- gold decorative accents must not merge visually into product edges.

## ASSET-049 — High-DPI export strategy

Flutter should normally receive one adequately sized source per logical asset rather than manually duplicated `@2x/@3x` variants. Default reusable primary cutout long side: about 1600 px where source quality supports it. Let the resolver/cache-width contract bound decode cost.

Create density-specific derivatives only if measured rendering/quality proves a real need. Do not bundle duplicate pixel-equivalent exports.

## ASSET-050 — Home visual release checklist

A Home asset wave is releasable only when:
- [ ] Drawer/Lunch source state is APPROVED.
- [ ] Canonical cutouts exist at resolver paths.
- [ ] Android compact/standard/large layouts preserve full product geometry.
- [ ] iOS safe-area composition does not force destructive crop.
- [ ] Desktop uses wide layout, not a stretched phone image.
- [ ] Product lighting/scale is coherent across hero and collection cards.
- [ ] No bitmap contains Flutter UI text/buttons/prices/ratings/navigation.
- [ ] White/ivory/navy edge QA passes.
- [ ] Product Master facts remain authoritative.
- [ ] Home screenshot comparison is recorded before stable release.
- [ ] Flutter Analyze/tests/release APK remain Green after integration.

## Status summary

ASSET-041..049 production contracts are defined. ASSET-050 checklist is defined but final PASS remains dependent on approved real product cutouts and an integrated APK screenshot comparison.
