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
| 4 | DESIGN-004 | Product Detail premium commerce hierarchy + gallery polish | #50 | COMPLETED |
| 5 | DESIGN-005 | Favorites + Account + information consistency | #51 | IN PROGRESS |
| 6 | DESIGN-006 | Motion + feedback + loading/offline state polish | #52 | P0 NEXT |
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

## DESIGN-004 stable receipt

- Issue: `#50` — completed through final reconciliation PR `#64`.
- Superseded working PR: `#63` — closed without merge after `main` advanced.
- Final validated PR head: `aa202b69c9d14e59a561a2adf5e4c203aa721f5b`.
- PR-context Flutter run: `31345555110` / run `#350` — green.
- PR APK candidate artifact: `9047257856`.
- Squash merge commit: `757dc066fce56f9cb0c70c31208d2b27ddffbc22`.
- Stable-main Flutter run: `31345765442` / run `#352` — green.
- Stable APK publication commit: `de69377c8d419c4a61bc5cb1aa818203f270617a`.
- Stable APK bytes: `51,014,306`.
- Stable APK SHA-256: `f39963ece4d16042e19e10a926423f3ef4357c0fe0b62a87ce25a8ea2e12fc70`.

### DESIGN-004 delivered

- Public V100 Drawer/Lunch entry points now promote the premium V110 Product Detail surface while retaining V10 as the legacy Product Master/behavior regression path.
- Product-led three-view gallery with explicit fullscreen/tap-to-zoom affordances and zoomable fullscreen interaction.
- Consolidated commerce hierarchy for title, verified facts, selected variant, variant controls and official-Amazon trust cue.
- SafeArea-aware adaptive Amazon purchase bar for compact widths and increased text scale.
- Persistent Drawer Favorites and variant-aware Amazon destinations preserved.
- Drawer/Lunch Product Master facts, approved Lunch spill-resistant guidance and care rules preserved.
- Focused compact 320×568 + 1.3× text-scale, gallery, share and variant-identity regressions green before merge.

## DESIGN-005 active execution boundary

Issue: `#51` — Favorites + Account + information consistency.

Branch: `agent/design-005-secondary-premium`.
Work receipt: `docs/work/DESIGN-005.md`.
Stable base: `de69377c8d419c4a61bc5cb1aa818203f270617a`.

### DESIGN-005 priorities

- Bring Favorites saved/empty states to the same product-led visual quality as Home, discovery and PDP.
- Preserve device-local Drawer Favorites persistence/removal/open behavior.
- Bring Account hierarchy up to the DESIGN-002 shell standard without inventing login/profile functionality.
- Harmonize About/Story, FAQ, Contact, Amazon Store, Social, Privacy, Terms and App Information navigation/presentation.
- Normalize shared headers, cards, dividers, spacing, icon treatment and touch targets.
- Reuse V102 corrected information/legal copy and Product Master facts rather than duplicating or inferring claims.
- Add compact 320×568 and 1.3× text-scaling regressions before merge.

### DESIGN-005 merge gate

- Flutter Analyze green on exact final PR head.
- Full Flutter test suite green.
- Favorites persistence/removal/open behavior green.
- Account/info routing contracts green.
- Empty/saved Favorites and Account compact/text-scale regressions green.
- Android release-mode APK candidate build/upload green.
- `main` untouched until all gates pass.
- After merge, stable-main CI must pass independently and republish `Last verified APK/WALKA-latest.apk` sourced from the DESIGN-005 merge commit.

## DESIGN-006 next execution boundary

Issue: `#52` — motion, feedback, loading/offline state polish.

Do not begin owner-visible DESIGN-006 runtime changes until DESIGN-005 reaches stable `main` with a matching verified APK receipt.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
