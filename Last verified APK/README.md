# Last verified WALKA APK

This folder is the owner-facing Android test location on stable `main`.

After OPS-001 is merged and the first stable-main Flutter workflow succeeds, CI publishes:

- `WALKA-latest.apk` — latest installable APK produced by a successful validation/build of stable `main`.
- `VERIFIED_BUILD.md` — version, source commit, workflow run, APK type, size, SHA-256, and build timestamp for that APK.

## Important

- Do not manually replace `WALKA-latest.apk` with a branch/local build.
- Branch/PR APKs are engineering candidates only.
- If a new `main` build fails, the last successful APK must remain unchanged.
- The workflow publishes a new APK only after Analyze, tests, and release APK build all succeed.
- No ZIP file is required for owner testing; install the APK directly from this folder.
