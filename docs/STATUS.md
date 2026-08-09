# WALKA Development Status

Last updated: 2026-08-10

## Current state

**Flutter visual freeze 1.0.0: COMPLETED**  
**Laravel API foundation 1.1.0: COMPLETED**  
**Flutter ↔ Laravel catalog integration 1.2.0: COMPLETED**  
**Database-backed catalog persistence 1.3.0: COMPLETED**  
**OPS-001 stable-main + verified APK delivery: IN PROGRESS**  
**Premium UI/UX program: DESIGN-001 IN PROGRESS (P0)**

WALKA has a released Flutter storefront connected to a versioned Laravel 13 API with resilient mobile caching/fallback and a database-backed Product/Variant catalog. Public commerce still redirects to official Amazon product listings.

The owner-facing stable source is `main`. Implementation remains on dedicated task branches until the required CI gates are green. OPS-001 is establishing `Last verified APK/WALKA-latest.apk` as the persistent Android test target produced only from successful stable-main validation.

The current product priority is the P0 premium UI/UX program in `docs/UI_UX_PRIORITY_PLAN.md`: DESIGN-001 Home fidelity first, then shell/navigation, discovery, Product Detail, secondary screens, motion/state polish and cross-device QA. **API-004 remains planned but queued behind the P0 design program unless a critical backend/security/data blocker requires it sooner.**

## Release board

| ID | Release | Scope | Status |
|---|---|---|---|
| UI-001 | 0.1.0 | Foundation + Splash + App Shell + Home | COMPLETED |
| UI-002 | 0.2.0 | Home fidelity + Drawer Product Detail | COMPLETED |
| UI-003 | 0.3.0 | Categories + Drawer collection browsing | COMPLETED |
| UI-004 | 0.4.0 | Favorites + Account + About | COMPLETED |
| UI-005 | 0.5.0 | Android/iOS polish + accessibility QA | COMPLETED |
| COM-001 | 0.6.0 | Variant-aware Drawer Amazon handoff | COMPLETED |
| STATE-001 | 0.7.0 | Persistent Drawer Favorites/customer state | COMPLETED |
| UI-006 | 0.8.0 | Lunch Box collection + Blue/Pink/Green PDP | COMPLETED |
| UI-007 | 0.9.0 | Search + discovery + results/filter/sort states | COMPLETED |
| UI-008 | 0.10.0 | Product UX completion + gallery/share/related products | COMPLETED |
| UI-009 | 1.0.0 | Information screens + cross-platform visual freeze | COMPLETED |
| API-001 | 1.1.0 | Laravel 13 API foundation + Product/Variant catalog contract | COMPLETED |
| API-002 | 1.2.0 | Flutter remote catalog/config integration + resilient local fallback | COMPLETED |
| API-003 | 1.3.0 | Database-backed Product/Variant catalog persistence | COMPLETED |
| OPS-001 | Delivery | Stable `main` + persistent `Last verified APK` pipeline | IN PROGRESS |
| DESIGN-001 | P0 | Premium product-led Home fidelity | IN PROGRESS |
| DESIGN-002..007 | P0 | Premium shell, discovery, PDP, secondary UI, motion/state and QA | QUEUED |
| API-004 | 1.4.0 | Authenticated catalog administration + safe authoring API | QUEUED |

## Active delivery and design coordination

### OPS-001 — stable owner delivery

- Issue: `#43`
- Original draft PR: `#44` — validated on an older main baseline but became stale after API-003 advanced `main`; it must not be force-merged.
- Final reconciliation branch: `agent/ops-001-stable-apk-delivery-final` — rebuilt from current `main`.
- Root engineering rules: `AGENTS.md`.
- Delivery lifecycle: `docs/DELIVERY_POLICY.md`.
- Stable Android target: `Last verified APK/WALKA-latest.apk`.
- Stable build receipt: `Last verified APK/VERIFIED_BUILD.md`.
- PR/branch builds are candidates only; only a successful current-`main` run may publish the root APK.
- Stale main runs skip publication, APK-only publication commits do not recursively retrigger the Flutter workflow, and final publication remains fast-forward-only.
- User-facing Android delivery does not use ZIP files in project chat.

### DESIGN-001 — P0 Home premium fidelity

- Issue: `#47` under design program `#46`.
- PR: `#54`.
- Branch: `agent/design-001-home-premium`.
- Replaces generic icon-led Home presentation with reusable Drawer/Lunch product visuals, premium hero hierarchy, curated product cards and editorial Lunch presentation.
- Preserves API-002 catalog state, stable IDs, offline fallback, Search/Categories destinations and Amazon Product Detail routing.
- Compact 320×568 coverage is a required merge gate.
- DESIGN-002 is next only after DESIGN-001 is green and stable.

