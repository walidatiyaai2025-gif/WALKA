# WALKA Creative Asset Export Specification

Status: **ASSET-002 production contract**  
Tracking: #197 / #199  
Applies to: primary product cutouts, editorial composites and PDP secondary imagery created by the ASSET lane.

## 1. Objective

Create a deterministic production workflow that preserves WALKA product truth while producing compact, reusable assets for Flutter. Source photography and editable masters are never treated as runtime assets. `docs/PRODUCT_MASTER.md` remains authoritative for product geometry, variants, materials and approved claims.

The protected `Images/` directory is visual-reference material only and must not be modified by asset-production tasks.

## 2. Asset tiers and naming

### Tier A — source photography

Owner-approved original photography/listing source. Keep outside the Flutter runtime bundle. Never overwrite or destructively edit the source.

Suggested local/master naming:

`<family>_<variant>_source_<sequence>.<ext>`

Examples:

- `drawer_white_source_01.jpg`
- `lunch_blue_source_01.jpg`

### Tier B — editable master

Photoshop/PSD, PSB or equivalent layered working file. Keep outside `mobile/assets/`. Name:

`<family>_<variant>_master_vNN.psd`

Example: `drawer_white_master_v01.psd`.

### Tier C — Flutter production export

Only optimized app-ready files enter `mobile/assets/`. Canonical filenames are fixed by the existing resolver:

- `mobile/assets/products/drawer/white.png`
- `mobile/assets/products/drawer/gray.png`
- `mobile/assets/products/lunch/blue.png`
- `mobile/assets/products/lunch/pink.png`
- `mobile/assets/products/lunch/green.png`

Do not add version suffixes, spaces, alternate capitalization or marketing labels to canonical runtime filenames.

## 3. Non-destructive Photoshop master structure

Recommended top-to-bottom layer groups:

1. `00_REFERENCE_LOCKED`
   - source image as Smart Object,
   - Product Master notes/reference swatches,
   - never paint directly on this layer.
2. `10_PRODUCT_MASK`
   - vector mask or high-quality pixel mask,
   - separate submasks for difficult translucent/highlight regions if required.
3. `20_RETOUCH`
   - healing/cleanup on empty retouch layers,
   - dust/scratch removal only,
   - no geometry reconstruction.
4. `30_TONE_COLOR`
   - clipped Curves/Levels/HSL/Selective Color adjustment layers,
   - preserve material texture and variant truth,
   - no generic recolor of one physical variant into another unless owner-approved source evidence explicitly supports it.
5. `40_CONTACT_SHADOW_OPTIONAL`
   - separate shadow layer,
   - removable and never merged into the product mask.
6. `90_QA_BACKGROUNDS`
   - Ivory, White and Navy temporary check layers,
   - excluded from export.

Masks and Smart Objects are preferred over destructive erasing. Save the editable master before flattening/export.

## 4. Color-management contract

- Working/export profile: **sRGB IEC 61966-2.1**.
- Convert to sRGB rather than merely assigning the profile when a source is in another color space.
- Embed the sRGB profile in production PNGs when the export tool permits it.
- Do not use Display-P3-only output for the canonical Flutter assets.
- Product variant colors must follow `docs/PRODUCT_MASTER.md`; photography should retain believable material highlights and shadow gradients rather than being forced to a flat swatch.

## 5. Background and alpha policy

Primary product media is exported on a transparent background.

Required:

- straight, clean silhouette with no baked card or page background,
- no marketplace chrome, price, rating, CTA, navigation or UI text,
- no white fringe visible on WALKA Navy,
- no dark fringe visible on white/ivory,
- no accidental semi-transparent holes in opaque plastic or SUS304 highlights,
- internal product openings/negative spaces remain faithful to the real product.

Do not solve difficult stainless-steel highlights by lowering the entire product alpha. Preserve physical highlights as opaque/near-opaque color information and remove only the true background.

## 6. Canvas, scale and safe-area rules

### Primary canonical cutouts

- Canvas: **1024 × 1024 px**, RGBA.
- Product is visually centered, not merely bounding-box centered.
- Target longest product dimension: **88–90%** of canvas.
- Minimum transparent safe margin at the nearest edge: **5% / 51 px**.
- Prefer 6–8% where the source/camera angle permits.
- Do not crop clips, handles, expandable wings, tray edges, utensils or other product geometry required to identify the approved set.

### Variant parity

Within one product family:

- keep apparent product scale within ±3% where source photography allows,
- align the visual center and principal baseline,
- use the same 1024 × 1024 canvas,
- normalize canvas placement; **do not warp, perspective-distort or reconstruct** real geometry simply to make two photos match.

