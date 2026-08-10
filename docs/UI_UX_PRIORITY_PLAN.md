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
| 4 | DESIGN-004 | Product Detail premium commerce hierarchy + gallery polish | #50 | P0 NEXT |
| 5 | DESIGN-005 | Favorites + Account + information consistency | #51 | P0 QUEUED |
| 6 | DESIGN-006 | Motion + feedback + loading/offline state polish | #52 | P0 QUEUED |
| 7 | DESIGN-007 | Cross-device visual QA + golden regression matrix | #53 | P0 QUEUED |

Parent design program: #46.

## DESIGN-003 stable receipt

- Issue: `#49` — completed.
- PR: `#61`.
- Final validated PR head: `26aa79dbae88f16dc2f2fc4d27446200a24a1040`.
- PR-context Flutter run: `31344067109` — green.
- Stable merge commit: `56863f06b603234e706a4be60509d8b166f84c64`.
- Stable-main Flutter run: `31344297255` — green.
- Stable APK publication commit: `5e636306d62ce7e405816d77d58a184c1dda09d1`.
- Verified APK SHA-256: `68759ecca4858804d5f80267eb71bf1e369e0e9b81a974ef19ed75e5c4def9e1`.
- Compact 320×568 and 1.3× text-scaling regressions are part of the full Flutter gate.

### DESIGN-003 delivered

- Product-led Categories with Drawer/Lunch editorial family presentation.
- Product-led Search results and preserved All / Drawer / Lunch filtering semantics.
- Reusable `WalkaProductVisual` replaces generic product icons as the dominant discovery visual.
- Remote/cache/bundled catalog path, stable Product/Variant IDs and token matching remain unchanged.
- Product Detail routing and variant-aware Amazon handoff remain unchanged.
- Search empty-state recovery and compact/scaled layouts are regression-tested.

## DESIGN-004 next execution boundary

Issue: `#50` — Product Detail premium commerce hierarchy + gallery polish.

The next slice should improve the existing Drawer and Lunch Product Detail experience without changing Product Master facts or the Amazon purchase architecture.

### DESIGN-004 priorities

- Strengthen product-first image/gallery hierarchy and gallery affordances.
- Make selected variant, title, key facts and official Amazon action immediately clear.
- Harmonize Drawer and Lunch PDP structure while preserving family-specific facts and care/safety language.
- Keep zoom/share/gallery behavior discoverable and accessible.
- Keep the Amazon purchase action prominent without introducing in-app cart/checkout/payment.
- Preserve stable Product/Variant IDs and API-driven purchase destinations.
- Add compact-width and text-scale regressions before merge.
- Require Flutter Analyze, full tests, Android release APK candidate and stable-main verified APK publication.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
