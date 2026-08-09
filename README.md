# WALKA

Premium mobile storefront for the WALKA home-organization brand.

## Stable Android test APK

The owner-facing stable branch is **`main` only**. Development work stays on task branches until its required CI gates are green and it is intentionally merged.

After every successful stable-main Flutter validation/build, the latest installable APK is published to:

`Last verified APK/WALKA-latest.apk`

Its source commit, workflow run, APK type, size, SHA-256 and build timestamp are recorded in:

`Last verified APK/VERIFIED_BUILD.md`

Branch/PR APKs are engineering candidates only and never replace the stable root APK. WALKA project chat does not use ZIP files for Android delivery.

See `docs/DELIVERY_POLICY.md` for the full branch → PR → stable-main → verified-APK lifecycle.

## Current scope — Phase 2

Phase 1 completed the premium Flutter UI/UX prototype. Phase 2 turns that approved experience into a functional storefront while keeping Amazon as the purchase destination.

Current direction:

- Flutter mobile app for Android and iOS.
- Premium WALKA visual system and completed screen navigation.
- Functional outbound purchase handoff to official Amazon listings.
- Customer state, search and remote catalog behavior delivered in small releases.
- Laravel introduced behind versioned APIs and repository/service boundaries.
- No in-app cart, checkout or payment flow; purchase completes on Amazon.

## Repository layout

- `Images/` — protected master visual references supplied by the brand owner.
- `mobile/` — Flutter mobile application.
- `backend/` — Laravel API application.
- `docs/` — phase plans, delivery policy, release receipts and current development status.
- `Last verified APK/` — owner-facing stable Android APK and verification receipt.
- `.github/workflows/` — Flutter/backend validation and build pipelines.

## Release track

Released foundations now include the Flutter visual freeze, Laravel API foundation, resilient Flutter ↔ Laravel catalog integration and database-backed catalog persistence. Current product work continues in small independently validated slices while Amazon remains the purchase destination.

See `docs/STATUS.md` for authoritative release receipts and `docs/UI_UX_PRIORITY_PLAN.md` for the current premium design queue.
