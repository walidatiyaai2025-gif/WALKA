# WALKA Creative Asset Export Specification

Status: **normative ASSET-002 authoring/export handoff**  
Parent: #199 / #392 / #197 / #230  
Product truth: `docs/PRODUCT_MASTER.md`  
Source/admission truth: `docs/ui/PRODUCTION_SOURCE_ADMISSION.json`  
Executable runtime admission: `mobile/tool/src/pav_models.dart`, `mobile/tool/src/png_asset_inspector.dart`, `mobile/tool/src/production_asset_validator.dart`

## 1. Precedence and purpose

This is the exact ASSET-002 deliverable for creative masters and Flutter-ready exports. It reconciles the original Photoshop/export requirements with the production admission validator currently enforced before stable APK publication.

When sources disagree, use this precedence:
1. `docs/PRODUCT_MASTER.md` controls product identity, geometry, material facts and approved colors.
2. Explicit owner source/visual decisions control source suitability and visual acceptance.
3. The executable PAV code controls the technical runtime PNG admission contract.
4. This specification and `CREATIVE_ASSET_PRODUCTION_STANDARD.md` describe the authoring workflow that must produce those valid runtime assets.
5. Protected `Images/` screens are read-only visual references, never automatic product-photo sources.

A documentation statement may not weaken a fail-closed executable rule. If PAV constants change, update this document in the same change.

## 2. Source/master separation and naming

Never edit a protected reference or the sole source destructively.

Recommended design-source layout:

```text
design-sources/
  drawer-organizer/
    white/
    gray/
  lunch-box/
    blue/
    pink/
    green/
```

Editable master names should use stable descriptive names such as:

```text
drawer-organizer-white-master.psd
lunch-box-blue-master.psd
```

Do not use UUIDs, dates, designer initials, `final-final`, or a screen name for a reusable product master. Source/master artwork is not bundled into Flutter.

The five canonical runtime product exports are fixed:

```text
mobile/assets/products/drawer/white.png
mobile/assets/products/drawer/gray.png
mobile/assets/products/lunch/blue.png
mobile/assets/products/lunch/pink.png
mobile/assets/products/lunch/green.png
```

Inside the `mobile` working directory PAV sees the corresponding paths as `assets/products/...`.

## 3. Non-destructive master structure

Photoshop or equivalent layer-capable tooling must preserve an editable source and masks. Use this conceptual structure:

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
- Keep the product base as a Smart Object/equivalent non-destructive object.
- Keep masks editable.
- Prefer adjustment layers for tonal/color work.
- Never use perspective changes to alter real geometry.
- Never reconstruct missing compartments, clips, tray sections, accessories, handles or organizer expansion from imagination.
- Never create Gray by generic recoloring of White when the required Gray presentation is unsupported by a real approved source.
- Never treat automated Pink cleanup or mechanical VPROOF as owner visual acceptance.

## 4. Color management

App-ready raster exports must carry **sRGB or iCCP color-profile metadata**. Working masters may use a broader internal workflow, but the Flutter export must be converted/tagged for the runtime contract.

Brand anchors:
- WALKA navy: `#003366`
- WALKA gold: `#D4AF37`

Product color truth remains in Product Master, including:
- Lunch Blue — PANTONE 4155 U
- Lunch Pink — PANTONE 9242 U
- Lunch Green — PANTONE 6198 U

Pantone targets do not permit flat recoloring. Preserve real highlights, shadows, molded PP texture, stainless separation and photographed material depth.

## 5. Canonical runtime PNG contract

The current executable PAV contract is normative for primary product cutouts:

| Property | Required runtime value |
|---|---|
| Format | PNG |
| Canvas | **1024 × 1024 px** |
| Bit depth | **8-bit** |
| Color type | **RGBA / PNG color type 6** |
| Compression method | 0 |
| Filter method | 0 |
| Interlace | **none / method 0** |
| Color metadata | **sRGB or iCCP required** |
| Transparent pixels | required |
| Outer perimeter | **fully transparent** |
| Visible content | required |
| Safe margin | **at least floor(5%) on every side** |
| Hard file ceiling | **1,258,291 bytes (1.2 MiB)** |
| Text metadata chunks | not allowed |
| Animation chunks | not allowed |
| Unsupported critical chunks | not allowed |

### Master resolution vs runtime resolution

The editable source/master may be larger than 1024 px and should retain enough native information for clean masking. Historical guidance that mentioned ~1600 px is a **source/master quality target only**. It is **not** the canonical Flutter primary-cutout size. The current runtime export must be exactly 1024×1024 while the PAV constants remain 1024×1024.

