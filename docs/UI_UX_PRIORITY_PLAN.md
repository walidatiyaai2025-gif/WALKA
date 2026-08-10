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
| 5 | DESIGN-005 | Favorites + Account + information consistency | #51 | COMPLETED |
| 6 | DESIGN-006 | Motion + feedback + loading/offline state polish | #52 | COMPLETED |
| 7 | DESIGN-007 | Cross-device visual QA + golden regression matrix | #53 | P0 NEXT |

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

## DESIGN-005 stable receipt

- Issue: `#51` — completed.
- PR: `#65`.
- Final branch head: `5583192ac200ef8e199a8faeaf812cdb9b812eff`.
- Branch workflow: `31346663707` / run `#361` — green.
- Branch APK candidate artifact: `9047608673`.
- Branch artifact SHA-256: `53a1325013ddeb4169f1913c41f86c388b432b7195e8e70bde07f08bdb6c27d6`.
- PR-context workflow: `31346813269` / run `#362` — green.
- PR synthetic-merge APK artifact: `9047655597`.
- PR artifact SHA-256: `dda255d88d00400484bdeec9e22d026791db4b1d2b3eb51b08f516fcd219ecbd`.
- Squash merge commit: `be2fa40d1c154ea94cf6b4a6d64e6666180c7a79`.
- Stable-main Flutter run: `31347074138` / run `#363` — green.
- Stable APK publication commit: `fe5295b2663de683b8cd7c4ac771540890bfbda9`.
- Stable APK bytes: `51,079,850`.
- Stable APK SHA-256: `0e84156206943365294bd1d429aa31634ec8790ed2924ed960cf3a4f0bf4d46e`.

### DESIGN-005 delivered

- Product-led Favorites empty state using the shared WALKA product visual language.
- Saved Drawer Organizer White/Gray cards with verified Drawer facts and direct premium Product Detail navigation.
- Existing device-local Favorites persistence/removal contract preserved unchanged.
- Premium Account hero and normalized Product & Support / Official Destinations / Legal & App grouping.
- Complete Our Story, FAQ, Contact, Amazon Store, Social, Privacy and Terms routes preserved.
- App Information now reflects connected `1.2.0+120`, versioned WALKA API + local fallback, official Amazon handoff, device-local Favorites and stable verified-APK delivery.
- No customer account/sign-in model invented.
- Compact 320×568 and 1.3× text-scaling regressions added for empty/saved Favorites, Account and App Information.
- Analyze, full Flutter tests, release APK candidate, stable-main rebuild and verified APK publication all green.

## DESIGN-006 stable receipt

- Issue: `#52` — completed.
- PR: `#67`.
- Final branch head: `c527520202e797a8e158bc4baf9fdc8806953db0`.
- Branch workflow: `31348073672` / run `#382` — green.
- Branch APK candidate artifact: `9048069441`.
- Branch artifact SHA-256: `1dd684c9076c8eb593d169c623892fdb5b2f93fa3c466ff1c756123cad26b76e`.
- PR-context workflow: `31348294447` / run `#383` — green.
- PR synthetic-merge APK artifact: `9048156234`.
- PR artifact SHA-256: `b249d5971b8c99d0dafdba731d1a3474642009dcec1967718d88cc95099fe373`.
- Squash merge commit: `179aef0cb761b49a9dbb4c35cfd82897dea1a279`.
- Stable-main Flutter run: `31356959759` / run `#384` — green.
- Stable-main APK artifact: `9051059890`.
- Stable-main artifact SHA-256: `8cdd39d8099a250fd0e6bbf392d49de4281e46bb50540a8f55ccf5cfaa3242e3`.
- Stable APK publication commit: `471b3b1d6fd3c079e2aba090cd38860cde6778ac`.
- Stable APK source commit: `179aef0cb761b49a9dbb4c35cfd82897dea1a279`.
- Stable APK bytes: `51,129,002`.
- Stable APK SHA-256: `44b6803ef6969e997bbac3237ab0ca7b22ac7f9baaa941be8c50b72fb8dfd4ba`.

### DESIGN-006 delivered

- Shared `WalkaMotion` timing/easing contract for 110 ms press, 180 ms selection/navigation and 240 ms emphasis/route-transition budget.
- Explicit reduced-motion/accessibility handling collapses WALKA-owned animation to zero duration.
- Transform-only `WalkaPressFeedback` keeps layout metrics and gesture ownership stable.
- Bottom navigation now uses the explicit WALKA motion contract.
- Shared live-region catalog status surface covers refreshing, saved-cache offline and bundled-fallback offline states.
- Catalog refresh remains non-blocking; the last validated catalog stays browsable.
- Cache/bundled states expose Retry only when a repository is available.
- Reduced-motion loading uses a static gold state bar rather than an indeterminate animation.
- Home, Search and Categories use V130 resilient wrappers while preserving the validated V121/V122 presentation and Search state.
- A side-effect-free presentation proxy suppresses duplicate legacy banners without changing the real catalog source/fallback/retry behavior.
- Product Master facts, stable IDs, Amazon handoff, Favorites persistence and `Images/` remain unchanged.
- Compact 320×568, 1.3× text scale, reduced-motion, semantics, press-layout and catalog-resilience regressions are green.

## DESIGN-007 active next execution boundary

Issue: `#53` — cross-device visual QA + golden regression matrix.

DESIGN-006 is now owner-visible stable with a matching verified APK receipt, so DESIGN-007 is unblocked and is the next P0 design slice. It should validate the completed premium system across compact/standard/large mobile widths, increased text scale and critical owner-visible flows without reopening completed visual architecture.

## Design program Definition of Done

The P0 design program is complete only when Home, navigation, discovery, PDPs, secondary screens and state/motion behavior form one consistent premium system and the cross-device visual QA slice is green. Each merged slice must remain independently installable from stable `main` through the verified APK delivery contract.
