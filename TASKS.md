# WALKA UI Implementation — Full Atomic Task Master Plan

Last audited: 2026-08-10
Repository: `walidatiyaai2025-gif/WALKA`
Primary implementation: Flutter under `mobile/`
Visual source: protected `Images/` reference masters

## 1. Mission

Implement the approved WALKA UI references as a modular Flutter system that is easy for multiple developers to work on concurrently. Every visual unit must be small, reusable, independently testable, Theme-aware, adaptive, and safe to merge into stable `main` only after validation.

### Source-of-truth order

1. **Product facts / claims / destinations:** `docs/PRODUCT_MASTER.md` and released behavior.
2. **Visual hierarchy / spacing / composition:** `Images/` references.
3. **Engineering / delivery rules:** `AGENTS.md` and `docs/DELIVERY_POLICY.md`.
4. **Existing implementation contracts:** current stable `main` Flutter code and tests.

Mock prices, ratings, VIP/account data, orders, payments, cart/checkout, unsupported product counts, and unsupported product claims visible in design references must **not** be invented in production UI.

---

## 2. Reference image audit

18 image files are currently present in `Images/`.

| Family | Android | iOS | PC/Desktop | Notes |
|---|---|---|---|---|
| Home / Landing | `Home for Android.png` | `Home for ios.png` | `Home for pc.png` | Complete 3-platform set |
| Product Detail | `Product page for Android.png` | `Product page for ios.png` | — | PC reference is not explicitly named |
| About / Story | `About for Android.png` | `About for ios.png` | `About page for PC.png` | Complete 3-platform set |
| Favorites | `Faivorets page for Android.png` | `Faivorets page for ios.png` | `Faivorets page for PC.png` | Complete 3-platform set; filename typo retained as source reference |
| Categories | `Categories page for Android.png` | `Categories page for ios.png` | — | PC reference is not explicitly named |
| Account Profile | `Account profile page for Android.png` | `Account profile page for ios.png` | `Account profile page for PC.png` | Complete 3-platform set |
| Duplicate/unnamed | `ChatGPT Image Aug 9, 2026, 08_12_03 PM.png` | — | — | Same Git blob as Account Android reference; treat as duplicate |
| Unclassified | `f96465c7-d756-4409-9963-d96bb6b5893e.png` | — | — | Must be classified before implementation |

**Important:** `Images/` is read-only for implementation tasks.

---

## 3. Current stable implementation status

The Android fidelity program is already partially delivered. Do not redo completed visual work; modularize and extend it safely.

| Slice | Status | Tracking |
|---|---|---|
| Android Home reference fidelity | ✅ COMPLETED / stable on `main` | Issue #72 / PR #73 |
| Android Categories + Search consistency | ✅ COMPLETED / stable on `main` | Issue #74 / PR #75 |
| Android Product Detail reference fidelity | ✅ COMPLETED / stable on `main` | Issue #76 / final PR #80 |
| Android Favorites reference fidelity | ✅ COMPLETED / stable on `main` | Issue #78 / PR #81 |
| Android Account + About fidelity | ✅ COMPLETED / stable on `main` | Issue #82 / PR #83 |
| Cross-screen modularization | ⬜ TODO | This plan |
| iOS reference parity | ⬜ TODO | This plan |
| PC/Desktop reference parity | ⬜ TODO | This plan |
| Final golden/screenshot matrix | ⬜ TODO | DESIGN-007 / #53 after fidelity program |

### Existing architecture to reuse

- `mobile/lib/design_system/walka_theme.dart`
- `mobile/lib/design_system/walka_adaptive.dart`
- `mobile/lib/design_system/walka_motion.dart`
- `mobile/lib/design_system/walka_shell.dart`
- `mobile/lib/design_system/walka_product_visual.dart`
- `mobile/lib/features/storefront/...`
- `mobile/lib/features/products/...`
- `mobile/lib/features/favorites/...`

