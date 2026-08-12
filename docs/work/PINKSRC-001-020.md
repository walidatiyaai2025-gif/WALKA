# PINKSRC-001..020 — Pink Source Extraction Contract Receipt

Parent: #304  
Asset parent: #203  
Visual-release blocker: #230  
Original production admission: PR #303

## Result

**20/20 source-contract tasks remain implemented. The contract is now genuinely migration-aware and the current Pink production state is fail-closed PENDING after direct visual rejection of the current-main candidate.**

The exact owner-approved source remains locked as `1000389975.jpg` with SHA-256 `11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5`, 189,515 bytes and 695×1536 pixels. Only the embedded product panel at `x=28, y=760, width=647, height=575` is approved for extraction; marketplace title/rating/offer/navigation pixels remain excluded.

PR #303 produced a mechanically valid 1024×1024 Pink candidate with SHA-256 `84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae`, 748,350 bytes and 51px safe margin. A later direct render of that exact current-main binary on White, Ivory and WALKA Navy exposed unacceptable white halo/background contamination on Navy. Mechanical metadata therefore must not override visual evidence.

### Direct current-main visual proof

- Source main commit: `cd6bb64c1b37af97e274f42ce5752ac110ecdc77`
- Visual-proof workflow run: `31625699344`
- Visual-proof artifact: `9153009337`
- Candidate SHA-256: `84b1c5b44980c29bf22ff88cafc747454d4caf8612209daa84edfc2e3f3a11ae`
- Navy result: **REJECTED — white halo/background contamination**
- Candidate remains in the repository only as a quarantined file; file presence alone cannot make it runtime eligible.

The v2 contract now supports both legitimate lifecycle modes without rewriting policy:

- `PENDING`: approved source, incomplete/rejected visual QA, no confirmed canonical export, no admitted fingerprint/provenance, runtime quarantined.
- `ADMITTED`: approved source, confirmed canonical fingerprint/export, every mandatory visual QA state PASS, provenance ADMITTED and runtime eligible.

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
- [x] PINKSRC-011 — White/Ivory/Navy visual QA remains mandatory before admission.
- [x] PINKSRC-012 — 96/160/240/384 downscale QA remains mandatory before admission.
- [x] PINKSRC-013 — Geometry preservation and baked-marketplace/UI exclusion remain mandatory.
- [x] PINKSRC-014 — Source-admission exact APPROVED identity cross-check implemented.
- [x] PINKSRC-015 — Provenance transition is fail-closed: PENDING while QA is incomplete/rejected; ADMITTED only with fingerprint + full QA.
- [x] PINKSRC-016 — Runtime transition is fail-closed: pending/quarantined before evidence parity, admitted only afterward.
- [x] PINKSRC-017 — Deterministic migration-aware parser/auditor and JSON report model implemented.
- [x] PINKSRC-018 — `--root/--json/--report/--enforce` CLI remains executable.
- [x] PINKSRC-019 — Regression suite covers source/panel invariants and the current fail-closed PENDING mode.
- [x] PINKSRC-020 — CI enforcement/report artifact workflow remains the executable contract gate.

## Current production-media state

- Drawer White: ADMITTED
- Drawer Gray: BLOCKED
- Lunch Blue: ADMITTED
- Lunch Pink: **PENDING — exact source approved, current candidate visually rejected**
- Lunch Green: PENDING until its separate faithful canonical branch passes full CI
- Production readiness: **2/5**
- Stable owner-visible publication: **BLOCKED** until genuine 5/5 media readiness plus final owner visual acceptance.

## Next Pink action

Produce a cleaner cutout from the exact approved product panel only, without recoloring, generative fill, geometry reconstruction or accessory invention. The replacement must pass White/Ivory/Navy and 96/160/240/384 visual QA before source admission, provenance and runtime are promoted together.

## Closure rule

#304 may close only when this migration-aware contract is Green on PR and latest main. #203 remains open until a clean Pink canonical binary passes actual visual QA. #230 remains open until all five production variants plus final owner-visible acceptance pass.
