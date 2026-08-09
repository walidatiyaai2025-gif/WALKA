# WALKA Development Status

Last updated: 2026-08-10

## Current stable state

**Flutter visual freeze 1.0.0: COMPLETED**  
**Laravel API foundation 1.1.0: COMPLETED**  
**Flutter ↔ Laravel catalog integration 1.2.0: COMPLETED**

Stable `main` currently contains WALKA Flutter `1.2.0+120` at source commit `c756c4f7c7ce316616315193f64db95efdb9bbc0`.

Two isolated team slices are currently active above that stable baseline:

- **API-003 / 1.3.0 — Database-backed catalog persistence**: issue `#41`, draft PR `#42`, backend-only scope preserving the Flutter 1.2 API contract.
- **OPS-001 — Stable main + persistent last verified APK delivery**: issue `#43`, branch `agent/ops-001-stable-apk-delivery`. This delivery slice adds repository-wide engineering rules and makes `main/Last verified APK/WALKA-latest.apk` the owner-facing Android test target after a successful stable-main build.

The owner tests only what is on `main`. Branch builds are engineering candidates and are not stable deliveries.

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
| API-003 | 1.3.0 | Database-backed Product/Variant catalog persistence | IN PROGRESS |
| OPS-001 | Delivery | Stable-main governance + persistent last verified APK | IN PROGRESS |

## OPS-001 stable delivery contract

- Root instructions: `AGENTS.md`
- Delivery policy: `docs/DELIVERY_POLICY.md`
- Stable APK folder: `Last verified APK/`
- Stable install file: `Last verified APK/WALKA-latest.apk`
- Verification receipt: `Last verified APK/VERIFIED_BUILD.md`
- No ZIP files are sent/offered in ChatGPT/project chat for owner testing.
- Feature/PR branches never replace the stable root APK.
- A new root APK is published only after a successful `main` Analyze + Test + release APK build.
- Failed or stale `main` runs leave the previous verified APK unchanged.
- APK-only publication commits do not retrigger the Flutter workflow.

### OPS-001 baseline discovery

The last stable API-002 `main` build before OPS-001 is workflow run `31340913267`, conclusion `success`, with artifact `9045832905`.

That existing workflow produced a debug APK. The extracted debug APK is `149,415,234` bytes with SHA-256 `07c34f148a80d8cb7f0f8b9fb38f7cb659b5cc96f04a623852ffda21f0abb9ca`, which is too large for normal direct GitHub repository storage. OPS-001 therefore changes stable delivery to an optimized release-mode installable APK, with an ARM64 release fallback if the universal release APK is still above the repository-safe threshold.

## API-002 authoritative release receipt — 1.2.0

- Release: `1.2.0`
- Package: `1.2.0+120`
- Issue: `#37`
- Authoritative PR: `#40`
- Superseded draft: `#39`
- Final PR head: `41aa25b6573372dc0ff87992313be7ca8c195468`
- PR Flutter workflow run: `31340458663` — green
- PR artifact ID: `9045704348`
- Merge/source commit on `main`: `c756c4f7c7ce316616315193f64db95efdb9bbc0`
- Stable `main` Flutter workflow run: `31340913267` — green
- Stable `main` artifact ID: `9045832905`

### API-002 delivered

- [x] Typed `/api/v1/health`, `/api/v1/config` and `/api/v1/catalog` mobile contracts
- [x] Remote → last-known-good cache → bundled Product Master fallback
- [x] SharedPreferences cache with corruption-safe reads
- [x] Stable Product/Variant contract validation for all five sellable variants
- [x] API-driven selected-variant Amazon destinations with deterministic ASIN fallback
- [x] Presentation adapter preserving the released Flutter 1.0 visual/navigation contract
- [x] Home/Search/Categories remote catalog integration
- [x] Favorites/Account behavior preserved
- [x] Loading/offline/cache state surfaced without blocking startup
- [x] Analyze green
- [x] Full Flutter suite green — 62 tests on authoritative PR head
- [x] Android runner generation green
- [x] Android APK build and artifact upload green
- [x] Squash-merged to stable `main`

### API-002 phase boundary

- No customer authentication or account sync.
- No remote Favorites sync.
- No database-backed catalog persistence in API-002; that is API-003.
- No cart, checkout, payment, orders, or Flutter visual redesign.
- Amazon remains the purchase destination.

## API-001 authoritative release receipt — 1.1.0

- Release: `1.1.0`
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
- [x] Drawer weight/packaging deliberately omitted because current Product Master does not verify them
- [x] Current Lunch food-grade PP, care/microwave rules and approved spill-resistance language preserved
- [x] `docs/API_V1_CONTRACT.md` added
- [x] Product Master contract test added
- [x] Backend CI runs for `backend/**` and `docs/PRODUCT_MASTER.md`
- [x] Composer manifest validation green
- [x] Composer dependency install green
- [x] Pint formatting gate green
- [x] Laravel feature tests green
- [x] `/api/v1` route smoke verification green
- [x] Flutter Analyze regression green
- [x] Flutter full test regression green
- [x] Android runner generation regression green
- [x] Android debug APK regression green
- [x] Flutter preview artifact upload green
- [x] PR #33 squash-merged to `main`

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

## Previous release receipts

| Release | Task | Final reference | Validated run | Artifact |
|---|---|---|---|---|
| `0.10.0` | UI-008 | PR #27 / `25540030642aad8ee79d53ddcc83c1a92e0c5ef3` | `31336273112` | `9044468109` |
| `0.9.0` | UI-007 | PR #22 / `830cc7b98fed6e59270db29c4a321199e0462bb0` | `31334834860` | `9044053306` |
| `0.8.0` | UI-006 | PR #19 / `797f9bbb4455b7d3e7973f4b61492a18e86f2e09` | `31333558586` | `9043684235` |
| `0.7.0` | STATE-001 | PR #16 / `a1b736cd71a3fbeece96675b35fa40e7e550ca80` | `31332976996` | `9043512197` |
| `0.6.0` | COM-001 | PR #13 / `4236573fd10e059e19df5b95e5285484db63e3a5` | `31332256549` | `9043300480` |

## API-003 execution boundary

API-003 moves the server-side catalog runtime storage to Laravel database persistence while preserving the public `/api/v1` response contract already consumed by Flutter 1.2.

Expected principles:

1. Preserve stable Product and Variant IDs.
2. Preserve current `/api/v1/catalog` response compatibility for Flutter 1.2.
3. Keep Product Master facts authoritative.
4. Keep Amazon selected-variant purchase destinations unchanged.
5. Use deterministic, idempotent database seeding.
6. Fail safely/observably if required catalog state is absent.
7. Keep Flutter visual/navigation architecture frozen.
8. Pass Backend API CI and Flutter regression CI before merge.

## Guardrails

1. `main` is stable-only and is the owner-facing source of truth.
2. `Images/` remains the master visual-reference folder and must not be modified by implementation tasks.
3. `docs/PRODUCT_MASTER.md` is the source of truth for product facts and approved usage/care language.
4. Product facts must not be inferred from mockups, stale branches or third-party catalog copies.
5. Backend and mobile work extend successful releases rather than replacing completed architecture.
6. New work stays in small, independently reviewable and releasable slices.
7. Every slice must pass the relevant backend and/or Flutter gates before merge.
8. Product copy must preserve approved lunch-box safety/usage language.
9. Laravel/API integration must not silently introduce in-app checkout or duplicate Amazon marketplace responsibilities.
10. Android owner testing uses `main/Last verified APK/WALKA-latest.apk`; ZIP files are not sent through project chat.
