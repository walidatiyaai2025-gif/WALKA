# PINKSRC-001..020 — Pink Source Extraction Contract Receipt

Parent: #304  
Asset parent: #203  
Visual-release blocker: #230  
Branch: `agent/limg-pink-source-contract-20`

## Result

**20/20 source-contract tasks implemented. Pink production media is intentionally not admitted by this slice.**

The exact owner-approved source is locked as `1000389975.jpg` with SHA-256 `11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5`, 189,515 bytes and 695×1536 pixels. Only the embedded product panel at `x=28, y=760, width=647, height=575` is approved for extraction; marketplace title/rating/offer/navigation pixels remain excluded.

A local source-derived cutout experiment was inspected against WALKA Navy and did not meet the required stainless/utensil edge and halo quality bar. It was **not committed, not fingerprinted as canonical, and not promoted**. The repository therefore remains truthful: Pink source is APPROVED, while Pink provenance/runtime admission stays PENDING until the real canonical cutout passes every mandatory visual QA check.

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
- [x] PINKSRC-011 — White/Ivory/Navy QA required before admission.
- [x] PINKSRC-012 — 96/160/240/384 downscale QA required before admission.
- [x] PINKSRC-013 — Geometry-preservation and baked-UI exclusion QA required.
- [x] PINKSRC-014 — Source-admission exact APPROVED identity cross-check implemented.
- [x] PINKSRC-015 — Provenance PENDING/fingerprint-null fail-closed check implemented.
- [x] PINKSRC-016 — Runtime Pink pending/quarantined check implemented.
- [x] PINKSRC-017 — Deterministic parser/auditor and JSON report model implemented.
- [x] PINKSRC-018 — `--root/--json/--report/--enforce` CLI implemented.
- [x] PINKSRC-019 — Focused regression suite covers all twenty contract invariants.
- [x] PINKSRC-020 — CI enforcement/report artifact workflow implemented; full Flutter Preview also exercises the contract through the full test suite.

## Files

- `docs/ui/PINK_SOURCE_EXTRACTION_CONTRACT.json`
- `mobile/tool/src/pink_source_contract.dart`
- `mobile/tool/verify_pink_source_contract.dart`
- `mobile/test/pinksrc_001_020_source_contract_test.dart`
- `.github/workflows/pink-source-contract.yml`
- `docs/work/PINKSRC-001-020.md`

## Fail-closed state after this slice

- Drawer White: ADMITTED
- Drawer Gray: BLOCKED
- Lunch Blue: ADMITTED
- Lunch Pink: **PENDING — source locked, production cutout not admitted**
- Lunch Green: PENDING
- Stable owner-visible publication: BLOCKED until genuine 5/5 media readiness plus final owner visual acceptance.

## Closure rule

#304 may close only after its PR checks are Green and the branch is merged. #203 and #230 remain open because this 20-task slice deliberately does not claim that a production-quality Pink cutout has passed visual QA.