Current adaptive shell is mobile-oriented and constrains primary content to 560px. Desktop references therefore require an explicit wide-layout architecture rather than simply stretching phone layouts.

---

## 4. Mandatory development rules

For **every atomic task** below:

1. Create/confirm a GitHub Issue or subtask reference.
2. Branch: `agent/<task-id>-<short-name>` from current stable `main`.
3. One component/slice per branch whenever practical.
4. New reusable widgets live in their own small file; do not grow existing 20–50 KB feature files further.
5. Use `WalkaColors`, `WalkaSpacing`, `WalkaRadius`, `WalkaType`, adaptive metrics, and `WalkaMotion`; do not hard-code a second design system.
6. Add focused Widget/Golden/Semantics tests for the component.
7. Run relevant Flutter gates: dependency resolution, format, analyze, full tests, Android runner validation, release APK build.
8. Open PR; no direct experimental work on `main`.
9. Merge immediately once required checks are green and scope is stable.
10. After owner-visible screen assembly changes, stable `main` must produce/update `Last verified APK/WALKA-latest.apk` and its receipt.
11. Never replace `Images/` masters.
12. Never send ZIP deliverables to the owner.

### Target presentation structure

```text
mobile/lib/
  design_system/
    components/
      buttons/
      cards/
      chrome/
      feedback/
      media/
      typography/
  features/
    storefront/presentation/
      pages/
      widgets/
    products/presentation/
      pages/
      widgets/
    favorites/presentation/
      pages/
      widgets/
    information/presentation/
      pages/
      widgets/
```

A page file should mostly compose widgets; it should not contain dozens of private widget classes.

---

# 5. Full Atomic Backlog

Legend: ✅ Done | 🟡 In progress | ⬜ Todo | ⛔ Blocked | ♻️ Existing code to extract/refactor

## A. Reference audit & coordination

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| REF-001 | ✅ | Architecture | Inventory all `Images/` references | Screen/platform matrix in this file |
| REF-002 | ✅ | Architecture | Detect duplicate image blobs | Duplicate Account Android image documented |
| REF-003 | ⬜ | Architecture | Classify `f96465c7-...png` | Rename/mapping decision documented without modifying master unless owner approves |
| REF-004 | ⬜ | Architecture | Build visual element checklist per Home reference | Header/hero/cards/strips/spacing checklist |
| REF-005 | ⬜ | Architecture | Build visual element checklist per Categories reference | Search/category/card/filter checklist |
| REF-006 | ⬜ | Architecture | Build visual element checklist per PDP reference | Gallery/variant/facts/CTA checklist |
| REF-007 | ⬜ | Architecture | Build visual element checklist per Favorites reference | Header/filter/sort/card/empty-state checklist |
| REF-008 | 🟡 | Architecture | Build visual element checklist per Account/About refs | Final checklist aligned with #82/#83 |
| REF-009 | ⬜ | Architecture | Record iOS-only differences vs Android | Safe area, top chrome, spacing, typography deltas |
| REF-010 | ⬜ | Architecture | Record PC-only differences vs mobile | Grid width, header/nav, two-column layouts, gutters |

