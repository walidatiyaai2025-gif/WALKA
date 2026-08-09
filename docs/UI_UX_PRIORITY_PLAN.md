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
| 2 | DESIGN-002 | App shell + bottom navigation premium polish | #48 | IN PROGRESS |
| 3 | DESIGN-003 | Categories + Search discovery refinement | #49 | P0 NEXT |
| 4 | DESIGN-004 | Product Detail premium commerce hierarchy + gallery polish | #50 | P0 QUEUED |
| 5 | DESIGN-005 | Favorites + Account + information consistency | #51 | P0 QUEUED |
| 6 | DESIGN-006 | Motion + feedback + loading/offline state polish | #52 | P0 QUEUED |
| 7 | DESIGN-007 | Cross-device visual QA + golden regression matrix | #53 | P0 QUEUED |

Parent design program: #46.

## DESIGN-002 active implementation

Branch: `agent/design-002-premium-shell`

### Problem

The released five-destination information architecture is sound, but persistent app chrome still relies on mostly default Material navigation treatment and locally repeated wordmark/header styling. That makes screen-to-screen polish less coherent than the new DESIGN-001 Home presentation.

### Implementation direction

- Centralize shell metrics, WALKA wordmark, top-level circular icon action and bottom navigation in reusable design-system primitives.
- Keep Home, Search, Categories, Favorites and Account in the released order with no route rewrite.
- Reduce navigation visual weight while preserving visible labels and minimum 48dp touch targets.
- Handle bottom system insets inside the shared navigation component.
- Standardize adaptive gutters and vertical section rhythm for subsequent DESIGN-003..005 work.
- Document the shared shell contract in `docs/DESIGN_SYSTEM_SHELL.md`.
- Preserve catalog state, offline fallback, Favorites persistence, Product Master facts and Amazon routing.

### Merge gate

- Flutter Analyze green.
- Full Flutter test suite green.
- DESIGN-002 focused 320×568 navigation regression green.
- 48dp shared icon-action target regression green.
- Android release-mode APK candidate build/upload green.
- Stable `main` remains untouched until the above gates pass.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
