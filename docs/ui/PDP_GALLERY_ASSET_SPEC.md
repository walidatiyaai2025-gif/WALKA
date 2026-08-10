# WALKA Product Detail Gallery Asset Contract

Tracking: #209 / #216  
Tasks: ASSET-061..070  
References: `Images/Product page for Android.png`, `Images/Product page for ios.png`  
Product truth: `docs/PRODUCT_MASTER.md`

## General gallery rule

Every gallery slot must be backed by an APPROVED source. A desired view is not permission to fabricate a view. If source photography does not show the required angle/detail, the slot is BLOCKED and the existing deterministic visual/fallback remains preferable to invented photography.

## ASSET-061 — Drawer primary gallery slot

Purpose: canonical product-identification view.
- source: approved Drawer White/Gray master;
- complete outer organizer geometry visible;
- transparent or neutral reusable presentation;
- no baked copy;
- selected variant must map to matching color asset;
- preserve 8-compartment organizer identity.

## ASSET-062 — Drawer expanded-state slot

Purpose: communicate expandability only when a real approved source shows the expanded state.
- do not stretch the closed-state image in Photoshop;
- keep side-extension geometry truthful;
- retain full left/right expanded edges;
- use a consistent gallery canvas with the primary view.

Status: BLOCKED until a suitable approved expanded-state source is admitted.

## ASSET-063 — Drawer non-slip/base detail slot

Purpose: close detail of the non-slip base/feet only if supported by a real source.
- crop may be tighter than primary gallery view;
- detail must still be recognizable in context;
- do not synthesize rubber texture or feet placement;
- no text label is required in the bitmap; Flutter owns the fact copy.

Status: BLOCKED until approved base-detail source exists.

## ASSET-064 — Drawer compartment/detail slot

Purpose: show organizer dividers/compartment structure.
- preserve real 8-compartment geometry;
- no cloned/rearranged divider layout;
- no utensil props unless they exist in an approved source and are appropriate to the app visual.

Status: source-dependent.

## ASSET-065 — Lunch primary gallery slot

Purpose: selected variant identification.
- canonical Blue/Pink/Green source;
- preserve clips/body/lid/tray silhouette as actually shown;
- transparent or neutral reusable framing;
- sibling colors must share camera orientation and optical scale when source permits.

## ASSET-066 — Lunch open 4-compartment tray slot

Purpose: explicitly show the SUS304 four-compartment tray.
- exactly 4 compartments;
- do not alter divider geometry;
- stainless material must retain realistic highlight/shadow detail;
- no food/liquid content that creates an unsupported leakproof implication;
- if food styling exists in source, it must remain compatible with approved dry/semi-wet positioning.

Status: BLOCKED until an approved open-tray source is admitted.

## ASSET-067 — Lunch accessory-set slot

Target visible set where source supports it:
- insulated carry bag;
- stainless sauce cup with lid;
- spoon;
- fork;
- Lunch Box itself as appropriate to composition.

Do not add missing accessories with generative reconstruction. A partial approved source may be used only if the gallery description remains truthful and does not imply a complete set that is not shown.

## ASSET-068 — Lunch SUS304/material-detail slot

Purpose: material/detail close-up.
- `SUS304` engraving may be shown only if present in the approved source;
- retain stainless texture and engraving geometry;
- avoid over-sharpening halos;
- Flutter copy owns care/microwave instructions; do not bake them into the image.

## ASSET-069 — Gallery aspect ratio and order contract

Default gallery order:

### Drawer
1. primary selected variant;
2. expanded state, if APPROVED;
3. compartment/detail, if APPROVED;
4. non-slip/base detail, if APPROVED.

### Lunch
1. primary selected variant;
2. open 4-compartment tray, if APPROVED;
3. accessory set, if APPROVED;
4. SUS304/material detail, if APPROVED.

All gallery assets should be authored to fit the existing stable gallery viewport with `BoxFit.contain`. Use a consistent canvas family; do not mix extreme portrait and panorama crops that cause erratic page-to-page scale changes.

## ASSET-070 — PDP gallery release checklist

- [ ] Every gallery file has an APPROVED source receipt.
- [ ] No gallery view was synthetically invented from another angle.
- [ ] Drawer geometry/8 compartments remain truthful.
- [ ] Lunch tray remains exactly 4 compartments.
- [ ] Lunch accessories/material detail match Product Master.
- [ ] Variant colors are correct and sibling framing is coherent.
- [ ] Gallery order is deterministic.
- [ ] `BoxFit.contain` does not clip product geometry.
- [ ] Fullscreen zoom remains sharp at expected scale without bundling wasteful source masters.
- [ ] No baked prices/ratings/unsupported claims/care copy.
- [ ] Android/iOS gallery screenshot comparison recorded.
- [ ] Analyze/tests/release APK Green after integration.

## Status summary

ASSET-061 and ASSET-065 primary-slot contracts are ready for admitted cutouts. ASSET-062..064 and ASSET-066..068 are explicitly source-dependent/BLOCKED until approved real views are available. ASSET-069 contract and ASSET-070 release gate are defined.