## B. Shared design-system atoms

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| DS-001 | ✅ | Design System | Extract `WalkaSectionHeader` | Completed via #87 / PR #88; reusable eyebrow/title/action widget + focused tests |
| DS-002 | ♻️ | Design System | Extract `WalkaReferenceTopBar` | Wordmark + action slots + safe-area handling |
| DS-003 | ♻️ | Design System | Extract `WalkaPrimaryButton` | Gold primary CTA wrapper using Theme tokens |
| DS-004 | ♻️ | Design System | Extract `WalkaSecondaryButton` | Navy outlined CTA wrapper |
| DS-005 | ♻️ | Design System | Extract `WalkaCircularIconButton` | Shared 48x48 action button replacing duplicated local variants |
| DS-006 | ⬜ | Design System | Create `WalkaPillChip` | Selectable/filter chip with active/inactive states |
| DS-007 | ⬜ | Design System | Create `WalkaSurfaceCard` | Shared premium card surface/radius/border/elevation |
| DS-008 | ⬜ | Design System | Create `WalkaEditorialCard` | Image/visual + heading + body + optional CTA slot |
| DS-009 | ⬜ | Design System | Create `WalkaMetricTile` | Compact metric/value/label block |
| DS-010 | ⬜ | Design System | Create `WalkaTrustStrip` | Reusable horizontal trust/benefit strip |
| DS-011 | ⬜ | Design System | Create `WalkaBenefitItem` | Icon + heading + supporting text unit |
| DS-012 | ♻️ | Design System | Extract `WalkaFavoriteButton` | Favorite heart action with persisted-state semantics |
| DS-013 | ⬜ | Design System | Create `WalkaEmptyState` | Visual/title/body/CTA slots |
| DS-014 | ♻️ | Design System | Extract catalog loading/offline feedback surface | Shared loading/cache/fallback/retry widget |
| DS-015 | ⬜ | Design System | Create `WalkaDividerLabel` | Section divider/title treatment used in account/info screens |
| DS-016 | ⬜ | Design System | Create `WalkaDestinationTile` | Leading icon, title, subtitle, trailing affordance |
| DS-017 | ⬜ | Design System | Create `WalkaProductMediaFrame` | Consistent aspect ratio, radius, semantics and image fallback |
| DS-018 | ♻️ | Design System | Wrap existing `WalkaProductVisual` behind media interface | Product visual fallback becomes implementation detail |
| DS-019 | ⬜ | Design System | Create `WalkaResponsiveGrid` | 1/2/3/4-column responsive grid primitive |
| DS-020 | ⬜ | Design System | Create `WalkaContentWidth` | Mobile/tablet/desktop width policy in one file |
| DS-021 | ⬜ | Design System | Extend typography roles | Display, page title, card title, label, caption, price/metric roles |
| DS-022 | ⬜ | Design System | Semantics/touch-target utility audit | Shared minimum 48px interaction contract |

## C. App shell, splash & navigation

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| SHELL-001 | ♻️ | Shell | Extract splash brand mark | `walka_splash_brand_mark.dart` + semantics test |
| SHELL-002 | ♻️ | Shell | Extract splash content panel | Headline/body/divider reusable composition |
| SHELL-003 | ♻️ | Shell | Extract bottom nav destination definition | Typed destination model; no private static duplication |
| SHELL-004 | ♻️ | Shell | Isolate `WalkaPremiumNavigationBar` | Dedicated file + selection/reduced-motion tests |
| SHELL-005 | ⬜ | Shell | Create mobile shell scaffold | IndexedStack/page persistence + nav only |
| SHELL-006 | ⬜ | Shell | Create wide/desktop shell scaffold | Desktop header/sidebar strategy without 560px cap |
| SHELL-007 | ⬜ | Shell | Route abstraction for tab switching | Named destination enum/controller; no magic indexes in feature widgets |
| SHELL-008 | ⬜ | Shell | iOS safe-area chrome pass | Status/notch/home-indicator compliant shell tests |

## D. Home / Landing

Android reference fidelity is already stable; tasks below focus on extracting it into reusable units and adding platform parity without visual regression.

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| HOME-001 | ✅ | Home | Android visual fidelity baseline | Existing stable reference implementation |
| HOME-002 | ♻️ | Home | Extract Home top header | Dedicated widget using shared top bar |
| HOME-003 | ♻️ | Home | Extract Home editorial hero | Dedicated hero file with slots for product visual/media |
| HOME-004 | ♻️ | Home | Extract Home hero CTA row | Browse/Search actions with compact wrapping |
| HOME-005 | ♻️ | Home | Extract Home benefit band | Navy/gold band composed from `WalkaBenefitItem` |
| HOME-006 | ♻️ | Home | Extract Collection card | Reusable Drawer/Lunch category card |
| HOME-007 | ♻️ | Home | Extract Collection section | Section header + responsive collection cards |
| HOME-008 | ♻️ | Home | Extract “Small Changes” module | Editorial card/module in isolated file |
| HOME-009 | ♻️ | Home | Extract Home trust strip | Shared trust-strip composition |
| HOME-010 | ⬜ | Home | Reduce Home page to composition-only file | Target page file primarily wires extracted widgets |
| HOME-011 | ⬜ | Home | iOS Home reference parity | Match `Home for ios.png` with shared widgets |
| HOME-012 | ⬜ | Home | PC Home responsive composition | Match `Home for pc.png` using wide shell/grid |
| HOME-013 | ⬜ | Home | Home visual regression tests | Android compact/standard/large + iOS + desktop goldens |