If source camera orientation materially differs, truth wins over artificial parity; document the difference in the task/PR.

## 7. Flutter fit contract

Canonical cutouts are designed for `BoxFit.contain`.

Therefore:

- the complete intended product silhouette must be inside the export canvas,
- no critical product geometry may depend on an external crop,
- transparent padding is intentional and consistent,
- screens may size/position the asset but must not require a baked card background.

## 8. Shadow policy

Default primary canonical asset: **no large photographic background shadow**.

Allowed only when it improves grounding without harming reuse:

- subtle contact shadow directly beneath the product,
- neutral/low-saturation,
- soft edge,
- opacity low enough to remain natural on white, ivory and navy,
- never a rectangular white glow or extracted source-background haze.

If a source shadow cannot be cleanly separated from a white background, remove it and let Flutter/UI provide elevation instead.

Editorial composites may use art-directed shadows because they are surface-specific, but those shadows must not be copied into the canonical cutout.

## 9. Alpha-edge cleanup procedure

At 100% and 200% zoom:

1. inspect the silhouette over White `#FFFFFF`, Ivory `#F8F6F1` and WALKA Navy `#003366`,
2. remove white matte/halo contamination,
3. remove isolated 1–2 px islands,
4. preserve intentional antialiasing,
5. inspect reflective stainless-steel rims separately,
6. inspect narrow clips, handles, expandable rails and utensil edges,
7. downscale-preview at 96, 160, 240 and 384 px to catch disappearing details.

Do not globally choke/erode the mask if it damages thin geometry. Correct local edges selectively.

## 10. Product-specific guardrails

### Drawer Organizer

- Real **8-compartment** expandable identity must remain visible/credible.
- White must keep edge separation on white/ivory without artificial dark outlines.
- Gray must come from a faithful Gray product source/treatment; do not flatten texture/shadows with a generic recolor.
- White/Gray should share canvas scale/orientation only when supported by real source views.

### Large Stainless Steel Bento Lunch Box

- Preserve the real **4-compartment SUS304 tray**.
- Preserve the PP outer-body identity and approved variant color.
- Accessories may remain when they are part of the approved source composition and help identify the sold set.
- Reflective steel requires manual highlight QA; a highlight that is white is not automatically background.
- Do not introduce visual cues or copy implying unsupported liquid/leakproof behavior.

## 11. PNG vs WebP decision

### Canonical primary product assets

Use **PNG RGBA** because:

- transparent-edge fidelity is priority,
- files are already referenced as `.png` by the resolver,
- deterministic alpha QA is easier across tooling.

Do not change the resolver to WebP merely for this asset-production task.

### Secondary/editorial imagery

WebP may be considered later only when:

- transparency/edge quality remains acceptable,
- visual comparison shows no material degradation,
- the consuming code/path explicitly supports the format,
- the change is separately reviewed.

## 12. Export optimization limits

For a 1024 × 1024 canonical PNG:

- target: **≤ 800 KB** when visually lossless optimization can achieve it,
- preferred for simple organizer cutouts: **≤ 400 KB**,
- hard quality rule: never damage reflective steel, edge antialiasing or product color merely to hit a byte target,
- strip unnecessary EXIF/editor thumbnails/private metadata,
- retain only metadata needed for correct color rendering (for example embedded sRGB profile).

Oversized source photographs and PSD/PSB masters must not be bundled under `mobile/assets/`.

## 13. Export checklist

Before committing a canonical asset:

- [ ] correct source/variant is documented,
- [ ] geometry matches Product Master,
- [ ] 1024 × 1024 RGBA,
- [ ] sRGB,
- [ ] ≥ 5% nearest-edge transparent margin,
- [ ] no baked UI/text/price/rating/background,
- [ ] no white/dark halo on White/Ivory/Navy,
- [ ] no missing steel highlights or transparent holes,
- [ ] acceptable at 96/160/240/384 px preview sizes,
- [ ] canonical filename/path exact,
- [ ] optimized file size without visible degradation,
- [ ] source/master is not bundled with Flutter.

## 14. QA receipt expected in asset PRs

Each asset PR should report:

- source filename and source type,
- final dimensions/mode,
- final file byte size,
- alpha bounding box / nearest-edge margin,
- family/variant identity check,
- light/ivory/navy visual QA result,
- small-card downscale QA result,
- known source-camera differences or blockers.

If any guardrail cannot be met from an approved source, leave the task **BLOCKED** rather than fabricating product photography.
