# PIMG Drawer White approved-source ingest v2

Status: IN PROGRESS
Parent: #271
Variant task: #200
Visual release blocker: #230
Branch: `agent/pimg-031-070-white-approved-ingest-v2`

## Source authority

- Approved source filename: `51yxoCdmqrL._AC_SL1500_(1).jpg`.
- Source state: `APPROVED` in `docs/ui/PRODUCTION_SOURCE_ADMISSION.json`.
- Exact source dimensions: 1416×943.
- Exact source SHA-256: `89d7b586c45bd6121537db479139449eb3b8f637c9396d83790d4fd0e03263c2`.
- The source was recovered from the owner-connected image library and independently recovered from the public media URL only after the bytes matched the same SHA-256. No `Images/` source was used or modified.

## Deterministic canonical export

The export preserves the real expanded organizer geometry. It removes only the white listing background using RGB distance threshold 18, selects the largest external product contour, fills that product silhouette so the real white organizer wells stay opaque, then normalizes the real source crop to a transparent 1024×1024 canvas with Lanczos resampling. No recolor, hidden geometry reconstruction, compartment invention, or synthetic product detail is performed.

- Canonical path: `mobile/assets/products/drawer/white.png`.
- PNG: 1024×1024, 8-bit RGBA.
- Color metadata: deterministic PNG `sRGB` chunk.
- SHA-256: `b2c6967b6ccb3283a90e26337f90fe15f2f707dbcf20531d760fb656c06d234f`.
- Bytes: 189,339.
- Inclusive alpha bounds: `[51, 184, 972, 839]`.
- Transparent safe margins: left 51, right 51, top 184, bottom 184; nearest 51.
- Canvas perimeter: fully transparent.

## QA evidence

White, Ivory and Navy surface inspection passes for the rebuilt v2 cutout; the broad residual white/background halo from the older rejected crop is not present. Downscale decode was verified at 96, 160, 240 and 384 pixels. Geometry is preserved from the approved real source and no marketplace/UI pixels are baked into the canonical asset.

The repository admission truth therefore advances only Drawer White to `ADMITTED`. Drawer Gray remains `BLOCKED`; Lunch Blue/Pink/Green remain `PENDING`. Global visual release remains blocked at 1/5 until the remaining faithful production media and final owner-visible acceptance pass.

## Delivery gates

Completion requires protected `Images/` guard, Flutter Analyze, full Flutter tests, PAV/readiness report, Android release APK, merge to `main`, and latest-main validation. CI/merge receipts will be appended after those gates complete.
