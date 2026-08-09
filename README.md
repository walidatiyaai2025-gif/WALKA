# WALKA

Premium mobile storefront for the WALKA home-organization brand.

## Stable Android test APK

The owner-facing stable branch is **`main` only**.

After every successful stable-main Flutter validation/build, the latest installable APK is published to:

`Last verified APK/WALKA-latest.apk`

Its source commit, workflow run, APK type, size, SHA-256 and build timestamp are recorded in:

`Last verified APK/VERIFIED_BUILD.md`

Development branches may be newer, but they are not considered stable and do not replace the APK above. Project chat does not use ZIP files for Android delivery.

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
- `backend/` — Laravel backend/API.
- `docs/` — phase plans, release slices, delivery policy and current development status.
- `Last verified APK/` — latest stable-main Android APK + verification receipt.
- `.github/workflows/` — backend and Flutter validation/build pipelines.
- `AGENTS.md` — repository-wide engineering/team rules.

## Current release track

- `1.0.0` — completed Flutter visual/product experience freeze.
- `1.1.0` — completed Laravel API foundation.
- `1.2.0` — completed Flutter ↔ Laravel remote catalog integration.
- `1.3.0` — database-backed catalog persistence is the active functional slice.
- `OPS-001` — stable-main governance and persistent last-verified APK delivery runs as an infrastructure slice alongside feature development.

See `docs/STATUS.md`, `docs/PHASE_2_FUNCTIONAL_PLAN.md` and `docs/DELIVERY_POLICY.md` for the active work and release evidence.
