# WALKA Premium Mobile UI/UX Priority Plan

Last updated: 2026-08-10

## Priority directive

**UI/UX is P0.** Until this program is completed, design-quality work is the first product priority unless a critical build/security/data blocker prevents a design slice from shipping.

The owner reviews only stable `main`. Every design slice is implemented on a dedicated branch, validated through Flutter CI, merged only when stable, then exposed through the latest verified APK process.

## Experience target

WALKA should feel like a premium US-market home-organization brand, not a generic marketplace app:

- Deep navy `#003366` for structure, typography and active states.
- Muted gold `#D4AF37` for restrained accents and primary action emphasis.
- Warm ivory/light neutral surfaces and generous negative space.
- Editorial hierarchy with product-led storytelling.
- Product-family visuals must dominate over generic Material icons.
- Calm, precise interaction feedback; no gratuitous motion.
- Android-first APK review with adaptive iOS-safe layouts.
- Accessibility and compact-device support are part of visual quality, not a later cleanup step.

## P0 execution queue

| Order | Task | Scope | GitHub | Status |
|---|---|---|---|---|
| 1 | DESIGN-001 | Home premium visual fidelity + product presentation | #47 | COMPLETED |
| 2 | DESIGN-002 | App shell + bottom navigation premium polish | #48 | COMPLETED |
| 3 | DESIGN-003 | Categories + Search discovery refinement | #49 | IN PROGRESS |
| 4 | DESIGN-004 | Product Detail premium commerce hierarchy + gallery polish | #50 | P0 NEXT |
| 5 | DESIGN-005 | Favorites + Account + information consistency | #51 | P0 QUEUED |
| 6 | DESIGN-006 | Motion + feedback + loading/offline state polish | #52 | P0 QUEUED |
| 7 | DESIGN-007 | Cross-device visual QA + golden regression matrix | #53 | P0 QUEUED |

Parent design program: #46.

## DESIGN-003 active implementation

Branch: `agent/design-003-premium-discovery`

### Problem

The released Search and Categories flows are functionally sound, but their dominant product surfaces still use generic `grid_view` and `lunch_dining` Material icons. That creates a visible quality gap next to the product-led DESIGN-001 Home and the shared premium DESIGN-002 shell.

### Implementation direction

- Replace dominant generic product icons in Categories and Search results with the reusable `WalkaProductVisual` family presentation.
- Give Drawer Organizer and Lunch Box distinct editorial family treatments while keeping one WALKA visual system.
- Preserve the released remote/cache/bundled catalog data path, stable Product/Variant IDs and search token matching.
- Preserve All / Drawer / Lunch family filtering and Product Detail routing.
- Improve search-field focus treatment, result count/source metadata and no-results recovery without changing semantics.
- Keep adaptive shell gutters and shared `WalkaWordmark` treatment from DESIGN-002.
- Add compact 320×568 regressions plus focused search/filter behavior tests.

### Merge gate

- Flutter Analyze green.
- Full Flutter test suite green.
- DESIGN-003 focused compact Categories regression green.
- Search query/filter/empty-state regressions green.
- Android release-mode APK candidate build/upload green.
- Stable `main` remains untouched until the above gates pass.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
