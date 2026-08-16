# WALKA Production Creative Asset QA

Status: **ASSET-010 production image QA receipt**  
Tracking: #197 / #207 / #220 / #230  
Source admission: `docs/ui/PRODUCTION_SOURCE_ADMISSION.json`  
Asset provenance: `docs/ui/PRODUCTION_ASSET_PROVENANCE.json`  
Runtime validator: `mobile/tool/src/production_asset_validator.dart`  
PNG inspector: `mobile/tool/src/png_asset_inspector.dart`  
Export standard: `docs/ui/CREATIVE_ASSET_EXPORT_SPEC.md`

## 1. Scope and status semantics

This receipt records **per-file production-asset QA**. It does not replace final owner-visible screen acceptance.

Per-file states in this document are intentionally limited to:
- **PASS** — the exact canonical product file is admitted, fingerprinted, within the executable PNG/runtime contract, and every mandatory provenance QA check is PASS. The file is eligible to participate in owner-visible integration, subject to the independent screen/release gates.
- **BLOCKED** — the variant does not currently have an admitted canonical file that satisfies the source/admission/visual contract. The file is not eligible for stable publication.

A per-file PASS is **not** permission to publish a stable APK. Final screen review remains governed by #220/#230 and the Visual Release Owner Gate. Current overall stable publication remains BLOCKED while Gray/Pink and final owner-screen acceptance are unresolved.

## 2. Mandatory QA checks

Every admitted primary product file must satisfy all applicable checks below:

1. exact canonical filename/path and stable variant mapping;
2. approved source and exact source-to-canonical provenance;
3. 1024×1024 8-bit RGBA PNG under the PAV contract;
4. sRGB/iCCP metadata, transparent pixels and fully transparent perimeter;
5. minimum floor(5%) transparent safe margin on every side (51 px on a 1024 canvas);
6. file size at or below the executable 1.2 MiB hard ceiling;
7. White / warm-Ivory / WALKA Navy alpha-edge review;
8. 96 / 160 / 240 / 384 downscale review;
9. source-faithful geometry and material/color preservation;
10. no baked UI text, unsupported claims, prices, ratings, navigation or marketplace chrome;
11. sibling canvas parity, duplicate-binary checks and visual-scale warnings reviewed by PAV;
12. owner-visible runtime resolver/media-surface audit Green;
13. Flutter Analyze, full tests and release APK build Green after integration.

Screen-level Android/iOS/desktop reference comparison is a **separate release-composition gate**. This receipt records the asset file as PASS or BLOCKED; it must never be read as a substitute for final per-screen owner acceptance.

## 3. Current per-file QA matrix

| Variant | Canonical path | File QA | Lifecycle | Source | Technical/visual note |
|---|---|---:|---|---|---|
| `drawer-organizer:white` | `mobile/assets/products/drawer/white.png` | **PASS** | ADMITTED | APPROVED | Exact admitted expanded White source; all mandatory provenance QA checks PASS. |
| `drawer-organizer:gray` | `mobile/assets/products/drawer/gray.png` | **BLOCKED** | BLOCKED | BLOCKED | Real Gray source is collapsed; expanded 8-compartment parity cannot be reconstructed. Await faithful expanded source or explicit owner approval of collapsed presentation. |
| `lunch-box:blue` | `mobile/assets/products/lunch/blue.png` | **PASS** | ADMITTED | APPROVED | Exact admitted Blue source-derived set; all mandatory provenance QA checks PASS. |
| `lunch-box:pink` | `mobile/assets/products/lunch/pink.png` | **BLOCKED** | PENDING | APPROVED | Approved source exists, but no owner-accepted/reconciled canonical export is admitted. Review-only cleanup evidence cannot substitute for owner acceptance. |
| `lunch-box:green` | `mobile/assets/products/lunch/green.png` | **PASS** | ADMITTED | APPROVED | Exact admitted Green owner-source derivative; all mandatory provenance QA checks PASS. |

Current file-level readiness: **3 PASS / 2 BLOCKED**.

## 4. drawer-organizer:white — PASS

- Canonical: `mobile/assets/products/drawer/white.png`
- Source: `SRC-DRAWER-WHITE-001` / `51yxoCdmqrL._AC_SL1500_(1).jpg`
- Source state: APPROVED
- Lifecycle: ADMITTED
- SHA-256: `b2c6967b6ccb3283a90e26337f90fe15f2f707dbcf20531d760fb656c06d234f`
- Bytes: 189,339
- Canvas: 1024×1024
- Alpha bounding box: `[51,184,972,839]`
- Nearest transparent safe margin: 51 px
- Color profile expectation: sRGB
- White/Ivory/Navy: PASS / PASS / PASS
- Downscale 96/160/240/384: PASS / PASS / PASS / PASS
- Geometry preserved: PASS
- Baked UI excluded: PASS
- File-size/decode note: comfortably below the 1.2 MiB hard ceiling; app uses optimized canonical file rather than the source master.
- Visual note: preserves the real expanded organizer silhouette and full side-wing/compartment identity. Stable screen publication still depends on the independent screen gate.

## 5. drawer-organizer:gray — BLOCKED

- Canonical target: `mobile/assets/products/drawer/gray.png`
- Source: `SRC-DRAWER-GRAY-001` / `IMG-20250919-WA0035.jpg`
- Source state: BLOCKED
- Lifecycle: BLOCKED
- Canonical export confirmed: no
- SHA/bytes/canvas/bbox: intentionally absent until an admissible canonical file exists
- White/Ivory/Navy and downscale QA: BLOCKED
- Geometry preserved: BLOCKED pending a truthful presentation decision
- Baked UI excluded: BLOCKED because there is no admitted canonical file to certify
- Blocker: the real Gray photo is collapsed and cannot truthfully produce expanded 8-compartment parity without reconstructing hidden geometry.
- Unblock path: provide/approve a faithful expanded Gray source, or explicitly approve a collapsed Gray canonical presentation. Never recolor White or synthesize missing geometry.
- Tracking: #201 and the Gray owner presentation-decision contract.

