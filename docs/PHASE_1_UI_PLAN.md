# Phase 1 — Premium Mobile UI/UX Prototype

## Objective

Deliver a premium Android/iOS Flutter experience that accurately communicates the WALKA brand and lets stakeholders navigate the full customer-facing screen map before backend work begins.

## Non-goals

Phase 1 does not include Laravel integration, APIs, database state, authentication, cart, checkout, payments, orders, Amazon deep-linking, analytics, or push notifications.

## Design direction

- Primary navy: `#003366`
- Accent gold: `#D4AF37`
- Warm light surfaces with generous whitespace
- Editorial/premium composition rather than marketplace density
- Serif-feeling display typography and clean sans-serif UI typography
- Product imagery remains visually dominant once product assets are mapped from `Images/`
- Bottom navigation: Home, Categories, Favorites, Account

## Release slices

### UI-001 / 0.1.0 — Foundation

- Flutter package and project bootstrap path
- WALKA color/spacing/radius/elevation tokens
- Splash screen
- Main application shell
- Bottom navigation
- First premium Home implementation
- Static Product preview screen reachable from Home
- Placeholder but navigable Categories, Favorites, Account and About screens
- Automated Flutter analyze/test/APK preview workflow

### UI-002 / 0.2.0 — Home + PDP fidelity

- Audit `Images/Home for Android.png` and iOS reference
- Audit Product reference screens
- Map usable product imagery into mobile assets
- Refine hero, collection modules and editorial content
- Complete product gallery, variants, specs and Amazon CTA presentation

### UI-003 / 0.3.0 — Category browsing

- Match Android/iOS category references
- Collection cards
- Category detail / product grid
- Responsive phone widths

### UI-004 / 0.4.0 — Favorites + Account + About

- Match favorite states and references
- Account/profile presentation shell
- About/Story experience
- Policy/contact placeholders

### UI-005 / 0.5.0 — Visual QA release

- Android/iOS safe-area review
- Accessibility and touch-target pass
- Text scaling pass
- Motion/navigation consistency
- Final Phase 1 screenshot checklist

## Definition of Done for each slice

A slice can be called released only when its code is on the integration branch, Flutter analyze succeeds, tests succeed, and Android preview APK build succeeds in CI.