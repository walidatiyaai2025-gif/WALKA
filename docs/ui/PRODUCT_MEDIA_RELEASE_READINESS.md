# WALKA Product Media Release Readiness

Parent visual blocker: #230  
VREL batch: #244  
Closure issue: #257  
Snapshot base: `648fd33c8b60a339df266f26d8daa4fa304d822a`

## Release state

**Engineering state: GREEN through the first 90 VREL hardening tasks.**  
**Owner-visible production-media release state: BLOCKED.**

The block is intentional. The release workflow now builds and uploads an engineering APK candidate even when production product media is incomplete, but it does not advance `Last verified APK` unless the five canonical production assets pass enforcement and the validated `main` SHA is still current.

Current owner-visible verified receipt remains pinned to the pre-gate build:
- source commit: `01cb7c1a01b82f4e126220e1e0ee481d7710e258`
- workflow run: `31436250598` / run #632
- version: `1.2.0+120`
- APK bytes: `53094356`
- APK SHA-256: `181b4f7e73412f570933a6ec049d1422eb630037da37fe163d67c0010fd39a03`

That pin is evidence that the production-asset gate is protecting owner-visible release state; it is not evidence that newer engineering code failed.

## Five-variant readiness — VREL-093 / VREL-094

| Variant | Source admission | Canonical runtime export | Release state | Exact unblock action |
|---|---|---|---|---|
| Drawer Organizer — White | APPROVED (`SRC-DRAWER-WHITE-001`) | `assets/products/drawer/white.png` — pending | BLOCKED | Export the admitted real expanded White source non-destructively to transparent PNG; pass geometry, alpha, framing and size-budget QA. |
| Drawer Organizer — Gray | BLOCKED (`SRC-DRAWER-GRAY-001`) for expanded parity | `assets/products/drawer/gray.png` — pending | BLOCKED | Provide/approve a faithful expanded Gray source **or** explicitly approve the real collapsed Gray presentation. Never synthesize expanded geometry. |
| Lunch Box — Blue | APPROVED (`SRC-LUNCH-BLUE-001`) | `assets/products/lunch/blue.png` — pending | BLOCKED | Produce the canonical transparent cutout from the admitted real source; preserve four compartments, materials and Product Master truth; pass alpha/framing/budget QA. |
| Lunch Box — Pink | APPROVED (`SRC-LUNCH-PINK-001`) | `assets/products/lunch/pink.png` — pending | BLOCKED | Extract only the approved clean product region; remove marketplace title/rating/navigation pixels; export and validate the canonical transparent PNG. |
| Lunch Box — Green | APPROVED (`SRC-LUNCH-GREEN-001`) | `assets/products/lunch/green.png` — pending | BLOCKED | Normalize canvas/scale/optical center from the admitted real source without geometry reconstruction; export and validate the canonical PNG. |

## Visual acceptance lifecycle — VREL-096

### PASS
Use PASS only when:
1. the canonical file exists at the resolver-owned path,
2. production asset enforcement passes,
3. the owner-visible screen has been checked against the applicable reference,
4. variant/color/geometry/material truth is preserved,
5. alpha edges and framing pass,
6. no forbidden baked content or unsupported claims are present,
7. responsive/accessibility checks pass.

### BLOCKED
Use BLOCKED when the next valid action depends on missing/insufficient source material or a required owner decision. BLOCKED is not a failed engineering test and must name the exact unblock action.

### REOPEN
Reopen a prior PASS if a later source/export introduces geometry, color, halo/fringe, crop, semantics, performance, product-truth or reference-fidelity regression. Reopened acceptance blocks a newer owner-visible stable publication until corrected and revalidated.

## Rollback procedure — VREL-097

If an admitted production asset regresses:
1. Do not edit protected `Images/` masters to mask the regression.
2. Revert/remove the bad canonical runtime asset or its admission commit.
3. The production gate must return BLOCKED; engineering APK candidates can still be built for diagnosis.
4. Keep `Last verified APK` pinned to the last owner-visible accepted build.
5. Restore/re-export only from the last known-good approved source after geometry/color/alpha/framing QA.
6. Re-run protected-master guard, Analyze, full Flutter tests, readiness report, performance audit and Android release APK candidate.
7. Require main asset enforcement + stale-main SHA guard before owner-visible verified APK publication can advance.
8. Record the replacement source/export and new visual acceptance result; never manually replace `Last verified APK` to bypass the gate.

## Final owner review checklist — VREL-098

### Home / Landing
- [ ] Hero uses real approved Lunch Green + Drawer White media at intended crop.
- [ ] Drawer/Lunch collection cards show correct real variant identity.
- [ ] Small Changes uses the approved Drawer White asset.
- [ ] 320 / 430 / desktop framing keeps product fully visible.
- [ ] White product remains visible on ivory/light stages without fake geometry-changing outline.

### Discovery / Search
- [ ] Category card media matches selected family/variant.
- [ ] Search result variant IDs map to correct production assets.
- [ ] No marketplace UI, price, rating or unsupported claim is baked into image pixels.
- [ ] iOS/mobile reference framing passes.
- [ ] PC Categories remains separate BLOCKED scope until an approved PC reference exists.

### Product Detail
- [ ] Primary gallery image resolves to the selected canonical variant.
- [ ] Variant switch changes product identity correctly.
- [ ] Fullscreen preserves primary image identity and safe areas.
- [ ] Secondary pages remain explicitly illustrative until approved secondary photography exists.
- [ ] Zoom inspection at 200% shows no matte, fringe, halo or clipped product geometry.
- [ ] PC PDP remains separate BLOCKED scope until an approved PC reference exists.

### Favorites
- [ ] Saved White/Gray IDs render the matching production asset.
- [ ] Crop/overlays do not obscure important product geometry.
- [ ] Remove/edit behavior and persistent variant identity remain intact.

### Account / About
- [ ] About product-story media uses approved Drawer White and Lunch Blue assets.
- [ ] Account remains free of unnecessary product-media decoding.
- [ ] About reference balance/framing passes Android/iOS/PC.

### Cross-cutting
- [ ] Product Master geometry/material/color facts match every admitted image.
- [ ] Protected `Images/` remains unchanged unless an explicit owner-approved master update is performed.
- [ ] Canonical bundle/per-file/APK budgets pass.
- [ ] Reduced motion, 1.3× text and iOS SafeArea tests pass.
- [ ] Production asset enforcement reports READY for all five canonical paths.
- [ ] Owner-visible `Last verified APK` advances only from a current validated `main` SHA.

## VREL-095 parent blocker reconciliation

Issue #230 remains the authoritative P0 visual-release blocker. VREL hardening has completed the release plumbing, resolver integration, safety gates, performance/accessibility contracts and acceptance tooling. What remains is **source/export admission and real-asset visual acceptance**, not more fallback plumbing.