## E. Search & Categories

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| CAT-001 | ✅ | Discovery | Android Categories reference fidelity | Existing stable implementation |
| CAT-002 | ✅ | Discovery | Search visual consistency with Categories | Existing stable implementation |
| CAT-003 | ♻️ | Discovery | Extract Categories top header | Shared reference top bar composition |
| CAT-004 | ♻️ | Discovery | Extract category hero/card | One category visual/title/count-free truthful card |
| CAT-005 | ⬜ | Discovery | Create category product-row card | Product visual + title + variant metadata + tap target |
| CAT-006 | ♻️ | Discovery | Extract Categories benefit/trust strip | Shared `WalkaTrustStrip` usage |
| CAT-007 | ⬜ | Discovery | Create Search field widget | Query field, clear action, semantics, keyboard behavior |
| CAT-008 | ⬜ | Discovery | Create Search filter chips | All/Drawer/Lunch with shared pill chip |
| CAT-009 | ⬜ | Discovery | Create Search results grid/list | Responsive item presentation |
| CAT-010 | ⬜ | Discovery | Create Search empty-state widget | Query-aware reset action |
| CAT-011 | ⬜ | Discovery | Reduce Categories page to composition only | No large private widget cluster |
| CAT-012 | ⬜ | Discovery | Reduce Search page to composition only | State wiring separated from visual widgets |
| CAT-013 | ⬜ | Discovery | iOS Categories parity | Match `Categories page for ios.png` |
| CAT-014 | ⛔ | Discovery | PC Categories parity | Blocked until PC reference is classified/added |
| CAT-015 | ⬜ | Discovery | Discovery visual regression matrix | Compact/standard/large/text-scale/iOS/desktop as applicable |

## F. Product Detail Page (Drawer + Lunch)

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| PDP-001 | ✅ | Commerce UI | Android PDP reference fidelity | Existing V111 stable implementation |
| PDP-002 | ♻️ | Commerce UI | Extract PDP app/header bar | Back + favorite/share action slots |
| PDP-003 | ♻️ | Commerce UI | Extract gallery viewport | Product media viewport with stable aspect ratio |
| PDP-004 | ♻️ | Commerce UI | Extract gallery page indicator/thumbnails | Independent selection widget |
| PDP-005 | ♻️ | Commerce UI | Extract fullscreen zoom viewer | Dedicated route/widget + gesture tests |
| PDP-006 | ♻️ | Commerce UI | Extract product identity block | Family/title/subtitle without unsupported claims |
| PDP-007 | ♻️ | Commerce UI | Extract favorite/share action row | Reusable action block |
| PDP-008 | ♻️ | Commerce UI | Extract variant selector | Color/finish swatches with selected semantics |
| PDP-009 | ⬜ | Commerce UI | Create verified-facts list widget | Product Master facts only |
| PDP-010 | ⬜ | Commerce UI | Create specification row/table widget | Label/value layout adaptive to narrow widths |
| PDP-011 | ⬜ | Commerce UI | Create care/usage guidance panel | Lunch-approved wording; Drawer-specific facts |
| PDP-012 | ♻️ | Commerce UI | Extract official-Amazon trust block | Destination disclosure separate from CTA |
| PDP-013 | ♻️ | Commerce UI | Extract sticky Amazon CTA bar | SafeArea-aware finite-width bar |
| PDP-014 | ⬜ | Commerce UI | Create PDP page composition | Drawer/Lunch driven by presentation model |
| PDP-015 | ⬜ | Commerce UI | iOS PDP reference parity | Match `Product page for ios.png` |
| PDP-016 | ⛔ | Commerce UI | PC PDP parity | Blocked until PC PDP reference is classified/added |
| PDP-017 | ⬜ | Commerce UI | PDP regression matrix | Variants, zoom, favorite, share, Amazon handoff, compact/text scale |

