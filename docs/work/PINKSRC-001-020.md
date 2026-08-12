# PINKSRC-001..020 — Pink Source Extraction Contract Receipt

Parent: #304  
Asset parent: #203  
Visual-release blocker: #230  
Initial PR: #305  
Parallel production admission: PR #303

## Result

**20/20 source-contract tasks implemented and reconciled with the evidence-backed Pink admission already delivered by parallel PR #303.**

The exact owner-approved source remains locked as `1000389975.jpg` with SHA-256 `11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5`, 189,515 bytes and 695×1536 pixels. Only the embedded product panel at `x=28, y=760, width=647, height=575` is approved for extraction; marketplace title/rating/offer/navigation pixels remain excluded.

While the original source-contract branch was validating, parallel PR #303 completed a faithful canonical Pink admission and merged first. That production admission is not overridden by this batch. Instead, the PINKSRC gate is migration-aware and now requires the entire admitted evidence chain to agree before accepting Pink as runtime-eligible.

### Current admitted Pink evidence

- Canonical path: `assets/products/lunch/pink.png`
- Canonical SHA-256: `84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae`
- Canonical bytes: `748350`
- Canvas: `1024×1024`
- Alpha bbox: `[51, 161, 972, 862]`
- Nearest transparent safe margin: `51px`
- Color profile expectation: `sRGB`
- White / Ivory / Navy QA: PASS
- 96 / 160 / 240 / 384 downscale QA: PASS
- Geometry preservation: PASS
- Baked marketplace/UI exclusion: PASS
- Source admission: APPROVED + canonical export present
- Provenance: ADMITTED
- Runtime: admitted / eligible

The earlier local source-derived experiment from this batch that showed unacceptable navy-background halo/utensil-edge quality remains discarded and was never committed. PR #303's separately validated canonical binary is the production truth.

## Task completion

- [x] PINKSRC-001 — Exact Pink source ID and filename recorded.
- [x] PINKSRC-002 — Exact source SHA-256 and byte size locked.
- [x] PINKSRC-003 — Source dimensions locked to 695×1536.
- [x] PINKSRC-004 — Approved embedded product-panel rectangle locked.
- [x] PINKSRC-005 — Crop positivity and source-bounds validation enforced.
- [x] PINKSRC-006 — Canonical path locked to `assets/products/lunch/pink.png`.
- [x] PINKSRC-007 — Canonical geometry locked to 1024×1024.
- [x] PINKSRC-008 — 8-bit RGBA + sRGB output contract locked.
- [x] PINKSRC-009 — Minimum 51 px transparent safe margin enforced.
- [x] PINKSRC-010 — Existing 1.2 MiB hard budget enforced.
- [x] PINKSRC-011 — White/Ivory/Navy QA required before admission and verified PASS for admitted Pink.
- [x] PINKSRC-012 — 96/160/240/384 QA required before admission and verified PASS.
- [x] PINKSRC-013 — Geometry-preservation and baked-UI exclusion QA required and verified PASS.
- [x] PINKSRC-014 — Source-admission exact APPROVED identity cross-check implemented.
- [x] PINKSRC-015 — Provenance transition is fail-closed: PENDING while incomplete; ADMITTED only with fingerprint + full QA.
- [x] PINKSRC-016 — Runtime transition is fail-closed: quarantined while incomplete; admitted only after evidence parity.
- [x] PINKSRC-017 — Deterministic parser/auditor and JSON report model implemented.
- [x] PINKSRC-018 — `--root/--json/--report/--enforce` CLI implemented.
- [x] PINKSRC-019 — Focused regression suite covers all twenty contract invariants and admitted-state reconciliation.
- [x] PINKSRC-020 — CI enforcement/report artifact workflow implemented; full Flutter Preview also exercises the contract through the full test suite.

## Files

- `docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json`
- `mobile/tool/src/pink_source_contract.dart`
- `mobile/tool/verify_pink_source_contract.dart`
- `mobile/test/pinksrc_001_020_source_contract_test.dart`
- `.github/workflows/pink-source-contract.yml`
- `docs/work/PINKSRC-001-020.md`

## Current production-media state

- Drawer White: ADMITTED
- Drawer Gray: BLOCKED
- Lunch Blue: ADMITTED
- Lunch Pink: **ADMITTED — guarded by exact source/canonical/QA/runtime parity**
- Lunch Green: PENDING
- Production readiness: **3/5**
- Stable owner-visible publication: still BLOCKED until genuine 5/5 media readiness plus final owner visual acceptance.

## Closure rule

#304 closes only after the reconciliation PR is Green, merged, and its latest-main Pink contract run is Green. #230 remains open because global visual release is not yet 5/5. #203 is managed by the production-admission lane and PR #303 rather than by this source-contract batch.
