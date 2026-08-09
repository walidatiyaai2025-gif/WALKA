# WALKA Stable Delivery Policy

## Owner-facing rule

The WALKA owner reviews and installs only what is on `main`. Newer code on another branch is development work and is not considered a stable delivery.

The stable Android install file is always expected at:

`Last verified APK/WALKA-latest.apk`

Its matching provenance is recorded at:

`Last verified APK/VERIFIED_BUILD.md`

## Delivery flow

1. **Issue/task** — define one small implementation slice and acceptance criteria.
2. **Task branch** — implement on an isolated `agent/...` branch.
3. **PR validation** — Flutter Analyze, full tests, Android generation, and an installable release APK must succeed for mobile-impacting work.
4. **Stable merge** — only validated work is merged into `main`.
5. **Independent main rebuild** — `main` runs the Flutter validation/build workflow again from the merged source.
6. **Stable APK publication** — only after that `main` run succeeds, CI replaces `Last verified APK/WALKA-latest.apk` and writes a fresh `VERIFIED_BUILD.md` receipt.
7. **Owner test** — the owner installs the APK from the root stable folder and does not need to inspect task branches or CI archive ZIPs.

## Failure behavior

- If Analyze, tests, Android generation, or APK build fail, the stable APK is not replaced.
- If `main` advances while an older run is still executing, that stale run is not allowed to publish its APK.
- The final Git push is fast-forward only, so a race cannot overwrite newer `main` history.
- Commits that only refresh `Last verified APK/**` are ignored by the Flutter push trigger to prevent an infinite workflow loop.

## APK storage behavior

Normal GitHub repositories reject individual files at or above GitHub's hard single-file threshold. The previous WALKA debug APK from stable API-002 was approximately 149 MB, so it is not suitable for direct normal Git storage.

The stable delivery workflow therefore builds an optimized **release-mode installable APK** after all tests pass:

- preferred: universal release APK;
- fallback: ARM64 release APK when the universal APK is larger than the repository-safe threshold used by CI;
- the chosen APK type is always written into `VERIFIED_BUILD.md`.

This is an owner/testing delivery. Production Play Store signing is a separate release concern and must not be inferred from this receipt.

## No-ZIP communication rule

ZIP archives may exist internally because GitHub Actions packages downloadable artifacts that way. They are not the owner-facing WALKA deliverable.

Developers/agents must not attach, send, or offer ZIP files in ChatGPT/project chat. For Android testing, direct the owner to `main` → `Last verified APK/WALKA-latest.apk` and its receipt.

## Stable-main definition

`main` can contain two kinds of commits:

1. validated implementation/documentation commits merged through the normal team workflow;
2. automated APK publication commits generated only after the corresponding `main` validation run succeeds.

An APK publication commit changes only `Last verified APK/WALKA-latest.apk` and `Last verified APK/VERIFIED_BUILD.md`; it does not introduce unvalidated application source changes.
