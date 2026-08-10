# WALKA Creative Asset Manifest

Status: **ASSET-001 initial audit / production-source admission matrix**  
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
| Drawer Organizer / White | `mobile/assets/products/drawer/white.png` | MISSING | ASSET-003 / #200 |
| Drawer Organizer / Gray | `mobile/assets/products/drawer/gray.png` | MISSING | ASSET-004 / #201 |
| Lunch Box / Blue | `mobile/assets/products/lunch/blue.png` | MISSING | ASSET-005 / #202 |
| Lunch Box / Pink | `mobile/assets/products/lunch/pink.png` | MISSING | ASSET-006 / #203 |
| Lunch Box / Green | `mobile/assets/products/lunch/green.png` | MISSING | ASSET-007 / #204 |

Until an approved binary exists at one of these paths, Flutter must keep using the deterministic painted fallback provided by the completed MEDIA lane.

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
| Home | Reusable Drawer/Lunch product cutouts | Optional editorial composite only if reusable cutouts cannot reproduce reference cleanly | BLOCKED on primary cutouts |
| Categories | Reusable product cutouts | Optional category composite | BLOCKED on primary cutouts |
| Search | Reusable variant cutouts | None expected unless reference requires it | BLOCKED on primary cutouts |
| Favorites | Reusable saved-product cutouts | None expected | BLOCKED on primary cutouts |
| PDP | Primary variant cutout | Secondary gallery/detail views from approved sources | Primary BLOCKED; secondary source set not yet admitted |
| About | No product asset required by default | Decorative/editorial art only if a reference-specific need is confirmed | No new production asset admitted yet |
| Account | No product asset required by default | Decorative art only if a reference-specific need is confirmed | No new production asset admitted yet |
| Splash / launcher | Existing design program already delivered branded launch experience | No duplicate work in this lane | OUT OF SCOPE / already delivered |

## Atomic production queue

| ID | Issue | Deliverable | Dependency |
|---|---|---|---|
| ASSET-001 | #198 | This manifest + source admission audit | — |
| ASSET-002 | #199 | Photoshop/master/export specification | ASSET-001 |
| ASSET-003 | #200 | `drawer/white.png` | Approved source + ASSET-002 |
| ASSET-004 | #201 | `drawer/gray.png` | Approved source + ASSET-002 |
| ASSET-005 | #202 | `lunch/blue.png` | Approved source + ASSET-002 |
| ASSET-006 | #203 | `lunch/pink.png` | Approved source + ASSET-002 |
| ASSET-007 | #204 | `lunch/green.png` | Approved source + ASSET-002 |
| ASSET-008 | #205 | Home/Categories editorial composites only where needed | Primary cutouts |
| ASSET-009 | #206 | PDP secondary gallery/detail assets | Approved source set |
| ASSET-010 | #207 | Production optimization + visual-fidelity QA | Produced assets |

## Current blockers / decisions required

1. The five canonical production PNGs are still missing.
2. No independent approved product-photo source set is present under `mobile/assets/`.
3. Full-screen `Images/` references are not admitted as direct product-photo binaries.
4. `f96465c7-d756-4409-9963-d96bb6b5893e.png` cannot be safely classified from repository metadata alone and remains BLOCKED pending visual review/owner confirmation.
5. PDP secondary gallery work must not invent views that are unsupported by an approved source image.

## Exit criteria for ASSET-001

ASSET-001 can close when:

- the UUID image is visually classified,
- an approved source is identified for each primary product variant or each unavailable variant is explicitly marked BLOCKED,
- this manifest records the final source-to-production mapping for every admitted asset.
