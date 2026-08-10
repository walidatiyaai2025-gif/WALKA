# WALKA Product Detail Gallery Creative Asset Wave

Status: ASSET-061..070 execution receipt  
Parent: #216 / #209 / #197  
References: `Images/Product page for Android.png`, `Images/Product page for ios.png`

PC PDP exact-reference parity remains blocked until the unresolved reference is visually classified. The gallery contract below is platform-responsive and can proceed without inventing a desktop screenshot target.

## Gallery principles

- The first gallery slot is always the canonical selected-variant production media.
- Secondary slots require a real approved source. A missing source creates a documented blocked slot, never a fabricated view.
- Product facts, dimensions and claims remain live Flutter copy; the image lane does not bake them into the bitmap.
- Gallery imagery must remain useful under `BoxFit.contain`, fullscreen zoom/pan and compact phone layouts.

## ASSET-061..070

| Task | Result | Contract / output |
|---|---|---|
| ASSET-061 — Drawer PDP primary gallery slot spec | **PASS** | Slot 1 uses selected White/Gray canonical cutout, 1:1 media master, transparent background, full expandable/canonical silhouette visible. |
| ASSET-062 — Drawer expanded-state gallery slot spec | **PASS / WHITE; BLOCKED / GRAY** | White can use the admitted expanded source. Gray expanded-state slot is blocked until real expanded Gray photography is admitted. No White-to-Gray recolor. |
| ASSET-063 — Drawer non-slip/base detail slot spec | **BLOCKED UNTIL SOURCE ADMISSION** | Only create if an approved photo clearly shows the actual non-slip base/underside. Do not synthesize texture or feet from Product Master text. |
| ASSET-064 — Drawer compartment/detail slot spec | **PASS WHERE SOURCE SUPPORTS** | A close/detail crop may show real compartment geometry from the approved White source. It must not crop in a way that implies a different compartment count. Gray requires its own real source for color-specific detail. |
| ASSET-065 — Lunch PDP primary gallery slot spec | **PASS** | Slot 1 uses selected Blue/Pink/Green canonical set cutout. Keep tray, lid/bag and included-set identity within safe frame. |
| ASSET-066 — Lunch open 4-compartment tray slot spec | **PASS** | Use approved real open-tray source(s). Tray must visibly remain 4-compartment SUS304. A generic or AI-reconstructed tray is not acceptable. |
| ASSET-067 — Lunch accessory-set slot spec | **PASS WHERE SOURCE SUPPORTS** | Show only real included items visible in approved source: insulated bag, sauce cup with lid, spoon and fork. No extra accessory props. |
| ASSET-068 — Lunch SUS304/material-detail slot spec | **PASS WHERE SOURCE SUPPORTS** | Use real stainless close/detail imagery and preserve highlights. Do not bake unsupported performance claims into the image. Text such as SUS304/material facts stays UI-side unless a separate approved infographic task is created. |
| ASSET-069 — PDP gallery aspect-ratio/order contract | **PASS** | Default order: primary → open/expanded state → structural/detail → accessory/material. Media viewport uses stable 1:1/near-square content with `contain`; fullscreen retains original aspect. Variant-inapplicable slots are omitted, not replaced with misleading duplicates. |
| ASSET-070 — PDP gallery visual QA/release receipt | **BLOCKED ON FINAL BINARIES** | Slot contract is ready. Final PASS requires approved primary assets, admitted secondary sources, variant mapping checks and reference-vs-APK validation. |

## Recommended gallery map

### Drawer Organizer

1. **Primary selected variant** — canonical transparent cutout.
2. **Expanded presentation** — White available; Gray blocked without real expanded source.
3. **Compartment close/detail** — source-supported crop only.
4. **Non-slip/base** — blocked until approved underside/base photography exists.

### Lunch Box

1. **Primary selected color set** — canonical transparent cutout.
2. **Open tray** — 4-compartment SUS304 view.
3. **Included accessories** — bag + sauce cup + spoon/fork, only where visible in source.
4. **Material/detail** — real stainless/product detail preserving reflections and geometry.

## Framing contract

- Canonical/primary: 1024×1024 RGBA PNG.
- Secondary photo: preserve native aspect where useful, but normalize export canvas so the product focal area sits inside central 80%.
- Fullscreen route may use higher-resolution approved derivatives when genuinely needed; do not bundle marketing masters indiscriminately.
- No carousel dots, zoom icons, labels or CTA graphics embedded in imagery.

## Variant applicability

| Slot | White Drawer | Gray Drawer | Blue Lunch | Pink Lunch | Green Lunch |
|---|---:|---:|---:|---:|---:|
| Primary | required | required | required | required | required |
| Expanded/open | supported | **blocked** | supported | supported if source | supported if source |
| Structural detail | source-dependent | source-dependent | source-dependent | source-dependent | source-dependent |
| Accessories/material | n/a | n/a | source-dependent | source-dependent | source-dependent |

## Visual QA gate

1. Selected variant and first gallery slot always agree.
2. Gray never inherits White pixels through recolor or geometry reconstruction.
3. Lunch tray retains four real compartments in every open-tray image.
4. Bright stainless/reflections are preserved in alpha/background cleanup.
5. Fullscreen zoom reveals no masking halos, AI artifacts or baked UI pixels.
6. Android/iOS media viewport hierarchy follows the protected references.
7. PC exact-reference sign-off remains blocked until an approved PC PDP reference exists.
8. Analyze, full tests and release APK must be Green after any owner-visible media integration.
