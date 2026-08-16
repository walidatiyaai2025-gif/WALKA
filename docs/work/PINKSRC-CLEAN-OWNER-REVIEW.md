# PINKSRC-CLEAN — Owner Visual Acceptance Gate

Date: 2026-08-16
Parent release blocker: #230
Pink review issue: #328

## Five tasks completed in this slice

1. **Register the clean review candidate without admitting it.**
   - Candidate SHA-256: `755ead90e98b51f2fd732c267c01671ffa776d59624565b7521bd4c4ac3f1776`.
   - 683551 bytes, 1024×1024, 8-bit RGBA+sRGB.
   - Alpha bbox `[51,128,973,895]`; minimum transparent safe margin 51 px.
   - Source-derived from the approved `1000389975.jpg` product panel only.
   - Mechanical VPROOF disposition is `NO_OBVIOUS_HALO`; that is diagnostic evidence, not visual acceptance.

2. **Add a separate owner visual-acceptance receipt.**
   - `docs/ui/PINK_OWNER_VISUAL_ACCEPTANCE.json` is bound to the exact review-candidate SHA.
   - Current status is `PENDING`; `ownerAccepted=false`; no actor/time is claimed.
   - White/Ivory/Navy, 96/160/240/384, geometry, baked-UI and reference-vs-candidate review stages remain `PENDING` until an explicit owner decision.

3. **Add an independent fail-closed owner-review auditor and CLI.**
   - Automation verifies candidate identity, receipt identity, source admission, provenance and runtime state.
   - Automation explicitly cannot set or infer owner acceptance.
   - Before acceptance, Pink must remain fully quarantined: provenance `PENDING`, runtime `pending`, source/runtime canonical export false.
   - After explicit acceptance, the receipt may exist while Pink remains pending for a separate reviewed admission change.
   - A later admission is valid only when source/provenance/runtime promotion is complete and the admitted SHA/bytes/dimensions/bbox/margin match the accepted candidate exactly.
   - Partial admission is forbidden.

4. **Add regression coverage for the human-acceptance boundary.**
   - Current repository state must report `AWAITING_OWNER_ACCEPTANCE` with zero gate blockers.
   - A simulated provenance/runtime admission while the owner receipt remains `PENDING` must fail with `PREMATURE-ADMISSION`.
   - A simulated explicit accepted receipt may remain safely separated from the later admission transition.
   - CLI/report and workflow wiring are executable regressions.

5. **Wire the owner-review gate into Pink Source Contract CI.**
   - Existing PINKSRC extraction/admission consistency checks remain unchanged.
   - A second report, `pink-owner-review-gate-report.json`, is generated, uploaded and enforced.
   - Any future attempt to mark Pink production-admitted without a matching explicit owner receipt is blocked by CI.

## Truth after this slice

- Drawer White: `ADMITTED`.
- Drawer Gray: `BLOCKED` — no fabricated expanded Gray geometry.
- Lunch Blue: `ADMITTED`.
- Lunch Pink: `PENDING` / runtime ineligible / canonical export unconfirmed.
- Lunch Green: `ADMITTED`.
- Global production-media truth remains 3 admitted / 1 pending / 1 blocked.
- Stable owner-visible publication remains blocked by #230.

This slice does **not** modify the Pink PNG binary, protected `Images/`, Product Master identity/facts, Pantone, ASIN or Amazon routing. It does **not** claim owner visual acceptance, Pink production admission, stable publication or production-live status.
