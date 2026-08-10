# DESIGN-006 — Motion + feedback + loading/offline state polish

Status: IN PROGRESS
Issue: #52
Parent: #46
Branch: `agent/design-006-motion-state-polish`
Stable base: `fe5295b2663de683b8cd7c4ac771540890bfbda9`

## Stable prerequisite receipt

DESIGN-005 is owner-visible stable before this slice begins:

- Issue: #51 — completed.
- PR: #65.
- Final feature head: `5583192ac200ef8e199a8faeaf812cdb9b812eff`.
- Branch Flutter run: `31346663707` / #361 — green.
- PR-context Flutter run: `31346813269` / #362 — green.
- PR-context APK artifact: `9047655597`.
- Squash merge: `be2fa40d1c154ea94cf6b4a6d64e6666180c7a79`.
- Stable-main Flutter run: `31347074138` / #363 — green.
- Stable APK publication commit: `fe5295b2663de683b8cd7c4ac771540890bfbda9`.
- Stable APK bytes: `51,079,850`.
- Stable APK SHA-256: `0e84156206943365294bd1d429aa31634ec8790ed2924ed960cf3a4f0bf4d46e`.

## Audit

### Catalog resilience

The catalog architecture already fails soft and does not block product discovery:

1. `WalkaCatalogController` starts from the bundled validated snapshot.
2. When a repository exists, `load()` announces loading while keeping that snapshot available.
3. `WalkaCatalogRepository` attempts remote first.
4. A remote failure falls back to the last valid cache.
5. If cache is unavailable or invalid, the bundled catalog remains the final fallback.

This behavior is correct and must not be replaced by a blank full-screen spinner.

### Current presentation gaps

- Home and Discovery each implement their own nearly-identical catalog status banner.
- Loading/offline feedback is visually static and lacks one shared semantics/live-region contract.
- There is no centralized motion duration/easing contract.
- Existing InkWell feedback is functional, but product surfaces do not share a restrained transform response.
- Reduced-motion behavior is not explicitly modeled by WALKA components.
- Search empty feedback is premium but is not yet part of a reusable state language.
- Public shell navigation uses framework defaults rather than an explicit WALKA motion duration.

## Motion principles

- Motion communicates state, hierarchy or touch response; it is never decoration.
- No motion may block input or delay navigation.
- Prefer transform/opacity over layout animation.
- Press feedback must not change layout metrics.
- Standard motion stays short and calm; complex motion is avoided.
- Reduced-motion / accessible-navigation requests collapse WALKA-owned animations to zero duration.
- Loading continues to expose usable fallback catalog content.

## First implementation slice

1. Add a shared `WalkaMotion` contract for durations, easing and reduced-motion handling.
2. Add shared non-layout-shifting press feedback for premium product cards.
3. Add one shared catalog status surface for loading/cache/bundled fallback states with live-region semantics.
4. Apply the status surface consistently to Home, Search and Categories.
5. Use explicit WALKA motion duration for the bottom navigation indicator.
6. Keep all state changes interactive while catalog refresh is in progress.
7. Add focused tests for reduced motion, remote/loading/cache/bundled status semantics, compact layout and press-feedback layout stability.

## Guardrails

- Product Master facts unchanged.
- Catalog repository/controller fallback order unchanged unless a test exposes a correctness defect.
- Stable Product/Variant IDs unchanged.
- Amazon purchase routing unchanged.
- Favorites persistence unchanged.
- No cart/checkout/payment.
- `Images/` untouched.
- No ZIP delivery.
- `main` remains stable-only.

## Definition of done

- Interaction feedback feels consistent and calm.
- Loading/offline/cache states visually belong to WALKA and remain understandable to assistive technologies.
- Reduced-motion behavior is explicit and test-covered.
- No animation-induced layout shifts or blocked input.
- Compact 320×568 + 1.3× regressions remain green.
- Flutter Analyze + full tests + Android release APK candidate green on exact final PR head.
- After merge, stable-main CI independently passes and republishes `Last verified APK/WALKA-latest.apk` from the DESIGN-006 merge commit.