## G. Favorites

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| FAV-001 | ✅ | Favorites | Android Favorites fidelity | Existing stable V131 implementation |
| FAV-002 | ♻️ | Favorites | Extract Favorites header/title/count | Dedicated header widget |
| FAV-003 | ♻️ | Favorites | Extract filter row | Filter chips independent from page state |
| FAV-004 | ♻️ | Favorites | Extract sort/edit row | Sort label/control + edit mode |
| FAV-005 | ♻️ | Favorites | Extract saved-product card | Media, identity, remove/edit/open actions |
| FAV-006 | ♻️ | Favorites | Extract empty Favorites state | Shared empty-state primitive + Continue Shopping |
| FAV-007 | ♻️ | Favorites | Extract Favorites trust strip | Shared trust strip |
| FAV-008 | ⬜ | Favorites | Reduce Favorites page to composition/state wiring | No large visual private classes |
| FAV-009 | ⬜ | Favorites | iOS Favorites reference parity | Match `Faivorets page for ios.png` |
| FAV-010 | ⬜ | Favorites | PC Favorites responsive composition | Match `Faivorets page for PC.png` |
| FAV-011 | ⬜ | Favorites | Favorites regression matrix | Empty/saved/remove/persistence/compact/iOS/desktop |

## H. Account Profile

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| ACC-001 | ✅ | Account | Android Account reference fidelity | Completed via #82 / PR #83 and stable on `main` |
| ACC-002 | 🟡 | Account | Extract Account reference top bar | Reusable top chrome from active branch implementation |
| ACC-003 | 🟡 | Account | Extract truthful profile/status hero | No fake identity/VIP/order/payment information |
| ACC-004 | 🟡 | Account | Extract overview metrics row | Released-state metrics only |
| ACC-005 | 🟡 | Account | Extract destination group title | Shared section heading treatment |
| ACC-006 | 🟡 | Account | Extract destination tile | Move to shared `WalkaDestinationTile` |
| ACC-007 | ⬜ | Account | Create Product & Support group composition | Favorites, Our Story, FAQ, Contact |
| ACC-008 | ⬜ | Account | Create Official Destinations group | Amazon Store, social destination(s) |
| ACC-009 | ⬜ | Account | Create Legal & App group | Privacy, Terms, App Information |
| ACC-010 | ⬜ | Account | Reduce Account page to composition only | Navigation callbacks + extracted widgets |
| ACC-011 | ⬜ | Account | iOS Account reference parity | Match `Account profile page for ios.png` |
| ACC-012 | ⬜ | Account | PC Account responsive composition | Match `Account profile page for PC.png` |
| ACC-013 | ⬜ | Account | Account regression matrix | Truthful copy/routes/compact/text scale/iOS/desktop |

