# WALKA Creative Asset Production Standard

Status: production standard for ASSET-011..020  
Parent: #209 / #197 / #210  
Product truth: `docs/PRODUCT_MASTER.md`  
Visual references: protected `Images/` directory  
Flutter media contract: `docs/ui/PRODUCT_MEDIA_MANIFEST.md`

## Purpose

This document defines the repeatable production workflow for every WALKA bitmap/vector asset created for the Flutter application. It separates protected UI references, editable creative masters and optimized Flutter exports. Product geometry, facts and approved colors must never be inferred from a mockup when they conflict with `docs/PRODUCT_MASTER.md`.

---

## ASSET-011 — Creative source inventory schema

Every candidate source must be recorded before editing with these fields:

| Field | Required | Meaning |
|---|---:|---|
| Source ID | yes | Stable short identifier, e.g. `SRC-LUNCH-BLUE-001` |
| Source path | yes | Repository path or owner-provided source location |
| Product family | yes | Drawer Organizer / Lunch Box / Brand / UI decorative |
| Variant | when applicable | White, Gray, Blue, Pink, Green |
| Source type | yes | product photo / reference screen / logo / vector / screenshot / owner master |
| Intended outputs | yes | canonical asset(s) the source may generate |
| Geometry confidence | yes | HIGH / MEDIUM / LOW |
| Color confidence | yes | HIGH / MEDIUM / LOW / N/A |
| Resolution | yes | pixel dimensions when known |
| Background | yes | transparent / solid / lifestyle / unknown |
| Rights/approval | yes | owner-approved / pending / unknown |
| Notes | optional | crop, reflections, occlusion, missing accessories, etc. |

A full-screen UI screenshot is normally a **reference source**, not automatically an approved reusable product-photography source.

---

## ASSET-012 — Source approval states

Only these states are valid:

### `APPROVED`
The source can be used to produce a specified app asset. Requirements:
- ownership/use approval is known;
- product/variant mapping is unambiguous;
- geometry is faithful to Product Master;
- the visible view is sufficiently complete for the target asset;
- color can be retained or calibrated without inventing material detail.

### `BLOCKED`
Do not create the target asset yet. Use when:
- source identity is unknown;
- product is materially occluded/cropped;
- required side/detail view does not exist;
- resolution is too weak for a clean cutout;
- geometry conflicts with Product Master;
- rights/owner approval are unclear.

The block note must state the exact missing source required, for example: `Need front 3/4 Blue Lunch image with complete clips and tray visible, minimum ~1600 px long side.`

### `REPLACE`
A technically usable source exists but a better source is required before stable release due to low resolution, color cast, compression, inaccurate variant color or poor angle. `REPLACE` may be used for prototype comparison only; it must not silently become the stable production master.

No fourth informal approval state is allowed.

---

## ASSET-013 — Non-destructive Photoshop layer naming

Editable masters must use a predictable group structure. Equivalent layer-capable software may be used, but the conceptual structure is mandatory.

```text
00_REFERENCE_LOCKED/
  source-original
  geometry-guides
01_PRODUCT_SMART_OBJECT/
  product-base
02_MASKING/
  primary-mask
  edge-refine
  hole-interior-masks
03_COLOR_MATERIAL/
  neutral-correction
  approved-variant-color
  metal-preservation
  highlight-control
04_RETOUCH/
  dust-defects
  compression-cleanup
05_LIGHT_SHADOW/
  highlight-recovery
  contact-shadow-preview
06_EXPORT_CHECKS/
  white-bg-check
  ivory-bg-check
  navy-bg-check
  alpha-fringe-check
99_GUIDES_NOT_EXPORT/
  safe-area
  optical-center
  crop-guides
```

Rules:
- Original source is never painted over destructively.
- Masks remain editable.
- Adjustment layers are preferred over destructive color transforms.
- Reference/check layers are disabled before production export.
- No UI text, price, ratings, buttons or navigation are baked into reusable product cutouts.

---

## ASSET-014 — Smart-object policy

The canonical product source layer must remain a Smart Object (or equivalent linked/non-destructive object).

