# WALKA Engineering Operating Rules

These instructions apply to the entire repository and to every developer/agent working on WALKA.

## 1. Stable-main rule

- `main` is the only branch the owner uses for stable review/testing.
- Do not develop experimental, partial, or unvalidated implementation directly on `main`.
- Every implementation task must use a dedicated task branch, normally `agent/<task-id>-<short-name>`.
- A task reaches `main` only after its relevant CI gates are green and the change is considered stable.
- If a task branch fails CI, keep fixing that branch; do not move the failure to `main`.
- Keep changes small enough to review, validate, and release independently.

## 2. Pull-request and team coordination

- Create/track a GitHub Issue for meaningful implementation slices.
- Keep the issue/PR scope explicit and record important validation receipts.
- Before editing shared roadmap/status/workflow files, check current open team PRs and minimize unnecessary merge conflicts.
- Preserve completed architecture unless the active task explicitly requires a compatible extension or verified defect fix.
- Never discard another team member's valid work just to simplify a merge.

## 3. Mandatory Flutter merge gate

A mobile-affecting slice is not stable until the relevant workflow has completed successfully, including:

1. dependency resolution,
2. `flutter analyze`,
3. full Flutter tests,
4. Android runner generation,
5. installable Android release APK build,
6. APK artifact/receipt generation.

`main` is the stable source of truth even if another branch has newer code.

## 4. Last verified APK contract

- Root folder: `Last verified APK/`.
- Stable install target: `Last verified APK/WALKA-latest.apk`.
- Build receipt: `Last verified APK/VERIFIED_BUILD.md`.
- The APK in this folder must come only from a successful validation run of the current stable `main` source.
- Feature/PR branch builds may upload CI artifacts for engineering validation, but they must never replace the root stable APK.
- A failed or stale `main` build must leave the previously verified APK untouched.
- The publishing workflow must record app version, source commit, workflow run, APK type, byte size, SHA-256, and build timestamp.
- If a universal APK is too large for normal GitHub repository storage, CI may publish the smaller ARM64 release APK and must record that fact in the receipt.

## 5. User-delivery rule: no ZIP files in chat

- **Do not attach, upload, send, or offer ZIP files through ChatGPT/project chat.**
- CI may internally create/use archive containers when GitHub Actions requires them, but the user-facing Android deliverable is the APK itself in `main` under `Last verified APK/`.
- Do not tell the owner to download a GitHub Actions ZIP in order to test WALKA when the stable repository APK is available.
- When reporting a successful Android build, point to the stable APK path and its verification receipt.

## 6. WALKA product/design guardrails

- `Images/` is the protected master visual-reference folder and is not modified by implementation tasks unless the owner explicitly requests an asset change.
- `docs/PRODUCT_MASTER.md` is authoritative for product facts, approved usage/care language, ASINs, and other verified product data.
- Purchases continue to complete on Amazon unless a future approved scope explicitly changes that architecture.
- Do not silently introduce in-app cart, checkout, payment, or duplicated Amazon marketplace responsibilities.

## 7. Definition of done

A task is complete only when implementation, tests, CI evidence, documentation/status impact, and stable delivery requirements for that task are all satisfied. "Code written" by itself is not completion.
