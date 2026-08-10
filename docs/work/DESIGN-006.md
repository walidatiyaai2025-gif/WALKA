# DESIGN-006 — Motion + feedback + loading/offline state polish

Status: COMPLETED
Issue: #52
Parent: #46
Implementation branch: `agent/design-006-motion-state-polish`
Final implementation head: `c527520202e797a8e158bc4baf9fdc8806953db0`
Stable merge: `179aef0cb761b49a9dbb4c35cfd82897dea1a279`

## Stable prerequisite receipt

DESIGN-005 was owner-visible stable before this slice began:

- Issue: #51 — completed.
- PR: #65.
- Final feature head: `5583192ac200ef8e199a8faeaf812cdb9b812eff`.
- Branch Flutter run: `31346663707` / #361 — green.
- PR-context Flutter run: `31346813269` / #362 — green.
- Squash merge: `be2fa40d1c154ea94cf6b4a6d64e6666180c7a79`.
- Stable receipt/docs source before DESIGN-006: `e03bc24fd837c620b58cce937eb86ff2b2e6ff59`.

## Audit and design intent

The existing catalog architecture already failed soft and kept product discovery usable: controller startup began from bundled validated data, repository load attempted remote first, then valid cache, then bundled fallback. DESIGN-006 preserved that behavior rather than replacing it with a blocking full-screen loading state.

The presentation gaps addressed by this slice were duplicated page-level catalog banners, no shared motion contract, no explicit reduced-motion behavior, inconsistent press feedback, and no single semantics/live-region pattern for loading/cache/bundled states.

## Motion contract delivered

`WalkaMotion` now owns the WALKA timing hierarchy:

- card press: `110 ms`
- variant/selection change: `180 ms`
- bottom-navigation selection: `180 ms`
- route-transition budget: `240 ms`
- standard easing: `easeOutCubic`
- emphasized easing: `easeInOutCubic`
- reduced-motion / accessible-navigation: `0 ms` for WALKA-owned motion

Motion communicates state or touch response only. It does not delay navigation, block input, or animate layout dimensions.

## Implementation delivered

1. Added shared `WalkaMotion` duration/easing/reduced-motion utilities.
2. Added transform-only `WalkaPressFeedback` that leaves layout bounds unchanged and does not own the tap gesture.
3. Added one shared `WalkaCatalogStatusBanner` with live-region semantics for refreshing, saved-cache offline and bundled-fallback offline states.
4. Loading keeps the currently validated catalog interactive and never blanks the storefront.
5. Offline cache/bundled states provide Retry when a repository is available.
6. Reduced-motion loading replaces the indeterminate progress animation with a static gold state bar.
7. Added V130 resilient Home/Search/Categories wrappers around the validated V121/V122 pages.
8. Added a side-effect-free presentation proxy so duplicate legacy banners are masked without changing the real controller snapshot/source/load behavior or touching the global Amazon purchase registry.
9. Bottom navigation now uses the explicit WALKA selection duration.
10. Existing Search query/filter/empty-state recovery, Product Detail routing, Favorites persistence and Amazon handoff remain unchanged.

## Guardrails preserved

- Product Master facts unchanged.
- Remote → cache → bundled catalog fallback order unchanged.
- Stable Product/Variant IDs unchanged.
- Variant-aware Amazon purchase routing unchanged.
- Favorites persistence unchanged.
- No cart, checkout, payment or orders.
- `Images/` untouched.
- No ZIP delivery.
- `main` remained stable-only until PR-context validation passed.

## Validation receipt

### Branch

- Head: `c527520202e797a8e158bc4baf9fdc8806953db0`
- Workflow: `31348073672` / run #382 — green
- APK candidate artifact: `9048069441`
- Artifact SHA-256: `1dd684c9076c8eb593d169c623892fdb5b2f93fa3c466ff1c756123cad26b76e`

### Pull request

- PR: #67
- Workflow: `31348294447` / run #383 — green
- Synthetic-merge APK artifact: `9048156234`
- Artifact SHA-256: `b249d5971b8c99d0dafdba731d1a3474642009dcec1967718d88cc95099fe373`
- Analyze: green
- Full Flutter suite: green
- Android release APK build/upload: green

Focused regressions covered reduced-motion duration behavior, static loading under reduced motion, cache vs bundled fallback semantics/recovery, the presentation proxy contract, public shell at 320×568 with 1.3× text scale, Favorites scope integration, and exact press-feedback layout bounds.

### Stable main

- Squash merge commit: `179aef0cb761b49a9dbb4c35cfd82897dea1a279`
- Stable-main workflow: `31356959759` / run #384 — green
- Stable-main APK artifact: `9051059890`
- Stable-main artifact SHA-256: `8cdd39d8099a250fd0e6bbf392d49de4281e46bb50540a8f55ccf5cfaa3242e3`
- Verified APK publication commit: `471b3b1d6fd3c079e2aba090cd38860cde6778ac`
- Verified APK source commit: `179aef0cb761b49a9dbb4c35cfd82897dea1a279`
- Verified APK bytes: `51,129,002`
- Verified APK SHA-256: `44b6803ef6969e997bbac3237ab0ca7b22ac7f9baaa941be8c50b72fb8dfd4ba`

## Definition of done

- [x] Interaction feedback is consistent, calm and non-blocking.
- [x] Loading/offline/cache states belong to the WALKA premium system.
- [x] State surfaces are understandable to assistive technologies.
- [x] Reduced-motion behavior is explicit and test-covered.
- [x] No animation-induced layout shifts or blocked input.
- [x] Compact 320×568 + 1.3× regressions are green.
- [x] Flutter Analyze and full tests are green.
- [x] Android release APK candidates are green in branch and PR context.
- [x] Stable-main CI is green.
- [x] `Last verified APK/WALKA-latest.apk` was republished after the DESIGN-006 stable merge.

## Next

DESIGN-007 / #53 — cross-device visual QA + golden regression matrix — is now the next P0 design slice.
