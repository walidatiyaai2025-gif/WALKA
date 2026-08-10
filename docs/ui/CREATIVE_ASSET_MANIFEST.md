# WALKA Creative Asset Manifest

Status: **ASSET-001 source audit / production-source admission matrix**  
Tracking: #197 / #198  
Base media plumbing: #184 / commit `98212557615b670369901d3581734dd623361ed1`

## Purpose

This document separates three different things that must not be conflated:

1. protected full-screen UI reference masters under `Images/`,
2. source/master artwork used by a designer to produce reusable assets,
3. optimized production assets bundled by Flutter under `mobile/assets/`.

`Images/` is read-only. A reference screenshot may guide composition, scale, lighting, hierarchy and crop intent, but it is not automatically admitted as a production product image.

Product truth comes from `docs/PRODUCT_MASTER.md`. If a reference conflicts with Product Master, Product Master wins.

## Current production bundle audit

### Existing branding asset

| Asset | Path | Status | Notes |
|---|---|---|---|
| WALKA logo | `mobile/assets/branding/walka_logo.svg` | PASS / existing | Existing reusable brand asset; no replacement required by this lane. |

### Canonical primary product media paths

The media resolver already owns these exact paths. The directories currently contain placeholders rather than approved product-photo PNG binaries.

| Variant | Canonical production path | Current creative status | Tracking |
|---|---|---|---|
| Drawer Organizer / White | `mobile/assets/products/drawer/white.png` | SOURCE ADMITTED; export pending | ASSET-003 / #200 |
| Drawer Organizer / Gray | `mobile/assets/products/drawer/gray.png` | SOURCE PARTIAL; final expanded-view parity BLOCKED | ASSET-004 / #201 |
| Lunch Box / Blue | `mobile/assets/products/lunch/blue.png` | SOURCE ADMITTED; export pending | ASSET-005 / #202 |
| Lunch Box / Pink | `mobile/assets/products/lunch/pink.png` | SOURCE ADMITTED WITH CLEAN CROP; export pending | ASSET-006 / #203 |
| Lunch Box / Green | `mobile/assets/products/lunch/green.png` | SOURCE ADMITTED; export/framing normalization pending | ASSET-007 / #204 |

Until an approved binary exists at one of these paths, Flutter must keep using the deterministic painted fallback provided by the completed MEDIA lane.

## Owner-provided source admission matrix

The owner-connected image library contains product-source material that is materially stronger than the full-screen UI mockups. These sources are admitted for derivative app-asset production only; source masters remain outside the Flutter bundle and `Images/` stays untouched.

| Product / variant | Owner source filename | Source type | Admission | Production use / blocker |
|---|---|---|---|---|
| Drawer Organizer / White | `51yxoCdmqrL._AC_SL1500_(1).jpg` | Clean listing product photo | **APPROVED** | Shows the real expanded organizer with both side wings and the central six sections, preserving the 8-compartment expandable identity. Suitable for transparent primary cutout. |
| Drawer Organizer / Gray | `IMG-20250919-WA0035.jpg` | Owner product/packaging photo | **PARTIAL** | Faithful Gray material/color and real product structure are visible, but the organizer is photographed collapsed. Suitable as Gray truth/reference; do not fabricate an expanded 8-compartment view. ASSET-004 remains BLOCKED for final parity until an approved expanded Gray source is available or the owner approves a collapsed canonical presentation. |
| Lunch Box / Blue | `main new(3).jpg` | Clean listing product photo | **APPROVED** | Clean white-background set with 4-compartment stainless tray, colored outer component, lid/bag and approved accessories visible. Suitable for transparent production extraction. |
| Lunch Box / Pink | `1000389975.jpg` | Owner listing screenshot containing clean main product panel | **APPROVED WITH CROP** | The embedded main product panel shows the Pink set and 4-compartment tray clearly. Only the clean product image region may be extracted; Amazon/UI/title/rating/navigation pixels must never enter the production asset. |
| Lunch Box / Green | `WhatsApp Image 2026-02-24 at 11.22.34 PM.jpeg` | Clean owner product photo | **APPROVED** | Clear Green set with 4-compartment SUS304 tray and accessories. Camera/layout differs from Blue/Pink, so export must normalize canvas, scale and visual center without reconstructing or inventing product geometry. |

### Source-admission rules applied

- Admitting a source does **not** admit unsupported copy or claims visible elsewhere in a screenshot/listing.
- Product geometry is never recolored/rebuilt to make variants match. Real variant photography wins over artificial parity.
- Cropping, masking, alpha cleanup, non-destructive tonal cleanup and canvas normalization are allowed.
- No mock price, rating, review count, cart/payment UI or marketplace chrome may be baked into production assets.
- Source/master files stay separate from optimized Flutter exports.

## Protected reference inventory

18 files are present under `Images/`.

