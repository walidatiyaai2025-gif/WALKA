# WALKA Product Media Manifest

Status: production asset integration contract.

## Current bundle audit

`mobile/assets/` now contains the WALKA branding asset plus declared production directories for Drawer Organizer and Lunch Box media. No approved product-photo PNGs are currently present in those directories, so owner-visible product surfaces continue to use the deterministic painted fallback until a matching production file is admitted.

Protected `Images/` reference masters remain design/reference inputs. They are not silently copied into production product-media paths because they are complete UI reference screens, not variant photography.

## Released catalog variant keys and production paths

These IDs come from the bundled catalog and are the stable resolver keys. The paths below are the only production filenames feature widgets need to know indirectly through `WalkaProductMediaResolver.production()`.

| Variant ID | Product | Production asset path | Current renderer while file is absent |
|---|---|---|---|
| `drawer-organizer:white` | Drawer Organizer / White | `assets/products/drawer/white.png` | painted fallback |
| `drawer-organizer:gray` | Drawer Organizer / Gray | `assets/products/drawer/gray.png` | painted fallback |
| `lunch-box:blue` | Large Stainless Steel Bento Lunch Box / Blue | `assets/products/lunch/blue.png` | painted fallback |
| `lunch-box:pink` | Large Stainless Steel Bento Lunch Box / Pink | `assets/products/lunch/pink.png` | painted fallback |
| `lunch-box:green` | Large Stainless Steel Bento Lunch Box / Green | `assets/products/lunch/green.png` | painted fallback |

## Flutter bundle contract

`mobile/pubspec.yaml` declares:

- `assets/products/drawer/`
- `assets/products/lunch/`

This means an approved image committed under the canonical filename is bundled by the next Flutter build without requiring screen-specific asset declarations. Home collection cards and discovery product rows now resolve by stable catalog variant ID instead of directly depending on `WalkaProductVisual`.

## Asset admission rules

An image may replace the painted fallback only when all of the following are true:

1. Product owner approves the file for app distribution.
2. Product/variant mapping is unambiguous.
3. Geometry and product structure are not visually altered from the approved product.
4. File uses the canonical production path above.
5. `pubspec.yaml` continues to declare the parent product asset directory.
6. The resolver registry maps the released catalog variant ID to that path.
7. Missing/corrupt asset behavior remains deterministic and semantic via the painted fallback.

## MEDIA-002 / MEDIA-003 status

The folder and Flutter declaration infrastructure is implemented. Actual product-photo binaries remain pending because none are currently present in the repository under the production paths. No fake photography is generated and no protected UI reference screenshot is treated as product photography.

## Performance contract

- Product asset decode uses a bounded cache width; the resolver default is 1200 physical pixels.
- Product media uses `BoxFit.contain` to avoid cropping product geometry.
- Do not bundle source-resolution marketing masters solely for small cards.
- Reuse stable variant mappings rather than constructing arbitrary asset paths in feature widgets.
- Painted fallback remains available for missing/corrupt assets and avoids blank surfaces.