## API-003 authoritative release receipt — 1.3.0

- Issue: `#41`
- PR: `#42`
- Final validated head: `212e0613c3f46449f1c78b733637375cff243e9e`
- Backend API PR run: `31341500292` — green
- Flutter Preview PR run: `31341500448` — green
- Flutter preview artifact ID: `9046007309`
- Artifact ZIP SHA-256: `ce6cfc442a584f84c677e5025c3c6ed200d1a9de433ec38b70c9ff1d56c15de6`
- Squash merge commit: `041196e73da6af866bce19f3e647cc1e53c718f2`

### API-003 delivered

- [x] `products` and `product_variants` migrations with stable string primary keys
- [x] Eloquent `Product` and `ProductVariant` models
- [x] Ordered features/facts/variants and nullable Pantone persistence
- [x] Deterministic idempotent `WalkaCatalogSeeder`
- [x] Product-Master-aligned database seed blueprint
- [x] `CatalogRepository` abstraction + `EloquentCatalogRepository`
- [x] `GET /api/v1/catalog` reads database state
- [x] Existing API v1 Product/Variant success response shape preserved for Flutter 1.2
- [x] All five stable variant IDs, ASINs, Pantones and Amazon destinations preserved
- [x] Explicit HTTP `503` / `catalog_unavailable` behavior for migrated-but-unseeded databases
- [x] Product Master persisted contract tests
- [x] Seeder idempotency, runtime DB-read and empty-database tests
- [x] Backend CI verifies migration + production seed before Pint/tests/routes
- [x] Flutter Analyze/full tests/Android debug APK/artifact regression green
- [x] Local migration and seed workflow documented

### API-003 phase boundary

- The public catalog remains read-only.
- API v1 keys and stable Product/Variant IDs were not changed.
- Product facts remain governed by `docs/PRODUCT_MASTER.md`.
- Drawer weight/packaging remain unpublished while unverified.
- Amazon remains the purchase destination.
- No Admin UI/CMS, customer authentication, remote Favorites sync, cart, checkout, payment or order processing was introduced.

## API-002 authoritative release receipt — 1.2.0

- Issue: `#37`
- Final PR: `#40`
- Superseded draft PR: `#39`
- Final validated head: `41aa25b6573372dc0ff87992313be7ca8c195468`
- Flutter Preview PR run: `31340458663` — green
- Full Flutter tests: `62` passed
- Flutter preview artifact ID: `9045704348`
- Artifact ZIP SHA-256: `e8acfcfb75dd8be3d85e1877ddc599787717027f3211567e31a558f6ec687cda`
- Squash merge commit: `c756c4f7c7ce316616315193f64db95efdb9bbc0`

### API-002 delivered

- [x] Typed mobile `/api/v1/health`, `/config` and `/catalog` contracts
- [x] Configurable `WALKA_API_BASE_URL`
- [x] Remote → last-known-good cache → bundled Product Master fallback
- [x] SharedPreferences cache with corruption-safe reads
- [x] Stable Product/Variant ID and metadata validation
- [x] Frozen presentation adapter preserving the released titles/order/navigation
- [x] Home, Search and Categories consume catalog state
- [x] Final V100 Product Detail visual experience preserved
- [x] API-driven selected-variant Amazon destinations with deterministic ASIN fallback
- [x] Fresh-install offline browsing preserved
- [x] Non-blocking loading/cache/offline status
- [x] Flutter package `1.2.0+120`
- [x] Analyze, 62 tests, Android runner, APK and artifact upload green

### API-002 phase boundary

- No server database authoring was introduced in API-002; API-003 added that persistence separately.
- Local Favorites behavior remains unchanged.
- No customer authentication, remote Favorites sync, cart, checkout, payment or orders were introduced.

## API-001 authoritative release receipt — 1.1.0

- Issue: `#20`
- Final PR: `#33`
- Superseded pre-1.0 draft: `#21`
- API namespace: `/api/v1`
- Final validated head: `73df4267870edfdbdd92003cc0f4686fe999e3b6`
- Backend API workflow run: `31338048724` — green
- Flutter Preview regression run: `31338048657` — green
- Merge commit: `c39f217f41e3df6ee15b95fc56c985218e779daa`

### API-001 delivered

