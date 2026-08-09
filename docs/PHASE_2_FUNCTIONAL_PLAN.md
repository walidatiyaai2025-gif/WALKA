# Phase 2 — Functional Storefront

## Objective

Turn the approved Phase 1 WALKA mobile prototype into a real customer-facing storefront while preserving the premium UI and the rule that purchases complete on Amazon.

Phase 2 is intentionally sliced into small releases so each increment can be reviewed, built and installed independently.

## Guardrails

- Amazon remains the purchase destination; WALKA does not implement an in-app cart, checkout or payment flow.
- `Images/` remains the master visual-reference folder and is not modified by implementation tasks.
- Existing Phase 1 screens are extended, not redesigned, unless a verified UX defect requires a change.
- New behavior must have deterministic tests where practical and must pass analyze/test/APK CI before release.
- Laravel is introduced behind repository/service boundaries so the Flutter UI is not coupled directly to HTTP details.

## Release slices

### COM-001 / 0.6.0 — Amazon purchase handoff

- Variant-aware official Amazon URLs for the drawer organizer.
- White and Gray PDP selections route to their matching listings.
- External app/browser launch through a dedicated commerce boundary.
- User-safe fallback when the device cannot open Amazon.
- Unit coverage for variant-to-ASIN mapping.

### STATE-001 / 0.7.0 — Persistent customer state

- Persist Favorites locally across app restarts.
- PDP favorite control becomes functional.
- Favorites screen reflects real saved state instead of a presentation-only state.
- Keep persistence behind a repository interface for later account sync.

### API-001 / 0.8.0 — Laravel API foundation

- Bootstrap Laravel backend structure.
- Versioned `/api/v1` health/config/catalog endpoints.
- Product DTOs for WALKA catalog data and Amazon destinations.
- Environment/config separation and API smoke tests.
- No authentication requirement yet.

### API-002 / 0.9.0 — Flutter remote catalog integration

- Flutter API client and repository layer.
- Remote product/catalog loading with explicit loading/error states.
- Local seed fallback so the app remains previewable if the API is unavailable.
- Keep navigation and premium layouts unchanged.

### REL-001 / 1.0.0 — Storefront release candidate

- Production configuration review.
- Android release signing/build pipeline.
- External-link, lifecycle and offline QA.
- Final accessibility/regression pass.
- Release receipt and installable Android candidate.

## Definition of Done

A release slice is complete only when its implementation is merged to `main`, Flutter analyze succeeds, tests succeed, the Android preview/release build succeeds as applicable, and `docs/STATUS.md` records the receipt.
