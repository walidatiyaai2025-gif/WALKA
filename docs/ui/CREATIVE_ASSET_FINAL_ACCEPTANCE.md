# WALKA Final Creative Asset Acceptance

Status: ASSET-101..110 execution receipt  
Parent: #220 / #209 / #197  
Cross-device source: `docs/ui/QA_ACCEPTANCE_MATRIX.md`

This document is the final creative-asset review gate. Checklist creation can complete before binaries are integrated; any result that depends on real production media or a stable APK remains `BLOCKED` until objective evidence exists.

## ASSET-101..110

| Task | Result | Contract / output |
|---|---|---|
| ASSET-101 — Reference-vs-APK Home comparison checklist | **PASS / CHECKLIST READY** | Compare Android/iOS/Desktop Home hierarchy, hero/product scale, collection media, navy/gold contrast, safe areas and no fallback once approved assets exist. |
| ASSET-102 — Reference-vs-APK Categories/Search comparison checklist | **PASS / CHECKLIST READY** | Compare Android/iOS discovery hierarchy, category/product media scale, query/filter states and compact behavior. PC exact parity remains reference-blocked. |
| ASSET-103 — Reference-vs-APK PDP comparison checklist | **PASS / CHECKLIST READY** | Compare Android/iOS gallery scale, selected variant, product identity, sticky Amazon CTA separation and fullscreen media behavior. PC exact parity remains reference-blocked. |
| ASSET-104 — Reference-vs-APK Favorites comparison checklist | **PASS / CHECKLIST READY** | Compare saved-card media scale, count/filter/edit treatment, empty state, iOS safe area and desktop wide composition. |
| ASSET-105 — Reference-vs-APK Account/About comparison checklist | **PASS / CHECKLIST READY** | Confirm no unnecessary product bitmap is introduced, brand/editorial imagery remains truthful, iOS safe areas work and desktop uses wide tiers. |
| ASSET-106 — Cross-variant color consistency review | **BLOCKED ON FINAL PRODUCT BINARIES** | Review White/Gray and Blue/Pink/Green together only after final canonical exports exist. Source truth/Product Master overrides mock color matching. |
| ASSET-107 — Alpha/fringe regression sweep | **BLOCKED ON FINAL PRODUCT BINARIES** | Every transparent product asset must pass White, warm Ivory and WALKA Navy inspection at 100% plus card-sized downscales. Current candidate extraction is not release-eligible because bright stainless/highlights were damaged. |
| ASSET-108 — Unsupported-copy/baked-text audit | **PASS / RULE + FUTURE BINARY SWEEP** | Production cutouts/editorial media must contain no UI chrome, price, rating, CTA, navigation, fake account state or unsupported claims. Existing accepted plan keeps copy live in Flutter. Repeat binary scan before release. |
| ASSET-109 — Final creative manifest reconciliation | **PASS / PLAN RECONCILED** | Canonical five paths, source admission, screen usage, blocked Gray presentation and secondary PDP source requirements are all explicitly accounted for across the creative wave documents. Final file hashes/sizes are appended only after binary admission. |
| ASSET-110 — Stable APK creative-asset acceptance receipt | **BLOCKED** | Requires five approved primary assets, owner-visible integration, full Flutter gates, release APK, stable-main publication and reference-vs-APK evidence. |

## ASSET-101 — Home comparison checklist

- [ ] Android Home matches reference hierarchy and product prominence.
- [ ] iOS Home respects notch/home-indicator spacing without changing product truth.
- [ ] Desktop Home uses wide content/grid treatment, not the 560px phone frame.
- [ ] Hero product media has no alpha damage on ivory/navy surfaces.
- [ ] Drawer/Lunch collection cards use resolver-backed production media.
- [ ] No bitmap contains CTA/price/rating/navigation text.
- [ ] No normal-path product fallback is visible when a matching approved asset exists.

## ASSET-102 — Categories / Search comparison checklist

- [ ] Android Categories product scale and card hierarchy match the protected reference.
- [ ] iOS Categories media remains clear after safe-area adjustments.
- [ ] Search inherits Categories visual grammar and does not invent a missing Search screenshot target.
- [ ] All five variant IDs map to the correct media.
- [ ] Thumbnails use contain semantics and remain legible at compact sizes.
- [ ] Loading/offline/empty states communicate with live UI/vector treatment.
- [ ] PC exact-reference checkbox remains blocked until a valid PC Categories visual is classified.

## ASSET-103 — Product Detail comparison checklist

