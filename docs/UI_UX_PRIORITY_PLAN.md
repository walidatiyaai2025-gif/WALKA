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
| 1 | DESIGN-001 | Home premium visual fidelity + product presentation | #47 | IN PROGRESS |
| 2 | DESIGN-002 | App shell + bottom navigation premium polish | #48 | P0 NEXT |
| 3 | DESIGN-003 | Categories + Search discovery refinement | #49 | P0 QUEUED |
| 4 | DESIGN-004 | Product Detail premium commerce hierarchy + gallery polish | #50 | P0 QUEUED |
| 5 | DESIGN-005 | Favorites + Account + information consistency | #51 | P0 QUEUED |
| 6 | DESIGN-006 | Motion + feedback + loading/offline state polish | #52 | P0 QUEUED |
| 7 | DESIGN-007 | Cross-device visual QA + golden regression matrix | #53 | P0 QUEUED |

Parent design program: #46.

## DESIGN-001 active implementation

### Problem found

The API-002 Home is structurally complete, but visible product surfaces rely heavily on generic `grid_view` / `lunch_dining` Material icons. This weakens perceived quality in the APK because the product is not the visual hero.

### Active solution

- Introduce an asset-free reusable `WalkaProductVisual` presentation component.
- Render distinguishable Drawer Organizer and Lunch Box silhouettes using deterministic Flutter painting.
- Use real variant colors for White/Gray and Blue/Pink/Green presentation.
- Replace icon-led Home hero/product presentation with product-led visuals.
- Strengthen editorial hierarchy, CTA treatment and product-card metadata.
- Preserve the API-002 catalog controller, stable product/variant IDs, offline fallback and Amazon routing.

### Merge gate

- Flutter Analyze green.
- Full Flutter test suite green.
- DESIGN-001 focused compact-width tests green.
- Android APK build green.
- No regression to Search, Categories, Favorites, Account or PDP routes.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