Requirements:
1. Scale/rotate the product through the Smart Object transform rather than resampling the raster repeatedly.
2. Variant color treatment must be adjustment-based where possible; never flatten the only editable master.
3. Drawer White/Gray siblings should share the same framing template when source angle permits.
4. Lunch Blue/Pink/Green siblings should share one framing template and camera orientation when source material permits.
5. Perspective changes that alter real geometry are prohibited.
6. Generative fill may not invent missing clips, compartments, tray geometry, accessories, handles, materials or product edges.
7. Any owner-approved retouch that reconstructs a tiny damaged edge must remain visually and mechanically faithful to the source and Product Master.

---

## ASSET-015 — Color-management and export policy

### Working/output color space
- App-ready raster exports: **sRGB IEC61966-2.1**.
- Embed/convert to sRGB before final export.
- Do not ship Display P3-only assets as the sole production raster unless a future explicit cross-platform color pipeline is added.

### WALKA brand colors
- Deep Navy: `#003366`.
- Muted Gold: `#D4AF37`.

### Product colors
Product colors are controlled by `docs/PRODUCT_MASTER.md`, including:
- Lunch Blue — PANTONE 4155 U.
- Lunch Pink — PANTONE 9242 U.
- Lunch Green — PANTONE 6198 U.

Pantone references are appearance targets, not permission to replace real material shading with a flat solid color. Preserve highlights, shadows, texture and PP/stainless material separation.

### White/Gray Drawer
- White must keep enough local contrast to remain visible on warm ivory/white UI surfaces.
- Gray must preserve molded-plastic depth and cannot be produced as a featureless monochrome recolor.

---

## ASSET-016 — Transparent alpha-edge cleanup standard

Primary reusable product cutouts use transparent backgrounds unless the task explicitly requires an editorial/lifestyle composite.

QA procedure:
1. Inspect at 100% and 200% against pure white.
2. Inspect against WALKA warm-ivory/light surface.
3. Inspect against WALKA navy `#003366`.
4. Check corners, clips, tray edges, thin utensil edges and organizer divider gaps.
5. Remove white/black matte halos.
6. Preserve intentional soft material edges and true antialiasing.
7. Do not erode the mask enough to make the product visibly smaller.
8. No isolated alpha specks outside the product footprint.

Automatic background removal is only a starting mask. Final edge acceptance is visual.

---

## ASSET-017 — Product canvas, padding and framing standard

Canonical reusable cutouts must be visually stable when rendered through Flutter `BoxFit.contain`.

### Master framing rules
- Product optical center should sit near canvas center; compensate for asymmetric accessories visually rather than by changing product scale per screen.
- Default transparent safe padding: **8–12% of canvas width/height** around the visible product where possible.
- No product edge may touch the canvas boundary.
- Preserve complete geometry; do not crop clips, expanded drawer edges, utensils, sauce cup or bag when those elements are part of the selected composition.
- Sibling variants must use the same export canvas dimensions and comparable visible-product occupancy.

### Primary production target
- Default long-side target for reusable primary cutout: approximately **1600 px** unless source resolution or measured Flutter usage justifies a smaller size.
- The application resolver currently bounds decode/cache width; do not bundle unnecessarily huge marketing masters.

### Surface-specific derivations
Generate separate derived assets only when a different crop/composition is genuinely required. Do not duplicate the same bitmap under multiple filenames merely for screen ownership.

---

## ASSET-018 — Shadow and contact-shadow policy

Reusable canonical product cutouts should normally contain **no large baked card shadow or environment background**.

Allowed:
- a subtle physically plausible contact shadow tightly attached to the product when the reference composition requires grounding and the same shadow works on all intended surfaces;
- retained real self-shadow/reflection that belongs to the photographed object.

Not allowed:
- dramatic floating drop shadows inconsistent across variants;
- baked rounded cards, gradients or UI panels;
- a shadow that becomes a visible gray rectangle on transparent export;
- separate lighting styles for sibling color variants.

Prefer Flutter/card elevation for UI-surface shadow. Prefer product asset shadow only when it represents product grounding rather than UI chrome.

