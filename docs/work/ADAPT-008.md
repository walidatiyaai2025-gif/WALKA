# ADAPT-008 — iOS safe-area test harness

Status: IN PROGRESS
Issue: #179
Parent Batch: #121
Task Master: #85
Branch: `agent/adapt-001-008-foundations`

## Delivered
- Added reusable `WalkaTestDevice` profiles and `walkaDeviceHarness` under `mobile/test/support/`.
- Includes representative iPhone notch/home-indicator insets (47px top / 34px bottom).
- Tests `WalkaSafeAreaChrome` through MediaQuery-driven insets with no `Platform.isIOS` branching.
- The same harness also supports compact/standard/large Android, tablet and desktop regression work.

## Validation
Pending PR-context Analyze, full Flutter tests and Android release APK gate.
