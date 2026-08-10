# WALKA Creative Asset Primary Production Wave

Status: ASSET-021..040 execution receipt  
Parent: #213 / #209 / #197  
Product truth: `docs/PRODUCT_MASTER.md`  
Production standard: `docs/ui/CREATIVE_ASSET_PRODUCTION_STANDARD.md`

## Purpose

This wave converts the admitted owner sources into explicit production decisions for the two Drawer variants and three Lunch Box variants. A task may complete with a `BLOCKED` or `FAIL/REWORK` result when the source or current extraction cannot satisfy the production standard. That is preferable to fabricating geometry or shipping damaged alpha masks.

## Current source truth

| Variant | Admitted source | Source decision |
|---|---|---|
| Drawer White | `51yxoCdmqrL._AC_SL1500_(1).jpg` | APPROVED — expanded real-product source |
| Drawer Gray | `IMG-20250919-WA0035.jpg` | PARTIAL — real Gray source, collapsed presentation only |
| Lunch Blue | `main new(3).jpg` | APPROVED |
| Lunch Pink | `1000389975.jpg` | APPROVED WITH CLEAN PRODUCT-PANEL CROP |
| Lunch Green | `WhatsApp Image 2026-02-24 at 11.22.34 PM.jpeg` | APPROVED — different camera/layout from Blue/Pink |

No source may override Product Master facts. Drawer remains an 8-compartment expandable organizer. Lunch remains a 4-compartment SUS304 tray with PP outer body, 4 clips/silicone gasket and the approved accessory set/colorways.

## ASSET-021..030 — Drawer Organizer

| Task | Result | Execution receipt |
|---|---|---|
| ASSET-021 — Drawer White source-selection receipt | **PASS** | `51yxoCdmqrL._AC_SL1500_(1).jpg` selected as the only admitted expanded White primary source. |
| ASSET-022 — Drawer White geometry cleanup plan | **PASS** | Preserve the real expanded outline and all 8 compartments. Allowed operations: non-destructive crop, neutral-background removal, minor tonal cleanup, alpha refinement and canvas normalization only. No compartment rebuilding or shape warping. |
| ASSET-023 — Drawer White alpha-mask QA | **FAIL / REWORK** | Current 1024×1024 extraction candidate preserves the silhouette but edge cleanup is not yet stable enough to be called canonical. Re-cut from the approved source using object-aware/manual masking rather than broad luminance removal. |
| ASSET-024 — Drawer White tonal separation on ivory | **PASS WITH REWORK NOTE** | The product remains distinguishable on warm ivory when the original edge/shadow information is retained. Do not brighten the body to pure #FFFFFF or erase the shallow molded edge contrast. |
| ASSET-025 — Drawer White tonal separation on navy | **FAIL / REWORK** | Current extraction exposes edge/mask damage on WALKA navy. Final export must preserve real light-gray edge transitions and remove white-background contamination without clipping product highlights. |
| ASSET-026 — Drawer Gray source-selection receipt | **PASS / PARTIAL SOURCE** | `IMG-20250919-WA0035.jpg` is valid Gray material/color truth, but only the collapsed presentation is visible. |
| ASSET-027 — Drawer Gray geometry cleanup plan | **PASS** | Preserve the photographed collapsed geometry exactly. No expansion reconstruction, no copying White geometry and recoloring it. If an expanded Gray source is later admitted, use that source for parity. |
| ASSET-028 — Drawer Gray alpha-mask QA | **BLOCKED** | Canonical Gray export remains blocked because the required final presentation is unresolved. Alpha QA starts only after an owner-approved canonical Gray source/presentation is admitted. |
| ASSET-029 — Drawer sibling framing parity | **BLOCKED** | White is expanded while current Gray source is collapsed. Matching scale by canvas normalization is allowed, but pretending the two geometries match is not. |
| ASSET-030 — Drawer primary cutout pair release receipt | **BLOCKED** | White needs mask rework and Gray lacks an approved expanded source/presentation. Resolver fallback remains the safe stable behavior. |

### Drawer canonical target

