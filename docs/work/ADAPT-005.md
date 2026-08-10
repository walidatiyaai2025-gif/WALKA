# ADAPT-005 — Remove fixed 560px desktop cap

Status: IN PROGRESS
Issue: #176
Parent Batch: #121
Task Master: #85
Branch: `agent/adapt-001-008-foundations`

## Delivered
- `WalkaAdaptiveFrame` now applies the 560px cap only to the mobile tier.
- Tablet and desktop use the shared 840px/1200px maxima.
- Tests verify a 600px mobile-width host remains capped at 560, an 820px tablet uses 820, and a 1440px desktop reaches 1200.

## Validation
Pending PR-context Analyze, full Flutter tests and Android release APK gate.
