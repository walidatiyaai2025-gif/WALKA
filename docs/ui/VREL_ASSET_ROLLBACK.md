# WALKA Production Asset Rollback Procedure

Task: **VREL-097**  
Parent batch: #244  
Parent visual-release blocker: #230

This procedure applies when a previously admitted production product asset later shows a visual, product-truth, mapping, alpha-edge, performance, or accessibility regression.

## Trigger conditions

Rollback is required when any admitted canonical product asset produces one or more of the following:

- wrong variant identity or color,
- fabricated/reconstructed geometry,
- clipped handles, clips, dividers, utensils or tray details,
- white matte, dark fringe, halo or damaged transparency,
- baked price/rating/review/marketplace UI/unsupported claims,
- wrong resolver mapping,
- unacceptable decode/bundle regression,
- owner-visible crop/framing regression,
- accessibility regression that hides product identity or actions.

## Immediate response

1. Mark the affected visual acceptance item **REOPEN**; a previous PASS is no longer authoritative.
2. Stop any new stable owner-visible publication that would contain the regressed asset.
3. Preserve the previous `Last verified APK/WALKA-latest.apk` and receipt; do not overwrite known-good owner delivery with a regressed build.
4. Identify the exact asset commit, variant ID, canonical path, APK candidate SHA-256, workflow run and readiness-report digest.
5. Revert or replace only the affected canonical asset and related admission metadata. Do not modify protected `Images/` references as part of rollback.
6. If rollback removes a canonical asset, allow the engineering fallback to remain available for development while the stable production-asset enforcement gate blocks new owner-visible publication.
7. Re-run production asset validation, protected-reference guard, Analyze, full Flutter tests and Android release APK build.
8. Re-run the affected Home/Discovery/PDP/Favorites/About visual acceptance checks with the real canonical asset.
9. Move acceptance from **REOPEN** to **PASS** only after the regression is actually resolved; otherwise move it to **BLOCKED** with the exact unblock action.

## Safety boundaries

- Product Master remains authoritative during rollback.
- Never fix a Gray-source gap by recoloring/reconstructing White photography.
- Never restore a broken Lunch mask by deleting real stainless/accessory detail.
- Never treat painted fallback as proof that final photography passes visual acceptance.
- Never publish a new stable APK solely to make the receipt look current while production-media acceptance is blocked.

## Recovery completion

Rollback recovery is complete only when the exact corrected source commit, CI run, APK candidate identity, production-asset readiness digest and visual acceptance state are recorded together. The previous verified APK remains the owner-safe rollback target until the corrected release is fully accepted.
