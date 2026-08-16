# VFIN — Reproducible Release Input Binding

Parent visual-release blocker: #230  
Related final-release batch: #275  
Dependency owner-gate merge: PR #383 / main `3f31af07792266f38a244278507177084287aa77`

## Five completed implementation tasks

1. **Pin the release toolchain**
   - Release Flutter is pinned to stable `3.47.0`, framework revision `4cf24164269a5ebf0c16a028a00727d0e77bbb05`, Dart `3.13.0` and Temurin Java `17`.
   - `docs/ui/RELEASE_TOOLCHAIN_CONTRACT.json` records the executable Android bootstrap, branding script and release-build recipe.

2. **Commit and enforce the dependency lock**
   - `mobile/pubspec.lock` is committed from the pinned Flutter resolver.
   - Authoritative tracked lock SHA-256: `641fa19dd51b89f3a214d70606af9b8358db58ef2e0b46e341d9805038c3774d`.
   - CI uses `flutter pub get --enforce-lockfile` and fails on lock removal or unresolved lock drift.
   - Flutter 3.47 analyzer migration is committed explicitly so package resolution no longer leaves hidden analyzer edits.
   - Full APK CI discovered that `flutter create --platforms=android` can rewrite transitive lock entries while bootstrapping the Android runner. The release workflow therefore restores the tracked lock when bootstrap changes it, reruns `flutter pub get --enforce-lockfile`, requires the exact authoritative lock SHA again, and fails if `pubspec.yaml`, `pubspec.lock` or `analysis_options.yaml` remains dirty before branding/build.

3. **Bind owner acceptance to deterministic release inputs**
   - Final owner acceptance remains `PENDING`; no decision is synthesized here.
   - In addition to the existing visual-input digest, the release gate computes a release-input digest covering app code/media, `pubspec.yaml`, `pubspec.lock`, Android branding, pinned toolchain contract and the release workflow.
   - A later change in that scope invalidates previously accepted release inputs until a newly validated APK is reviewed.
   - PR APK receipts distinguish the implementation/source head from GitHub's synthetic PR validation merge commit, preventing merge-test SHA from being mistaken for the owner-reviewed implementation revision.

4. **Add fail-closed release-input regressions**
   - Missing dependency lock fails closed.
   - Toolchain/release-scope shrinkage fails closed.
   - Visual drift and release-input drift are independently detected.
   - Android bootstrap dependency reconciliation is ordered before branding and release build.
   - Accepted receipts require exact reviewed source/APK evidence plus workflow-run and artifact IDs.

5. **Publish APK evidence as one governed release package**
   - Engineering APK artifacts include the production-readiness report, visual-release report, owner-acceptance receipt, toolchain contract and the reconciled tracked dependency lock.
   - `VERIFIED_BUILD.md` records implementation/source SHA, validation SHA, pinned toolchain, authoritative lock SHA, APK SHA and both deterministic input digests.
   - A future stable `Last verified APK` publication copies the same evidence bundle and remains blocked unless the production + owner visual release enforcement is fully READY.

## Bootstrap and validation evidence

Release Input · Reproducibility Contract bootstrap run `31947136594` generated the dependency lock under Flutter 3.47.0 and confirmed:
- framework revision `4cf24164269a5ebf0c16a028a00727d0e77bbb05`;
- Dart `3.13.0`;
- Temurin Java `17.0.20+8`;
- tracked lock SHA-256 `641fa19dd51b89f3a214d70606af9b8358db58ef2e0b46e341d9805038c3774d`.

Permanent Release Input run `31947476933` passed pinned toolchain, tracked lock and release-scope enforcement. Artifact `9263704162` recorded lock/toolchain/analyzer evidence.

During PR #385 full APK validation, an intermediate artifact proved the Android bootstrap had rewritten the validated lock after the initial lock gate. That evidence was treated as a release-contract defect rather than accepted. The workflow was hardened to reconcile back to the tracked lock before any production APK build; only a later exact-head Green APK receipt may be used as final evidence for this PR.

## Production truth preserved

- Drawer White: `ADMITTED`
- Drawer Gray: `BLOCKED` — owner source/presentation decision still required.
- Lunch Blue: `ADMITTED`
- Lunch Pink: `PENDING` — explicit owner visual acceptance still required.
- Lunch Green: `ADMITTED`
- Readiness: **3/5**
- Final screen owner acceptance: `PENDING`
- Stable owner-visible publication: **BLOCKED**

No product binary, protected `Images/` master, Product Master fact, ASIN/Pantone mapping or Amazon destination is modified by this hardening slice. APK SHA is retained as the exact reviewed-artifact receipt; independent Android builds are not assumed to be byte-identical.