## 6. Canvas, framing and padding

For a canonical primary cutout:
- Preserve the entire selected product composition; do not crop real product geometry to hit a visual ratio.
- Keep every visible edge off the canvas boundary.
- PAV requires at least `floor(5%)` transparent safe margin on each side. On a 1024 canvas this is a minimum of **51 px**.
- An authoring target of roughly 8–12% breathing room is preferred where the real source/composition permits it, but the enforceable minimum is 5% on each side.
- Keep optical center reasonably centered; PAV emits a warning when normalized X or Y optical-center offset exceeds 0.16.
- Sibling variants in one family must use one canonical canvas size. PAV blocks sibling canvas mismatch.
- PAV warns when sibling visible-area scale ratio exceeds 1.35; treat that as a mandatory visual-review item before owner acceptance.
- Byte-identical canonical binaries across released variants are blocked as a duplicate-production error.

## 7. Alpha-edge cleanup

Primary reusable product cutouts use transparent backgrounds.

Required review surfaces:
1. pure white,
2. WALKA warm ivory/light surface,
3. WALKA navy `#003366`,
4. common downscaled product sizes where applicable.

Inspect clips, organizer dividers, thin utensil edges, stainless edges, holes and semi-transparent antialiasing. Remove white/black matte contamination without shrinking the real silhouette or flattening material texture.

A background-removal tool may create an initial mask, but automated output is never sufficient by itself for final visual acceptance.

## 8. Shadow policy

Canonical reusable product cutouts must not contain UI-card backgrounds, large baked shadows, gradients, prices, ratings, badges, buttons or navigation.

A subtle source-faithful contact shadow may be retained only when it belongs to the product grounding and works consistently on all intended surfaces. Prefer Flutter UI elevation for card/surface shadow.

## 9. Format and compression policy

Primary product cutout: lossless PNG under the runtime contract above.

Other asset classes may use:
- PNG or lossless WebP for small alpha illustrations after QA,
- WebP for photographic editorial backgrounds when platform QA is green,
- SVG for supported vector branding.

Do not create screen-specific duplicate bitmaps when Flutter can reuse one admitted product asset with `BoxFit.contain`.

Optimization order:
1. use the correct runtime dimensions,
2. remove unnecessary transparent excess while preserving safe margin,
3. losslessly optimize PNG,
4. remove prohibited metadata,
5. verify edge/color/material fidelity again.

Never reduce bytes by smearing edges, clipping accessories or changing real geometry.

## 10. Source admission and visual decisions

A technically valid PNG is not automatically an approved production asset. Stable admission also requires the variant source row to be APPROVED and `canonicalExportPresent=true` at the exact canonical path.

Current fail-closed examples:
- Drawer Gray remains blocked until a faithful approved expanded Gray source exists or the owner explicitly approves the collapsed Gray presentation. No White recolor or hidden-geometry reconstruction.
- Lunch Pink clean candidate remains review-only until the explicit owner receipt accepts the exact bound candidate and admission is separately reconciled.

Do not change these states merely to make PAV green.

## 11. Mandatory release handoff

Before an owner-visible stable publication can use a new primary asset, all applicable checks must pass:

- source recorded and correctly mapped;
- source explicitly APPROVED;
- `canonicalExportPresent=true` only after the exact export exists;
- Product Master geometry/material/color truth preserved;
- exact canonical path;
- 1024×1024, 8-bit RGBA, valid PNG structure;
- sRGB/iCCP metadata;
- transparent pixels and fully transparent perimeter;
- ≥51 px safe margin on every side at 1024×1024;
- ≤1,258,291 bytes;
- no prohibited text/animation/critical chunks;
- no duplicate canonical binary across released variants;
- sibling framing/canvas review complete;
- White/Ivory/Navy edge review complete;
- relevant responsive `BoxFit.contain` presentation reviewed;
- owner visual decision complete where explicitly required;
- Flutter Analyze, full tests, media/readiness gates and release APK build Green;
- stable publication owner gate independently authorizes release.

## 12. Drift-control contract

`mobile/test/creative_asset_export_spec_contract_test.dart` binds this document to current PAV constants and canonical paths. If the executable validator changes its canvas, budget or released-primary path set, CI must fail until this specification is updated in the same change.

This file completes the exact ASSET-002 documentation deliverable; it does not admit Gray/Pink, mutate product assets, or authorize stable publication.
