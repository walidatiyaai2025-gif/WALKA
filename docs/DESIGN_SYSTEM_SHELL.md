# WALKA Premium Mobile Shell

Status: DESIGN-002 shared chrome contract

## Purpose

This contract keeps WALKA navigation, headers, spacing and common touch affordances consistent across the five primary mobile destinations while preserving the released information architecture and Amazon purchase boundary.

## Layout frame

- Mobile content is centered with a maximum content width of `560dp`.
- Horizontal page gutter is adaptive:
  - `< 360dp`: `16dp`
  - `360–430dp`: `20dp`
  - `> 430dp`: `24dp`
- Standard section rhythm is `32dp`; compact handsets may use `24dp`.
- Primary content uses WALKA ivory; wide framing uses the neutral surface color.

The reusable source is `mobile/lib/design_system/walka_shell.dart` together with `walka_adaptive.dart`.

## Brand header

Use `WalkaWordmark` instead of rebuilding WALKA typography per page.

- Compact header: 22px wordmark with the premium-home-organization descriptor.
- Feature/splash header: 42px wordmark.
- Light surface: WALKA navy wordmark and muted descriptor.
- Dark surface: white wordmark and cool-neutral descriptor.
- Keep the wordmark semantic heading exposed once; decorative child text is excluded from duplicate semantics.

Header actions use `WalkaShellIconButton` so circular affordances have the same border, shadow, icon scale and minimum `48×48dp` touch target.

## Bottom navigation

`WalkaPremiumNavigationBar` is the only persistent primary navigation treatment for the current application shell.

The five destinations remain unchanged and in this order:

1. Home
2. Search
3. Categories
4. Favorites
5. Account

Rules:

- Navigation height: `72dp` before device bottom inset.
- The bottom system inset is handled by `SafeArea`; gesture/navigation bars must never cover destinations.
- Every destination keeps a minimum accessible Material touch target.
- Selected state uses navy with a restrained translucent gold indicator.
- Unselected icon/label states use muted slate.
- Labels remain visible at compact widths; navigation must not rely on icon recognition alone.
- A subtle top divider and shadow separate persistent chrome from content without creating a heavy floating dock.

## Shared controls

- Primary action: themed gold pill, navy text, minimum 54dp height.
- Secondary action: outlined navy pill, minimum 48dp touch target.
- Text actions: navy, padded to a minimum 48dp touch target.
- Icon actions: `WalkaShellIconButton` for top-level circular chrome; standard themed `IconButton` elsewhere.
- Cards: prefer white/ivory surfaces, restrained WALKA line borders, and radius tokens from `WalkaRadius`.
- Chips/badges: use compact content, WALKA palette, pill geometry and avoid creating competing primary CTAs.

## Accessibility and device contract

- `320×568` remains a required compact-handset regression size.
- Primary interactive controls must preserve at least a 48dp touch target.
- Text labels cannot be removed from the five persistent destinations.
- New shell work must pass Flutter Analyze, the full test suite and Android APK build before reaching stable `main`.

## Governance

- `main` remains stable-only.
- `Images/` remains reference-only for implementation work.
- Shell work must not change Product Master facts, API stable IDs, catalog fallback behavior, Favorites persistence or Amazon routing.
- Stable Android delivery continues through `Last verified APK/WALKA-latest.apk` only after a successful current-`main` validation run.
