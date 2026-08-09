# WALKA Development Status

Last updated: 2026-08-09

## Current state

**Phase 1.5 — Full Clickable Flutter Experience: IN PROGRESS**

Phase 1 premium mobile UI/UX is complete and COM-001 Amazon handoff is released on `main`. Product direction is now to finish the real Flutter screen set and visual freeze before persistent state or Laravel/API work continues.

## Release board

| ID | Release | Scope | Status |
|---|---|---|---|
| UI-001 | 0.1.0 | Foundation + Splash + App Shell + Home + navigation skeleton | COMPLETED |
| UI-002 | 0.2.0 | Home fidelity + Product Detail | COMPLETED |
| UI-003 | 0.3.0 | Categories + collection browsing | COMPLETED |
| UI-004 | 0.4.0 | Favorites + Account + About | COMPLETED |
| UI-005 | 0.5.0 | Android/iOS polish + accessibility + visual QA | COMPLETED |
| COM-001 | 0.6.0 | Variant-aware Amazon purchase handoff for Drawer Organizer | COMPLETED |
| UI-006 | 0.7.0 | Lunch Box collection + Blue/Pink/Green PDP | IN PROGRESS |
| UI-007 | 0.8.0 | Search + discovery + results/filter/sort states | PLANNED |
| UI-008 | 0.9.0 | Product UX completion + gallery/share/related products | PLANNED |
| UI-009 | 1.0.0 | Information screens + cross-platform visual freeze | PLANNED |
| STATE-001 | post-1.0 | Persistent Favorites/customer state | DEFERRED |
| API-001 | post-1.0 | Laravel API foundation | DEFERRED |

## UI-006 acceptance checklist

- [x] `0.7.0+7` package version
- [x] Premium Lunch Collection screen
- [x] Blue / Pink / Green product variants
- [x] Variant visual tokens + Pantone labels
- [x] Full Lunch Box PDP
- [x] Three gallery presentation states
- [x] 1200 ml / four-compartment product detail presentation
- [x] SUS304 tray / PP body / insulated bag / utensils / sauce cup content
- [x] Locked usage guidance: dry & semi-wet foods, not intended for liquids, carry upright
- [x] Categories routes to Drawer and Lunch collections
- [x] Official Blue/Pink/Green Amazon ASIN mapping added to the existing commerce boundary
- [x] Lunch ASIN unit coverage added
- [x] Compact storefront + lunch PDP smoke coverage added
- [ ] CI analyze green
- [ ] CI tests green
- [ ] Android preview APK green
- [ ] PR merged to `main`
- [ ] `0.7.0` preview considered releasable

## COM-001 preserved baseline

- Drawer White ASIN: `B0FQN4DCTG`
- Drawer Gray ASIN: `B0FQN4L2ZD`
- Existing external Amazon launch behavior remains intact.

## Phase boundary

No Laravel/API work is allowed before UI-009 visual freeze. No in-app cart, checkout or payment flow is planned; Amazon remains the purchase destination.

## Guardrails

1. `Images/` remains the master visual-reference folder and must not be modified by implementation tasks.
2. Completed visual architecture is extended, not rewritten, unless visual QA proves a specific defect.
3. New work remains split into independently reviewable and releasable slices.
4. Every slice must pass analyze, tests and Android build gate before release.
5. User-visible product copy must preserve the approved lunch-box safety/usage language.
