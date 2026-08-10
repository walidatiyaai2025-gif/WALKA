# WALKA Product Media Manifest

Status: MEDIA-001 audit source.

## Current bundle audit

`mobile/assets/` currently contains branding assets only. No approved Drawer Organizer or Lunch Box product photography is bundled in the Flutter application.

Protected `Images/` reference masters are not production assets and must not be copied into `mobile/assets/` by implementation tasks.

## Released catalog variant keys

These IDs come from the bundled catalog and are the stable resolver keys:

| Variant ID | Product | Approved visual asset | Current renderer |
|---|---|---|---|
| `drawer-organizer:white` | Drawer Organizer / White | None bundled | `WalkaPaintedProductMedia` fallback |
| `drawer-organizer:gray` | Drawer Organizer / Gray | None bundled | `WalkaPaintedProductMedia` fallback |
| `lunch-box:blue` | Large Stainless Steel Bento Lunch Box / Blue | None bundled | `WalkaPaintedProductMedia` fallback |
| `lunch-box:pink` | Large Stainless Steel Bento Lunch Box / Pink | None bundled | `WalkaPaintedProductMedia` fallback |
| `lunch-box:green` | Large Stainless Steel Bento Lunch Box / Green | None bundled | `WalkaPaintedProductMedia` fallback |

## Asset admission rules

An asset may enter the production registry only when all of the following are true:

1. Product owner explicitly approves the file for app distribution.
2. Product/variant mapping is unambiguous.
3. Geometry and product structure are not visually altered from the approved product.
4. File has an intentional production path under `mobile/assets/products/...`.
5. `pubspec.yaml` declares that path.
6. The resolver registry maps the released catalog variant ID to the asset.
7. Missing/corrupt asset behavior remains deterministic and semantic via the painted fallback.

## MEDIA-002 / MEDIA-003 status

Blocked pending approved bundleable product assets. Git does not track empty directories, and creating placeholder product images or copying protected reference masters would violate the delivery/product rules. These two tasks must remain blocked until real assets are approved.

## Performance contract

- Product asset decode uses a bounded cache width; the resolver default is 1200 physical pixels.
- Product media should use `BoxFit.contain` to avoid cropping product geometry.
- Do not bundle source-resolution marketing masters solely for small cards.
- Reuse stable variant mappings rather than constructing arbitrary asset paths in feature widgets.
- Painted fallback remains available for offline/tests/missing assets and avoids blank surfaces.
