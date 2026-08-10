# SHELL-001 — Extract splash brand mark

Status: IN PROGRESS
Issue: #139
Branch: `agent/shell-001-splash-brand-mark`
Parent: #85 UI Task Master

## Scope

Extract the active storefront splash brand mark into a dedicated shared widget while preserving the released splash geometry, official SVG asset and semantics.

## Delivered on task branch

- Added `mobile/lib/design_system/components/chrome/walka_splash_brand_mark.dart`.
- Preserves `assets/branding/walka_logo.svg`.
- Preserves the released radial gold glow, 8px vertical padding, `214` compact width and `252` standard width.
- Preserves the `WALKA For You` image semantic while excluding redundant SVG internals.
- Replaces only the private splash brand-mark implementation in `WalkaStorefrontSplashV102`; splash copy, CTA, navigation and layout remain feature-owned.
- Adds focused tests for compact/standard sizing and image semantics.

## Guardrails

- No splash content-panel or CTA behavior changes.
- No shell/tab navigation changes.
- No Product Master, catalog, Favorites persistence, backend or Amazon-boundary changes.
- `Images/` untouched.
- No ZIP delivery.

## Required validation before stable merge

- [ ] Flutter dependency resolution / formatting path.
- [ ] `flutter analyze` Green.
- [ ] Full Flutter tests Green.
- [ ] Android runner / WALKA branding Green.
- [ ] Release APK build Green.
- [ ] PR-context validation Green.
- [ ] Merge to stable `main` only after required gates pass.
