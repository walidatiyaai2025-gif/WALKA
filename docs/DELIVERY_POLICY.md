# WALKA Stable Delivery Policy

## Owner-facing source of truth

`main` is the only stable owner-facing branch. Task branches are implementation candidates until their required CI gates pass and they are intentionally merged.

## Development lifecycle

1. Start each meaningful slice from current `main` on a dedicated task branch.
2. Implement and test only on that branch.
3. Open/update the matching Issue and Pull Request.
4. Require the relevant CI gates to pass on the final PR head.
5. Merge only stable work to `main`.
6. Let the `main` Flutter workflow rebuild the app from the exact stable source.
7. Publish the successful stable build to `Last verified APK/`.

## Android delivery contract

The root owner-facing Android files are:

- `Last verified APK/WALKA-latest.apk`
- `Last verified APK/VERIFIED_BUILD.md`

The receipt records app version, source commit, workflow run, APK type, file size, SHA-256 and build timestamp.

Feature/PR builds may create GitHub Actions artifacts for engineering validation, but they must never overwrite the root stable APK.

## Failure safety

- Analyze, tests and release build must succeed before a candidate can be published.
- A failed `main` build leaves the previous verified APK untouched.
- A workflow run must re-check that `main` still points to its validated source commit before publishing.
- If `main` advanced during a run, that stale run skips publication.
- The final Git push remains fast-forward-only, so a concurrent `main` update cannot be overwritten.
- APK publication commits contain only generated stable-delivery files and are excluded from the Flutter push trigger to prevent recursion.

## Repository size safety

GitHub normal repository storage rejects files at or above its single-file hard limit. WALKA therefore stages a release-mode universal APK first and uses a smaller ARM64 release APK when the universal candidate exceeds the configured 95 MiB safety threshold. The selected APK type is written into the receipt.

## Chat delivery rule

Do not send or offer ZIP files through ChatGPT/project chat for WALKA Android testing. The user-facing deliverable is the stable APK in `main` under `Last verified APK/`.