## I. About / Our Story

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| ABOUT-001 | ✅ | Information | Android About reference fidelity | Completed via #82 / PR #83 and stable on `main` |
| ABOUT-002 | 🟡 | Information | Extract About editorial hero | Bounded hero safe inside vertical scroll |
| ABOUT-003 | 🟡 | Information | Extract story intro block | Editorial title/body component |
| ABOUT-004 | 🟡 | Information | Extract product-story visual block | Drawer/Lunch visual + narrative layout |
| ABOUT-005 | 🟡 | Information | Extract value card | Reusable icon/title/body card |
| ABOUT-006 | ⬜ | Information | Create values grid/stack | Adaptive 1/2/3-column composition |
| ABOUT-007 | ⬜ | Information | Create design-principles section | Reusable editorial list/card composition |
| ABOUT-008 | ⬜ | Information | Create Amazon-boundary closing panel | Truthful final CTA/disclosure |
| ABOUT-009 | ⬜ | Information | Reduce About page to composition only | No oversized private-widget file |
| ABOUT-010 | ⬜ | Information | iOS About reference parity | Match `About for ios.png` |
| ABOUT-011 | ⬜ | Information | PC About responsive composition | Match `About page for PC.png` |
| ABOUT-012 | ⬜ | Information | About regression matrix | Scroll, text scale, content truth, iOS/desktop |

## J. Adaptive / iOS / Desktop architecture

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| ADAPT-001 | ♻️ | Platform | Preserve compact breakpoint `<360` | Regression tests for 320×568 |
| ADAPT-002 | ♻️ | Platform | Preserve comfortable mobile breakpoint around 430 | Standard/large Android tests |
| ADAPT-003 | ⬜ | Platform | Add tablet breakpoint | Explicit tablet width/token contract |
| ADAPT-004 | ⬜ | Platform | Add desktop breakpoint | Explicit wide width/token contract |
| ADAPT-005 | ⬜ | Platform | Replace fixed 560px desktop cap behavior | Mobile frame only applies to mobile; desktop gets wide composition |
| ADAPT-006 | ⬜ | Platform | Desktop max-content/gutter tokens | Shared desktop content width and side gutters |
| ADAPT-007 | ⬜ | Platform | Desktop top navigation/header | Reusable PC chrome based on references |
| ADAPT-008 | ⬜ | Platform | iOS safe-area test harness | Top notch + bottom home indicator scenarios |
| ADAPT-009 | ⬜ | Platform | Platform-aware spacing policy | Shared tokens, not screen-local `Platform.isIOS` hacks |
| ADAPT-010 | ⬜ | Platform | Pointer/hover/focus states for desktop | Mouse/keyboard accessible cards/buttons/navigation |
| ADAPT-011 | ⬜ | Platform | Desktop keyboard traversal | Predictable focus order and visible focus |
| ADAPT-012 | ⬜ | Platform | Text scale 1.3× cross-platform harness | Shared test utility for all reference screens |

## K. Asset/media mapping

`mobile/assets/` currently contains branding only; product presentation therefore still relies heavily on generated/custom-painted visuals.

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| MEDIA-001 | ⬜ | Media | Audit which approved product visuals can be legally/technically bundled | Asset manifest with source and purpose |
| MEDIA-002 | ⬜ | Media | Create product media asset folders | `assets/products/drawer/`, `assets/products/lunch/` as approved |
| MEDIA-003 | ⬜ | Media | Add asset declarations to `pubspec.yaml` | Deterministic Flutter asset loading |
| MEDIA-004 | ⬜ | Media | Create product-media resolver | Stable product/variant → asset mapping |
| MEDIA-005 | ⬜ | Media | Keep custom-painted visual as fallback | Offline/test fallback remains deterministic |
| MEDIA-006 | ⬜ | Media | Add missing-asset/error semantics | No silent blank cards |
| MEDIA-007 | ⬜ | Media | Image sizing/performance audit | Avoid oversized decode/cache memory usage |

## L. Tests, golden QA, release gates