- `mobile/assets/products/drawer/white.png`
- `mobile/assets/products/drawer/gray.png`
- 1024×1024 RGBA PNG primary target.
- Minimum 5% transparent safe margin where geometry permits.
- `BoxFit.contain` compatible; never crop side wings or compartment edges.

## ASSET-031..040 — Lunch Box

| Task | Result | Execution receipt |
|---|---|---|
| ASSET-031 — Lunch Blue source-selection receipt | **PASS** | `main new(3).jpg` admitted as the primary Blue source. It shows the 4-compartment stainless tray, outer component, lid/bag and accessories on a clean listing background. |
| ASSET-032 — Lunch Blue master geometry cleanup plan | **PASS** | Preserve all real product/set components. Extract the set as one coherent composition unless a future gallery task explicitly creates component-specific derivatives. Do not erase stainless highlights as background. |
| ASSET-033 — Lunch Blue approved-color calibration | **PASS / SOURCE-LOCKED** | Blue body/bag treatment must remain source-faithful and visually consistent with the Product Master Blue reference (PANTONE 4155 U). No hue shift is allowed merely to match another mockup. |
| ASSET-034 — Lunch Pink source-selection receipt | **PASS** | `1000389975.jpg` admitted only through the clean product-image panel. Marketplace chrome/title/rating/UI pixels are excluded from any derivative. |
| ASSET-035 — Lunch Pink approved-color calibration | **PASS / SOURCE-LOCKED** | Preserve the real Pink source color and use Product Master PANTONE 9242 U as the approval reference. Avoid clipping pale pink edges into the background. |
| ASSET-036 — Lunch Green source-selection receipt | **PASS** | `WhatsApp Image 2026-02-24 at 11.22.34 PM.jpeg` admitted as the real Green source. |
| ASSET-037 — Lunch Green approved-color calibration | **PASS / SOURCE-LOCKED** | Preserve real Green material/color; Product Master PANTONE 6198 U is the approval reference. Canvas/framing normalization is permitted; geometry reconstruction is not. |
| ASSET-038 — Lunch 3-color framing/orientation parity | **BLOCKED / NORMALIZATION REQUIRED** | Blue/Pink are compositionally closer; Green uses a different camera/layout. Target parity is equal visual weight, center of mass and safe padding, not fake camera-angle reconstruction. |
| ASSET-039 — Lunch stainless/accessory detail preservation QA | **FAIL / REWORK** | Broad white-background removal damages bright stainless and utensil highlights. Final masks must be object-aware/manual and keep the full 4-compartment tray, sauce cup, fork/spoon and visible clips/bag details. |
| ASSET-040 — Lunch primary cutout trio release receipt | **BLOCKED** | Sources are admitted, but current extraction quality is not eligible for `main`. Do not publish until stainless/highlight alpha QA passes on White, Ivory and Navy backgrounds. |

### Lunch canonical targets

- `mobile/assets/products/lunch/blue.png`
- `mobile/assets/products/lunch/pink.png`
- `mobile/assets/products/lunch/green.png`
- Primary target: 1024×1024 RGBA PNG.
- Preserve real 4-compartment SUS304 tray geometry and visible accessory set.
- The final edge mask must distinguish bright stainless/white accessories from the original background; luminance-keying alone is prohibited.

## Masking correction required before binary ingest

The latest local extraction review found a repeatable failure mode: white-background removal was treating bright stainless, cutlery and white accessory highlights as background. This creates holes and missing detail that become obvious on WALKA navy. The next production pass must use one of:

1. object-aware selection followed by manual mask cleanup,
2. path/pen-tool treatment around hard product boundaries plus selective soft masks for reflections,
3. channel-assisted masking only when manually protected highlight regions are restored.

A candidate is rejected if the Navy test surface reveals missing tray walls, missing utensils, clipped white lid components, or halo/fringe contamination.

## Exit criteria

The wave is release-complete only when:

- White Drawer mask passes White/Ivory/Navy inspection;
- Gray canonical presentation is owner-approved and has a faithful source;
- Blue/Pink/Green Lunch masks preserve stainless and accessory detail;
- sibling variants have comparable visual weight without geometry fabrication;
- all five exact canonical paths exist and pass the repository production-asset verifier;
- Flutter Analyze, full tests and Android release APK are Green after integration.
