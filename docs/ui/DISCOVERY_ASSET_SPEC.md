# WALKA Categories / Search Production Media Contract

Tracking: #209 / #215  
Tasks: ASSET-051..060  
References: `Images/Categories page for Android.png`, `Images/Categories page for ios.png`  
Search basis: released Categories visual grammar and `docs/ui/REFERENCE_ELEMENT_CHECKLISTS.md`

## ASSET-051 — Android Categories media audit

Android Categories needs reusable product imagery, not screenshot slices. Required media classes:
- Drawer category media;
- Lunch category media;
- variant-level product thumbnails/rows resolved from the canonical product assets.

No bitmap is required for the top bar, title, category count, filters, chips, benefit strip or navigation.

## ASSET-052 — iOS Categories media audit

Reuse the same approved product media as Android. iOS differences are layout/safe-area concerns owned by Flutter. A separate iOS bitmap is allowed only when a reference-specific crop is objectively required and can be derived from the same approved source without changing product geometry.

## ASSET-053 — Desktop discovery media requirements

There is no explicitly classified PC Categories reference. Desktop media therefore follows responsive-system behavior rather than inventing a PC screenshot target:
- same reusable product cutouts;
- wider responsive grid/row composition;
- no desktop-only product photography until an approved PC visual/reference or editorial requirement exists.

Status: product assets can be specified; pixel-perfect PC visual parity remains BLOCKED on reference classification.

## ASSET-054 — Drawer category hero/card media

Preferred source: canonical Drawer cutout via resolver.
- maintain complete organizer geometry;
- favor White or the currently selected/catalog-context variant without inventing a third color;
- no baked category name/count;
- keep optical occupancy stable across card sizes;
- if an editorial derivative is later needed, preserve a center-biased safe focal area.

## ASSET-055 — Lunch category hero/card media

Preferred source: canonical Lunch cutout via resolver.
- use only released Blue/Pink/Green variants;
- preserve 4-compartment tray/accessory truth when visible;
- no unsupported liquid/leakproof visual claims;
- keep orientation compatible with product-row and PDP presentation.

## ASSET-056 — Search Drawer thumbnail specification

Search should reuse the canonical Drawer product media unless profiling proves a smaller derivative is worthwhile. Thumbnail rules:
- `BoxFit.contain`;
- no baked labels;
- transparent background preferred;
- visual center consistent with Categories/Favorites;
- target derivative budget, if created: <= 250 KB;
- never crop expandable edges or compartment identity.

## ASSET-057 — Search Lunch thumbnail specification

Same rule: reuse canonical variant cutout first. If a dedicated derivative is justified, it must be generated from the approved canonical master and preserve:
- selected color identity;
- clips/body/tray silhouette;
- readable stainless-vs-PP material separation;
- same framing across Blue/Pink/Green.

## ASSET-058 — Discovery visual-scale matrix

| Surface | Media behavior | Target occupancy |
|---|---|---|
| Category hero/card | product dominant, generous negative space | approx. 65–78% of media box |
| Search/product row | compact full-product identity | approx. 70–82% |
| Favorites saved card | same optical scale family as Search | approx. 70–82% |
| Desktop grid | preserve product scale, add whitespace rather than aggressive enlargement | responsive |

Occupancy is an optical target, not a destructive crop rule. Complete product geometry wins.

## ASSET-059 — Discovery decode/file-size budget

- Prefer shared canonical cutout and existing resolver/cache-width logic.
- Do not introduce a thumbnail derivative solely to save a trivial amount of decode time.
- If measured scrolling performance needs a derivative, long side should normally be in the ~480–720 px range depending on actual rendered density.
- Target dedicated thumbnail file size <= 250 KB.
- Avoid storing identical image bytes under multiple screen-specific names.

## ASSET-060 — Discovery visual release checklist

- [ ] Drawer/Lunch media come from APPROVED sources.
- [ ] Category and Search surfaces share visual scale language.
- [ ] Search results resolve the selected variant correctly.
- [ ] All/Drawer/Lunch filter UI remains Flutter-native.
- [ ] No fake category/product counts are baked into art.
- [ ] Android and iOS crops preserve full product geometry.
- [ ] Desktop behavior is responsive and does not claim unclassified PC reference parity.
- [ ] Scrolling thumbnails meet decode/file-size budget.
- [ ] Missing-asset fallback remains deterministic.
- [ ] Analyze/tests/release APK remain Green after integration.

## Status summary

ASSET-051..059 contracts are defined. ASSET-060 final PASS requires admitted product binaries plus integrated screenshot/performance verification.
