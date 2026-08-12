# LIMG-BLUE — Approved Lunch Box Blue production admission

Tracking: #291  
Parent visual-release blocker: #230  
Status: **IMPLEMENTED ON BRANCH / CI PENDING**

## Exact approved source

- Source filename: `main new(3).jpg`
- Source SHA-256: `1ad36a3c917ea7e0e4dbadfd68070e4ebc1392cf78217fd860640e1a3d68077e`
- Source bytes: `71422`
- Source authority: `SRC-LUNCH-BLUE-001` / `APPROVED`
- Protected `Images/` masters: **untouched**

The canonical asset was derived only from the approved real source. The production operation is limited to background separation, alpha-edge cleanup, canvas normalization and source-derived aspect-ratio-preserving scaling. No product recolor, accessory invention, hidden-geometry reconstruction, generated photography, marketplace chrome, price/rating UI or unsupported claim was introduced.

## Canonical runtime asset

- Path: `mobile/assets/products/lunch/blue.png`
- Runtime canonical path: `assets/products/lunch/blue.png`
- SHA-256: `a36a0034fe8a8f807f8b1020c12dd85907807743b842aa71493e0f0ef04271f4`
- Bytes: `743513`
- Canvas: `1024 × 1024`
- PNG: 8-bit RGBA / color type 6
- Color profile: explicit `sRGB` chunk
- Interlace: none
- Alpha bounding box: `[51, 108, 972, 914]`
- Transparent safe margins: left `51`, top `108`, right `51`, bottom `109`
- Nearest transparent safe margin: `51 px` (5% floor satisfied)
- Hard file budget: PASS (< 1.2 MiB)

## Visual and downscale QA

- White surface: PASS
- Ivory surface: PASS
- WALKA Navy surface: PASS
- 96 px decode/presentation: PASS
- 160 px decode/presentation: PASS
- 240 px decode/presentation: PASS
- 384 px decode/presentation: PASS
- Four-compartment tray and included visible set geometry preserved: PASS
- Baked UI / marketplace chrome excluded: PASS

## Runtime admission progression

After this branch is validated and merged, authoritative production-media state becomes:

- ADMITTED: `2 / 5` — Drawer White + Lunch Blue
- PENDING: `2 / 5` — Lunch Pink + Lunch Green
- BLOCKED: `1 / 5` — Drawer Gray
- Mechanical five-of-five readiness: **false**
- Stable owner-visible visual publication: **false**
- Owner visual acceptance: **REQUIRES_OWNER_REVIEW**

Issue #230 remains open. Drawer Gray remains fail-closed; no expanded Gray geometry is synthesized. Pink/Green remain pending until their own exact-source canonical exports pass the same gates.

## Required merge gates

Do not mark this receipt stable/complete merely because the binary exists. Before merge require the normal repository workflow to prove:

- protected reference guard: PENDING
- Flutter Analyze: PENDING
- full Flutter tests: PENDING
- runtime/provenance/PAV enforcement: PENDING
- Android release APK: PENDING

The PR/CI run and APK evidence can be appended after GitHub Actions reports Green.
