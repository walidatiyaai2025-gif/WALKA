# WALKA

Premium mobile storefront prototype for the WALKA home-organization brand.

## Current scope — Phase 1

Phase 1 is intentionally UI/UX only:

- Flutter mobile app for Android and iOS.
- Premium WALKA visual system.
- Screen-to-screen navigation.
- Static/mock product and category content.
- Amazon purchase CTA is visual only in this phase.
- No Laravel, API, authentication, cart, checkout, payment, or order logic yet.

## Repository layout

- `Images/` — master visual references supplied by the brand owner.
- `mobile/` — Flutter mobile prototype.
- `docs/` — phase plan, UI rules, release slices, and status.
- `.github/workflows/` — preview validation/build pipeline.

## Preview releases

Phase 1 is delivered in small reviewable slices so every completed slice can produce an Android preview artifact.

1. `0.1.0` — foundation, design system, splash, shell, navigation, first home experience.
2. `0.2.0` — home polish + product detail.
3. `0.3.0` — categories + collection browsing.
4. `0.4.0` — favorites + profile + about.
5. `0.5.0` — cross-platform polish, accessibility, visual QA.

See `docs/STATUS.md` for the active slice.