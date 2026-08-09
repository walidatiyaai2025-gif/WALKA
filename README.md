# WALKA

Premium mobile storefront for the WALKA home-organization brand.

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

- `Images/` — master visual references supplied by the brand owner.
- `mobile/` — Flutter mobile application.
- `docs/` — phase plans, release slices and current development status.
- `.github/workflows/` — Flutter validation and preview build pipeline.

## Release track

Completed Phase 1 releases:

1. `0.1.0` — foundation, design system, splash, shell and navigation.
2. `0.2.0` — premium home + product detail.
3. `0.3.0` — categories + collection browsing.
4. `0.4.0` — favorites + profile + about presentation.
5. `0.5.0` — cross-platform polish, accessibility and visual QA.

Phase 2 starts with:

6. `0.6.0` — functional Amazon purchase handoff.
7. `0.7.0` — persistent customer Favorites state.
8. `0.8.0` — Laravel API foundation.
9. `0.9.0` — Flutter remote catalog integration.
10. `1.0.0` — storefront release candidate.

See `docs/PHASE_2_FUNCTIONAL_PLAN.md` and `docs/STATUS.md` for the active slice.
