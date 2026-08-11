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

## Current scope — Backend-first mobile control plane

The current product direction is to make the Laravel Admin Dashboard the control plane for mobile content.

**Any mobile-facing content, ordering, visibility, media assignment or safe presentation setting that can be changed without shipping a new app build should be controlled from the backend/dashboard and consumed dynamically by Flutter.**

Current direction:

- Flutter mobile app for Android and iOS, plus the production web preview.
- Premium WALKA visual system and released screen navigation.
- Laravel backend and protected `/admin` dashboard.
- Backend-controlled catalog presentation already connected to Flutter.
- Expansion into Home, PDP, discovery, media, FAQ/support/legal content and safe remote presentation configuration.
- Draft/preview/publish/revision/audit/rollback controls for mutable content.
- Resilient last-known-good cache and bundled fallbacks in Flutter.
- Functional outbound purchase handoff to official Amazon listings.
- No in-app cart, checkout or payment flow; purchase completes on Amazon.
- Protected Product Master facts, stable identity, security and executable behavior remain governed rather than freely editable.

## Repository layout

- `Images/` — protected master visual references supplied by the brand owner.
- `mobile/` — Flutter mobile application.
- `backend/` — Laravel API + Admin Dashboard application.
- `docs/` — phase plans, CMS/control-plane plan, delivery policy, release receipts and current development status.
- `Last verified APK/` — owner-facing stable Android APK and verification receipt.
- `.github/workflows/` — Flutter/backend validation and build pipelines.

## Current roadmap

The backend-first content program is defined in:

`docs/MOBILE_CONTENT_CONTROL_PLAN.md`

The Admin Dashboard delivery strategy is defined in:

`docs/ADMIN_DASHBOARD_PLAN.md`

The program starts with CMS publication/version/rollback foundations, then expands product/PDP authoring, Home/discovery, media, information/support content, remote presentation configuration and governed Amazon destination management.

Amazon remains the purchase destination throughout this program.

See `docs/STATUS.md` for historical release receipts and `docs/UI_UX_PRIORITY_PLAN.md` for the premium design program.