| ID | Status | Lane | Atomic task | Expected output |
|---|---|---|---|---|
| QA-001 | ⬜ | QA | Shared golden test harness | Deterministic fonts/surface/device config |
| QA-002 | ⬜ | QA | Android compact 320×568 suite | No overflow + critical goldens |
| QA-003 | ⬜ | QA | Android standard-phone suite | Reference comparison baseline |
| QA-004 | ⬜ | QA | Android large-phone suite | Large width reference baseline |
| QA-005 | ⬜ | QA | 1.3× text-scale suite | No clipping/overflow |
| QA-006 | ⬜ | QA | iOS phone safe-area suite | iOS references + safe-area verification |
| QA-007 | ⬜ | QA | Desktop 1280px suite | PC references at standard desktop width |
| QA-008 | ⬜ | QA | Desktop 1440px suite | Large desktop spacing/grid validation |
| QA-009 | ⬜ | QA | Reduced-motion suite | All WALKA-owned motion disabled cleanly |
| QA-010 | ⬜ | QA | Semantics/touch-target suite | 48px interactions and accessible labels |
| QA-011 | ⬜ | QA | Navigation smoke flow | Splash → Home/Search/Categories/Favorites/Account/About/PDP |
| QA-012 | ⬜ | QA | Product truth regression | Product Master wording/variants/destinations preserved |
| QA-013 | ⬜ | QA | Favorites persistence regression | Device-local White/Gray persistence preserved |
| QA-014 | ⬜ | QA | Amazon boundary regression | No cart/checkout/payment; correct external handoff |
| QA-015 | ⬜ | QA | Analyze + full test gate | Green before PR merge |
| QA-016 | ⬜ | QA | Android release APK gate | Installable APK produced before stable merge |
| QA-017 | ⬜ | QA | Stable-main APK publication check | `Last verified APK/WALKA-latest.apk` + receipt match source commit |
| QA-018 | ⬜ | QA | Final screenshot acceptance matrix | One checklist linking every reference to tested screen/device |

---

# 6. Recommended team distribution

These lanes can run in parallel after shared atoms stabilize:

- **Lane A — Design System / Shell:** DS-*, SHELL-*, ADAPT-*.
- **Lane B — Storefront:** HOME-*, CAT-*.
- **Lane C — Commerce:** PDP-*, MEDIA-*.
- **Lane D — Lifestyle / Secondary:** FAV-*, ACC-*, ABOUT-*.
- **Lane E — QA / Release:** QA-* starts immediately with harness work, then follows every merged component.

### Merge-conflict rule

Developers should avoid editing the same page file simultaneously. Extract components first; after extraction, each developer works mostly in separate widget files. Assembly-page edits should be scheduled as short integration tasks after component PRs merge.

---

# 7. Immediate execution queue

1. **Do not duplicate #82/#83.** Account + About Android reference fidelity is completed and stable on `main`.
2. Continue `DS-002` through `DS-010` as independent extraction/reuse tasks; `DS-001` is completed.
3. Run `HOME-002..010`, `CAT-003..012`, `PDP-002..014`, and `FAV-002..008` as visual-preserving modularization tasks.
4. Classify `f96465c7-...png` (`REF-003`) before claiming missing PC Product/Categories reference coverage.
5. Implement iOS parity: Home → Categories → PDP → Favorites → Account → About.
6. Implement desktop architecture, then the four explicitly named PC references: Home → Favorites → Account → About.
7. Implement PC Product/Categories only after a valid reference is identified or approved.
8. Close with DESIGN-007 cross-device/golden matrix and stable APK publication.

---

# 8. Definition of Done for one Atomic UI Task

A task can be marked **DONE** only when all applicable items are true:

- [ ] Dedicated component/widget file exists and is reasonably small.
- [ ] No duplicated colors/spacing/radii outside the shared theme unless the reference requires a documented exception.
- [ ] Widget has a focused test.
- [ ] Compact width is overflow-free.
- [ ] 1.3× text scale is safe for owner-visible UI.
- [ ] Existing navigation/state/business behavior is preserved.
- [ ] Product claims come from Product Master/released truth, not mock design content.
- [ ] `flutter analyze` is Green.
- [ ] Full Flutter tests are Green.
- [ ] Android release APK gate is Green for mobile-affecting slices.
- [ ] PR is reviewed/mergeable and merged to stable `main`.
- [ ] Owner-visible screen assemblies refresh the stable verified APK receipt.

This file is the atomic UI execution board. Update task status here whenever a task starts, changes scope, is blocked, or completes so the whole team sees one source of truth.