| Reference file | Family / platform | Creative use | Direct production admission |
|---|---|---|---|
| `Home for Android.png` | Home / Android | Composition, hierarchy, product prominence, crop/perspective reference | NO — full-screen UI master |
| `Home for ios.png` | Home / iOS | iOS composition and safe-area visual reference | NO — full-screen UI master |
| `Home for pc.png` | Home / Desktop | Wide-layout composition and focal-area reference | NO — full-screen UI master |
| `Product page for Android.png` | PDP / Android | Gallery framing, product scale and PDP hierarchy reference | NO — full-screen UI master |
| `Product page for ios.png` | PDP / iOS | iOS PDP framing and spacing reference | NO — full-screen UI master |
| `About for Android.png` | About / Android | Editorial treatment/background reference only | NO — full-screen UI master |
| `About for ios.png` | About / iOS | Editorial treatment/background reference only | NO — full-screen UI master |
| `About page for PC.png` | About / Desktop | Wide editorial treatment/background reference only | NO — full-screen UI master |
| `Faivorets page for Android.png` | Favorites / Android | Saved-product visual scale and empty/saved-state composition reference | NO — full-screen UI master |
| `Faivorets page for ios.png` | Favorites / iOS | iOS saved-product visual scale reference | NO — full-screen UI master |
| `Faivorets page for PC.png` | Favorites / Desktop | Wide saved-product presentation reference | NO — full-screen UI master |
| `Categories page for Android.png` | Categories / Android | Category-card/product-row composition reference | NO — full-screen UI master |
| `Categories page for ios.png` | Categories / iOS | iOS discovery composition reference | NO — full-screen UI master |
| `Account profile page for Android.png` | Account / Android | Account visual treatment reference; not product-media source | NO — full-screen UI master |
| `Account profile page for ios.png` | Account / iOS | Account visual treatment reference; not product-media source | NO — full-screen UI master |
| `Account profile page for PC.png` | Account / Desktop | Wide account treatment reference; not product-media source | NO — full-screen UI master |
| `ChatGPT Image Aug 9, 2026, 08_12_03 PM.png` | Duplicate of Account Android | Duplicate reference only; same Git blob as Account Android | NO — duplicate full-screen UI master |
| `f96465c7-d756-4409-9963-d96bb6b5893e.png` | Unclassified | **BLOCKED: visual classification required** | NO until visually classified and owner/source status is known |

## Asset-source admission policy

A visual source is eligible for production work only if all of the following are true:

- the product/variant identity is unambiguous,
- the source can preserve real product geometry without reconstruction guesswork,
- color treatment can remain faithful to Product Master,
- the source has enough resolution for the intended export,
- the owner has approved the source for app distribution or derivative production,
- the result can be exported without baking UI copy, prices, ratings, navigation, or unsupported claims into the asset.

If these conditions are not met, the asset task is BLOCKED rather than filled with fabricated product details.

## Product geometry and color constraints

### Drawer Organizer

- 8 compartments.
- Approved colorways: White and Gray.
- Keep the organizer identity and expandable form truthful.
- Primary production files should be transparent reusable product cutouts.

### Large Stainless Steel Bento Lunch Box

- 4-compartment SUS304 stainless tray.
- PP outer body.
- Approved colorways: Blue, Pink and Green.
- Preserve the real product structure and visible included-set identity when a source view includes accessories.
- Do not create visual cues that imply unsupported liquid/leakproof behavior.

## Screen-to-asset need matrix

| Surface | Primary need | Secondary need | Current status |
|---|---|---|---|
| Home | Reusable Drawer/Lunch product cutouts | Optional editorial composite only if reusable cutouts cannot reproduce reference cleanly | Source set admitted; production exports pending |
| Categories | Reusable product cutouts | Optional category composite | Source set admitted; production exports pending |
| Search | Reusable variant cutouts | None expected unless reference requires it | Source set admitted; production exports pending |
| Favorites | Reusable saved-product cutouts | None expected | Source set admitted; production exports pending |
| PDP | Primary variant cutout | Secondary gallery/detail views from approved sources | Primary sources admitted except Gray expanded parity; secondary source set still requires audit |
| About | No product asset required by default | Decorative/editorial art only if a reference-specific need is confirmed | No new production asset admitted yet |
| Account | No product asset required by default | Decorative art only if a reference-specific need is confirmed | No new production asset admitted yet |
| Splash / launcher | Existing design program already delivered branded launch experience | No duplicate work in this lane | OUT OF SCOPE / already delivered |

## Atomic production queue

| ID | Issue | Deliverable | Dependency |
|---|---|---|---|
| ASSET-001 | #198 | This manifest + source admission audit | — |
| ASSET-002 | #199 | Photoshop/master/export specification | ASSET-001 source admission |
| ASSET-003 | #200 | `drawer/white.png` | Approved source + ASSET-002 |
| ASSET-004 | #201 | `drawer/gray.png` | Approved expanded source/owner presentation decision + ASSET-002 |
| ASSET-005 | #202 | `lunch/blue.png` | Approved source + ASSET-002 |
| ASSET-006 | #203 | `lunch/pink.png` | Approved source + ASSET-002 |
| ASSET-007 | #204 | `lunch/green.png` | Approved source + ASSET-002 |
| ASSET-008 | #205 | Home/Categories editorial composites only where needed | Primary cutouts |
| ASSET-009 | #206 | PDP secondary gallery/detail assets | Approved source set |
| ASSET-010 | #207 | Production optimization + visual-fidelity QA | Produced assets |

## Current blockers / decisions required

1. The five canonical production PNGs are not all delivered yet.
2. Gray has a faithful real-product source, but only in the collapsed presentation; no fabricated expanded Gray photography is allowed.
3. Full-screen `Images/` references are not admitted as direct product-photo binaries.
4. `f96465c7-d756-4409-9963-d96bb6b5893e.png` cannot be safely classified from repository metadata alone and remains BLOCKED pending visual review/owner confirmation.
5. PDP secondary gallery work must not invent views that are unsupported by an approved source image.

## Exit criteria for ASSET-001

ASSET-001 can close when:

- the UUID image is visually classified or explicitly dispositioned as non-blocking for product-media production,
- an approved source is identified for each primary product variant or each unavailable presentation is explicitly marked BLOCKED,
- this manifest records the final source-to-production mapping for every admitted asset.