- [x] Dedicated `backend/` Laravel 13 application
- [x] PHP 8.3+ runtime contract
- [x] `GET /api/v1/health`
- [x] `GET /api/v1/config`
- [x] `GET /api/v1/catalog`
- [x] Typed Product + Variant API contract
- [x] Stable product and variant IDs
- [x] All five current sellable variants exposed
- [x] Variant-aware ASIN and official Amazon `purchase_url`
- [x] Lunch Pantone metadata exposed
- [x] Typed Product Master facts exposed through `facts`
- [x] Product Master contract tests and dedicated Backend API CI

## UI-009 authoritative release receipt — 1.0.0

PR #32 is the authoritative UI-009 Product Master / final-copy reconciliation and supersedes the stale product-copy state from PR #29.

- Release: `1.0.0`
- Package: `1.0.0+100`
- Issue: `#26`
- Authoritative reconciliation PR: `#32`
- Final reconciliation merge commit: `e531a618bfb1656cf9045ef680a1607c2c382035`
- Validated `main` workflow run: `31337710628`
- Final `main` artifact ID: `9044893446`
- Final `main` artifact SHA-256: `f261ee7e891eb0db2699b0ae71794bf17087f4e815916b63c4690cb33425d9ef`
- Extracted final APK SHA-256: `bc7c251b9168d24451f53d0bf79e3fc1009feb538065a9393865b862ec730ae3`

### UI-009 delivered

- [x] `1.0.0+100` real application package version
- [x] Final Home / Search / Categories / Favorites / Account experience
- [x] Final Product Detail entry points for all five variants
- [x] Fullscreen gallery / zoom / share / related-product treatment
- [x] Selected-variant Amazon handoff
- [x] Information/legal/account screens
- [x] Persistent Drawer Favorites
- [x] Product Master copy contracts
- [x] Compact-phone, text-scale, large-mobile and accessibility regression gates

## Previous release receipts

| Release | Task | Final reference | Validated run | Artifact |
|---|---|---|---|---|
| `0.10.0` | UI-008 | PR #27 / `25540030642aad8ee79d53ddcc83c1a92e0c5ef3` | `31336273112` | `9044468109` |
| `0.9.0` | UI-007 | PR #22 / `830cc7b98fed6e59270db29c4a321199e0462bb0` | `31334834860` | `9044053306` |
| `0.8.0` | UI-006 | PR #19 / `797f9bbb4455b7d3e7973f4b61492a18e86f2e09` | `31333558586` | `9043684235` |
| `0.7.0` | STATE-001 | PR #16 / `a1b736cd71a3fbeece96675b35fa40e7e550ca80` | `31332976996` | `9043512197` |
| `0.6.0` | COM-001 | PR #13 / `4236573fd10e059e19df5b95e5285484db63e3a5` | `31332256549` | `9043300480` |

## API-004 execution boundary

API-004 remains the next backend capability after the current P0 delivery/design work. It should add protected catalog authoring without weakening the released public contract.

Expected principles:

1. Authentication/authorization applies only to administrative write surfaces.
2. Public `GET /api/v1/catalog` remains backward compatible and read-only.
3. Product/Variant stable IDs cannot be silently replaced.
4. Product facts and approved usage/care copy remain governed by `docs/PRODUCT_MASTER.md`.
5. Writes require validation for ASIN, Amazon destination, Pantone, ordering and required facts.
6. Changes are auditable and safe to roll back/reconcile.
7. Flutter 1.2 does not require an API-driven navigation rewrite.
8. No cart, checkout, payment or order processing is introduced by catalog administration.

## Guardrails

1. `main` is stable-only and is the owner-facing source of truth.
2. Implementation work uses dedicated task branches and only reaches `main` after the relevant CI gates are green.
3. `Last verified APK/WALKA-latest.apk` is the owner-facing Android install target once OPS-001 is released; failed/stale builds must not replace it.
4. Do not send or offer ZIP files through project chat for Android delivery.
5. `Images/` remains the master visual-reference folder and must not be modified by implementation tasks.
6. `docs/PRODUCT_MASTER.md` is the source of truth for product facts and approved usage/care language.
7. Product facts must not be inferred from mockups, stale branches or third-party catalog copies.
8. Backend and mobile work extend successful releases rather than discarding completed architecture.
9. New work stays in small, independently reviewable and releasable slices.
10. Every slice must pass the relevant backend and/or Flutter gates before merge.
11. Product copy must preserve approved lunch-box safety/usage language.
12. Laravel/API integration must not silently introduce in-app checkout or duplicate Amazon marketplace responsibilities.
