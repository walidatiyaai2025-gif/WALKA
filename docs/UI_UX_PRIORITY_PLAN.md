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
| 3 | DESIGN-003 | Categories + Search discovery refinement | #49 | COMPLETED |
| 4 | DESIGN-004 | Product Detail premium commerce hierarchy + gallery polish | #50 | IN PROGRESS |
| 5 | DESIGN-005 | Favorites + Account + information consistency | #51 | P0 NEXT |
| 6 | DESIGN-006 | Motion + feedback + loading/offline state polish | #52 | P0 QUEUED |
| 7 | DESIGN-007 | Cross-device visual QA + golden regression matrix | #53 | P0 QUEUED |

Parent design program: #46.

## DESIGN-003 stable receipt

- Squash merge: `56863f06b603234e706a4be60509d8b166f84c64`.
- Stable-main Flutter Preview: run `31344297255` (#333), green.
- Verified APK publication commit: `5e636306d62ce7e405816d77d58a184c1dda09d1`.
- `Last verified APK/VERIFIED_BUILD.md` points to the DESIGN-003 merge commit.

## DESIGN-004 active implementation

Branch: `agent/design-004-premium-pdp`

### Problem

The released V10 Drawer and Lunch Product Detail surfaces already provide the correct Product Master facts, fullscreen gallery, share treatment and Amazon handoff. The remaining gap is commerce hierarchy: gallery, selected variant, verified facts, care/trust language and the Amazon action should read as one deliberate premium purchase surface rather than a sequence of independent widgets.

### Implementation direction

- Keep `product_experience_v10.dart` as the verified legacy/product-copy path and build DESIGN-004 as the next public Product Detail surface.
- Make the selected product/variant and Amazon purchase action immediately legible after the gallery.
- Use WALKA product-led visuals and a calmer editorial gallery treatment with explicit fullscreen/zoom/share affordances.
- Make the persistent Amazon action adaptive instead of depending on a fixed-width desktop-like button treatment.
- Keep Drawer and Lunch on one component system while preserving product-specific facts and approved usage/care language.
- Preserve Drawer persistent Favorites behavior and all variant-aware Amazon URLs.
- Preserve `docs/PRODUCT_MASTER.md` as the only fact source; do not add inferred specs or leakproof claims.
- Add focused compact-width and 1.3× text-scale regressions for both Product Detail families.

### Merge gate

- Flutter Analyze green.
- Full Flutter test suite green.
- Drawer and Lunch DESIGN-004 behavior tests green.
- 320×568 + 1.3× text-scaling Product Detail regressions green.
- Fullscreen gallery/zoom/share discoverability green.
- Product Master copy and Amazon routing contracts preserved.
- Android release-mode APK candidate build/upload green.
- Stable `main` remains untouched until the above gates pass.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
