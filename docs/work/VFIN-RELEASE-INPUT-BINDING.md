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
   - Locked file SHA-256: `641fa19dd51b89f3a214d70606af9b8358db58ef2e0b46e341d9805038c3774d`.
   - CI uses `flutter pub get --enforce-lockfile` and fails on lock mutation or removal.
   - Flutter 3.47 analyzer migration is committed explicitly so package resolution no longer leaves hidden platform-directory edits.

3. **Bind owner acceptance to deterministic release inputs**
   - Final owner acceptance remains `PENDING`; no decision is synthesized here.
   - In addition to the existing visual-input digest, the release gate now computes a release-input digest covering app code/media, `pubspec.yaml`, `pubspec.lock`, Android branding, pinned toolchain contract and the release workflow.
   - A later change in that scope invalidates previously accepted release inputs until a newly validated APK is reviewed.

4. **Add fail-closed release-input regressions**
   - Missing dependency lock fails closed.
   - Toolchain/release-scope shrinkage fails closed.
   - Visual drift and release-input drift are independently detected.
   - Accepted receipts require exact reviewed source/APK evidence plus workflow-run and artifact IDs.

5. **Publish APK evidence as one governed release package**
   - Engineering APK artifacts now include the production-readiness report, visual-release report, owner-acceptance receipt, toolchain contract and dependency lock.
   - `VERIFIED_BUILD.md` records pinned toolchain, lock SHA, APK SHA and both deterministic input digests.
   - A future stable `Last verified APK` publication copies the same evidence bundle and remains blocked unless the production + owner visual release enforcement is fully READY.

## Bootstrap evidence

Release Input · Reproducibility Contract run `31947136594` generated the dependency lock under Flutter 3.47.0 and confirmed:
- framework revision `4cf24164269a5ebf0c16a028a00727d0e77bbb05`;
- Dart `3.13.0`;
- Temurin Java `17.0.20+8`;
- lock SHA-256 `641fa19dd51b89f3a214d70606af9b8358db58ef2e0b46e341d9805038c3774d`.

Permanent Release Input run `31947476933` passed pinned toolchain, tracked lock and release-scope enforcement. Artifact `9263704162` recorded the lock/toolchain/analyzer evidence.

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