---

## ASSET-019 — Responsive focal-safe-area policy

For any editorial composite or non-transparent hero image, record a focal-safe rectangle.

### Safe-area goals
- Compact phone: critical product content remains visible in a center-biased ~70% width / ~70% height zone.
- Standard/large phone: composition may breathe outward but must preserve the same product focal center.
- iOS: no important pixels depend on top status/notch or bottom home-indicator regions.
- Desktop: wide crops may add negative space; never scale/crop the product until mechanical geometry disappears.

If one bitmap cannot survive both phone and desktop crops without losing hierarchy, create explicit mobile and wide derivatives from the same approved master and record them in the Creative Asset Manifest.

Text belongs in Flutter whenever possible; do not create bitmap text merely to solve responsive layout.

---

## ASSET-020 — PNG/WebP and file-size budget matrix

### Format decision
| Asset type | Preferred format | Reason |
|---|---|---|
| Primary product cutout with alpha | PNG | predictable lossless alpha/edge quality |
| Small decorative illustration with alpha | PNG or lossless WebP after QA | choose smaller artifact-free output |
| Photographic editorial background without critical alpha | WebP where Flutter/platform QA is green | substantial size saving |
| Logo/vector mark | SVG where existing pipeline supports it | crisp scalable geometry |
| Source/master artwork | never bundled as app asset | editing source only |

### Initial size budgets
These are review thresholds, not a license to destroy quality:
- Primary transparent product cutout: target **≤ 900 KB** each; investigate anything > 1.2 MB.
- Search/category thumbnail derivative, if a distinct derivative is justified: target **≤ 250 KB**.
- Editorial mobile composite: target **≤ 600 KB**.
- Editorial desktop/wide composite: target **≤ 900 KB**.
- Small empty/decorative illustration: target **≤ 180 KB**.

### Optimization order
1. Remove unused transparent canvas.
2. Ensure dimensions match real rendering needs.
3. Lossless PNG optimization for alpha cutouts.
4. Evaluate WebP for photographic composites.
5. Compare edge fidelity, product color and material texture before accepting smaller output.

Never reduce size by changing product geometry, smearing compartment edges or clipping accessories.

---

## Production export naming

The five primary canonical filenames remain fixed by the existing resolver:

```text
mobile/assets/products/drawer/white.png
mobile/assets/products/drawer/gray.png
mobile/assets/products/lunch/blue.png
mobile/assets/products/lunch/pink.png
mobile/assets/products/lunch/green.png
```

Secondary assets must use descriptive lowercase kebab-case and live under the product family directory or a clearly documented subdirectory. Avoid dates, UUIDs, `final-final`, designer initials or screen names when the asset is reusable.

---

## Mandatory pre-release checklist

A production asset is eligible for stable integration only when all applicable items pass:

- [ ] Source recorded in Creative Asset Manifest.
- [ ] Source state is APPROVED.
- [ ] Product/variant mapping is unambiguous.
- [ ] Product geometry matches Product Master.
- [ ] Approved product color/material appearance preserved.
- [ ] Editable master is non-destructive.
- [ ] Alpha edges pass white/ivory/navy inspection.
- [ ] Canvas/framing matches sibling variants.
- [ ] No baked unsupported UI text/claims/prices/ratings.
- [ ] Correct canonical filename/path.
- [ ] File-size budget checked.
- [ ] Flutter `BoxFit.contain` presentation checked on relevant surfaces.
- [ ] Reference-vs-app comparison recorded.
- [ ] Analyze/tests/release APK remain Green after owner-visible integration.

## Completion mapping

This document completes the production-standard deliverables for:
- ASSET-011 source inventory schema.
- ASSET-012 source approval states.
- ASSET-013 Photoshop layer naming.
- ASSET-014 Smart Object policy.
- ASSET-015 sRGB/color management.
- ASSET-016 transparent alpha cleanup.
- ASSET-017 canvas/padding/framing.
- ASSET-018 shadow policy.
- ASSET-019 responsive focal-safe areas.
- ASSET-020 PNG/WebP/file-size budgets.
