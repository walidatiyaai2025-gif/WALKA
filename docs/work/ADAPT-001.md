# ADAPT-001 — Preserve compact breakpoint below 360

Status: IN PROGRESS
Issue: #172
Parent Batch: #121
Task Master: #85
Branch: `agent/adapt-001-008-foundations`

## Delivered
- Preserves the existing `<360` compact-phone contract.
- Centralizes compact detection in `WalkaAdaptiveMetrics.isCompactWidth`.
- Keeps 16px horizontal padding for 320px compact devices.
- Adds explicit 320×568 coverage through the shared device harness.

## Guardrails
- No Product Master, commerce, backend, Favorites persistence or `Images/` changes.
- Existing Android phone geometry remains authoritative.

## Validation
Pending PR-context Analyze, full Flutter tests and Android release APK gate.
