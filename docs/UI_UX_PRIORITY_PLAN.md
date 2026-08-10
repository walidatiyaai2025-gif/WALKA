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

## DESIGN-004 active execution boundary

Issue: `#50` — Product Detail premium commerce hierarchy + gallery polish.

Final reconciliation branch: `agent/design-004-premium-pdp-final`.

The implementation is reconciled onto the latest stable `main`, including the DESIGN-003 documentation receipt and latest verified-APK publication commit. The earlier working PR #63 remains a validation branch only and must not be merged after the documentation divergence.

### DESIGN-004 delivered on the branch

- Promotes the public V100 Drawer/Lunch entry points to the new premium V110 Product Detail surface while retaining V10 as a legacy copy/behavior regression reference.
- Adds a product-led three-view gallery with explicit fullscreen and tap-to-zoom affordances plus a zoomable `InteractiveViewer` fullscreen experience.
- Consolidates title, verified facts, selected variant, variant controls and official-Amazon trust cue directly below the gallery.
- Replaces the fixed-width purchase treatment with a SafeArea-aware responsive Amazon bar that stacks on compact width and elevated text scale.
- Keeps Drawer persistent Favorites on the existing controller and keeps variant-aware Amazon destinations on the existing commerce registry.
- Harmonizes Drawer and Lunch hierarchy through shared premium fact cards, editorial panels, disclosures and related-collection presentation.
- Preserves approved Lunch spill-resistant, dry-meal and upright-carry guidance and documented care rules.
- Keeps Drawer claims restricted to Product Master facts: plastic, 8 compartments, 13 × 15 × 2 in, expandable to 22.4 in, non-slip base, White/Gray.
- Adds focused Drawer/Lunch compact 320×568 at 1.3× text-scaling coverage, gallery/fullscreen behavior, variant identity behavior and share-sheet discovery tests.
- Fixes a real unbounded related-product visual found by CI without changing the shared product visual contract.

### Reconciliation/validation state

- Latest stable base before final reconciliation: `1c577ebb0f56bb5e219273dd80ff6de0ba1772ef`.
- Pre-reconciliation implementation head: `a69efe941e844dd98963ea29b34c9f76e8051930`.
- Pre-reconciliation Flutter Preview run: `31345401042` (#346).
- Flutter Analyze: green.
- Full Flutter tests: green.
- Android release APK build/artifact remains a required gate before the final PR can become Ready.
- The final reconciliation branch must independently rerun all gates against current `main`; the pre-reconciliation result alone is not merge authorization.

### DESIGN-004 merge gate

- Flutter Analyze green on the exact final PR head.
- Full Flutter suite green, including direct V10 legacy contracts.
- Drawer and Lunch DESIGN-004 behavior tests green.
- 320×568 + 1.3× text-scaling Product Detail regressions green.
- Fullscreen gallery/zoom/share discoverability green.
- Product Master copy and Amazon routing contracts preserved.
- Android release-mode APK candidate build/upload green.
- Stable `main` untouched until those gates pass.
- After merge, stable-main CI must pass independently and republish `Last verified APK/WALKA-latest.apk` sourced from the DESIGN-004 merge commit.

## DESIGN-005 next execution boundary

Issue: `#51` — Favorites + Account + information consistency.

Do not begin owner-visible DESIGN-005 changes until DESIGN-004 reaches stable `main` and a matching verified APK receipt exists. Audit work may happen earlier, but runtime changes remain on a separate branch.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