- [ ] Android/iOS gallery viewport hierarchy follows the references.
- [ ] First slot always matches selected variant.
- [ ] Drawer remains 8 compartments / expandable identity.
- [ ] Lunch open tray remains 4-compartment SUS304.
- [ ] Bright stainless highlights are not removed by alpha cleanup.
- [ ] Fullscreen zoom exposes no halos, missing utensils or reconstructed geometry.
- [ ] Official Amazon disclosure and CTA remain Flutter UI, not embedded in image.
- [ ] PC exact-reference checkbox remains blocked until an approved PC PDP visual exists.

## ASSET-104 — Favorites comparison checklist

- [ ] Saved product media uses the same canonical assets as discovery/PDP.
- [ ] Remove/edit/open affordances remain live and accessible.
- [ ] Empty state uses shared feedback visual language.
- [ ] Android compact/standard and 1.3× text cases remain overflow-free.
- [ ] iOS safe area remains clear.
- [ ] Desktop uses wide composition and visible pointer/keyboard focus.

## ASSET-105 — Account / About comparison checklist

- [ ] Account does not add decorative product photography where the reference does not require it.
- [ ] No fake user/VIP/order/payment state is rendered or baked into media.
- [ ] About product-story media, if used, resolves approved product visuals only.
- [ ] Closing Amazon panel remains truthful and live UI.
- [ ] Android/iOS/PC editorial hierarchy follows available references.
- [ ] Desktop media/content stays bounded inside the shared 1200px tier.

## ASSET-106 — Cross-variant color review

When final files exist, review in a single controlled sheet:

- Drawer White vs Gray: same family identity; natural material separation; no forced recolor parity.
- Lunch Blue: Product Master reference PANTONE 4155 U.
- Lunch Pink: Product Master reference PANTONE 9242 U.
- Lunch Green: Product Master reference PANTONE 6198 U.
- Stainless tray stays neutral metallic across all three colorways.
- Bag/body color may vary with real-source lighting; normalize only gross white balance/exposure, never remap product identity to match a mockup.

## ASSET-107 — Alpha / fringe regression sweep

For each final transparent PNG:

1. inspect at 100% on pure White;
2. inspect on warm Ivory `#F8F6F1`;
3. inspect on WALKA Navy `#003366`;
4. inspect at 96 / 160 / 240 / 384 logical-presentation equivalents;
5. reject white halo, dark fringe, missing stainless highlights, broken utensils, clipped bag/lid edges or semi-transparent background residue;
6. verify full alpha bbox remains inside the safe canvas margin.

## ASSET-108 — Unsupported copy / baked text audit

Reject any production media containing:

- prices, discounts or ratings;
- product counts;
- buttons, chips, nav bars or marketplace chrome;
- fake user/order/VIP/payment state;
- `leakproof` or any unsupported liquid claim;
- cart/checkout/payment language;
- dimensions/spec text unless a future separately approved infographic task explicitly requires it.

Brand text physically printed on the real product/bag is permitted when it is part of the actual product photography.

## ASSET-109 — Manifest reconciliation table

| Variant | Canonical path | Source state | Final binary state |
|---|---|---|---|
| Drawer White | `mobile/assets/products/drawer/white.png` | approved expanded source | REWORK / alpha mask not yet accepted |
| Drawer Gray | `mobile/assets/products/drawer/gray.png` | partial real Gray source | BLOCKED / canonical presentation unresolved |
| Lunch Blue | `mobile/assets/products/lunch/blue.png` | approved | REWORK / stainless alpha preservation required |
| Lunch Pink | `mobile/assets/products/lunch/pink.png` | approved with clean crop | REWORK / stainless alpha preservation required |
| Lunch Green | `mobile/assets/products/lunch/green.png` | approved | REWORK / stainless alpha preservation + framing normalization required |

## ASSET-110 — Stable APK creative acceptance receipt template

Do not mark PASS until all fields are real:

- Stable source commit: `<sha>`
- Workflow run: `<run>`
- App version: `<version>`
- Stable APK path: `Last verified APK/WALKA-latest.apk`
- APK SHA-256: `<sha256>`
- Product assets: `5/5 PASS`
- Home comparison: `PASS`
- Categories/Search comparison: `PASS` (PC reference exception recorded)
- PDP comparison: `PASS` (PC reference exception recorded)
- Favorites comparison: `PASS`
- Account/About comparison: `PASS`
- Cross-variant color QA: `PASS`
- Alpha/fringe sweep: `PASS`
- Unsupported-copy audit: `PASS`
- Flutter Analyze: `PASS`
- Full Flutter tests: `PASS`
- Android release APK build: `PASS`

Any failed field keeps ASSET-110 BLOCKED and prevents the creative lane from declaring final visual acceptance.
