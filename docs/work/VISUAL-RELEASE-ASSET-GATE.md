# VISUAL-RELEASE-ASSET-GATE — P0 #230

Status: IN PROGRESS
Priority: P0 / release blocker
Branch: `agent/visual-release-asset-gate`

## Goal

Prevent `Last verified APK/WALKA-latest.apk` from being refreshed as an owner-visible stable release while WALKA is still rendering product fallbacks because any canonical production product asset is missing or invalid.

## Canonical required assets

- `mobile/assets/products/drawer/white.png`
- `mobile/assets/products/drawer/gray.png`
- `mobile/assets/products/lunch/blue.png`
- `mobile/assets/products/lunch/pink.png`
- `mobile/assets/products/lunch/green.png`

These paths match `WalkaProductMediaResolver.production()` and are the single release-gate contract.

## Behavior

- Pull requests run the gate in report-only mode so unrelated implementation PRs can still validate while showing asset readiness.
- `main` publication runs the gate in enforce mode after the APK candidate is built/uploaded but before `Last verified APK` is updated.
- Enforce mode requires every canonical file to exist, be non-empty and have a valid PNG signature.
- Missing production photography is never synthesized or replaced by protected `Images/` screen references.

## Definition of Done

- Gate script is versioned under `mobile/tool/`.
- Flutter Preview reports asset readiness on PRs.
- Stable main publication is blocked while one or more required assets are absent/invalid.
- Once all five approved assets are admitted, the normal verified-APK publication path resumes automatically.
