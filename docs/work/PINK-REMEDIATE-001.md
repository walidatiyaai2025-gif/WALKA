# PINK-REMEDIATE — deterministic review-candidate edge cleanup

Parent issue: #323  
Visual-release blocker: #230

This lane does **not** admit Pink media. It creates a separate review candidate from the currently quarantined Pink PNG and preserves fail-closed production truth.

## Invariants

- The canonical `assets/products/lunch/pink.png` is read-only to the remediation CLI.
- Only RGB values of semi-transparent near-white mismatch pixels may change.
- Alpha bytes are preserved byte-for-byte.
- Fully opaque and fully transparent pixels are untouched.
- Visible alpha bounds and therefore geometry framing remain unchanged.
- Nearest light/neutral opaque interior causes the edge pixel to be preserved, protecting legitimate stainless/white antialiasing.
- Replacement RGB comes only from the nearest opaque source-derived interior ring; no recolor palette, generative fill, geometry reconstruction or accessory invention is permitted.
- The output is a review candidate under `build/pink-remediation/`, never an admitted runtime asset.
- Direct White/Ivory/Navy + downscale proof and owner visual acceptance remain mandatory before any future admission change.

## Validation

`flutter test test/pink_edge_matte_test.dart` exercises halo reduction, alpha preservation, opaque/transparent immutability, light-material preservation, deterministic PNG round-trip and visible-bounds preservation.

`dart run tool/remediate_pink_edge_matte.dart` creates the review candidate and receipt. The command fails if no white-matte pixels are changed, alpha/bounds change, or VPROOF mismatch count fails to improve.