## 6. lunch-box:blue — PASS

- Canonical: `mobile/assets/products/lunch/blue.png`
- Source: `SRC-LUNCH-BLUE-001` / `main new(3).jpg`
- Source state: APPROVED
- Lifecycle: ADMITTED
- SHA-256: `a36a0034fe8a8f807f8b1020c12dd85907807743b842aa71493e0f0ef04271f4`
- Bytes: 743,513
- Canvas: 1024×1024
- Alpha bounding box: `[51,108,972,914]`
- Nearest transparent safe margin: 51 px
- Color profile expectation: sRGB
- White/Ivory/Navy: PASS / PASS / PASS
- Downscale 96/160/240/384: PASS / PASS / PASS / PASS
- Geometry preserved: PASS
- Baked UI excluded: PASS
- File-size/decode note: below the 1.2 MiB hard ceiling; no oversized listing/source master is bundled in place of the canonical file.
- Visual note: preserves the real four-compartment SUS304 tray and source-derived Blue set/accessory identity without unsupported leakproof/liquid claims.

## 7. lunch-box:pink — BLOCKED

- Canonical target: `mobile/assets/products/lunch/pink.png`
- Source: `SRC-LUNCH-PINK-001` / `1000389975.jpg`
- Source state: APPROVED
- Lifecycle: PENDING
- Canonical export confirmed: no
- Production provenance SHA/bytes/canvas/bbox: intentionally null until admission is reconciled
- White/Ivory/Navy and downscale QA in production provenance: PENDING, therefore this ASSET-010 receipt records the file as BLOCKED for stable use
- Geometry preserved / baked UI excluded: PENDING in production provenance
- Important distinction: a mechanically clean review candidate and automated edge proof are diagnostic evidence only. They do not constitute owner visual acceptance.
- Unblock path: explicit owner acceptance of the exact review-bound candidate, followed by a separate fingerprint-locked admission reconciliation and full CI.
- Tracking: #328. Never infer acceptance from engineering CI or from this QA document.

## 8. lunch-box:green — PASS

- Canonical: `mobile/assets/products/lunch/green.png`
- Source: `SRC-LUNCH-GREEN-001` / `WhatsApp Image 2026-02-24 at 11.22.34 PM.jpeg`
- Source state: APPROVED
- Lifecycle: ADMITTED
- SHA-256: `477925e0694a987a4e82fd104eb98a78a50877ac7f78ea902252fbcca4ee6127`
- Bytes: 752,436
- Canvas: 1024×1024
- Alpha bounding box: `[68,51,954,972]`
- Nearest transparent safe margin: 51 px
- Color profile expectation: sRGB
- White/Ivory/Navy: PASS / PASS / PASS
- Downscale 96/160/240/384: PASS / PASS / PASS / PASS
- Geometry preserved: PASS
- Baked UI excluded: PASS
- File-size/decode note: below the 1.2 MiB hard ceiling; canonical framing is normalized without replacing the real source camera/product geometry.
- Visual note: preserves the real four-compartment SUS304 Green set and approved product identity.

## 9. Color, sibling and composition notes

- Product color truth remains governed by Product Master and approved sources. Blue/Pink/Green Pantone targets do not authorize flat recoloring or material reconstruction.
- White/Gray and Blue/Pink/Green sibling variants share the same 1024 canonical canvas contract where admitted.
- PAV blocks duplicate canonical binaries and sibling canvas mismatch; visible-area scale drift is surfaced for review.
- Reusable product files use `BoxFit.contain` on normal product surfaces. A screen may not solve parity by destructively cropping the canonical product image.
- Any screen-specific editorial composite or secondary gallery photo requires its own approved source and QA; it does not inherit PASS merely because the primary canonical variant passes.

## 10. Reference-composition / owner-visible boundary

ASSET-010 checks that the reusable files are fit for owner-visible integration; final Android/iOS/desktop **screen composition** acceptance remains separate because it evaluates layout, hierarchy, copy, breakpoint behavior and the combined screen rather than only the underlying product file.

Therefore:
- admitted file PASS does not set any #220 screen group to PASS;
- this document does not set `VISUAL_RELEASE_OWNER_ACCEPTANCE.json` to ACCEPTED;
- this document does not authorize stable publication;
- Gray/Pink blockers must not be hidden by a fallback, recolor, placeholder or screen crop;
- main stable publication is expected to remain blocked until the independent release gate is genuinely satisfied.

## 11. Release evidence rule

After any change to an owner-visible production image:
1. update source admission/provenance with exact fingerprints only after legitimate acceptance;
2. run PAV and the owner-visible media audit;
3. run Flutter Analyze and the full test suite;
4. build an installable release APK;
5. retain stable-publication enforcement evidence;
6. never publish stable if PAV/owner gate reports BLOCKED.

`mobile/test/creative_asset_qa_contract_test.dart` binds this receipt to the current provenance lifecycle, canonical paths, admitted fingerprints and mandatory QA states so a future asset/admission change cannot silently leave this document stale.

This completes the ASSET-010 **QA receipt and eligibility policy**. It deliberately leaves Gray and Pink BLOCKED and leaves final screen/stable release acceptance to #220/#230.
